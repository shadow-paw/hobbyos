.equ MULTIBOOT_ALIGN,    (1<<0)                                  // align loaded modules on page boundaries
.equ MULTIBOOT_MEMINFO,  (1<<1)                                  // provide memory map
.equ MULTIBOOT_FLAGS,    (MULTIBOOT_ALIGN | MULTIBOOT_MEMINFO)   // this is the Multiboot 'flag' field
.equ MULTIBOOT_MAGIC,    (0x1BADB002)                            // 'magic number' lets bootloader find the header
.equ MULTIBOOT_CHECKSUM, (-(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS))  // checksum of above, to prove we are multiboot

.section .multiboot
.align 4
    .int MULTIBOOT_MAGIC
    .int MULTIBOOT_FLAGS
    .int MULTIBOOT_CHECKSUM
