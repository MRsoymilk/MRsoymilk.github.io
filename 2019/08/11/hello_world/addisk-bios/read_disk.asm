%include "var.asm"
ReadDisk:
  mov ah, 0x02
  mov bx, PROGRAM_SPACE
  mov al, 2
  mov dl, [BOOT_DISK]
  mov ch, 0x00
  mov dh, 0x00
  mov cl, 0x02
  int 0x13

  jc DiskReadFailed
  ret

  DiskReadFailed:
    mov bx, DISK_READ_ERROR_String
    call PrintString
    jmp $

%include "print.asm"

BOOT_DISK: db 0
DISK_READ_ERROR_String: db "Disk read failed", 0x0a, 0x0d, 0

