// kernel.c - the kernel's main function, called from kernel_entry.asm

#include "../drivers/screen.h"
#include "../drivers/keyboard.h"
#include "../cpu/isr.h"

void kernel_main(void) {
    clear_screen();
    print("Welcome to myOS!\n");

    print("Setting up interrupts...\n");
    isr_install();
    init_keyboard();
    __asm__ volatile ("sti");   // interrupts back on (switch_pm.asm turned them off with cli)

    print("Ready! Start typing:\n\n");

    // nothing else to do, so sleep until the next interrupt (a key press)
    while (1) {
        __asm__ volatile ("hlt");
    }
}
