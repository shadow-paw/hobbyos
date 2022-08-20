.intel_syntax noprefix
.include "kernel.inc"
.include "tss.inc"

.global _start
.extern kmain, _kernel_end, idtr, _syscall_handler

.section .bss
.align 4096
kstack:     .fill 8192, 1, 0
kstack_end:
mmu_pdt:    .fill 4096, 1, 0
mmu_pt:     .fill 4096, 1, 0
tss:        .fill 104, 1, 0

.section .rodata
.align 16
gdtr:   .short 6 * 8 -1
        .int   offset gdt
        .short 0

.align 16
gdt:
    .int 0, 0
    .int 0x0000FFFF, 0x00CF9A00  // 0x08 CODE32 DPL0
    .int 0x0000FFFF, 0x00CF9200  // 0x10 DATA32 DPL0
    .int 0x0000FFFF, 0x00CFFA00  // 0x18 CODE32 DPL3
    .int 0x0000FFFF, 0x00CFF200  // 0x20 DATA32 DPL3
    .int 0, 0                    // TSS

.section .text
.align 16
_start:
    // Upon boot, ebx is point to multiboot information.
    // We will avoid using ebx in the bootstrap and it should be
    // preserved when calling ctor/dtor (cdecl convention).
    // The multiboot information should be passed to kmain.

    // Setup page tables
    // Virtual 0G + kernel end -> Physical 0G + kernel_end (kernel loaded addr)
    // Virtual 3G + kernel_end -> Physical 0G + kernel_end (kernel high addr)
    // PT: iterate all 4k pages until kernel end
    mov     edi, offset mmu_pt - KERNEL_BASE
    mov     ecx, offset _kernel_end - KERNEL_BASE
    mov     eax, 3
.1:
    stosd
    add     eax, 4096
    cmp     eax, ecx
    jb      .1
    // PDT: both PMA and VMA points to the PTs
    mov     esi, offset mmu_pdt - KERNEL_BASE
    mov     dword ptr [esi + (KERNEL_PMA>>22)*4], offset mmu_pt - KERNEL_BASE +3
    mov     dword ptr [esi + (KERNEL_VMA>>22)*4], offset mmu_pt - KERNEL_BASE +3
    // Enable paging
    mov     cr3, esi
    mov     eax, cr0
    or      eax, 1<<31
    mov     cr0, eax
    // Load GDT & Reload selectors
    lgdt    [gdtr]
    mov     eax, SEG_DATA32_0
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax
    mov     esp, offset kstack_end
    jmp     SEG_CODE32_0:.higher_half
.higher_half:
    // Unmap 1M
    mov     dword ptr [esi + (KERNEL_PMA>>22)*4], 0
    mov     cr3, esi
    // IDT
    lidt    [idtr]
    // TSS
    mov     dword ptr [tss + tss32.ss0], SEG_DATA32_0
    mov     dword ptr [tss + tss32.esp0], esp
    mov     eax, tss
    shl     eax, 16
    or      eax, 0x67                // [Base 15..00][Limit 15..00]
    mov     [gdt + SEG_TSS], eax
    mov     eax, offset tss
    mov     edx, offset tss
    shr     edx, 16
    and     eax, 0xFF000000
    and     edx, 0x000000FF
    or      eax, edx
    or      eax, 0x00008900
    mov     [gdt + SEG_TSS +4], eax
    mov     eax, SEG_TSS
    ltr     ax
    // syscall
    call_idt_set    0x80, _syscall_handler, 0b1110111000000000  // P DPL=3 TYPE=1110
    // Setup minimal C environment
    xor     ebp, ebp
    // constructors
    mov     esi, offset ctor_start
.ctors_next:
    cmp     esi, offset ctor_end
    jae     .ctors_done
    mov     eax, [esi]
    // skip -1 and 0 as doc in https://gcc.gnu.org/onlinedocs/gccint/Initialization.html
    or      eax, eax
    jz      .ctors_skip
    cmp     eax, -1
    je      .ctors_skip
    call    eax
.ctors_skip:
    add     esi, 4
    jmp     .ctors_next
.ctors_done:
    // invoke kmain
    add     ebx, KERNEL_BASE // multiboot info, convert to VMA
    push    ebx
    call    kmain
    // destructors
    mov     esi, offset dtor_end
.dtors_next:
    sub     esi, 4
    cmp     esi, offset dtor_start
    jb      .dtors_done
    mov     eax, [esi]
    // skip -1 and 0 as doc in https://gcc.gnu.org/onlinedocs/gccint/Initialization.html
    or      eax, eax
    jz      .dtors_next
    cmp     eax, -1
    je      .dtors_next
    call    eax
    jmp     .dtors_next
.dtors_done:
    // should not be here, just halt
    cli
.halt:
    hlt
    jmp .halt
