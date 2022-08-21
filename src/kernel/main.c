#include <stdbool.h>
#include <stdint.h>
#include "multiboot.h"
#include "mmu.h"
#include "hal.h"
#include "kdebug.h"

void kmain(const struct MULTIBOOT_BOOTINFO* bootinfo) {
    mmu_init(bootinfo);
    hal_init();
    kdebug("hello world\n");
    for (;;) {
        __asm volatile("hlt");
    }
}
