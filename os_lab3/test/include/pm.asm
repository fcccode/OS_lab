%include "include/pm.inc"
org 0x7e00
jmp begin
label_gdt:          Descriptor                0,                     0, 0
label_desc_normal:  Descriptor                0,                0xffff, DA_DRW
label_desc_code32:  Descriptor     GDT_UNDEFINE,    seg_code32_len - 1, DA_C + DA_32
label_desc_code16:  Descriptor     GDT_UNDEFINE,                0xffff, DA_C
label_desc_data:    Descriptor     GDT_UNDEFINE,          data_len - 1, DA_DRW
label_desc_stack:   Descriptor     GDT_UNDEFINE,          top_of_stack, DA_DRWA + DA_32
label_desc_test:    Descriptor         0x500000,                0xffff, DA_DRW
label_desc_video:   Descriptor          0xB8000,                0xffff, DA_DRW

gdt_len     equ     $ - label_gdt
gdt_ptr     dw      gdt_len - 1
            dd      GDT_UNDEFINE

selector_normal     equ     label_desc_normal - label_gdt
selector_code32     equ     label_desc_code32 - label_gdt
selector_code16     equ     label_desc_code16 - label_gdt
selector_data       equ     label_desc_data   - label_gdt
selector_stack      equ     label_desc_stack  - label_gdt
selector_test       equ     label_desc_test   - label_gdt
selector_video      equ     label_desc_video  - label_gdt

data:
    sp_value_in_real_mode   dw      0
    pm_message:             dw      "In Protect Mode Now .", 0
    offset_pm_message       equ     pm_message - $$
    str_test:               db      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
    offset_str_test         equ     str_test - $$
    data_len                equ     $ - data

[BITS 32]
label_stack:
    times 512 db 0
top_of_stack                equ     $ - label_stack - 1

[BITS 16]
begin:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x0100

	mov	[label_go_back_to_real+3], ax
	mov	[sp_value_in_real_mode], sp

    ;初始化16位代码段描述符
    mov	ax, cs
	movzx eax, ax
	shl	eax, 4
	add	eax, label_seg_code16
	mov	word [label_desc_code16 + 2], ax
	shr	eax, 16
	mov	byte [label_desc_code16 + 4], al
	mov	byte [label_desc_code16 + 7], ah

    ;由于nasm的限制，只好在这里设置label_seg_code32
    xor eax, eax
    mov ax, cs
    ;cs * 10h + label_seg_code32
    shl eax, 4
    add eax, label_seg_code32
    ;+2存放低16位
    mov word [label_desc_code32 + 2], ax
    shr eax, 16
    ;+4存放17-24位
    mov byte [label_desc_code32 + 4], al
    ;+7存放25-32位
    mov byte [label_desc_code32 + 7], ah

	; 初始化数据段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, data
	mov	word [label_desc_data + 2], ax
	shr	eax, 16
	mov	byte [label_desc_data + 4], al
	mov	byte [label_desc_data + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, label_stack
	mov	word [label_desc_stack + 2], ax
	shr	eax, 16
	mov	byte [label_desc_stack + 4], al
	mov	byte [label_desc_stack + 7], ah

	; 为加载 gdtr 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, label_gdt		; eax <- gdt 基地址
	mov	dword [gdt_ptr + 2], eax	; [gdtptr + 2] <- gdt 基地址


    ;设置gdt_ptr指向label_gdt
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, label_gdt
    mov dword [gdt_ptr + 2], eax

    lgdt [gdt_ptr]
    cli
    in al, 92h
    or al, 00000010b
    out 92h, al
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp dword selector_code32:0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

label_real_entry:		; 从保护模式跳回到实模式就到了这里
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	sp, [sp_value_in_real_mode]

	in	al, 92h		; `.
	and	al, 11111101b	;  | 关闭 a20 地址线
	out	92h, al		; /

	sti			; 开中断

    jmp $

[bits	32]

label_seg_code32:
	mov	ax, selector_data
	mov	ds, ax			; 数据段选择子
	mov	ax, selector_test
	mov	es, ax			; 测试段选择子
	mov	ax, selector_video
	mov	gs, ax			; 视频段选择子
	mov	ax, selector_stack
	mov	ss, ax			; 堆栈段选择子

	mov	esp, top_of_stack


	; 下面显示一个字符串
	mov	ah, 0ch			; 0000: 黑底    1100: 红字
	xor	esi, esi
	xor	edi, edi
	mov	esi, offset_pm_message	; 源数据偏移
	mov	edi, (80 * 10 + 0) * 2	; 目的数据偏移。屏幕第 10 行, 第 0 列。
	cld
.1:
	lodsb
	test	al, al
	jz	.2
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1
.2:	; 显示完毕

	call	dispreturn
	call	testread
	call	testwrite
	call	testread

	; 到此停止
	jmp	selector_code16:0

; ------------------------------------------------------------------------
testread:
	xor	esi, esi
	mov	ecx, 8
.loop:
	mov	al, [es:esi]
	call	dispal
	inc	esi
	loop	.loop

	call	dispreturn

	ret
; testread 结束-----------------------------------------------------------


; ------------------------------------------------------------------------
testwrite:
	push	esi
	push	edi
	xor	esi, esi
	xor	edi, edi
	mov	esi, offset_str_test	; 源数据偏移
	cld
.1:
	lodsb
	test	al, al
	jz	.2
	mov	[es:edi], al
	inc	edi
	jmp	.1
.2:

	pop	edi
	pop	esi

	ret
; testwrite 结束----------------------------------------------------------


; ------------------------------------------------------------------------
; 显示 al 中的数字
; 默认地:
;	数字已经存在 al 中
;	edi 始终指向要显示的下一个字符的位置
; 被改变的寄存器:
;	ax, edi
; ------------------------------------------------------------------------
dispal:
	push	ecx
	push	edx

	mov	ah, 0ch			; 0000: 黑底    1100: 红字
	mov	dl, al
	shr	al, 4
	mov	ecx, 2
.begin:
	and	al, 01111b
	cmp	al, 9
	ja	.1
	add	al, '0'
	jmp	.2
.1:
	sub	al, 0ah
	add	al, 'a'
.2:
	mov	[gs:edi], ax
	add	edi, 2

	mov	al, dl
	loop	.begin
	add	edi, 2

	pop	edx
	pop	ecx

	ret
; dispal 结束-------------------------------------------------------------


; ------------------------------------------------------------------------
dispreturn:
	push	eax
	push	ebx
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0ffh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	ebx
	pop	eax

	ret
; dispreturn 结束---------------------------------------------------------

seg_code32_len	equ	$ - label_seg_code32


; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[bits	16]
label_seg_code16:
	; 跳回实模式:
	mov	ax, selector_normal
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	eax, cr0
	and	al, 11111110b
	mov	cr0, eax

label_go_back_to_real:
	jmp	0:label_real_entry	; 段地址会在程序开始处被设置成正确的值

seg_code16_len	equ	$ - label_seg_code16