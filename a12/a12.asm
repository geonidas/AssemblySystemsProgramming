; Giovanni Mueco
; Section 1001
; CS 218
; Assignment #12
; Threading program, provided template

; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	-1

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

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

; -----
;  Message strings

header		db	"*******************************************", LF
		db	ESC, "[1m", "Primes Program", ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Prime Count", LF, NULL
msgDoneMain	db	"Prime Count: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

primeLimit	dq	10000			; array size
isSequential	db	TRUE			; bool

; -----
;  Globals (used by threads)

iCounter	dq	0
primeCount	dq	0

myLock		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0

; -----
;  Variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Variables for getParams function

LIMITMIN	equ	1000
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./primes <-s|-p> ",
		db	"-l <ocatlNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errSSpec	db	"Error, invalid sequential/parallel specifier."
		db	LF, NULL
errPLSpec	db	"Error, invalid prime limit specifier."
		db	LF, NULL
errPLValue	db	"Error, prime out of range."
		db	LF, NULL
argsChk db	"-s"
argpChk db  "-p"
arglChk db  "-l"
withinRange db TRUE
; -----
;  Variables for int2octal function

ddEight		dd	8
tmpNum		dd	0

; -----

section	.bss

tmpString	resb	20


; ***************************************************************

section	.text

; -----
; External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Prime number counting program.

global main
main:
	push	rbp
	mov	rbp, rsp

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, isSequential
	mov	rcx, primeLimit
	call	getParams

	cmp	rax, TRUE
	jne	progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

;  Create new thread(s)
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);
;  if sequntial, start 1 thread
;  if parallel, start 3 threads


;	YOUR CODE GOES HERE
	mov 	rdi, pthreadID0
	mov 	rsi, NULL
	mov 	rdx, primeCounter
	mov 	rcx, NULL
	call pthread_create

	cmp byte[isSequential], TRUE 
	je skipParallel

	mov 	rdi, pthreadID1
	mov 	rsi, NULL
	mov 	rdx, primeCounter
	mov 	rcx, NULL
	call pthread_create

	mov 	rdi, pthreadID2
	mov 	rsi, NULL
	mov 	rdx, primeCounter
	mov 	rcx, NULL
	call pthread_create


	skipParallel: 


;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);


;	YOUR CODE GOES HERE
	 mov 	rdi, qword[pthreadID0]
	 mov 	rsi, NULL 
	 call 	pthread_join

	cmp byte[isSequential], TRUE 
	je skipParallelJoin

	 mov 	rdi, qword[pthreadID1]
	 mov 	rsi, NULL 
	 call 	pthread_join

	 mov 	rdi, qword[pthreadID2]
	 mov 	rsi, NULL 
	 call 	pthread_join
	skipParallelJoin:
; -----
;  Display final count

showFinalResults:
	mov	rdi, msgDoneMain
	call	printString

	mov	rdi, qword [primeCount]
	mov	rsi, tmpString
	call	intToOctal

	mov	rdi, tmpString
	call	printString

	mov	rdi, newLine
	call	printString

; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	mov	rax, SYS_exit			; system call for exit
	mov	rdi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, primeCounter()
;	Detemrine which numbers between 1 and
;	primeLimit (gloabally available) are prime.

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)

global primeCounter
primeCounter:

;	YOUR CODE GOES HERE
	push rdi
	push r8
	push r10
	push rax
	;print starting message
	mov 	rdi, msgThread1
	call printString 

	mov 	r8, qword[primeLimit]
	mov 	r10, 0	;i counter

pCountLp:
	cmp 	r10, r8
	je pCountLpEnd
	mov 	rdi, r10
	call isPrime
	cmp rax, TRUE 
	jne skipPrimeCount
	 	inc qword[primeCount]
skipPrimeCount:
	inc 	r10
	jmp pCountLp
pCountLpEnd:

	pop rax
	pop r10
	pop r8
	pop rdi
	
	ret 
