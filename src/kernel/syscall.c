#include <stddef.h>
#include <stdint.h>
#include "kdebug.h"

int syscall_null() {
    kdebug("SYSCALL: function 0 not supported, terminating.\n");
    return -1;
}
int syscall_exit(int code) {
    kdebug("SYSCALL: exit(%X)\n", code);
    return -1;
}
int syscall_open(const char * file, int flags, int mode) {
    kdebug("SYSCALL: open(%s, %X, %X)\n", file, flags, mode);
    return -1;
}
int syscall_close(int fd) {
    kdebug("SYSCALL: close(%X)\n", fd);
    return -1;
}
size_t syscall_read(int fd, void* buf, size_t len) {
    kdebug("SYSCALL: read(%d, %X, %d)\n", fd, buf, len);
    return -1;
}
size_t syscall_write(int fd, char* s, size_t len) {
    (void)fd;
    // kdebug("SYSCALL: write(%d, %X, %d)\n", fd, s, len);
    for (size_t i=0; i < len; i++) {
        kdebug("%c", s[i]);
    }
    return (size_t)len;
}
size_t syscall_lseek(int fd, uint64_t offset, int whence) {
    kdebug("SYSCALL: lseek(%X, %lX, %X)\n", fd, offset, whence);
    return -1;
}
int syscall_unlink(const char* file) {
    kdebug("SYSCALL: unlink(%s)\n", file);
    return -1;
}
int syscall_getpid() {
    return -1;
}
int syscall_kill(int pid, int sig) {
    kdebug("SYSCALL: kill(%X, %X)\n", pid, sig);
    return -1;
}
int syscall_fstat(int fd, void* st) {
    (void)fd;
    (void)st;
    return -1;
}
size_t syscall_sbrk(size_t nbytes) {
    (void)nbytes;
    return -1;
}
int syscall_usleep(unsigned int usec) {
    kdebug("SYSCALL: usleep(%X)\n", usec);
    return -1;
}
uintptr_t syscall_table[] = {
    (uintptr_t) syscall_null,
    (uintptr_t) syscall_exit,
    (uintptr_t) syscall_open,
    (uintptr_t) syscall_close,
    (uintptr_t) syscall_read,
    (uintptr_t) syscall_write,
    (uintptr_t) syscall_lseek,
    (uintptr_t) syscall_unlink,
    (uintptr_t) syscall_getpid,
    (uintptr_t) syscall_kill,
    (uintptr_t) syscall_fstat,
    (uintptr_t) syscall_sbrk,
    (uintptr_t) syscall_usleep
};
