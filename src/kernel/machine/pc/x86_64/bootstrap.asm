.intel_syntax noprefix
.include "kernel.inc"
.include "tss.inc"

.global _start, tss
.extern kmain, _kernel_end, idtr, _syscall_handler

// interrupt stack
.equ IST_SIZE, 4096

.section .bss
.align 4096
ist:        .fill 7 * IST_SIZE, 1, 0
kstack:     .fill 8192, 1, 0
kstack_end:
mmu_pml4t:  .fill 4096, 1, 0
mmu_pdpt:   .fill 4096, 1, 0
mmu_pdt:    .fill 4096, 1, 0
mmu_pt:     .fill 4096, 1, 0
tss:        .fill 104, 1, 0

.section .rodata
.align 16
gdtr32:
    .short 11 * 8 -1
    .int offset gdt - KERNEL_BASE
.align 16
gdtr:
    .short 11 * 8 -1
    .quad offset gdt
.align 16
gdt:
    .int 0, 0
    .int 0x0000FFFF, 0x00AF9A00  // 0x08 CODE64 DPL0
    .int 0x0000FFFF, 0x008F9200  // 0x10 DATA64 DPL0
    .int 0x0000FFFF, 0x00AFFA00  // 0x18 CODE64 DPL3
    .int 0x0000FFFF, 0x008FF200  // 0x20 DATA64 DPL3
    .int 0x0000FFFF, 0x00CF9A00  // 0x28 CODE32 DPL0
    .int 0x0000FFFF, 0x00CF9200  // 0x30 DATA32 DPL0
    .int 0x0000FFFF, 0x00CFFA00  // 0x38 CODE32 DPL3
    .int 0x0000FFFF, 0x00CFF200  // 0x40 DATA32 DPL3
    .int 0, 0, 0, 0              // TSS

.section .text
.code32
.align 16
_start:
    // Upon boot, ebx is point to multiboot information.
    // We will avoid using ebx in the bootstrap and it should be
    // preserved when calling ctor/dtor (cdecl convention).
    // The multiboot information should be passed to kmain.

    // Make sure we got long mode
    mov     eax, 0x80000000
    cpuid
    cmp     eax, 0x80000001
    jb .nolongmode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .nolongmode

    // Setup simple page table
    // Virtual 0G + kernel end -> Physical 0G + kernel_end (kernel loaded addr)
    // Virtual High + kernel_end -> Physical 0G + kernel_end (kernel high addr)
    mov     edi, offset mmu_pt - KERNEL_BASE
    mov     ecx, offset _kernel_end - KERNEL_BASE
    mov     eax, 3
.1:
    mov     [edi], eax
    mov     dword ptr [edi +4], 0
    add     edi, 8
    add     eax, 4096
    cmp     eax, ecx
    jb      .1
    // PDT
    mov     esi, offset mmu_pdt - KERNEL_BASE
    mov     dword ptr [esi + ((0>>21) & 511) *8], offset mmu_pt - KERNEL_BASE +3
.if ((KERNEL_BASE>>21) & 511) != 0
    mov     dword ptr [esi + ((KERNEL_BASE>>21) & 511) *8], offset mmu_pt - KERNEL_BASE +3
.endif
    // PDPT
    mov     esi, offset mmu_pdpt - KERNEL_BASE
    mov     dword ptr [esi + ((0>>30) & 511) *8], offset mmu_pdt - KERNEL_BASE +3
.if ((KERNEL_BASE>>30) & 511) != 0
    mov     dword ptr [esi + ((KERNEL_BASE>>30) & 511) *8], offset mmu_pdt - KERNEL_BASE +3
.endif
    // PML4T
    mov     esi, offset mmu_pml4t - KERNEL_BASE
    mov     dword ptr [esi + ((0>>39) & 511) *8], offset mmu_pdpt - KERNEL_BASE +3
.if ((KERNEL_BASE>>39) & 511) != 0
    mov     dword ptr [esi + ((KERNEL_BASE>>39) & 511) *8], offset mmu_pdpt - KERNEL_BASE +3
.endif
    // Disable paging
    mov     eax, cr0
    and     eax, 0x7FFFFFFF
    mov     cr0, eax
    // Enable PAE
    mov     cr3, esi
    mov     eax, cr4
    or      eax, 1<<5
    mov     cr4, eax
    // Enable long mode
    mov     ecx, 0xC0000080
    rdmsr
    or      eax, 1<<8
    wrmsr
    // Enable paging
    mov     eax, cr0
    or      eax, 1<<31
    mov     cr0, eax
    // Load GDT with low address as we still at long compatibility mode
    lgdt    [gdtr32 - KERNEL_BASE] // 101010
    mov     eax, SEG_DATA64_0
    mov     ds, ax
    jmp     SEG_CODE64_0:.reloadcs - KERNEL_BASE
