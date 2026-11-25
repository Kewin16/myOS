// kernel.c - the kernel's main function, called from kernel_entry.asm

#include "../drivers/screen.h"
#include "util.h"

void kernel_main(void) {
    clear_screen();
    print("Welcome to myOS!\n");
    print("Running in 32-bit protected mode, kernel written in C\n\n");

    // scrolling test: print more lines than fit on the screen (25 rows)
    char num[12];
    for (int i = 1; i <= 30; i++) {
        int_to_str(i, num);
        print("Line ");
        print(num);
        print("\n");
    }
    print("If you can read this, scrolling works!");
}
