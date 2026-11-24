; print.asm
; 16-bit real mode: print a null-terminated string using the BIOS.
; Input: SI = address of the string
print_string:
  pusha              ; save all registers so the caller's values survive
  mov ah, 0x0e       ; BIOS teletype function
.loop:
  lodsb              ; AL = [SI], then SI++
  cmp al, 0          ; end of string?
  je .done
  int 0x10           ; print the character in AL
  jmp .loop
.done:
  popa               ; restore the registers we saved
  ret
