%include "var.asm"

[org PROGRAM_SPACE]

mov bx, LOADER_MSG
call PrintString

jmp $

%include "print.asm"

LOADER_MSG: db "Loader", 0x0a, 0x0d, 0

times 2048 - ($ - $$) db 0
