;	Giovanni Mueco
;	assignment 5
;   section 1001

; -----


; *****************************************************************

section	.data

; -----
;  Define standard constants

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

SYS_exit	equ	60			; call code for terminate

; -------------------------------------------------------------- 
;  Provided Data Set

sides		dw	 10,  14,  13,  37,  54 
		dw	 14,  29,  64,  67,  34 
		dw	 31,  13,  20,  61,  36 
		dw	 14,  53,  44,  19,  42 
		dw	 44,  52,  31,  42,  56 
		dw	 15,  24,  36,  75,  46 
		dw	 27,  41,  53,  62,  10 
		dw	 33,   4,  73,  31,  15 
		dw	  5,  11,  22,  33,  70 
		dw	 15,  23,  15,  63,  26 
		dw	 16,  13,  64,  53,  65 
		dw	 26,  12,  57,  67,  34 
		dw	 24,  33,  10,  61,  15 
		dw	 38,  73,  29,  17,  93 
		dw	 64,  73,  74,  23,  56 
		dw	  9,   8,   4,  10,  15 
		dw	 13,  23,  53,  67,  35 
		dw	 14,  34,  13,  71,  81 
		dw	 17,  14,  17,  25,  53 
		dw	 23,  73,  15,   6,  13 

length		dd	100 

caMin		dw	0 
caMid		dw	0 
caMax		dw	0 
caSum		dd	0 
caAve		dw	0 

cvMin		dd	0 
cvMid		dd	0 
cvMax		dd	0 
cvSum		dd	0 
cvAve		dd	0 

; -----
; Additional variables (if any)


; -------------------------------------------------------------- 
;  Uninitialized data 

section	.bss 

cubeAreas	resw	100 
cubeVolumes	resd	100 


; *****************************************************************

section	.text
global _start
_start:

; -----
;CODE STUFF

;insert areas & volumes

	mov rsi, 0
	mov rax, 0
	mov ecx, dword [length]

;after stats
	mov r10, sides
	mov r11, cubeVolumes
	mov r13, cubeAreas
	mov r14, 6

volsLp:
	movzx eax, word [r10]

	mov ebx, eax
	mul eax
	mul r14d
	mov word [r13], ax
	mov rdx, 0
	div r14d
	mul ebx
	mov dword [r11], eax
	add r10, 2
	add r11, 4
	add r13, 2
	loop volsLp

;get volume min max sum
	mov eax, dword [cubeVolumes]
	mov dword [cvMin], eax
	mov dword [cvMax], eax
	mov dword [cvSum], 0

	mov r12, cubeVolumes

;calc volume
	mov rcx, 0
	mov ecx, dword [length]

volStatsLp:
	mov eax, dword [r12]
	add dword[cvSum], eax
	cmp eax, dword [cvMax]
	jbe maxDone
	mov dword [cvMax], eax

maxDone:
	cmp eax, dword [cvMin]
	jae minDone
	mov dword [cvMin], eax

minDone:
	add r12, 4
	dec rcx
	cmp rcx, 0
	jne volStatsLp

;get area min max sum
	mov rax, 0
	mov ax, word [cubeAreas]
	mov word [caMin], ax
	mov word [caMax], ax
	mov dword [caSum], 0

	mov r12, cubeAreas

;calc volume
	mov rcx, 0
	mov ecx, dword [length]

areaStatsLp:
	mov ax, word [r12]
	add dword[caSum], eax
	cmp ax, word [caMax]
	jbe amaxDone
	mov word [caMax], ax

amaxDone:
	cmp ax, word [caMin]
	jae aminDone
	mov word [caMin], ax

aminDone:
	add r12, 2
	dec rcx
	cmp rcx, 0
	jne areaStatsLp

;find caAve
	mov eax, dword [caSum]
	mov edx, 0
	div dword [length]
	mov word [caAve], ax

;find cvAve
	mov eax, dword [cvSum]
	mov edx, 0
	div dword [length]
	mov dword [cvAve], eax


;find cvMid
	mov r8, 2
	mov rdx, 0
	mov eax, dword [length]
	div r8d

	cmp rdx, 0
	jne oddLen

;evenLen
	mov r9d, dword [cubeVolumes+eax*4]
	mov bx, word [cubeAreas+eax*2]
	dec eax
	add r9d, dword [cubeVolumes+eax*4]
	add bx, word [cubeAreas+eax*2]
	mov eax, r9d
	mov rdx, 0
	div r8d
	mov dword [cvMid], eax
	mov ax, bx
	mov rdx, 0
	div r8w
	mov word [caMid], ax
	jmp midDone

oddLen:
	inc eax
	mov r9d, dword [cubeVolumes+eax*4]
	mov dword [cvMid], r9d
	mov bx, word [cubeAreas+eax*2]
	mov word [caMid], bx

midDone:

;find caMid
;	mov r8, 2
;	mov rdx, 0
;	mov eax, dword [length]
;	div r8d

;	cmp rdx, 0
;	jne aOddLen

;aEvenLen
	
;	dec ax
	
	
;	jmp aMidDone

;aOddLen:
;	inc ax
	
	

;aMidDone:





; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS
	syscall