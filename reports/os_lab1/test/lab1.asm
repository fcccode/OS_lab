; ������ 2018-3

org 07c00h					;��֪���������뽫�����ص�07c00h��

jmp main

;���ݶ�
data:
    count   dw delay
    dcount  dw ddelay
    x       dw 7
    y       dw 0
    xmax    dw 25
    xmin    dw -1
    ymax    dw 80
    ymin    dw -1
    vx      dw 1
    vy      dw 1
    char    db 'A'
    color   db 01h
    myid db 'Lixinrui 15323032'
    delay equ 6000					
    ddelay equ 1000					

main:
    call cls                    ; ���BIOS��ʾ����Ϣ
    mov ax,cs
	mov es,ax					; ES = 0
	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS
	mov	ax,0B800h				; �ı������Դ���ʼ��ַ
	mov	gs,ax					; GS = B800h
    mov byte[char],'A'
loop:
    call sleep
    call show
    call move
    call change_speed
    jmp loop

cls:
    pusha           ;����Ĵ�����ֵ
    mov ah,0x06     ;����10��BIOS�жϵ�6�Ź���
    mov al,0        ;al=0��������
    mov bh,0x07     ;���ý���Ļ��Ϊ�ڵװ���
    mov ch,0        ;��(0,0)��(24,79)
    mov cl,0   
    mov dh,24  
    mov dl,79  
    int 0x10        ;�����ж�
    popa            ;�ָ��Ĵ�����ֵ
    ret             ;����

sleep:
    pusha
    mov cx, ddelay      
    OUTER:
        mov bx, delay
        INNER:
            dec bx
            jg INNER
    loop OUTER
    popa
    ret

show:	
    pusha
    xor ax,ax                 ; �����Դ��ַ
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,byte[color]			;  0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
	mov al,byte[char]			;  AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո����
    call cls
	mov word[gs:bp],ax  		;  ��ʾ�ַ���ASCII��ֵ
    call print_id
    popa
    ret

print_id:
    pusha
    mov ax, myid 
    mov bp, ax      ;es:bp: �ַ����׵�ַ
    mov cx, 17      ;�ַ�������
    mov ax, 01300h  ;����Write string����
    mov bx, 00F1h   ;�׵����֣���˸
    mov dx, 00920h  ;��ʾ����Ļ����
    int 10h
    popa
    ret

move:
    pusha
    mov ax, word[vx]
    mov bx, word[vy]
    add word[x], ax
    add word[y], bx
    popa
    ret

change_color:
    cmp byte[color],0Fh ;��ǰ�ַ���ɫ�Ƿ�Ϊ���һ��
    jnz no_rst          ;������ǣ�ѡ����һ��
    mov byte[color],0   ;����ǣ�����
no_rst:
    inc byte[color]     ;ѡ����һ��
    ret

change_speed:
    pusha
check_x:
    mov ax, word[x]
    cmp ax, word[xmin]
    jz  reverse_vx
    cmp ax, word[xmax]
    jz  reverse_vx
    jmp check_y
reverse_vx:
    call change_color
    neg word[vx]
check_y:
    mov bx, word[y]
    cmp bx, word[ymin]
    jz reverse_vy
    cmp bx, word[ymax]
    jz reverse_vy
    popa
    ret
reverse_vy:
    call change_color
    neg word[vy]
    popa
    ret
    
end:
    jmp $                   ; ֹͣ��������ѭ�� 
	
times 510 - ($ -$$)     db  0
dw    0xaa55
