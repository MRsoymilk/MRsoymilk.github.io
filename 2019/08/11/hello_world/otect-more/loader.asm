%include "var.asm"
;--------------------------------------------
org LOADER_ADDRESS
 
  jmp loader_start
  
;构建gdt及其内部的描述符===============================================
  GDT_BASE:   dd    0x00000000 
	      	   dd    0x00000000
 
  CODE_DESC:  dd    0x0000FFFF 
	      	   dd    DESC_CODE_HIGH4    ; 0x9800
 
  DATA_STACK_DESC:  dd    0x0000FFFF
	      		 dd    DESC_DATA_HIGH4    ; 0x9200
 
  VIDEO_DESC: dd    0x80000007	       ; limit=(0xbffff-0xb8000)/4k=0x7
	          dd    DESC_VIDEO_HIGH4  ; 此时dpl为0
 
  GDT_SIZE    equ   $ - GDT_BASE    ; 0x0020
  GDT_LIMIT   equ   GDT_SIZE -	1   ; 0x001f
  times 60 dq 0					 ; 此处预留60个描述符的空位(slot)
  SELECTOR_CODE  equ (0x0001<<3) + TI_GDT + RPL0     ; 8[1000] 相当于(CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0 ; 0x0008
  SELECTOR_DATA  equ (0x0002<<3) + TI_GDT + RPL0	 ; 16[10000] 同上     ; 0x0010
  SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0	 ; 24[11000] 同上     ; 0x0018
 
 
  ;以下是定义gdt的指针，前2字节是gdt界限，后4字节是gdt起始地址
  gdt_ptr  dw  GDT_LIMIT 
	   	dd  GDT_BASE
;======================================================================
			
loader_start:

;-----------------   准备进入保护模式   -------------------
;1 打开A20
;2 加载gdt
;3 将cr0的pe位置1
 
   ;-----------------  打开A20  ----------------
   in al,0x92
   or al,0000_0010B
   out 0x92,al
 
   ;-----------------  加载GDT  ----------------
   lgdt [gdt_ptr]
 
   ;-----------------  cr0第0位置1  ----------------
   mov eax, cr0
   or eax, 0x00000001
   mov cr0, eax
 
   jmp dword SELECTOR_CODE:p_mode_start	     ; 刷新流水线，避免分支预测的影响,这种cpu优化策略，最怕jmp跳转，
					     ; 这将导致之前做的预测失效，从而起到了刷新的作用。
 
[bits 32]
p_mode_start:
   mov ax, SELECTOR_DATA
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov esp,0x900
   mov ax, SELECTOR_VIDEO
   mov gs, ax
	
   ;160=80个字符[80*2]
   mov byte [gs:160*8],     'P'
   mov byte [gs:160*8+2],   'r'
   mov byte [gs:160*8+4],   'o'
   mov byte [gs:160*8+6],   't'
   mov byte [gs:160*8+8],   'e'
   mov byte [gs:160*8+10],  'c'
   mov byte [gs:160*8+12],  't'

   mov ax, DESC_CODE_HIGH4
   mov ax, DESC_DATA_HIGH4
   mov ax, DESC_VIDEO_HIGH4
   mov ax, GDT_SIZE
   mov ax, GDT_LIMIT
   mov ax, SELECTOR_CODE
   mov ax, SELECTOR_DATA
   mov ax, SELECTOR_VIDEO
 
   jmp $
