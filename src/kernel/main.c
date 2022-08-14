#include <stdbool.h>
#include <stdint.h>
#include "kdebug.h"

void kmain(void* bootinfo) {
    (void)bootinfo;
    kdebug("hello world");
}
