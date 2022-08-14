#include "uart.h"
#include "kdebug.h"

void kdebug(const char* text) {
    for (; *text; text++) {
        uart_putc(*text);
    }
}
