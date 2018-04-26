; ������ 2018-3
[bits 32]

%macro putchar 4
    pusha
    xor ax,ax                 ; �����Դ��ַ
    mov ax,%1
	mov bx,80
	mul bx
	add ax,%2
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,%3			;  0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
	mov al,%4			;  AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո����
	mov word[gs:bp],ax  		;  ��ʾ�ַ���ASCII��ֵ
    ;call print_id
    popa
%endmacro

%define len         20
%define sizeof_word 2

%macro program 4

SECTION .text align=4096
[global main]
main:
    ;call cls                    ; ���BIOS��ʾ����Ϣ
    ;mov ax,cs
	;mov es,ax					; ES = 0
	;mov ds,ax					; DS = CS
	;mov es,ax					; ES = CS
;	mov	ax,0B800h				; �ı������Դ���ʼ��ַ
;	mov	gs,ax					; GS = B800h
    mov byte[char],'A'
    init_x:
    mov ax, word[xmin]
    cmp word[x], ax
    jg  init_y
    inc ax
    mov word[x], ax
    init_y:
    mov ax, word[ymin]
    cmp word[y], ax
    jg  _loop
    inc ax
    mov word[y], ax

    _loop:
    call move
    call change_speed
    ;putchar word[old_x], word[old_y], 0x0000, 0x20
    putchar word[x], word[y], byte[color], byte[char]
    inc word[cnt]
    ;call record_histroy
    mov cx, 600
    OUTER:
    mov bx, 200
    INNER:
    dec bx
    jg INNER
    loop OUTER
    jmp _loop

record_histroy:
    pusha
    cld
    mov si, old_x + 1 * sizeof_word
    mov di, old_x
    %rep    len - 1
            movsw
    %endrep
    mov si, old_y + 1 * sizeof_word
    mov di, old_y
    %rep    len - 1
            movsw
    %endrep
    mov ax, word[x]
    mov word[old_x + (len - 1) * sizeof_word], ax
    mov ax, word[y]
    mov word[old_y + (len - 1) * sizeof_word], ax
    popa
    ret

;cls:
;    pusha           ;����Ĵ�����ֵ
;    mov ah,0x06     ;����10��BIOS�жϵ�6�Ź���
;    mov al,0        ;al=0��������
;    mov bh,0x07     ;���ý���Ļ��Ϊ�ڵװ���
;    mov ch,0        ;��(0,0)��(24,79)
;    mov cl,0
;    mov dh,24
;    mov dl,79
;    int 0x10        ;�����ж�
;    popa            ;�ָ��Ĵ�����ֵ
;    ret             ;����


;print_id:
;    pusha
;    mov ax, myid
;    mov bp, ax      ;es:bp: �ַ����׵�ַ
;    mov cx, 17      ;�ַ�������
;    mov ax, 01300h  ;����Write string����
;    mov bx, 00F1h   ;�׵����֣���˸
;    mov dx, 00920h  ;��ʾ����Ļ����
;    int 10h
;    popa
;    ret

move:
    pusha
    mov ax, word[vx]
    mov bx, word[vy]
    add word[x], ax
    add word[y], bx
    popa
    ret

change_color:
    mov ax, %0
    add ax, 1

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
	
;���ݶ�

SECTION .data align=4096
    count   dw delay
    dcount  dw ddelay
    x       dw 7 + %1 + 1
    y       dw 0 + %3 + 1
    xmin    dw %1
    xmax    dw %2
    ymin    dw %3
    ymax    dw %4
    vx      dw 1
    vy      dw 1
    char    db 'A'
    color   db 01h
    myid    db 'Lixinrui 15323032'
    old_x   times len   dw 0
    old_y   times len   dw 0
    cnt     dw 0
    delay equ 600
    ddelay equ 100


SECTION .bss align=4096

%endmacro
