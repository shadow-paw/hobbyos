#include "ioport.h"
#include "uart.h"

bool uart_putc(char c) {
    const uint16_t base = 0x03F8;
    while ((inb(base + 5) & 0x20) == 0) {
      // Busy loop
    }
    outb(base, (uint8_t)c);
    return true;
}
