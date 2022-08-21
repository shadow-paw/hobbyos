#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include "mmu.h"

// Page table custom flags
#define MMU_PAGE_ONDEMAND (0x0100)

// inline assembly
#define _INT_DISABLE() __asm volatile("pushf\ncli")
#define _INT_RESTORE() __asm volatile("popf")
#define _MOVCR3(paddr) __asm volatile("mov cr3, %0" : : "r"(paddr) : "memory")
#define _INVLPG(ptr)   __asm volatile("invlpg [%0]" : : "r"(ptr) : "memory")
inline void _RELOADCR3() {
    phys_addr_t cr3;
    __asm volatile("mov %0, cr3" : "=A" (cr3));
    _MOVCR3(cr3);
}

// MMU recursive mapping & address Conversion Helpers
// PML1T = Level 1 = PT
// PML2T = Level 2 = PDT
// PML3T = Level 3 = PDPT (64-bit only)
// PML4T = Level 4 = PML4T (64-bit only)
#if defined(__i386__)
  #define MMU_PAGETABLE_LEVELS  2
  #define MMU_RECURSIVE_SLOT    1023UL
  // 1024 entries per table: 2<<10
  #define MMU_PAGETABLE_SHIFT   10
  #define MMU_PAGETABLE_ENTRIES (1UL << MMU_PAGETABLE_SHIFT)
  #define MMU_PML1T_VMA         (MMU_RECURSIVE_SLOT << (12 + MMU_PAGETABLE_SHIFT))
  #define MMU_PML2T_VMA         (MMU_PML1T_VMA + (MMU_RECURSIVE_SLOT << 12))
  #define MMU_PML2T_PTR(addr)   ((phys_addr_t*)(MMU_PML2T_VMA))
  #define MMU_PML1T_PTR(addr)   \
    ((phys_addr_t*) ((uintptr_t)MMU_PML1T_VMA + \
     ((((uintptr_t)(addr)) >> MMU_PAGETABLE_SHIFT) & ((MMU_PAGETABLE_ENTRIES-1) << 12))))
    // 0x3FF000
  #define MMU_PML2T_INDEX(addr) ((((uintptr_t)(addr)) >> (12 + MMU_PAGETABLE_SHIFT)) & (MMU_PAGETABLE_ENTRIES-1))
  #define MMU_PML1T_INDEX(addr) ((((uintptr_t)(addr)) >> 12) & (MMU_PAGETABLE_ENTRIES-1))
  // Kernel base from kernel.ld
  #define MMU_KERNEL_BASE   (0xC0000000)
  #define MMU_KERNEL_PMA    (0x00100000)
  // Growing address of frame allocator
  #define MMU_FRAMEPOOL_VMA (0xFF800000)
#elif defined(__x86_64__)
  #define MMU_PAGETABLE_LEVELS  4
  #define MMU_RECURSIVE_SLOT    510UL
  // 512 entries per table: 2<<9
  #define MMU_PAGETABLE_SHIFT   9
  #define MMU_PAGETABLE_ENTRIES (1UL << MMU_PAGETABLE_SHIFT)
  #define MMU_PML1T_VMA         (0xFFFF000000000000UL + (MMU_RECURSIVE_SLOT << (12 + MMU_PAGETABLE_SHIFT *3)))
  #define MMU_PML2T_VMA         (MMU_PML1T_VMA        + (MMU_RECURSIVE_SLOT << (12 + MMU_PAGETABLE_SHIFT *2)))
  #define MMU_PML3T_VMA         (MMU_PML2T_VMA        + (MMU_RECURSIVE_SLOT << (12 + MMU_PAGETABLE_SHIFT)))
  #define MMU_PML4T_VMA         (MMU_PML3T_VMA        + (MMU_RECURSIVE_SLOT << 12))
  #define MMU_PML4T_PTR(addr)   ((phys_addr_t*)MMU_PML4T_VMA)
  #define MMU_PML3T_PTR(addr) \
    ((phys_addr_t*)(MMU_PML3T_VMA + \
    ((((uintptr_t)(addr)) >> (MMU_PAGETABLE_SHIFT*3)) & ((MMU_PAGETABLE_ENTRIES-1) << 12))))
    // 0x7FFFFFF000
  #define MMU_PML2T_PTR(addr) \
    ((phys_addr_t*)(MMU_PML2T_VMA + ((((uintptr_t)(addr)) >> (MMU_PAGETABLE_SHIFT*2)) \
    & ((MMU_PAGETABLE_ENTRIES*MMU_PAGETABLE_ENTRIES-1) << 12))))
    // 0x003FFFF000
  #define MMU_PML1T_PTR(addr) \
    ((phys_addr_t*)(MMU_PML1T_VMA + ((((uintptr_t)(addr)) >> (MMU_PAGETABLE_SHIFT  )) \
    & ((MMU_PAGETABLE_ENTRIES*MMU_PAGETABLE_ENTRIES*MMU_PAGETABLE_ENTRIES-1) << 12))))
    // 0x7FFFFFF000
  #define MMU_PML4T_INDEX(addr) ((((uintptr_t)(addr)) >> (12 + MMU_PAGETABLE_SHIFT*3)) & (MMU_PAGETABLE_ENTRIES-1))
  #define MMU_PML3T_INDEX(addr) ((((uintptr_t)(addr)) >> (12 + MMU_PAGETABLE_SHIFT*2)) & (MMU_PAGETABLE_ENTRIES-1))
  #define MMU_PML2T_INDEX(addr) ((((uintptr_t)(addr)) >> (12 + MMU_PAGETABLE_SHIFT)) & (MMU_PAGETABLE_ENTRIES-1))
  #define MMU_PML1T_INDEX(addr) ((((uintptr_t)(addr)) >> 12) & (MMU_PAGETABLE_ENTRIES-1))
  // Kernel base from kernel.ld
  #define MMU_KERNEL_BASE   (0xFFFFFFFFC0000000)
  #define MMU_KERNEL_PMA    (0x00100000)
  // Growing address of frame allocator
  #define MMU_FRAMEPOOL_VMA (0xFFFFFFFFF0000000)
