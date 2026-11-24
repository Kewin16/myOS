; boot.asm - boots in 16-bit real mode then switches to 32-bit protected mode

[org 0x7c00]

  ; segment regs to 0 + set up a stack
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov bp, 0x9000
  mov sp, bp

  mov si, MSG_REAL_MODE
  call print_string

  call switch_to_pm   ; doesn't return

  jmp $

%include "print.asm"
%include "gdt.asm"
%include "print_pm.asm"
%include "switch_pm.asm"

[bits 32]
BEGIN_PM:
  mov ebx, MSG_PROT_MODE
  call print_string_pm
  jmp $

MSG_REAL_MODE db 'Started in 16-bit real mode', 0
MSG_PROT_MODE db 'Landed in 32-bit protected mode!', 0

times 510-($-$$) db 0
dw 0xaa55
