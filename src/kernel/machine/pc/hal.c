#include "hal.h"

// cpuex.asm
void cpuex_init();
// pic.asm
void pic_init();

bool hal_init() {
    cpuex_init();
    pic_init();
    // enable interrupts
    __asm volatile("sti");
    return true;
}
