// keyboard.c - turns key presses into characters on screen
// the keyboard sends a "scancode" (just a number for which key) on port 0x60.
// pressing a key gives the code, releasing it gives the code + 0x80

#include "keyboard.h"
#include "ports.h"
#include "screen.h"
#include "../cpu/isr.h"

#define KEYBOARD_DATA 0x60
#define LSHIFT 0x2a
#define RSHIFT 0x36
#define RELEASED 0x80

// scancode -> character (scancode set 1, uk/us-ish layout). 0 = key we ignore
static const char normal[] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' '
};

static const char shifted[] = {
    0, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '\b',
    0, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n',
    0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~',
    0, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0,
    '*', 0, ' '
};

static int shift_held;

static void keyboard_callback(registers_t *regs) {
    (void) regs;   // don't need it, this just stops the unused warning
    unsigned char scancode = port_byte_in(KEYBOARD_DATA);

    // shift pressed / released
    if (scancode == LSHIFT || scancode == RSHIFT) { shift_held = 1; return; }
    if (scancode == (LSHIFT | RELEASED) || scancode == (RSHIFT | RELEASED)) { shift_held = 0; return; }

    // ignore other key releases and anything not in our table
    if (scancode & RELEASED) return;
    if (scancode >= sizeof(normal)) return;

    char c = shift_held ? shifted[scancode] : normal[scancode];
    if (c != 0) print_char(c);
}

void init_keyboard(void) {
    register_irq_handler(1, keyboard_callback);
}
