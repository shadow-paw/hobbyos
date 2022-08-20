.intel_syntax noprefix
.include "kernel.inc"
.include "tss.inc"

.global _syscall_handler
.extern syscall_table, tss

.section .text
.align 16
// Max 4 parameters: rdi rsi rdx r9
_syscall_handler:
    cmp     rax, 12
    ja      .fault
    mov     r10, rsp
    mov     rsp, qword ptr [tss + tss64.rsp0]   // switch to kernel stack
    sti
    push    rcx      // ring3 rip
    push    r11      // rflags
    push    r10      // user stack
    mov     r11, offset syscall_table
    mov     rcx, r9  // 4th parameter

    call    qword ptr [r11 + rax*8]

    pop     r10
    pop     r11
    pop     rcx
    cli
    mov     rsp, r10
    sysretq

.fault:
    mov     eax, -1
    sysretq
