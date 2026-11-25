// idt.h - the interrupt descriptor table
// tells the cpu which function to run for each interrupt (0-255)
#ifndef IDT_H
#define IDT_H

void set_idt_gate(int n, unsigned int handler);
void load_idt(void);

#endif
