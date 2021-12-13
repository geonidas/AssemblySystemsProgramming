;  Giovanni Mueco
;  CS 218, Assignment #6
;  Section 1001

;  Write a simple assembly language program to convert integers
;  to ASCII charatcers and output the ASCII strings to the screen
;  (using the provided routine).

; --------------------------------------------------------------
;  STEP #3
;  Macro, "octal2int", to convert a signed octal/ASCII string
;  into an integer.  The macro reads the octal/ASCII string (byte-size,
;  signed, NULL terminated) and converts to a doubleword sized integer.
;  Assumes valid/correct data.  As such, no error checking is performed.

;  Example:  given the ASCII string: "+123", NULL
;  (+ sign, "1", followed by "2",  followed by "3", and NULL)
;  would be converted to integer 83.

;  Note, the string address is passed in %1 (first argument), which
;  must not be altered until the address is used.

;  Note, should preserve any registers that the macro alters
;  by pushing and, when done, poping.  The registers pushed/poped
;  below may need to be updated based on the actual code.

; -----
;  Arguments
;	%1 -> string address (reg)
;	%2 -> integer number (reg)


%macro	octal2int	2
	push	rax
	push	rcx
	push	r8
	push	rdi ; neg
	push 	r10
	push 	r11 ;octal string
	push 	r12
	push 	r13
	push 	r14
	push 	r15
	;mov 	r11, %1
	mov 	r8, 1
;check sign
	mov 	r10, 0
	cmp 	byte[%1+r10], "+"
	je 		%%isPos
	mov 	r8, -1
	%%isPos:

	inc 	r10
	mov 	r12, 0
%%octLp:
	cmp  byte[%1+r10], NULL
	je %%octLpEnd
	mov 	rax, 0 
	mov 	 al, byte[%1+r10]
	sub 	 al, "0"
	push 	rax
	inc 	r10
	jmp %%octLp
%%octLpEnd:
	
	mov 	r15, r10
	dec 	r15
	mov 	r13, 0
%%calcLp:
	cmp 	r13, r15
	je %%calcLpEnd
	push 	r13
	mov 	rax, 8
	mov 	rbx, 8
	cmp 	r13, 0
	je %%powSkip
	%%powLp:
		cmp 	r13, 1
		je %%powLpEnd
		mul 	rbx
		sub 	r13, 1
		jmp %%powLp 
	%%powSkip:
		mov 	rax, 1
	%%powLpEnd:
	pop 	r13
	pop 	r14
	mul 	r14
	add 	r12, rax
	inc 	r13
	jmp 	%%calcLp
%%calcLpEnd:

	mov 	rax, r8
	imul 	r12d
	mov 	dword[%2], eax

	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	r11
	pop 	r10
	pop 	rdi
	pop 	r8
	pop 	rcx
	pop 	rax
%endmacro


; --------------------------------------------------------------
;  STEP #4
;  Macro, "int2octal", to convert a signed base-10 integer into
;  an octal/ASCII string representing the octal value.  The macro stores
;  the result into an ASCII string (byte-size, right justified,
;  blank filled, NULL terminated).  Each integer is a doubleword value.
;  Assumes valid/correct data.  As such, no error checking is performed.

;  Example:  Since, 11 (base 10) is 13 (base 8), then the integer 8
;  would be converted to ASCII resulting in: "      +13", NULL
;  (6 spaces, + sign, and "1" followed by "3", and NULL).

;  To access the value, copy into a register.  For example:
;	mov	eax, %1

;  Note, should preserve any registers that the macro alters
;  by pushing and, when done, poping.  The registers pushed/poped
;  below may need to be updated based on the actual code.

; -----
;  Arguments
;	%1 -> integer number
;	%2 -> string address


%macro	int2octal	2
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

;divide num by 8 loop
;push remainders onto stack

	mov eax, %1

	mov r14, %2
	mov rdi, 0

	mov rdx, 0
	mov rcx, 0

;set sign
	mov byte [r14+rdi], "+"
	cmp eax, 0
	jge %%posNum
	mov byte [r14+rdi], "-"
	mov r9, -1
	imul r9d
%%posNum:
	inc rdi

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
	mov byte [r14+rdi], al
	inc rdi
	loop %%popLoop

mov byte [r14+rdi], NULL


	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
%endmacro


; --------------------------------------------------------------
;  Simple macro to display a string.
;	Call:	printString  <stringAddress>

;	Arguments:
;		%1 -> <string>, string address

;  Algorithm:
;	Count characters (excluding NULL).
;	Use system service to display string at address <string>

%macro	printString	1
	push	rax			; save altered registers
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	mov	rdx, 0
	mov	rdi, %1
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	mov	rsi, %1			; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro


; --------------------------------------------------------------
;  Simple to skip forward to next string in an array of NULL
;  terminated strings.

;	Call:	nextString  <string>
;	Arguments:
;		%1 -> string address (reg)
;  Note, changes passed register

