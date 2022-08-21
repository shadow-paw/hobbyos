#include <stdbool.h>
#include <stdint.h>
#include "multiboot.h"
#include "mmu.h"
#include "hal.h"
#include "kmalloc.h"
#include "kdebug.h"

void kmain(const struct MULTIBOOT_BOOTINFO* bootinfo) {
    mmu_init(bootinfo);
    hal_init();
    char *p1 = (char*)kmalloc(16);
    p1[0] = 'a';
    p1[1] = 0;
    kdebug("p1: %p - %s\n", p1, p1);

    char *p2 = (char*)kmalloc(16);
    p2[0] = 'b';
    p2[1] = 0;
    kdebug("p2: %p - %s\n", p2, p2);

    kfree(p1);
    kfree(p2);

    char *p3 = (char*)kmalloc(16);
    p3[0] = 'c';
    p3[1] = 0;
    kdebug("p3: %p - %s\n", p3, p3);
    kfree(p3);

    kdebug("hello world\n");
    for (;;) {
        __asm volatile("hlt");
    }
}