;;;;;;;;;091830481-02sdhjofhsiopdfqijwrjqwljp0r2389uoiqjweoirjo3;1
;;;jalkjdfjoiu983u24jlsejr88708213u4(*&)(*YHIOUH(*YU@HOPIEJOI))
;)*(#(*JHF*J)@@_E_@J!))J)E*#*U)*R$&Y&*Y%*&^^&%HIEI&#E^@(@)EW*YH&#$(YE)!@UE&#Y



; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Check if a passed number is prime.
;	note, uses iSqrt() function for integer square root approximation

;  Arguments:
;	number (value)
;  Returns:
;	TRUE/FALSE

global	isPrime
isPrime:

;	YOUR CODE GOES HERE
	push 	r10 	;holds num
	mov 	r10, 0 
	mov 	r10, rdi
	push 	rdi
	push 	rbx
	push 	rdx
	push 	r8
	push 	r9

	cmp 	r10, 2
	jb noPrime
	cmp 	r10, 2
	je 	yesPrime 
	mov 	rdx, 0
	mov 	rax, r10
	mov 	rbx, 2
	div 	ebx
	cmp 	rdx, 0
	ja noPrime
	mov 	rdi, r10
	call iSqrt 
	mov 	r8, 0
	mov 	r8d, eax
	mov 	r9, 3
	oddLp:
		cmp 	r9, r8
		ja yesPrime 
		mov 	rdx, 0
		mov 	rax, r10
		div 	r9
		cmp 	rdx, 0
		je noPrime
		add 	r9, 2
		jmp oddLp 

	yesPrime:
	mov 	rax, TRUE 
	jmp isPrimeEnd
	noPrime:
	mov 	rax, FALSE 
	isPrimeEnd:

	pop 	r9
	pop 	r8
	pop 	rdx
	pop 	rbx
	pop 	rdi
	pop 	r10

	ret 

; ******************************************************************
;  Function to calculate and return an integer estimate of
;  the square root of a given number.

;  To estimate the square root of a number, use the following
;  algorithm:
;	sqrt_est = number
;	iterate 50 times
;		sqrt_est = ((number/sqrt_est)+sqrt_est)/2

; -----
;  Call:
;	ans = iSqrt(number)

;  Arguments Passed:
;	1) number, value - rdi

;  Returns:
;	square root value (in eax)


global	iSqrt
iSqrt:

	push 	r10
	push 	r11
	push 	rbx
;	YOUR CODE GOES HERE
	mov  	r10d, 0
	mov 	r11d, edi
sqrtLp:
	cmp 	r10, 50
	je sqrtLpEnd
	mov 	rdx, 0
	mov 	eax, edi
	mov 	ebx, r11d
	div 	ebx
	mov 	rdx, 0
	add 	eax, r11d
	mov 	ebx, 2
	div 	ebx
	mov 	r11d, eax
	inc 	r10
	jmp sqrtLp
sqrtLpEnd:

	mov 	rax, 0
	mov 	eax, r11d
	;inc  eax

	pop 	rbx
	pop 	r11
	pop 	r10

ret



; ******************************************************************
;  Convert integer to ASCII/Octal string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value
;	2) string, address
; -----
;  Returns:
;	ASCII/Octal string (NULL terminated)

global	intToOctal
intToOctal:

;	YOUR CODE GOES HERE
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	r8

;divide num by 8 loop
;push remainders onto stack

	mov rax, rdi

	mov r14, rsi
	mov r8, 0

	mov rdx, 0
	mov rcx, 0

i2oLp:
	cmp rax, 0
	je exi2oLp

	mov rbx, 8
	mov rdx, 0
	div rbx

	push rdx
	inc rcx
	jmp i2oLp

exi2oLp:

popLoop:
	cmp rcx, 0
	je popLoopEnd
	pop rax
	add al, "0"
	mov byte [r14+r8], al
	inc r8
	dec rcx
	jmp popLoop 
popLoopEnd:

mov byte [r14+r8], NULL


	pop	r8
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

ret 

; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
; Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************
;  Function getParams()
;	Get, check, convert, verify range, and return the
;	thread count and prime limit.

;  Example HLL call:
;	stat = getParams(argc, argv, &isSequntial, &primeLimit)

;  This routine performs all error checking, conversion of ASCII/Vegismal
;  to integer, verifies legal range of each value.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	<-s|-p> -l <vegismalNumber>

; -----
;  Arguments:
;	1) ARGC, value
;	2) ARGV, address
;	3) sequential(bool), address
;	4) prime limit (dword), address

global getParams
getParams:

;	YOUR CODE GOES HERE

	push 	rbx 	 ;used for a given string from argv
	push 	r9		 ;used to increment through strings
	push 	r10
	mov 	r10, rdi ; set argc
	push 	rdi
	push 	r11
	mov 	r11, rsi ;set argv ADDRESS
	push 	rsi
	push 	r12
	mov 	r12, rdx ; set isSequential ADDRESS
	push 	rdx
	push 	r13
	mov 	r13, rcx ; set primeLimit ADDRESS
	push 	rcx
	push 	r14 	 ; holds a char
	push 	r15

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;ARG ERROR CHECKING
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

;if argc == 1
;usage error check

	cmp r10, 1
	jne usageMsgDone
	mov rdi, errUsage
	call printString
	jmp termArg
	usageMsgDone:

;if argc > 3
;many error check

; 	cmp r10, 3
; 	jbe manyChkDone
; 	mov rdi, errOptions
; 	call printString
; 	jmp termArg 
; 	manyChkDone:

; ;if argc < 3
; ;few error check

; 	cmp r10, 3
; 	jae fewChkDone
; 	mov rdi, errOptions 
; 	call printString
; 	jmp termArg 
; 	fewChkDone:

	cmp r10, 4
	je fewChkDone
	mov rdi, errOptions 
	call printString
	jmp termArg 
	fewChkDone:

;erorr check for "-s" or "-p"
	mov 	r15, 1   ;rcx as an index for argv
	mov 	r9, 0
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-s" for success

