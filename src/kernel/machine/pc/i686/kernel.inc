.equ KERNEL_BASE,  (0xC0000000)
.equ KERNEL_PMA,   (0x00100000)
.equ KERNEL_VMA,   (KERNEL_BASE + KERNEL_PMA)

.equ SEG_CODE32_0, (0x08)
.equ SEG_DATA32_0, (0x10)
.equ SEG_CODE32_3, (0x18)
.equ SEG_DATA32_3, (0x20)
.equ SEG_TSS,      (0x28)

.equ IRQ_BASE_INTNUM, (0x20)

.macro call_idt_set vector, handler, flags
    push    \flags
    push    offset \handler
    push    \vector
    call    idt_set
    add     esp, 12
.endm
