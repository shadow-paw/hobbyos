#include <stdint.h>

void kdebug(const char* fmt, ...);

void CPUEX_00(void) {
    kdebug("CPUEX00 : #DE Divide Error Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_01(void) {
    kdebug("CPUEX01 : #DB Debug Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_02(void) {
    kdebug("CPUEX02 : NMI CPUEXerrupt. IP\n");
    __asm volatile("cli; hlt");
}
void CPUEX_03(void) {
    kdebug("CPUEX03 : #BP BreakpoCPUEX Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_04(void) {
    kdebug("CPUEX04 : #OF Overflow Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_05(void) {
    kdebug("CPUEX05 : #BR BOUND Range Exceeded Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_06(void) {
    kdebug("CPUEX06 : #UD Invalid Opcode Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_07(void) {
    kdebug("CPUEX07 : #NM Device Not Available Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_08(void) {
    kdebug("CPUEX08 : #DF Double Fault Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_0A(uint64_t code) {
    kdebug("CPUEX0A : #TS Invalid TSS Exception. CODE:%d\n", code);
    __asm volatile("cli; hlt");
}
void CPUEX_0B(uint64_t code) {
    kdebug("CPUEX0B : #NP Segment Not Present. CODE:%d\n", code);
    __asm volatile("cli; hlt");
}
void CPUEX_0C(uint64_t code) {
    kdebug("CPUEX0C : #SS Stack Fault Exception. CODE:%d\n", code);
    __asm volatile("cli; hlt");
}
void CPUEX_0D(uint64_t code, uint64_t ip) {
    kdebug("CPUEX0D : #GP General Protection Exception. IP: %X CODE:%d\n", ip, code);
    __asm volatile("cli; hlt");
}
void CPUEX_10(void) {
    kdebug("CPUEX10 : #MF x87 FPU Floating-PoCPUEX Error.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_11(uint64_t code) {
    kdebug("CPUEX11 : #AC Alignment Check Exception. CODE:%d\n", code);
    __asm volatile("cli; hlt");
}
void CPUEX_12(void) {
    kdebug("CPUEX12 : #MC Machine Check Exception.\n");
    __asm volatile("cli; hlt");
}
void CPUEX_13(void) {
    kdebug("CPUEX13 : #XM SIMD Floating-PoCPUEX Exception.\n");
    __asm volatile("cli; hlt");
}
