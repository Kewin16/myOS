; print.asm - prints a string using the bios (16-bit real mode only)
; put the string's address in si before calling, string has to end with a 0

print_string:
  pusha              ; save regs so we don't mess up whoever called us
  mov ah, 0x0e       ; 0x0e = bios "print a char" function
.loop:
  lodsb              ; grab next char into al (si moves on by itself)
  cmp al, 0          ; hit the 0 at the end?
  je .done
  int 0x10           ; bios prints whatever's in al
  jmp .loop
.done:
  popa               ; put the regs back
  ret
