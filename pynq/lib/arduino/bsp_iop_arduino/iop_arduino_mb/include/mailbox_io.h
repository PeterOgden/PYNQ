#ifndef MAILBOX_IO_H_
#define MAILBOX_IO_H_

#include <unistd.h>
#include <stdint.h>

char mailbox_inbyte(intptr_t device);
void mailbox_outbyte(intptr_t device, char c);
int mailbox_close(int fd);
int mailbox_open(const char* pathname, int flags, ...);
ssize_t mailbox_read(int file, void* ptr, size_t len);
ssize_t mailbox_write(int file, const void* ptr, size_t len);
long mailbox_lseek(int fd, long offset, int whence);
int mailbox_available(int fd);

#endif
