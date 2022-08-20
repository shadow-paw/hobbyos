.intel_syntax noprefix
.include "kernel.inc"

.global idtr, idt_set

.section .bss
.align 4096
idt:    .fill 256, 8, 0

.section .rodata
.align 16
idtr:   .short 256 * 8 -1
        .int   offset idt
        .short 0

.section .text
// void idt_set(num, function, access (P:1 DPL:2 0:1 TYPE:4 0:5);
idt_set:
    push    eax
    push    ecx
    push    edx
    mov     eax, [esp+20]
    mov     ecx, [esp+24]
    mov     edx, eax
    and     eax, 0x0000FFFF
    and     edx, 0xFFFF0000
    or      eax, SEG_CODE32_0 << 16
    or      edx, ecx
    mov     ecx, [esp+16]
    mov     [idt +ecx*8], eax
    mov     [idt +ecx*8+4], edx
    pop     edx
    pop     ecx
    pop     eax
    ret
