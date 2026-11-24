; gdt.asm
; The Global Descriptor Table: tells the CPU what memory segments exist
; once we're in 32-bit protected mode. We use the simplest setup (the
; "flat model"): one code segment and one data segment, both covering
; the full 4GB address space.

gdt_start:

gdt_null:            ; the CPU requires the first entry to be all zeros
  dd 0x0
  dd 0x0

gdt_code:            ; code segment: where instructions run from
  dw 0xffff          ; limit, bits 0-15
  dw 0x0             ; base, bits 0-15
  db 0x0             ; base, bits 16-23
  db 10011010b       ; access: present, ring 0 (kernel), code, readable
  db 11001111b       ; flags: 4KB granularity, 32-bit + limit bits 16-19
  db 0x0             ; base, bits 24-31

gdt_data:            ; data segment: where variables and the stack live
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b       ; access: present, ring 0, data, writable
  db 11001111b
  db 0x0

gdt_end:

; The CPU doesn't load the table directly. It loads this small
; descriptor, which says how big the table is and where it starts.
gdt_descriptor:
  dw gdt_end - gdt_start - 1   ; size of the table, minus 1
  dd gdt_start                 ; address of the table

; Handy constants: the offset of each segment inside the table.
; In protected mode, segment registers hold these offsets.
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
