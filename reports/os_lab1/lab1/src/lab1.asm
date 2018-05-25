; ������ 2018-3

org 07c00h					;��֪���������뽫�����ص�07c00h��

jmp main                    ;��main������ʼִ��

;����4������
;cls, print_id, change_color, sleep
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

change_color:
    cmp byte[color],0Fh ;��ǰ�ַ���ɫ�Ƿ�Ϊ���һ��
    jnz no_rst          ;������ǣ�ѡ����һ��
    mov byte[color],0   ;����ǣ�����
no_rst:
    inc byte[color]     ;ѡ����һ��
    ret
    
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

;���ݶ�
data:
    count   dw delay
    dcount  dw ddelay
    rdul    db Dn_Rt         
    x       dw 1
    y       dw 1
    char    db 'A'
    color   db 01h
    myid db 'Lixinrui 15323032'
    Dn_Rt equ 1                  
    Up_Rt equ 2                  
    Up_Lt equ 3                 
    Dn_Lt equ 4                  
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

move:
    call sleep
      mov al,1
      cmp al,byte[rdul]
	jz  DnRt
      mov al,2
      cmp al,byte[rdul]
	jz  UpRt
      mov al,3
      cmp al,byte[rdul]
	jz  UpLt
      mov al,4
      cmp al,byte[rdul]
	jz  DnLt
      jmp $	

DnRt:
	inc word[x]
	inc word[y]
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dr2ur
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  dr2dl
	jmp show
dr2ur:
      mov word[x],23
      mov byte[rdul],Up_Rt	
    call change_color
      jmp show
dr2dl:
      mov word[y],78
      mov byte[rdul],Dn_Lt	
    call change_color
      jmp show

UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],78
      mov byte[rdul],Up_Lt	
    call change_color
      jmp show
ur2dr:
      mov word[x],1
      mov byte[rdul],Dn_Rt	
    call change_color
      jmp show

	
	
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      call change_color
      jmp show
ul2ur:
      mov word[y],1
      mov byte[rdul],Up_Rt	
      call change_color
      jmp show

	
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],1
      mov byte[rdul],Dn_Rt	
      call change_color
      jmp show
	
dl2ul:
      mov word[x],23
      mov byte[rdul],Up_Lt	
      call change_color
      jmp show
	
show:	
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
	jmp move
	
end:
    jmp $                   ; ֹͣ��������ѭ�� 
	


times 510 - ($ -$$)     db  0
dw    0xaa55
