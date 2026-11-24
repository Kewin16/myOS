; print_pm.asm - prints a string in 32-bit protected mode
; no bios anymore so we write straight to video memory at 0xb8000.
; each char on screen = 2 bytes: the ascii code then the colour
; put the string's address in ebx before calling

[bits 32]
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY   ; edx = where on screen we're writing (starts top left)

.loop:
  mov al, [ebx]           ; char
  mov ah, WHITE_ON_BLACK  ; colour
  cmp al, 0               ; end of string?
  je .done
  mov [edx], ax           ; write both bytes to the screen
  add ebx, 1              ; next char
  add edx, 2              ; next screen cell (2 bytes each)
  jmp .loop

.done:
  popa
  ret
