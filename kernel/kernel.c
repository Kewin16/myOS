// kernel.c - first bit of C running on the bare metal!
// no OS = no printf, so we write to video memory ourselves like in print_pm.asm

void kernel_main(void) {
    char *video = (char *) 0xb8000;   // text mode screen memory
    const char *msg = "Hello from the C kernel!";

    // second line of the screen = 80 chars in, 2 bytes per char
    int offset = 80 * 2;

    for (int i = 0; msg[i] != 0; i++) {
        video[offset + i * 2] = msg[i];       // the char
        video[offset + i * 2 + 1] = 0x0a;     // colour: light green on black
    }
}
