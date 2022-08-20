// 8259A Programmable Interrupt Controller
.intel_syntax noprefix
.include "kernel.inc"

.global pic_init
.extern idt_set

.equ PIC_MASTER_CMD,  (0x20)
.equ PIC_MASTER_DATA, (0x21)
.equ PIC_SLAVE_CMD,   (0xA0)
.equ PIC_SLAVE_DATA,  (0xA1)

.section .text
// void pic_init();
pic_init:
    call_idt_set    IRQ_BASE_INTNUM + 0x00, _IRQ_00, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x01, _IRQ_01, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x02, _IRQ_02, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x03, _IRQ_03, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x04, _IRQ_04, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x05, _IRQ_05, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x06, _IRQ_06, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x07, _IRQ_07, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x08, _IRQ_08, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x09, _IRQ_09, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x0A, _IRQ_0A, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x0B, _IRQ_0B, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x0C, _IRQ_0C, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x0D, _IRQ_0D, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x0E, _IRQ_0E, 0b1000111000000000  // P DPL=0 TYPE=1110
    call_idt_set    IRQ_BASE_INTNUM + 0x0F, _IRQ_0F, 0b1000111000000000  // P DPL=0 TYPE=1110
    // PIC map IRQ0-IRQF to ISR20-T2F
    mov     al, 0x11
    out     PIC_MASTER_CMD, al
    out     PIC_SLAVE_CMD, al
    mov     al, IRQ_BASE_INTNUM
    out     PIC_MASTER_DATA, al
    mov     al, IRQ_BASE_INTNUM+8
    out     PIC_SLAVE_DATA, al
    mov     al, 0x04
    out     PIC_MASTER_DATA, al
    mov     al, 0x02
    out     PIC_SLAVE_DATA, al
    mov     al, 1
    out     PIC_MASTER_DATA, al
    out     PIC_SLAVE_DATA, al
    xor     al, al
    out     PIC_MASTER_DATA, al
    out     PIC_SLAVE_DATA, al
    // Setup PIT timer
    mov     al, 0x36
    out     0x43, al
    // 1193180/1000Hz = 0x04A9
    mov     al, 0xA9
    out     0x40, al
    mov     al, 0x04
    out     0x40, al
    ret

// ----------------------------------------------
// IRQ Handlers
// ----------------------------------------------
.align 16
_IRQ_00:      // PIT
    push    eax
    mov     al, 0x20
    out     0x20, al
    pop     eax
    iretd

.align 16
_IRQ_01:
_IRQ_02:
_IRQ_03:
_IRQ_04:
_IRQ_05:
_IRQ_06:
_IRQ_07:
    push    eax
    mov     al, 0x20
    out     0x20, al
    pop     eax
    iretd

.align 16
_IRQ_08:
_IRQ_09:
_IRQ_0A:
_IRQ_0B:
_IRQ_0C:
_IRQ_0D:
_IRQ_0E:
_IRQ_0F:
    push    eax
    mov     al, 0x20
    out     0xA0, al  // ack slave PIC
    out     0x20, al  // ack master PIC
    pop     eax
    iretd
