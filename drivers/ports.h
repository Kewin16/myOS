// ports.h - reading/writing I/O ports (how we talk to hardware directly)
#ifndef PORTS_H
#define PORTS_H

unsigned char port_byte_in(unsigned short port);
void port_byte_out(unsigned short port, unsigned char data);

#endif
