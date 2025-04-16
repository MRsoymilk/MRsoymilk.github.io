%include "var.asm"
org 0x7c00

mov bx, MBR_MSG
call PrintString

mov [BOOT_DISK], dl
mov bp, 0x7c00
mov sp, bp
call ReadDisk

jmp PROGRAM_SPACE

%include "print.asm"
%include "read_disk.asm"

MBR_MSG: db "MBR", 0x0a, 0x0d, 0

times 510 - ($ - $$) db 0
db 0x55, 0xaa
