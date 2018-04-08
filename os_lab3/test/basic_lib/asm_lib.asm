BITS 16
%define _16_BIT_DIRECT_USED_IN_C_

[global sys_bios_clear_screen]
[global sys_bios_print_string]
[global sys_bios_getchar]
[global sys_execve_bin]
[global sys_sleep]
[extern sys_int08_arrive]


sys_bios_print_string:
    push bp
    mov bp, sp
    mov cx, word[bp + 10]    
    mov bx, word[bp + 14]    
    mov bh, 0
    mov dx, word[bp + 18]   
	mov	ax, ds		        
	mov	es, ax		        
	mov	ax, 1301h		    
    mov gs, bp
    mov bp, word[bp + 6]    
	int	10h			        
    mov bp, gs
    pop bp
    %ifdef _16_BIT_DIRECT_USED_IN_C_
    pop ecx
    jmp cx
    %else
    ret
    %endif

sys_bios_clear_screen:
    pusha           
    mov ah,0x06     
    mov al,0        
    mov bh,0x07     
    mov ch,0        
    mov cl,0   
    mov dh,24  
    mov dl,79  
    int 0x10        
    popa            
    %ifdef _16_BIT_DIRECT_USED_IN_C_
    pop ecx
    jmp cx
    %else
    ret
    %endif

sys_bios_getchar:
    mov ah, 0
    int 16h
    mov ah, 0
    ret

sys_execve_bin:
    push bp
    mov bp, sp
    pusha         ;这里要保护寄存器!!!
    push ds
    push es
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov word[0xA000], 0xCD
    mov word[0xA000 + 2], 20h
    mov word[0xA00A], return_point
    mov word[0xA00A + 2], cs
    jmp 0x1000:0xA100
return_point:
    mov ax, 0x0000
    mov ss, ax
    pop ax
    mov es, ax
    pop ax
    mov ds, ax
    popa
    pop bp
    %ifdef _16_BIT_DIRECT_USED_IN_C_
    pop ecx
    jmp cx
    %else
    ret
    %endif

sys_sleep:
    push bp
    mov bp, sp
    pusha
    mov cx, word[bp+10]
    sleep_loop:
        cmp byte[sys_int08_arrive], 0
        jz sleep_loop
        mov ax, 0
        xchg al, byte[sys_int08_arrive]
        loop sleep_loop
    popa
    pop bp
    %ifdef _16_BIT_DIRECT_USED_IN_C_
    pop ecx
    jmp cx
    %else
    ret
    %endif
