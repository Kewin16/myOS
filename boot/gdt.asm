; gdt.asm - the GDT (global descriptor table)
; protected mode needs this to know what memory segments exist.
; using the simple "flat" setup: one code + one data segment, both
; covering all 4GB, so basically no segmentation

gdt_start:

gdt_null:            ; first entry has to be all zeros, cpu needs it
  dd 0x0
  dd 0x0

gdt_code:            ; code segment
  dw 0xffff          ; limit (bits 0-15)
  dw 0x0             ; base (bits 0-15)
  db 0x0             ; base (bits 16-23)
  db 10011010b       ; access byte: present, ring 0, code, readable
  db 11001111b       ; flags: 4KB pages + 32-bit, and limit bits 16-19
  db 0x0             ; base (bits 24-31)

gdt_data:            ; data segment, same as code apart from the access byte
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b       ; access byte: present, ring 0, data, writable
  db 11001111b
  db 0x0

gdt_end:

; lgdt doesn't take the table itself, it takes this little struct:
; size of the table (minus 1) + where it starts
gdt_descriptor:
  dw gdt_end - gdt_start - 1
  dd gdt_start

; offsets into the table, these are what go in the segment regs later
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
