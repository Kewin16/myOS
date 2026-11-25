// isr.c - sets up the idt + pic, and handles interrupts once they arrive

#include "isr.h"
#include "idt.h"
#include "../drivers/ports.h"
#include "../drivers/screen.h"
#include "../kernel/util.h"

// the pic chips (master + slave) that pass hardware interrupts to the cpu
#define PIC1_CMD  0x20
#define PIC1_DATA 0x21
#define PIC2_CMD  0xa0
#define PIC2_DATA 0xa1
#define PIC_EOI   0x20   // "end of interrupt"

extern unsigned int isr_stub_table[];   // from interrupt.asm

static irq_handler_t irq_handlers[16];

// by default the pic sends irqs 0-7 as interrupts 8-15, which clashes with
// the cpu's own exceptions. this moves irqs 0-15 to 32-47 instead
static void remap_pic(void) {
    port_byte_out(PIC1_CMD, 0x11);    // start setup on both chips
    port_byte_out(PIC2_CMD, 0x11);
    port_byte_out(PIC1_DATA, 0x20);   // master starts at 32
    port_byte_out(PIC2_DATA, 0x28);   // slave starts at 40
    port_byte_out(PIC1_DATA, 0x04);   // tell master the slave is on irq 2
    port_byte_out(PIC2_DATA, 0x02);   // tell slave it's chained to the master
    port_byte_out(PIC1_DATA, 0x01);   // 8086 mode
    port_byte_out(PIC2_DATA, 0x01);

    // masks: a 1 bit = ignore that irq. only let the keyboard (irq 1) through for now
    port_byte_out(PIC1_DATA, 0xfd);   // 1111 1101
    port_byte_out(PIC2_DATA, 0xff);
}

void isr_install(void) {
    for (int i = 0; i < 48; i++) {
        set_idt_gate(i, isr_stub_table[i]);
    }
    remap_pic();
    load_idt();
}

void register_irq_handler(int irq, irq_handler_t handler) {
    irq_handlers[irq] = handler;
}

// cpu exceptions (divide by zero etc). nothing clever, just say what happened and stop
void isr_handler(registers_t *regs) {
    char num[12];
    int_to_str(regs->int_no, num);
    print("\nCPU exception ");
    print(num);
    print("! System halted.");
    while (1) {
        __asm__ volatile ("cli; hlt");
    }
}

void irq_handler(registers_t *regs) {
    int irq = regs->int_no - 32;

    // have to tell the pic we're done or it won't send any more.
    // irqs 8-15 come through the slave so it needs telling too
    if (irq >= 8) port_byte_out(PIC2_CMD, PIC_EOI);
    port_byte_out(PIC1_CMD, PIC_EOI);

    if (irq_handlers[irq] != 0) {
        irq_handlers[irq](regs);
    }
}
