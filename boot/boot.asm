; boot.asm - loads the kernel from disk, switches to 32-bit mode, then jumps into it

[org 0x7c00]
KERNEL_OFFSET equ 0x1000   ; where we load the kernel in memory

  ; segment regs to 0 + set up a stack
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov bp, 0x9000
  mov sp, bp

  mov [BOOT_DRIVE], dl     ; bios puts the boot drive number in dl, save it for later

  mov si, MSG_REAL_MODE
  call print_string

  call load_kernel
  call switch_to_pm        ; doesn't return

  jmp $

%include "print.asm"
%include "disk.asm"
%include "gdt.asm"
%include "print_pm.asm"
%include "switch_pm.asm"

[bits 16]
load_kernel:
  mov si, MSG_LOAD_KERNEL
  call print_string

  mov bx, KERNEL_OFFSET    ; load to 0x1000
  mov dh, 16               ; 16 sectors = 8KB, plenty for now
  mov dl, [BOOT_DRIVE]
  call disk_load
  ret

[bits 32]
BEGIN_PM:
  mov ebx, MSG_PROT_MODE
  call print_string_pm
  call KERNEL_OFFSET       ; jump into the kernel!
  jmp $                    ; only get here if the kernel returns

BOOT_DRIVE db 0
MSG_REAL_MODE db 'Started in 16-bit real mode', 13, 10, 0
MSG_LOAD_KERNEL db 'Loading kernel...', 13, 10, 0
MSG_PROT_MODE db 'Landed in 32-bit protected mode!', 0

times 510-($-$$) db 0
dw 0xaa55
