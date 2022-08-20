.intel_syntax noprefix
.include "kernel.inc"

.global idtr, idt_set

.section .bss
.align 4096
idt:    .fill 512, 8, 0  // 256 x 16

.section .rodata
.align 16
idtr:   .short 256 * 16 -1
        .quad  offset idt
        .short 0

.section .text
// void idt_set(num, function, access (P:1 DPL:2 0:1 TYPE:4 0:5);
idt_set:
    mov     r11, offset idt
    mov     eax, esi
    and     eax, 0xFFFF
    or      eax, SEG_CODE64_0 << 16
    shr     rsi, 16
    shl     rsi, 16
    or      rsi, rdx
    shl     rdi, 4
    mov     dword ptr [r11 + rdi], eax
    mov     qword ptr [r11 + rdi +4], rsi
    mov     dword ptr [r11 + rdi +12], 0
    ret
