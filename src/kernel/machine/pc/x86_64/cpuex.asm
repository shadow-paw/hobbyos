.intel_syntax noprefix
.include "kernel.inc"

.global cpuex_init
.extern idt_set
.extern CPUEX_00, CPUEX_01, CPUEX_02, CPUEX_03, CPUEX_04, CPUEX_05, CPUEX_06, CPUEX_07
.extern CPUEX_08, CPUEX_0A, CPUEX_0B, CPUEX_0C, CPUEX_0D, CPUEX_0E, CPUEX_10, CPUEX_11
.extern CPUEX_12, CPUEX_13

.section .text
// void cpuex_init();
cpuex_init:
    call_idt_set    0x00, _CPUEX_00, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x01, _CPUEX_01, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x02, _CPUEX_02, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x03, _CPUEX_03, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x04, _CPUEX_04, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x05, _CPUEX_05, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x06, _CPUEX_06, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x07, _CPUEX_07, 0b1000111000000001  // P DPL=0 TYPE=1110 IST=1
    call_idt_set    0x08, _CPUEX_08, 0b1000111000000001  // P DPL=0 TYPE=1110 IST=1
    call_idt_set    0x0A, _CPUEX_0A, 0b1000111000000001  // P DPL=0 TYPE=1110 IST=1
    call_idt_set    0x0B, _CPUEX_0B, 0b1000111000000001  // P DPL=0 TYPE=1110 IST=1
    call_idt_set    0x0C, _CPUEX_0C, 0b1000111000000001  // P DPL=0 TYPE=1110 IST=1
    call_idt_set    0x0D, _CPUEX_0D, 0b1000111000000001  // P DPL=0 TYPE=1110 IST=1
    call_idt_set    0x0E, _CPUEX_0E, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x10, _CPUEX_10, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x11, _CPUEX_11, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    call_idt_set    0x12, _CPUEX_12, 0b1000111000000010  // P DPL=0 TYPE=1110 IST=2
    call_idt_set    0x13, _CPUEX_13, 0b1000111000000000  // P DPL=0 TYPE=1110 IST=0
    ret

// ----------------------------------------------
// CPU Exception Handlers
// ----------------------------------------------
.align 16
_CPUEX_00:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_00
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_01:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_01
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_02:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_02
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_03:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_03
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_04:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_04
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_05:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_05
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_06:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_06
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_07:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_07
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_08:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_08
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_0A:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    mov     rdi, [rsp + 9*8]
    call    CPUEX_0A
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    add     rsp, 8
    iretq

.align 16
_CPUEX_0B:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    mov     rdi, [rsp + 9*8]
    call    CPUEX_0B
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    add     rsp, 8
    iretq

.align 16
_CPUEX_0C:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    mov     rdi, [rsp + 9*8]
    call    CPUEX_0C
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    add     rsp, 8
    iretq

.align 16
_CPUEX_0D:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    mov     rdi, [rsp + 9*8]
    mov     rsi, [rsp + 10*8]
    call    CPUEX_0D
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    add     rsp, 8
    iretq

.align 16
_CPUEX_0E:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    mov     rdi, [rsp + 9*8]
    mov     rsi, cr2
    mov     rdx, [rsp + 10*8]
    call    CPUEX_0E
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    add     rsp, 8
    iretq

.align 16
_CPUEX_10:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_10
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_11:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    mov     rdi, [rsp + 9*8]
    call    CPUEX_11
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    add     rsp, 8
    iretq


.align 16
_CPUEX_12:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_12
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq

.align 16
_CPUEX_13:
    push    rax
    push    rcx
    push    rdx
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    r10
    push    r11
    call    CPUEX_13
    pop     r11
    pop     r10
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    pop     rdx
    pop     rcx
    pop     rax
    iretq
