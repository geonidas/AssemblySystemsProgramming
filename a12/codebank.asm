%macro	int2octal	2

	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	r8

;divide num by 8 loop
;push remainders onto stack

	mov eax, %1

	mov r14, %2
	mov r8, 0

	mov rdx, 0
	mov rcx, 0

;set sign
	mov byte [r14+r8], "+"
	cmp eax, 0
	jge %%posNum
	mov byte [r14+r8], "-"
	mov r9, -1
	imul r9d
%%posNum:
	inc r8

%%i2oLp:
	cmp rax, 0
	je %%exi2oLp

	mov ebx, 8
	cdq
	idiv ebx

	push rdx
	inc rcx
	jmp %%i2oLp

%%exi2oLp:

%%popLoop:
	pop rax
	add al, "0"
	mov byte [r14+r8], al
	inc r8
	loop %%popLoop

mov byte [r14+r8], NULL


	pop	r8
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

%endmacro