%macro	nextString	1

%%skpForward:
	cmp	byte [%1], NULL
	je	%%nextStringDone
	inc	%1
	jmp	%%skpForward

%%nextStringDone:
	inc	%1

%endmacro


; --------------------------------------------------------------

section	.data

; -----
;  Define standard constants

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
NULL		equ	0
ESC		equ	27

; -----
;  Misc. constants

MAX_STR_SIZE	equ	10
NUMS_PER_LINE	equ	5

newLine		db	LF, NULL

; -----
;  Header string definitions.

hdr1		db	LF, "**********************************"
		db	LF, "CS 218 - Assignment #6", LF
		db	LF, LF, NULL
hdr2		db	LF, LF, "----------------------"
		db	LF, "List Stats"
		db	LF, NULL

firstNum	db	"First Number: ", NULL
firstNumPlus	db	"First Number (*2): ", NULL

lstSum		db	LF, "List Sum:"
		db	LF, NULL
lstAve		db	LF, "List Average:"
		db	LF, NULL

; -----
;  Misc. data definitions (if any).

weight		dd	8

; -----
;  Assignment #6 Provided Data:

oNum1		db	"+12345", NULL
iNum1		dd	0

oLst1		db	   "+17", NULL,   "-347", NULL,  "+6747", NULL, "-12375", NULL
len1		dd	4
sum1		dd	0
ave1		dd	0

oLst2		db	   "+32", NULL, "-16740", NULL, "+10300", NULL, "-25000", NULL
		db	"+11000", NULL, "-14321", NULL, "+22432", NULL, "-11010", NULL
		db	"-11201", NULL,   "+312", NULL,     "-7", NULL ,   "-16", NULL
		db	  "-731", NULL,  "-5173", NULL, "-10345", NULL, "-15557", NULL
		db	 "+2360", NULL, "-13230", NULL, "+21234", NULL, "+11111", NULL
		db	 "+1725", NULL,  "-6312", NULL,   "+420", NULL,  "-5532", NULL
len2		dd	24
sum2		dd	0
ave2		dd	0

oLst3		db	"+12627", NULL, "-11622", NULL, "+15110", NULL, "+10667", NULL
		db	"+26516", NULL,  "-5112", NULL,   "+152", NULL, "+21344", NULL
		db	  "+134", NULL,  "+7206", NULL, "+24112", NULL,  "+1231", NULL
		db	 "+7765", NULL, "-17312", NULL,   "+312", NULL,   "+704", NULL
		db	"-12344", NULL,	"+27111", NULL,     "+7", NULL,     "-6", NULL
		db	"-11512", NULL,  "+7552", NULL, "+11344", NULL, "+10134", NULL
		db	 "-7164", NULL,   "+471", NULL,  "-2344", NULL,   "-214", NULL
		db	"-11212", NULL, "+11115", NULL,	 "-1265", NULL, "-22130", NULL
		db	   "+75", NULL, "+23311", NULL
len3		dd	34
sum3		dd	0
ave3		dd	0

oLst4		db	 "+7164", NULL,  "+1067", NULL, "+11721", NULL, "+21000", NULL
		db	 "-2174", NULL,  "-2127", NULL, "-23212", NULL,   "+117", NULL
		db	"-20163", NULL, "+12112", NULL, "+11345", NULL, "+11064", NULL
		db	"+11721", NULL, "+26000", NULL, "-23575", NULL, "+13725", NULL
		db	 "+3110", NULL,   "-120", NULL, "+13332", NULL, "+10022", NULL
		db	 "-7560", NULL, "+12313", NULL, "+11760", NULL,  "+4312", NULL
		db	"+17465", NULL, "+23241", NULL, "-27431", NULL,   "-730", NULL
		db	 "+4313", NULL, "+30233", NULL, "+13657", NULL, "-31113", NULL
		db	 "+1661", NULL, "+11312", NULL, "+17555", NULL, "-12241", NULL
		db	"+13231", NULL,  "+3270", NULL,  "-7653", NULL, "+15127", NULL
len4		dd	40
sum4		dd	0
ave4		dd	0

; --------------------------------------------------------------

section	.bss

num1String	resb	MAX_STR_SIZE
tempString	resb	MAX_STR_SIZE
tempNum		resd	1


; --------------------------------------------------------------

section	.text
global	_start
_start:

