; 读取硬盘n个扇区
ReadDisk:
  ; mov esi, eax  ;备份eax
  push ax
  mov di, cx      ;备份cx
  ; 1 设置要读取的扇区
  mov dx, 0x1f2   ; dx = 0x1f2
  mov al, cl      ; al = cl
  out dx, al      ; 读取的扇区数, dx = al = 0x1, 0x1f2端口值为1

  ; mov eax, esi  ; 恢复ax
  pop ax          ; ax = 0x1

  ; 2 将LBA地址存入0x1f3 ~ 0x1f6
  ; LBA地址7~0位写入端口0x1f3
  mov dx, 0x1f3   ; dx = 0x1f3
  out dx, al      ; dx = 1

  ; LBA地址15~8位写入端口0x1f4
  mov cl, 8       ; cl = 8
  shr ax, cl      ; eax = 0
  mov dx, 0x1f4   ; dx = 0x1f4
  out dx, al      ; dx = 0

  ; LBA地址23~16位写入端口0x1f5
  shr ax, cl      ; eax = 0
  mov dx, 0x1f5   ; dx = 0x1f5
  out dx, al      ; dx = 0

  shr ax, cl      ; eax = 0
  and al, 0x0f    ; lba第24~27位，al = 0
  or al, 0xe0     ; 设置7~4位1110，表示lba模式, al = 1110_0000b
  mov dx, 0x1f6   ; dx = 0x1f6
  out dx, al      ; dx = 1110_0000b

  ; 3 向0x1f7端口写入读命令，0x20
  mov dx, 0x1f7   ; dx = 0x1f7
  mov al, 0x20    ; al = 0x20
  out dx, al      ; dx = 0x20

; 4 检测硬盘状态
NotReady:
  ; 同一端口，写时表示写入命令字，读时表示读入硬盘状态
  nop
  in al, dx       ; al = dx
  ; 第4位为1表示硬盘控制器已准备好数据传输
  ; 第7位为1表示硬盘忙
  and al, 0x88    ; al & 0x88 =  1000_1000b
  cmp al, 0x08 
  jnz NotReady    ; 等待硬盘准备好

  ; 5 从0x1f0端口读数据
  mov ax, di      ; ax = di
  mov dx, 256     ; dx = 256
  mul dx ; 
  mov cx, ax      ; cx = ax
  ; di 为要读取的扇区数，一个扇区有512个字节，每次读入一个字
  ; 共需di * 512 / 2 次，所以di * 256
  mov dx, 0x1f0   ; dx = 0x1f0

GoOnRead:
  in ax, dx       ; ax = dx端口值
  mov [bx], ax    ; [bx] = ax，写入内存
  add bx, 2       ; bx += 2
  loop GoOnRead
  ret
