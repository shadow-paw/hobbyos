#include "hal.h"

// pic.asm
void pic_init();

bool hal_init() {
    pic_init();
    // enable interrupts
    __asm volatile("sti");
    return true;
}
