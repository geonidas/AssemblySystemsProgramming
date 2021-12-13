;  CS 218 - Assignment 8
;  Functions Template.

; --------------------------------------------------------------------
;  Write assembly language procedures/functions.

;  * Void function, bubbleSort(), sorts the numbers into descending
;    order (large to small).  Uses the bubble sort algorithm from
;    assignment #7 (modified to sort in descending order).

;  * Void function, cubeAreas(), to calculate the area of each cube
;    in a series of cube sides.

;  * Void function, cubeStats(), that given an array of integer
;    cube areas, finds the minimum, maximum, sum, integer average,
;    sum of numbers evenly divisible by 3.

;  * Integer function, iMedian(), to compute and return the integer
;    median for a list of numbers. Note, for an odd number of items,
;    the median value is defined as the middle value.  For an even
;    number of values, it is the integer average of the two middle
;    values. A 32-bit integer function returns the result in eax.

;  * Integer function, eStatistic(), to compute the m-statistic for
;    a list of numbers.

;  Note, all data is signed!

; ********************************************************************************

section	.data

; -----
;  Define standard constants.

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
;  Variables for bubbleSort() void function (if any)


; -----
;  Variables for cubeAreas() void function (if any)


; -----
;  Variables for cubeStats() void function (if any)


; -----
;  Variables for integer iMedian() function (if any)


; -----
;  Variables for integer eStatistic() function (if any)



; **************************************************************************

section	.text

; **************************************************************************
;  Function to calculate cube areas
;	cubeAreas[i] = 6 ∗ sides[i]^2

; -----
;  Call:
;	cubeAreas(cSides, len, cAreas);

;  Arguments Passed:
;	1) cube sides array, addr = rdi
;	2) length, value = esi
;	3) cube areas array, addr = rdx

;  Returns:
;	cAreas[] via reference

global cubeAreas
cubeAreas:


;	YOUR CODE GOES HERE
	push r12
	mov r12, rdx
	push rdx

	mov r11, 0
	mov r10, 6
areaCalcLp:
	cmp r11d, esi
	je areaCalcDone
	mov eax, dword [rdi+r11*4]
	mul eax
	mul r10d
	mov dword [r12+r11*4], eax
	inc r11
	jmp areaCalcLp
areaCalcDone:

	pop rdx
	pop r12
	ret

; **************************************************************************
;  Function to implement bubble sort to sort an integer array.
;	Note, sorts in desending order

; -----
;  HLL Call:
;	bubbleSort(list, len);

;  Arguments Passed:
;	1) list, addr =rdi
;	2) length, value =esi

;  Returns:
;	sorted list (list passed by reference)

global	bubbleSort
bubbleSort:


;	YOUR CODE GOES HERE
	push r10
	push r13
	push rcx
	push rbx
	push r14
	mov r10, 0
	mov r10d, esi
	push rsi

;bubbleSort

	;mov r10, 0
	;mov r10d, dword [len] ;r10 = i(len)
outerLp:
	cmp r10, 0
	je outerLpEnd

	mov r14b, FALSE
	mov rcx, 0	;rcx = j
	mov r13, r10
	dec r13		;r13 = i-1
innerLp:
	cmp rcx, r13
	je innerLpEnd
	mov eax, dword [rdi+rcx*4]	;eax = lst[j](also tmp)
	mov rsi, rcx
	inc rsi 	;rsi = j+1
	mov ebx, dword [rdi+rsi*4] 	;ebx=lst[j+1]
	cmp eax, ebx
	jge skipSwap
	mov dword [rdi+rcx*4], ebx
	mov dword [rdi+rsi*4], eax
	mov r14b, TRUE
skipSwap:
	inc rcx
	jmp innerLp
innerLpEnd:
	dec r10
	jmp outerLp
outerLpEnd:

	pop rsi
	pop r14
	pop rbx
	pop rcx
	pop r13
	pop r10

	ret

; **************************************************************************
;  Function to find some statistical information of an integer array:
;	minimum, median, maximum, sum, average, sum of numbers
;	evenly diviside by 3
;  Note, you may assume the list is already sorted.

; -----
;  HLL Call:
;	cubeStats(list, len, min, max, sum, ave, threeSum);

