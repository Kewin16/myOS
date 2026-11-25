; disk.asm - loads sectors from the boot disk using the bios (16-bit)
; dh = how many sectors to read, dl = which drive
; es:bx = where in memory to put them

disk_load:
  pusha
  push dx              ; save dh so we can check how many sectors we actually got

  mov ah, 0x02         ; bios "read sectors" function
  mov al, dh           ; number of sectors
  mov ch, 0x00         ; cylinder 0
  mov dh, 0x00         ; head 0
  mov cl, 0x02         ; start at sector 2 (sector 1 is the boot sector, sectors start at 1 not 0)
  int 0x13             ; do the read
  jc disk_error        ; carry flag set = something went wrong

  pop dx
  cmp al, dh           ; al = sectors actually read
  jne disk_error
  popa
  ret

disk_error:
  mov si, DISK_ERROR_MSG
  call print_string
  jmp $

DISK_ERROR_MSG db 'Disk read error!', 0
