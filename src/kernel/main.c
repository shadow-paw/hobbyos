#include <stdbool.h>
#include <stdint.h>
#include "hal.h"
#include "kdebug.h"

void test_timer() {
    kdebug("timer\n");
}
void kmain(void* bootinfo) {
    (void)bootinfo;
    hal_init();
    kdebug("hello world\n");
    for (;;) {
        __asm volatile("hlt");
    }
}