; ******************************
;  Main program
;	display headers
;	calls the macro on various data items
;	display results to screen (via provided macro's)

;  Note, since the print macros do NOT perform an error checking,
;  	if the conversion macros do not work correctly,
;	the print string will not work!

;  Debugging Tip:
;	Since macro's can be difficult to debug, can write the code
;	and place it in the main (below) where each macro call is.
;	After the code is debugged and working, can copy it into
;	the macro (making the appropriate adjustments for the labels
;	and arguments).

; ******************************
;  Prints some cute headers...

	printString	hdr1
	printString	firstNum
	printString	oNum1
	printString	newLine

; -----
;  STEP #1
;  Convert ASCII octal NULL terminated string at 'oNum1' (esi)
;	into an integer which is placed into 'iNum1'

	mov	rsi, oNum1
	octal2int	rsi, iNum1


; 	push	rax
; 	push	rcx
; 	push	r8
; 	push	rdi ; neg
; 	push 	r10
; 	push 	r11 ;octal string
; 	push 	r12
; 	push 	r13
; 	push 	r14
; 	push 	r15
; 	;mov 	r11, %1
; 	mov 	r8, 1
; ;check sign
; 	mov 	r10, 0
; 	cmp 	byte[oNum1+r10], "+"
; 	je 		isPos
; 	mov 	r8, -1
; 	isPos:

; 	inc 	r10
; 	mov 	r12, 0
; octLp:
; 	cmp  byte[oNum1+r10], NULL
; 	je octLpEnd
; 	mov 	rax, 0 
; 	mov 	 al, byte[oNum1+r10]
; 	sub 	 al, "0"
; 	push 	rax
; 	inc 	r10
; 	jmp octLp
; octLpEnd:
	
; 	mov 	r15, r10
; 	dec 	r15
; 	mov 	r13, 0
; calcLp:
; 	cmp 	r13, r15
; 	je calcLpEnd
; 	push 	r13
; 	mov 	rax, 8
; 	mov 	rbx, 8
; 	cmp 	r13, 0
; 	je powSkip
; 	powLp:
; 		cmp 	r13, 1
; 		je powLpEnd
; 		mul 	rbx
; 		sub 	r13, 1
; 		jmp powLp 
; 	powSkip:
; 		mov 	rax, 1
; 	powLpEnd:
; 	pop 	r13
; 	pop 	r14
; 	mul 	r14
; 	add 	r12, rax
; 	inc 	r13
; 	jmp 	calcLp
; calcLpEnd:

; 	mov 	rax, r8
; 	imul 	r12d
; 	mov 	dword[iNum1], eax

; 	pop 	r15
; 	pop 	r14
; 	pop 	r13
; 	pop 	r12
; 	pop 	r11
; 	pop 	r10
; 	pop 	rdi
; 	pop 	r8
; 	pop 	rcx
; 	pop 	rax



; -----
;  Perform simple *2 operation

	mov	eax, dword [iNum1]
	mov	ebx, 2
	imul	ebx

; -----
;  STEP #2
;  Convert the double-word integer (in eax) into a string which
;	will be stored into the 'num1String'

	int2octal	eax, num1String

; -----
;  Display a simple header and then the ASCII/octal string.

	printString	firstNumPlus
	printString	num1String


; ******************************
;  Next, repeatedly call the macro on each value in an array.

; -----
;  Data Set #1

	printString	hdr2

	mov	ecx, dword [len1]		; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, oLst1			; address of string

cvtLoop1:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum1], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop1

	int2octal	dword [sum1], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum1]
	cdq
	idiv	dword [len1]
	mov	dword [ave1], eax
	int2octal	dword [ave1], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

; -----
;  Data Set #2

	printString	hdr2

	mov	ecx, [len2]			; length
	mov	rsi, 0				; starting index of integer list
	mov	rdi, oLst2			; address of string

cvtLoop2:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum2], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop2

	int2octal	dword [sum2], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum2]
	cdq
	idiv	dword [len2]
	mov	dword [ave2], eax
	int2octal	dword [ave2], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

; -----
;  Data Set #3

	printString	hdr2

	mov	ecx, [len3]			; length
	mov	esi, 0				; starting index of integer list
	mov	edi, oLst3			; address of string

cvtLoop3:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum3], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop3

	int2octal	dword [sum3], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum3]
	cdq
	idiv	dword [len3]
	mov	dword [ave3], eax
	int2octal	dword [ave3], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

; -----
;  Data Set #4

	printString	hdr2

	mov	ecx, [len4]			; length
	mov	esi, 0				; starting index of integer list
	mov	edi, oLst4			; address of string

cvtLoop4:
	push	rcx
	push	rdi

	octal2int	rdi, tempNum

	mov	eax, dword [tempNum]
	add	dword [sum4], eax

	pop	rdi
	nextString	edi			; update addr to next string

	pop	rcx
	dec	rcx				; check length
	cmp	rcx, 0
	ja	cvtLoop4

	int2octal	dword [sum4], tempString	; convert integer (eax) into octal string

	printString	lstSum			; display header string
	printString	tempString		; print string
	printString	newLine

	mov	eax, [sum4]
	cdq
	idiv	dword [len4]
	mov	dword [ave4], eax
	int2octal	dword [ave4], tempString	; convert integer (eax) into octal string

	printString	lstAve			; display header string
	printString	tempString		; print string

	printString	newLine
	printString	newLine

; ******************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit			; call code for exit (sys_exit)
	mov	rdi, EXIT_SUCCESS
	syscall