;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) minimum, addr
;	4) maximum, addr
;	5) sum, addr
;	6) average, addr
;	7) threeSum, addr

;  Returns:
;	minimum, maximum, sum, average, amd
;	three sum via pass-by-reference

global cubeStats
cubeStats:


;	YOUR CODE GOES HERE
	push rbp
	mov rbp, rsp
	push rbx
	push r11
	mov r11, rcx
	push rcx
	push r12
	mov r12, r9
	push r9
	push r13
	mov r13, r8
	push r8
	push r10
	mov r10, rdx
	push rdx
	push r14
	push r15
	


	mov eax, dword [rdi] ;dword [lst]
	mov dword [r10], eax
	mov dword [r11], eax
	mov dword [r13], 0
	mov rbx, rdi
	mov rcx, 0
	mov ecx, esi
	mov r14, 0 ;threeCnt
	mov r15, qword [rbp+16]
calcLp:
	mov eax, dword [rbx]
	add dword [r13], eax
	cmp eax, dword[r10]
	jge minDone
	mov dword[r10], eax

minDone:
	cmp eax, dword [r11]
	jle maxDone
	mov dword [r11], eax

maxDone:

	mov r9, rax
	mov r8, 3
	cdq
	idiv r8d
	cmp edx, 0
	jne threeDone
	inc r14 ;dword [threeCnt]
	add dword [r15], r9d

threeDone:
	add rbx, 4
	dec rcx
	cmp rcx, 0
	jne calcLp

;find ave
	mov eax, dword [r13]
	mov rdx, 0
	div esi
	mov dword [r12], eax

	pop r15
	pop r14
	pop rdx
	pop r10
	pop r8
	pop r13
	pop r9
	pop r12
	pop rcx
	pop r11
	pop rbx
	pop rbp

	ret

; **************************************************************************
;  Function to calculate the integer median of an integer array.
;	Note, for an odd number of items, the median value is defined as
;	the middle value.  For an even number of values, it is the integer
;	average of the two middle values.

; -----
;  HLL Call:
;	med = iMedian(list, len);

;  Arguments Passed:
;	1) list, addr - 8
;	2) length, value - 12

;  Returns:
;	integer median - value (in eax)

global iMedian
iMedian:


;	YOUR CODE GOES HERE


;find mid
	mov r8, 2
	mov rdx, 0
	mov rax, 0
	mov eax, esi
	div r8d

	cmp rdx, 0
	jne oddLen

;evenLen
	mov r9d, dword [rdi+rax*4]
	dec rax
	add r9d, dword [rdi+rax*4]
	mov eax, r9d
	cdq
	idiv r8d
	jmp midDone

oddLen:
	mov r9d, dword [rdi+rax*4]
	mov eax, r9d

midDone:	

	ret

; **************************************************************************
;  Function to calculate the integer e-statictic of an integer array.
;	Formula for eStat is:
;		eStat = sum [ (list[i] - median)^2 ]
;	Must use iMedian() function to find median.
;  Note, due to the data sizes, the summation must be performed as a quad-word.

; -----
;  HLL Call:
;	var = eStatistic(list, len);

;  Arguments Passed:a
;	1) list, addr
;	2) length, value

;  Returns:
;	eStat - value (in rax)

global eStatistic
eStatistic:


;	YOUR CODE GOES HERE
	push r10
	push r11
	push r12 ;eStat
	push r13 ;added to eStat

	;get median

	mov r9, rdi
	push rdi
	mov r10, rsi
	push rsi

	mov rax, 0

	mov rdi, r9
	mov esi, r10d
	call iMedian

	mov r11, 0
	mov r9, rax
	mov r11d, eax ;r11d = med

	pop rsi
	pop rdi

	mov rax, 0
	mov r8, 0
	mov r12, 0

eStatLp:
	cmp r8d, esi
	je eStatDone

	mov rdx, 0
	mov rax, 0
	mov eax, dword [rdi+r8*4]
	sub rax, r11
	imul rax

	;possible error here
	;add rax, rdx
	add r12, rax

	inc r8
	jmp eStatLp
eStatDone:

	mov rax, r12

	pop r13
	pop r12
	pop r11
	pop r10
	ret

; ***************************************************************************

