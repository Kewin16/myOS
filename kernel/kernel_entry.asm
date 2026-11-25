; kernel_entry.asm - tiny bit of asm that calls our C code
; this has to be the first thing in the kernel binary, since the
; bootloader just jumps to the very start of it (0x1000)

[bits 32]
[extern kernel_main]   ; kernel_main lives in kernel.c, the linker sorts this out
[extern __bss_start]   ; these two come from the linker: start and end of the
[extern _end]          ; .bss section (global variables that start at 0)
global _start          ; the linker looks for _start as the entry point

_start:
  ; .bss isn't actually stored in kernel.bin, so whatever junk was in that
  ; memory is still there. zero it ourselves so globals really start at 0
  cld
  mov edi, __bss_start
  mov ecx, _end
  sub ecx, edi
  xor eax, eax
  rep stosb            ; write al (0) to [edi], ecx times

  call kernel_main
  jmp $                ; hang if kernel_main ever returns
