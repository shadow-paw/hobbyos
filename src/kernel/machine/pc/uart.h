#ifndef KERNEL_MACHINE_PC_UART_H_
#define KERNEL_MACHINE_PC_UART_H_

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

bool uart_putc(char c);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // KERNEL_MACHINE_PC_UART_H_