#else
  #error Unsupported architecture.
#endif

#define MMU_KERNEL_VMA  ((uintptr_t)(MMU_KERNEL_BASE + MMU_KERNEL_PMA))
#define MMU_VMA2PMA(x)  (((uintptr_t)(x)) - MMU_KERNEL_BASE)
#define MMU_PMA2VMA(x)  (((uintptr_t)(x)) + MMU_KERNEL_BASE)

// externs
extern char _kernel_end;
extern phys_addr_t mmu_pml2t[];
#if MMU_PAGETABLE_LEVELS >= 3
extern phys_addr_t mmu_pml3t[];
#endif
#if MMU_PAGETABLE_LEVELS >= 4
extern phys_addr_t mmu_pml4t[];
#endif
void kdebug(const char* fmt, ...);

// Frame Allocator
phys_addr_t MMU_FRAMEPOOL_PML1T[4096 / sizeof(phys_addr_t)] __attribute__((aligned(4096)));
#if MMU_PAGETABLE_LEVELS >= 2
  phys_addr_t MMU_FRAMEPOOL_PML2T[4096 / sizeof(phys_addr_t)] __attribute__((aligned(4096)));
#endif
#if MMU_PAGETABLE_LEVELS >= 3
  phys_addr_t MMU_FRAMEPOOL_PML3T[4096 / sizeof(phys_addr_t)] __attribute__((aligned(4096)));
#endif
phys_addr_t MMU_FRAMEPOOL_FIRSTPAGE[4096 / sizeof(phys_addr_t)] __attribute__((aligned(4096)));
volatile phys_addr_t* MMU_frames = (phys_addr_t*)MMU_FRAMEPOOL_VMA;
volatile unsigned int MMU_frames_next = 0;  // index for next allocation

