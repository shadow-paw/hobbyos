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
    call_idt_set    0x00, _CPUEX_00, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x01, _CPUEX_01, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x02, _CPUEX_02, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x03, _CPUEX_03, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x04, _CPUEX_04, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x05, _CPUEX_05, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x06, _CPUEX_06, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x07, _CPUEX_07, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x08, _CPUEX_08, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x0A, _CPUEX_0A, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x0B, _CPUEX_0B, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x0C, _CPUEX_0C, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x0D, _CPUEX_0D, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x0E, _CPUEX_0E, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x10, _CPUEX_10, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x11, _CPUEX_11, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x12, _CPUEX_12, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    0x13, _CPUEX_13, 0b1000111000000000  // P DPL=0 TYPE=1110
    ret

// ----------------------------------------------
// CPU Exception Handlers
// ----------------------------------------------
.align 16
_CPUEX_00:
    pusha
    call    CPUEX_00
    popa
    iretd

.align 16
_CPUEX_01:
    pusha
    call    CPUEX_01
    popa
    iretd

.align 16
_CPUEX_02:
    pusha
    call    CPUEX_02
    popa
    iretd

.align 16
_CPUEX_03:
    pusha
    call    CPUEX_03
    popa
    iretd

.align 16
_CPUEX_04:
    pusha
    call    CPUEX_04
    popa
    iretd

.align 16
_CPUEX_05:
    pusha
    call    CPUEX_05
    popa
    iretd

.align 16
_CPUEX_06:
    pusha
    call    CPUEX_06
    popa
    iretd

.align 16
_CPUEX_07:
    pusha
    call    CPUEX_07
    popa
    iretd

.align 16
_CPUEX_08:
    pusha
    call    CPUEX_08
    popa
    iretd

.align 16
_CPUEX_0A:
    pusha
    push    dword ptr [esp+32]
    call    CPUEX_0A
    add     esp, 4
    popa
    add     esp, 4
    iretd

.align 16
_CPUEX_0B:
    pusha
    push    dword ptr [esp+32]
    call    CPUEX_0B
    add     esp, 4
    popa
    add     esp, 4
    iretd

.align 16
_CPUEX_0C:
    pusha
    push    dword ptr [esp+32]
    call    CPUEX_0C
    add     esp, 4
    popa
    add     esp, 4
    iretd

.align 16
_CPUEX_0D:
    pusha
    push    dword ptr [esp+32]
    push    dword ptr [esp+40]
    call    CPUEX_0D
    add     esp, 8
    popa
    add     esp, 4
    iretd

.align 16
_CPUEX_0E:
    pusha
    mov     eax, cr2
    push    dword ptr [esp+36]
    push    eax
    push    dword ptr [esp+40]
    call    CPUEX_0E
    add     esp, 12
    popa
    add     esp, 4
    iretd

.align 16
_CPUEX_10:
    pusha
    call    CPUEX_10
    popa
    iretd

.align 16
_CPUEX_11:
    pusha
    push    dword ptr [esp+32]
    call    CPUEX_11
    add     esp, 4
    popa
    add     esp, 4
    iretd

.align 16
_CPUEX_12:
    pusha
    call    CPUEX_12
    popa
    iretd

.align 16
_CPUEX_13:
    pusha
    call    CPUEX_13
    popa
    iretd
