// screen.h - text mode screen driver
#ifndef SCREEN_H
#define SCREEN_H

#define VIDEO_MEMORY 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
#define WHITE_ON_BLACK 0x0f

void clear_screen(void);
void print_char(char c);
void print(const char *str);

#endif
