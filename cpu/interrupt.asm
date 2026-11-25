; interrupt.asm - the first code that runs when an interrupt happens
; each stub pushes the interrupt number, then jumps to a common bit
; that saves all the registers and calls into C

[bits 32]
[extern isr_handler]   ; in isr.c
[extern irq_handler]   ; in isr.c

; some cpu exceptions push an error code and some don't.
; for the ones that don't we push a fake 0, so the stack always looks the same
%macro ISR_NOERR 1
isr%1:
  push dword 0         ; fake error code
  push dword %1        ; interrupt number
  jmp isr_common_stub
%endmacro

%macro ISR_ERR 1
isr%1:
  push dword %1        ; cpu already pushed the error code
  jmp isr_common_stub
%endmacro

; hardware interrupts (IRQs). %1 = irq number, %2 = where it ends up in the idt
%macro IRQ 2
irq%1:
  push dword 0
  push dword %2
  jmp irq_common_stub
%endmacro

; cpu exceptions 0-31
ISR_NOERR 0    ; divide by zero
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6    ; invalid opcode
ISR_NOERR 7
ISR_ERR   8    ; double fault
ISR_NOERR 9
ISR_ERR   10
ISR_ERR   11
ISR_ERR   12
ISR_ERR   13   ; general protection fault
ISR_ERR   14   ; page fault
ISR_NOERR 15
ISR_NOERR 16
ISR_ERR   17
ISR_NOERR 18
ISR_NOERR 19
ISR_NOERR 20
ISR_ERR   21
ISR_NOERR 22
ISR_NOERR 23
ISR_NOERR 24
ISR_NOERR 25
ISR_NOERR 26
ISR_NOERR 27
ISR_NOERR 28
ISR_ERR   29
ISR_ERR   30
ISR_NOERR 31

; hardware irqs 0-15, remapped to 32-47 (see isr.c)
IRQ 0, 32      ; timer
IRQ 1, 33      ; keyboard
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47

isr_common_stub:
  pusha                ; save eax, ecx, edx, ebx, esp, ebp, esi, edi
  push esp             ; pointer to everything we just pushed = registers_t in C
  call isr_handler
  add esp, 4           ; remove the pointer
  popa
  add esp, 8           ; remove the interrupt number + error code
  iret                 ; return from the interrupt

irq_common_stub:
  pusha
  push esp
  call irq_handler
  add esp, 4
  popa
  add esp, 8
  iret

; table of all 48 stub addresses so C can loop over them
global isr_stub_table
isr_stub_table:
%assign i 0
%rep 32
  dd isr%[i]
%assign i i+1
%endrep
%assign i 0
%rep 16
  dd irq%[i]
%assign i i+1
%endrep
