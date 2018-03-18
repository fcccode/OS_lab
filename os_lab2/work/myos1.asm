;����Դ���루myos1.asm��
%macro print_string 4
	mov	ax, cs	       ; �������μĴ���ֵ��CS��ͬ
	mov	ds, ax	       ; ���ݶ�
	mov	bp, %1		 ; BP=��ǰ����ƫ�Ƶ�ַ
	mov	ax, ds		 ; ES:BP = ����ַ
	mov	es, ax		 ; ��ES=DS
	mov	cx, %2             ; CX = ������=9��
	mov	ax, 1301h		 ; AH = 13h�����ܺţ���AL = 01h��������ڴ�β��
	mov	bx, 0007h		 ; ҳ��Ϊ0(BH = 0) �ڵװ���(BL = 07h)
      mov   dh, %3		 ; �к�=0
	mov	dl, %4	       ; �к�=0
	int	10h			 ; BIOS��10h���ܣ���ʾһ���ַ�
%endmacro

%macro install_int 2
      push es
      mov ax, 0
      mov es, ax
      mov word[es : %1*4], %2
      mov word[es : %1*4 +2], cs
      pop ax
      mov es, ax
%endmacro

%macro set_psp 1
      mov word[0xA000], 0xCD
      mov word[0xA000 + 2], 20h
      mov word[0xA00A], %1
      mov word[0xA00A + 2], cs
%endmacro

org  7c00h		; BIOS���������������ص�0:7C00h��������ʼִ��

jmp Start

Message:          db 'Welcome to HHOS ver1.01', 0dh, 0ah
MessageLength     equ   ($-Message)
Promot:           db 'shell>'
PromotLength      equ ($-Promot)
Input:            db 0
OffSetOfUserPrg1  equ 0xA100
panic_21h_msg     dw 'Currently only 4ch function of int 21h is implemented'
paini_21h_len     equ ($-panic_21h_msg)

Start:
    call cls
    print_string Message, MessageLength, 0, 0
    print_string Promot, PromotLength, 1, 0
    install_int 20h, interrupt_20h
    install_int 21h, interrupt_21h
WaitInput:
      mov   ah, 0
      int   16h
      sub   al, 0x30
      mov   byte[Input], al
      ;call save_cursor
LoadnEx:
     ;�����̻�Ӳ���ϵ����������������ڴ��ES:BX����
      mov ax,cs                ;�ε�ַ ; ������ݵ��ڴ����ַ
      mov es,ax                ;���öε�ַ������ֱ��mov es,�ε�ַ��
      mov bx, OffSetOfUserPrg1  ;ƫ�Ƶ�ַ; ������ݵ��ڴ�ƫ�Ƶ�ַ
      mov ah,2                 ; ���ܺ�
      mov al,2                 ;������
      mov dl,0                 ;�������� ; ����Ϊ0��Ӳ�̺�U��Ϊ80H
      mov dh,0                 ;��ͷ�� ; ��ʼ���Ϊ0
      mov ch,0                 ;����� ; ��ʼ���Ϊ0
      mov cl,byte[Input]       ;��ʼ������ ; ��ʼ���Ϊ1
      add cl, cl               
      add cl, 1                ;user1->3, user2->5, ... userN->2*N + 1
      int 13H ;                ���ö�����BIOS��13h����
      ; �û�����a.com�Ѽ��ص�ָ���ڴ�������
      set_psp AfterRun
      pusha
      jmp OffSetOfUserPrg1
AfterRun:
      popa
    jmp Start

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


interrupt_20h:
      mov ah, 4ch
interrupt_21h:
      cmp ah, 4ch
      jnz panic_21h_func_not_impl
      jmp dword[0xA00A]
      iret
panic_21h_func_not_impl:
      print_string panic_21h_msg, paini_21h_len, 0, 0
      jmp $

      times 510-($-$$) db 0
      db 0x55,0xaa

