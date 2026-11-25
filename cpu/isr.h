// isr.h - interrupt handling
#ifndef ISR_H
#define ISR_H

// what the stack looks like when isr_handler/irq_handler get called.
// order matters: it's the reverse of what got pushed
typedef struct {
    unsigned int edi, esi, ebp, esp, ebx, edx, ecx, eax;   // pushed by pusha
    unsigned int int_no, err_code;                         // pushed by our stubs
    unsigned int eip, cs, eflags;                          // pushed by the cpu
} registers_t;

typedef void (*irq_handler_t)(registers_t *regs);

void isr_install(void);
void register_irq_handler(int irq, irq_handler_t handler);

#endif
