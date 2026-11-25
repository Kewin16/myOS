// ports.c - "in" and "out" are cpu instructions with no C equivalent,
// so we use a bit of inline asm

#include "ports.h"

// read a byte from a port
unsigned char port_byte_in(unsigned short port) {
    unsigned char result;
    __asm__ volatile ("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

// write a byte to a port
void port_byte_out(unsigned short port, unsigned char data) {
    __asm__ volatile ("out %%al, %%dx" : : "a" (data), "d" (port));
}
