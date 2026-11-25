; kernel_entry.asm - tiny bit of asm that calls our C code
; this has to be the first thing in the kernel binary, since the
; bootloader just jumps to the very start of it (0x1000)

[bits 32]
[extern kernel_main]   ; kernel_main lives in kernel.c, the linker sorts this out
global _start          ; the linker looks for _start as the entry point

_start:
  call kernel_main
  jmp $                ; hang if kernel_main ever returns
