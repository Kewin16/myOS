// idt.c - building and loading the idt

#include "idt.h"

#define KERNEL_CODE_SEG 0x08   // CODE_SEG from gdt.asm
#define IDT_ENTRIES 256

// one entry in the idt (8 bytes). the handler address is split in two
// halves because intel. packed = don't let the compiler add padding
struct idt_gate {
    unsigned short low_offset;    // handler address bits 0-15
    unsigned short sel;           // code segment to run it in
    unsigned char always0;
    unsigned char flags;          // present, ring 0, 32-bit interrupt gate
    unsigned short high_offset;   // handler address bits 16-31
} __attribute__((packed));

// what lidt wants: size of the table - 1, then where it is (same idea as the gdt)
struct idt_register {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed));

static struct idt_gate idt[IDT_ENTRIES];
static struct idt_register idt_reg;

void set_idt_gate(int n, unsigned int handler) {
    idt[n].low_offset = handler & 0xffff;
    idt[n].sel = KERNEL_CODE_SEG;
    idt[n].always0 = 0;
    idt[n].flags = 0x8e;          // 1000 1110 = present, ring 0, interrupt gate
    idt[n].high_offset = (handler >> 16) & 0xffff;
}

void load_idt(void) {
    idt_reg.limit = IDT_ENTRIES * sizeof(struct idt_gate) - 1;
    idt_reg.base = (unsigned int) &idt;
    __asm__ volatile ("lidt (%0)" : : "r" (&idt_reg));
}