arg2Lp:
	cmp 	byte[rbx+r9], NULL ;ends loop when we hit null
	je 	arg2LpEnd
	
	mov 	r14b, byte[argsChk+r9] ;takes char from string variable containing "-s"
	cmp 	byte [rbx+r9], r14b
	je skipP

	mov 	r14b, byte[argpChk+r9] ;checks for "p"
	cmp 	byte [rbx+r9], r14b
	jne 	arg2err
	mov 	qword[r12], FALSE
	
skipP:
	inc 	r9
	jmp arg2Lp
arg2LpEnd:
	cmp 	r9, 2
	jne 	arg2err
	jmp arg2ChkEnd
arg2err:
	mov 	rdi, errSSpec
	call 	printString
	jmp termArg 	;terminate program
arg2ChkEnd:

;error check for "-l"

	inc 	r15		;r15 = 2
	mov 	r9, 0 	;reset r9 to 0 to loop through arg4 string
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-l" for success

arg3Lp:
	cmp 	byte[rbx+r9], NULL ;ends loop when we hit null
	je 	arg3LpEnd
	
	mov 	r14b, byte[arglChk+r9] ;takes char from string variable containing "-l"
	cmp 	byte [rbx+r9], r14b
	jne 	arg3err
	
	inc 	r9
	jmp arg3Lp
arg3LpEnd:
	cmp 	r9, 2
	jne 	arg3err
	jmp arg3ChkEnd
arg3err:
	mov 	rdi, errPLSpec
	call 	printString
	jmp termArg 	;terminate program
arg3ChkEnd:

;error check for prime range
;; needs new algorithm
	inc 	r15		;r15 = 3
	mov 	r9, 0 	;reset r9 to 0 to loop through arg4 string
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-l" for success

	mov 	rdi, rbx
	mov 	rsi, withinRange
	call octChk 
	cmp 	byte[withinRange], FALSE
	je limitErr 
	;mov 	rsi, tmpNum
	mov 	rdi, rbx
	mov 	rsi, primeLimit
	call octal2int
	cmp 	qword[primeLimit], LIMITMAX 
	ja limitErr
	cmp 	qword[primeLimit], LIMITMIN 
	jb limitErr
	jmp skipLimitErr
limitErr:
	mov 	rdi, errPLSpec
	call 	printString
	jmp termArg 	;terminate program
skipLimitErr:
	
	mov rax, TRUE 

	jmp skipTermArg
;ends the program if error is found
termArg:
	; mov rax, SYS_exit
	; mov rdi, NOSUCCESS 
	; syscall
	mov rax, FALSE 
skipTermArg:
	

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;ARG END OF ERROR CHECKING
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

	pop 	r15
	pop 	r14
	pop 	rcx
	pop 	r13
	pop 	rdx
	pop 	r12
	pop 	rsi
	pop 	r11
	pop 	rdi
	pop 	r10
	pop 	r9
	pop 	rbx

ret

; ******************************************************************
;  Function: Check and convert ASCII/octal to integer
;	return false 

;  Example HLL Call:
;	stat = octal2int(vStr, &num);

global	octal2int
octal2int:

;	YOUR CODE GOES HERE
	push	rax
	push	rcx
	push	r8
	;push	rdi ;vStr
	push 	r10
	push 	r11 ;octal string
	push 	r12
	push 	r13
	push 	r14

	;mov 	r11, %1
	mov 	r8, 1
	mov  	r10, 0
	mov 	r12, 0
octLp:
	cmp  byte[rdi+r10], NULL
	je octLpEnd
	mov 	rax, 0 
	mov 	 al, byte[rdi+r10]
	sub 	 al, "0"
	push 	rax
	inc 	r10
	jmp octLp
octLpEnd:
	

	mov 	r13, 0
calcLp:
	cmp 	r13, r10
	je calcLpEnd
	push 	r13
	mov 	rax, 8
	mov 	rbx, 8
	cmp 	r13, 0
	je powSkip
	powLp:
		cmp 	r13, 1
		je powLpEnd
		mul 	rbx
		sub 	r13, 1
		jmp powLp 
	powSkip:
		mov 	rax, 1
	powLpEnd:
	pop 	r13
	pop 	r14
	mul 	r14
	add 	r12, rax
	inc 	r13
	jmp 	calcLp
calcLpEnd:

	mov 	rax, r8
	imul 	r12d
	mov 	dword[rsi], eax

	pop 	r14
	pop 	r13
	pop 	r12
	pop 	r11
	pop 	r10
	;pop 	rdi
	pop 	r8
	pop 	rcx
	pop 	rax

ret


; ******************************************************************
; function that checks if a string contains non-octal values
global octChk
octChk:
	push	r10 ;counter
	mov 	r10, 0 ;counter
	octChkLp:
		cmp 	byte[rdi+r10], NULL
		je octChkLpEnd
		cmp 	byte[rdi+r10], "0"
		jb setFalse 
		cmp 	byte[rdi+r10], "7"
		ja setFalse 

		inc r10
		jmp octChkLp 

		setFalse:
			mov byte[rsi], FALSE 
	octChkLpEnd:

	pop 	r10

ret