.reloadcs:
.code64
    // reload gdtr with high address
    lgdt    [gdtr]
    mov     eax, SEG_DATA64_0
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     rsi, offset kstack_end
    mov     rcx, offset .higher_half
    push    rax             // new SS
    push    rsi             // new RSP
    push    2               // new FLAGS
    push    SEG_CODE64_0    // new CS
    push    rcx             // new RIP
    iretq
.higher_half:
    // unmap low address
    xor     rax, rax
.if ((KERNEL_BASE>>39) & 511) != 0
    mov     [mmu_pml4t], rax
.endif
.if ((KERNEL_BASE>>30) & 511) != 0
    mov     [mmu_pdpt], rax
.endif
.if ((KERNEL_BASE>>21) & 511) != 0
    mov     [mmu_pdt], rax
.endif
    mov     rsi, cr3
    mov     cr3, rsi
    // IDT
    mov     rdi, offset idtr
    lidt    [rdi]
    // TSS
    mov     rdi, offset gdt
    mov     rsi, offset tss
    mov     rdx, offset ist + IST_SIZE
    mov     [rsi + tss64.ist1], rdx
    add     rdx, IST_SIZE
    mov     [rsi + tss64.ist2], rdx
    add     rdx, IST_SIZE
    mov     [rsi + tss64.ist3], rdx
    add     rdx, IST_SIZE
    mov     [rsi + tss64.ist4], rdx
    add     rdx, IST_SIZE
    mov     [rsi + tss64.ist5], rdx
    add     rdx, IST_SIZE
    mov     [rsi + tss64.ist6], rdx
    add     rdx, IST_SIZE
    mov     [rsi + tss64.ist7], rdx
    mov     edx, esi
    mov     eax, esi
    mov     ebx, esi
    shl     eax, 16
    or      eax, 103                            // eax = Base[15..00] Limit[15..00]
    shr     edx, 16
    and     ebx, 0xFF000000
    and     edx, 0x000000FF
    or      edx, ebx
    or      edx, 0x00008900                     // [G=0][AVL=0][P][DPL=0][TYPE=1001][00]
    shr     rsi, 32
    mov     [rdi + SEG_TSS], eax
    mov     [rdi + SEG_TSS+4], edx
    mov     [rdi + SEG_TSS+8], esi
    mov     dword ptr [rdi + SEG_TSS+12], 0
    mov     eax, SEG_TSS
    ltr     ax
    // syscall
    mov     ecx, 0xC0000080
    rdmsr
    or      eax, 1<<0           // IA32_EFER.SCE Syscall Enabled
    wrmsr
    mov     ecx, 0xC0000081     // IA32_STAR
    xor     eax, eax
    mov     edx, ((SEG_CODE32_3+3) <<16) | SEG_CODE64_0
    wrmsr
    mov     ecx, 0xC0000082     // IA32_LSTAR
    mov     rax, offset _syscall_handler
    mov     rdx, rax
    shr     rdx, 32
    wrmsr
    mov     ecx, 0xC0000084     // IA32_FMASK
    mov     eax, 0x0200         // IF
    xor     edx, edx
    wrmsr
    // Setup minimal C environment
    xor     rbp, rbp
    // constructors
    mov     rsi, offset ctor_start
.ctors_next:
    cmp     rsi, offset ctor_end
    jae     .ctors_done
    mov     rax, [rsi]
    // skip -1 and 0 as doc in https://gcc.gnu.org/onlinedocs/gccint/Initialization.html
    or      rax, rax
    jz      .ctors_skip
    cmp     rax, -1
    je      .ctors_skip
    call    rax
.ctors_skip:
    add     rsi, 8
    jmp     .ctors_next
.ctors_done:
    // invoke kmain
    mov     rcx, rbx
    add     rcx, KERNEL_BASE // multiboot info, convert to VMA
    xor     rbx, rbx
    call    kmain
    // destructors
    mov     rsi, offset dtor_end
.dtors_next:
    sub     rsi, 8
    cmp     rsi, offset dtor_start
    jb      .dtors_done
    mov     rax, [rsi]
    // skip -1 and 0 as doc in https://gcc.gnu.org/onlinedocs/gccint/Initialization.html
    or      rax, rax
    jz      .dtors_next
    cmp     rax, -1
    je      .dtors_next
    call    rax
    jmp     .dtors_next
.dtors_done:
    // should not be here, just halt
    cli
.halt:
    hlt
    jmp .halt

.nolongmode:
    hlt
