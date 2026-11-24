; print_pm.asm
; 32-bit protected mode: no BIOS anymore, so we write straight into
; video memory. In text mode the screen lives at 0xB8000, and each
; character takes 2 bytes: the ASCII code, then a colour byte.
; Input: EBX = address of a null-terminated string

[bits 32]
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY   ; EDX = where the next character goes (top-left)

.loop:
  mov al, [ebx]           ; AL = the character
  mov ah, WHITE_ON_BLACK  ; AH = its colour
  cmp al, 0               ; end of string?
  je .done
  mov [edx], ax           ; write character + colour to the screen
  add ebx, 1              ; next character in the string
  add edx, 2              ; next cell on screen (2 bytes per cell)
  jmp .loop

.done:
  popa
  ret
