.equ KERNEL_BASE,  (0xFFFFFFFFC0000000)
.equ KERNEL_PMA,   (0x00100000)
.equ KERNEL_VMA,   (KERNEL_BASE + KERNEL_PMA)

.equ SEG_CODE64_0, (0x08)
.equ SEG_DATA64_0, (0x10)
.equ SEG_CODE64_3, (0x18)
.equ SEG_DATA64_3, (0x20)
.equ SEG_CODE32_0, (0x28)
.equ SEG_DATA32_0, (0x30)
.equ SEG_CODE32_3, (0x38)
.equ SEG_DATA32_3, (0x40)
.equ SEG_TSS,      (0x48)

.equ IRQ_BASE_INTNUM, (0x20)

.macro call_idt_set vector, handler, flags
    mov     rdi, \vector
    mov     rsi, offset \handler
    mov     rdx, \flags
    call    idt_set
.endm