bool mmu_mark(const void* addr, phys_addr_t paddr, uint32_t flag) {
#if MMU_PAGETABLE_LEVELS >= 4
    phys_addr_t* pml4t = MMU_PML4T_PTR(addr);
    unsigned int pml4t_index = MMU_PML4T_INDEX(addr);
    if ((pml4t[pml4t_index] & (MMU_PROT_PRESENT|MMU_PAGE_ONDEMAND)) == 0) {
        pml4t[pml4t_index] = MMU_PAGE_ONDEMAND|MMU_PROT_RW;
    }
#endif
#if MMU_PAGETABLE_LEVELS >= 3
    phys_addr_t* pml3t = MMU_PML3T_PTR(addr);
    unsigned int pml3t_index = MMU_PML3T_INDEX(addr);
    if ((pml3t[pml3t_index] & (MMU_PROT_PRESENT|MMU_PAGE_ONDEMAND)) == 0) {
        pml3t[pml3t_index] = MMU_PAGE_ONDEMAND|MMU_PROT_RW;
    }
#endif
#if MMU_PAGETABLE_LEVELS >= 2
    phys_addr_t* pml2t = MMU_PML2T_PTR(addr);
    unsigned int pml2t_index = MMU_PML2T_INDEX(addr);
    if ((pml2t[pml2t_index] & (MMU_PROT_PRESENT|MMU_PAGE_ONDEMAND)) == 0) {
        pml2t[pml2t_index] = MMU_PAGE_ONDEMAND|MMU_PROT_RW;
    }
#endif
    phys_addr_t* pml1t = MMU_PML1T_PTR(addr);
    unsigned int pml1t_index = MMU_PML1T_INDEX(addr);
    if ((pml1t[pml1t_index] & MMU_PROT_PRESENT) == 0) {
        if ((flag & MMU_MAP_NOALLOC) == 0) {
            pml1t[pml1t_index] = (phys_addr_t)(MMU_PAGE_ONDEMAND | (flag & MMU_PROT_MASK));
        } else {
            pml1t[pml1t_index] = (phys_addr_t)(paddr | (flag & MMU_PROT_MASK) | MMU_PROT_PRESENT);
            _INVLPG(addr);
        }
    } else {
        if ( (flag & MMU_MAP_NOALLOC) == 0 ) {
            pml1t[pml1t_index] = (pml1t[pml1t_index] & (~(phys_addr_t)MMU_PROT_MASK))
                                 | ((phys_addr_t)flag & MMU_PROT_MASK)
                                 | MMU_PROT_PRESENT;
        } else {
            kdebug("MMU : map fail, addr:%p paddr:%X flag=%d entry:%X\n", addr, paddr, flag, pml1t[pml1t_index]);
            return false;
        }
    }
    return true;
}
bool mmu_init(const struct MULTIBOOT_BOOTINFO* multiboot) {
    const struct MULTIBOOT_BOOTINFO_MMAP* map_next =
        (const struct MULTIBOOT_BOOTINFO_MMAP*)MMU_PMA2VMA(multiboot->mmap_addr);
    const uint32_t map_count = multiboot->mmap_length / sizeof(struct MULTIBOOT_BOOTINFO_MMAP);
    const uint64_t kend = (MMU_VMA2PMA((uintptr_t)&_kernel_end));
    uint64_t start, end;
    unsigned int pt_index = 0;
    // Install recursive page directory
#if MMU_PAGETABLE_LEVELS == 2
    mmu_pml2t[MMU_PML2T_INDEX(MMU_PML2T_VMA)] =
        MMU_VMA2PMA(mmu_pml2t) + (MMU_PROT_PRESENT|MMU_PROT_RW);
#elif MMU_PAGETABLE_LEVELS == 3
    mmu_pml3t[MMU_PML4T_INDEX(MMU_PML3T_VMA)] =
        MMU_VMA2PMA(mmu_pml3t) + (MMU_PROT_PRESENT|MMU_PROT_RW);
#elif MMU_PAGETABLE_LEVELS == 4
    mmu_pml4t[MMU_PML4T_INDEX(MMU_PML4T_VMA)] =
        MMU_VMA2PMA(mmu_pml4t) + (MMU_PROT_PRESENT|MMU_PROT_RW);
#else
    #error Unsupported page table levels.
#endif
    // Map memory MMU_FRAMEPOOL_VMA
#if MMU_PAGETABLE_LEVELS >= 3
    phys_addr_t* frame_pml3t = mmu_pml3t;
#endif
#if MMU_PAGETABLE_LEVELS >= 2
    phys_addr_t* frame_pml2t = mmu_pml2t;
#endif
#if MMU_PAGETABLE_LEVELS >= 4
    if (MMU_PML4T_INDEX(MMU_FRAMEPOOL_VMA) != MMU_PML4T_INDEX(MMU_KERNEL_BASE)) {
        mmu_pml4t[MMU_PML4T_INDEX(MMU_FRAMEPOOL_VMA)] =
            MMU_VMA2PMA(MMU_FRAMEPOOL_PML3T) + (MMU_PROT_PRESENT|MMU_PROT_RW);
        frame_pml3t = MMU_FRAMEPOOL_PML3T;
    }
#endif
#if MMU_PAGETABLE_LEVELS >= 3
    if (MMU_PML3T_INDEX(MMU_FRAMEPOOL_VMA) != MMU_PML3T_INDEX(MMU_KERNEL_BASE)) {
        frame_pml3t[MMU_PML3T_INDEX(MMU_FRAMEPOOL_VMA)] =
            MMU_VMA2PMA(MMU_FRAMEPOOL_PML2T) + (MMU_PROT_PRESENT|MMU_PROT_RW);
        frame_pml2t = MMU_FRAMEPOOL_PML2T;
    }
#endif
#if MMU_PAGETABLE_LEVELS >= 2
    frame_pml2t[MMU_PML2T_INDEX(MMU_FRAMEPOOL_VMA)] =
        MMU_VMA2PMA(MMU_FRAMEPOOL_PML1T) + (MMU_PROT_PRESENT|MMU_PROT_RW);
#endif
    MMU_FRAMEPOOL_PML1T[MMU_PML1T_INDEX(MMU_FRAMEPOOL_VMA)] =
        MMU_VMA2PMA(MMU_FRAMEPOOL_FIRSTPAGE) + (MMU_PROT_PRESENT|MMU_PROT_RW);
    _RELOADCR3();
    // Build stack of available physical page
    MMU_frames_next = 0;
    for (uint32_t i = 0; i < map_count; i++) {
        const struct MULTIBOOT_BOOTINFO_MMAP* map = map_next;
        map_next = (const struct MULTIBOOT_BOOTINFO_MMAP*)((uintptr_t)map + map->size + 4);
        // if (map->type != 1) continue;
        start = ((map->addr + 4095) >>12) <<12;            // align to 4K
        end = ((map->addr + map->len) >>12) <<12;
        if (map->type != 1) continue;
        for (; start < end; start += 4096) {
            // skip memory below kernel, those already mapped into kernel space
            if (start <= kend) continue;
            // upon setting MMU_frames[...] across page size, a page fault occur and demand allocated
            if (pt_index != (MMU_frames_next >> MMU_PAGETABLE_SHIFT)) {
                pt_index = (MMU_frames_next >> MMU_PAGETABLE_SHIFT);
                mmu_mark((const void*)&MMU_frames[MMU_frames_next], 0, MMU_PAGE_ONDEMAND);
                // Trigger #PF and we will pop a page there, which would decrease MMU_frames_index.
                // We want cpu to retry on the read op here, so the actual write op can use correct index.
                volatile phys_addr_t* ptr = &MMU_frames[MMU_frames_next];
                (void)*ptr;
            }
            MMU_frames[MMU_frames_next] = (phys_addr_t)start;
            MMU_frames_next++;
        }
    }
    return true;
}
phys_addr_t mmu_frame_alloc(void) {
    phys_addr_t addr = 0;
    _INT_DISABLE();
    if (MMU_frames_next > 0) {
        MMU_frames_next--;
        addr = MMU_frames[MMU_frames_next];
    }
    _INT_RESTORE();
    return addr;
}
void mmu_frame_free(phys_addr_t addr) {
    _INT_DISABLE();
    MMU_frames[MMU_frames_next] = addr;
    MMU_frames_next++;
    _INT_RESTORE();
}
bool mmu_mmap(const void* mem, phys_addr_t paddr, size_t size, unsigned int flag) {
    for (size_t off = 0; off < size; off += 4096) {
        if (!mmu_mark((const uint8_t*)mem + off, paddr+off, flag)) return false;
    }
    return true;
}
bool mmu_munmap(const void* mem, size_t size, unsigned int flag) {
    for (size_t off = 0; off < size; off += 4096) {
        const void* addr = (const uint8_t*)mem + off;
        phys_addr_t* pml1t = MMU_PML1T_PTR(addr);
        unsigned int entry = pml1t[MMU_PML1T_INDEX(addr)];
        pml1t[MMU_PML1T_INDEX(addr)] = 0;
        if ((entry & MMU_PROT_PRESENT) != 0) {
            if ((entry & MMU_PROT_PRESENT) != 0 && (flag & MMU_MUNMAP_NORELEASE) == 0) {
                entry &= ~((phys_addr_t)0xFFF);
                if (entry) {
                    mmu_frame_free(entry);
                    _INVLPG(addr);
                }
            }
        }
    }
    return true;
}
void CPUEX_0E(phys_addr_t code, phys_addr_t addr, phys_addr_t ip) {
    phys_addr_t page, prot;
    phys_addr_t* pml1t;
    kdebug("CPUEX_0E: #PF Page Fault Exception.\nIP:%p CODE:%d ADDR:%p\n", ip, (uint32_t)code, addr);
    pml1t = MMU_PML1T_PTR(addr);
    if ((code & 1) == 0) {  // Page Not Present
        if ((pml1t[MMU_PML1T_INDEX(addr)] & MMU_PAGE_ONDEMAND) == 0) {
            kdebug("     #PF: Access to unallocated memory.\n");
            __asm volatile("cli; hlt");
        }
        page = mmu_frame_alloc();
        prot = pml1t[MMU_PML1T_INDEX(addr)] & MMU_PROT_MASK;
        pml1t[MMU_PML1T_INDEX(addr)] = page | prot | MMU_PROT_PRESENT;
        _INVLPG((const void*)addr);
        // https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html
        __builtin_memset((void*)((addr >> 12) << 12), 0, 4096);
    } else {
        kdebug("     #PF: Access to protected memory.\n");
        __asm volatile("cli; hlt");
    }
}
