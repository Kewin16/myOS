; switch_pm.asm
; Flip the CPU from 16-bit real mode into 32-bit protected mode.

[bits 16]
switch_to_pm:
  cli                     ; turn off interrupts: the BIOS handlers won't work in 32-bit mode
  lgdt [gdt_descriptor]   ; tell the CPU where our GDT is

  mov eax, cr0            ; CR0 is a control register; bit 0 = protected mode on/off
  or eax, 0x1             ; set bit 0
  mov cr0, eax            ; we're now in protected mode (sort of)

  jmp CODE_SEG:init_pm    ; far jump: loads CS with our code segment and flushes
                          ; the CPU's pipeline of old 16-bit instructions

[bits 32]
init_pm:
  mov ax, DATA_SEG        ; point every data segment register at our data segment
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov ebp, 0x90000        ; put the stack somewhere roomy and out of the way
  mov esp, ebp

  call BEGIN_PM           ; hand over to our 32-bit code in boot.asm
