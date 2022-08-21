#ifndef KERNEL_MACHINE_PC_MMU_H_
#define KERNEL_MACHINE_PC_MMU_H_

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include "multiboot.h"

// CPU DEFINED
#define MMU_PROT_PRESENT     (0x0001)
#define MMU_PROT_RO          (0x0000)
#define MMU_PROT_RW          (0x0002)
#define MMU_PROT_USER        (0x0004)
#define MMU_PROT_MASK        (MMU_PROT_RO|MMU_PROT_RW|MMU_PROT_USER)

#define MMU_MAP_NOALLOC      (1)
#define MMU_MUNMAP_RELEASE   (0)
#define MMU_MUNMAP_NORELEASE (1)

#if defined(__i386__)
  typedef uint32_t phys_addr_t;
#elif defined(__x86_64__)
  typedef uint64_t phys_addr_t;
#else
  #error Unsupported architecture.
#endif

#ifdef __cplusplus
extern "C" {
#endif

bool mmu_init(const struct MULTIBOOT_BOOTINFO* multiboot);
bool mmu_mmap(const void* mem, phys_addr_t paddr, size_t size, unsigned int flag);
bool mmu_munmap(const void* mem, size_t size, unsigned int flag);

#ifdef __cplusplus
};
#endif

#endif  // KERNEL_MACHINE_PC_MMU_H_
