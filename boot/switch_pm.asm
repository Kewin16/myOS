; switch_pm.asm - switches the cpu from 16-bit real mode to 32-bit protected mode

[bits 16]
switch_to_pm:
  cli                     ; interrupts off, bios ones would crash us in 32-bit mode
  lgdt [gdt_descriptor]   ; load our gdt

  mov eax, cr0            ; bit 0 of cr0 = protected mode on/off
  or eax, 0x1             ; can't set it directly so copy, set bit, copy back
  mov cr0, eax

  jmp CODE_SEG:init_pm    ; far jump sets cs to our code segment and clears out
                          ; any 16-bit instructions the cpu already fetched

[bits 32]
init_pm:
  mov ax, DATA_SEG        ; all the other segment regs -> data segment
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov ebp, 0x90000        ; new stack, well out of the way
  mov esp, ebp

  call BEGIN_PM           ; back to boot.asm, now in 32-bit
