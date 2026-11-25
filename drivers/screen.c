// screen.c - printing to the screen in text mode
// the screen is 80x25 chars, each char = 2 bytes in video memory (char + colour)
// positions here are counted in chars, so row 2 col 5 = 2 * 80 + 5

#include "screen.h"
#include "ports.h"

// the vga card's ports for controlling the cursor
#define REG_SCREEN_CTRL 0x3d4
#define REG_SCREEN_DATA 0x3d5

// ask the vga card where the cursor is. the position is 16 bits
// but the port is 8 bits, so we read it in two halves
static int get_cursor(void) {
    port_byte_out(REG_SCREEN_CTRL, 14);           // 14 = high byte
    int pos = port_byte_in(REG_SCREEN_DATA) << 8;
    port_byte_out(REG_SCREEN_CTRL, 15);           // 15 = low byte
    pos += port_byte_in(REG_SCREEN_DATA);
    return pos;
}

// move the blinking cursor, same idea as above but writing
static void set_cursor(int pos) {
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (unsigned char) (pos >> 8));
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (unsigned char) (pos & 0xff));
}

// shift every row up by one and blank the bottom row
static void scroll(void) {
    char *video = (char *) VIDEO_MEMORY;
    int row_bytes = MAX_COLS * 2;

    for (int i = 0; i < (MAX_ROWS - 1) * row_bytes; i++) {
        video[i] = video[i + row_bytes];
    }

    for (int i = (MAX_ROWS - 1) * row_bytes; i < MAX_ROWS * row_bytes; i += 2) {
        video[i] = ' ';
        video[i + 1] = WHITE_ON_BLACK;
    }
}

void clear_screen(void) {
    char *video = (char *) VIDEO_MEMORY;

    for (int i = 0; i < MAX_ROWS * MAX_COLS; i++) {
        video[i * 2] = ' ';
        video[i * 2 + 1] = WHITE_ON_BLACK;
    }
    set_cursor(0);
}

void print_char(char c) {
    char *video = (char *) VIDEO_MEMORY;
    int pos = get_cursor();

    if (c == '\n') {
        pos = (pos / MAX_COLS + 1) * MAX_COLS;   // jump to the start of the next row
    } else if (c == '\b') {
        if (pos > 0) pos--;                      // go back one and blank it out
        video[pos * 2] = ' ';
        video[pos * 2 + 1] = WHITE_ON_BLACK;
    } else {
        video[pos * 2] = c;
        video[pos * 2 + 1] = WHITE_ON_BLACK;
        pos++;
    }

    // gone off the bottom? scroll up and stay on the last row
    if (pos >= MAX_ROWS * MAX_COLS) {
        scroll();
        pos -= MAX_COLS;
    }

    set_cursor(pos);
}

void print(const char *str) {
    for (int i = 0; str[i] != 0; i++) {
        print_char(str[i]);
    }
}
