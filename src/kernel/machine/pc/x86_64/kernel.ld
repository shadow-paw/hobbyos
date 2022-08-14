OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

/* Our kernel will be sit on top -1GB */
KERNEL_BASE = 0xFFFFFFFFC0000000;
KERNEL_PMA = 0x00100000;
KERNEL_VMA = KERNEL_BASE + KERNEL_PMA;

SECTIONS
{
    . = KERNEL_VMA;
    _kernel_start = .;

    .text BLOCK(4K) : AT(KERNEL_PMA) {
        *(.multiboot)
        *bootstrap*(.text)
        *(.text)
		*(.gnu.linkonce.t*)
    }
    .rodata BLOCK(4K) : ALIGN(4K) {
        *(.rodata)
		*(.gnu.linkonce.r*)
        . = ALIGN(16);
		ctor_start = .;
        *(.ctors)
        ctor_end = .;
        dtor_start = .;
        *(.dtors)
        dtor_end = .;
    }
    .data BLOCK(4K) :ALIGN(4K) {
        *(.data)
		*(.gnu.linkonce.d*)
        *(.eh_frame*)
    }
    .bss BLOCK(4K) : ALIGN(4K) {
        sbss = .;
        *(COMMON)
        *(.bss)
        *(.gnu.linkonce.b*)
        ebss = .;
    }
    . = ALIGN(4096);
    _kernel_end = .;

	/DISCARD/ :
    {
        *(.comment)
    }
}
