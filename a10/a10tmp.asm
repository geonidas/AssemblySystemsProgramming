;  Giovanni Mueco
;  Section 1001
;  Assignment #10
;  Support Functions.
;  Provided Template

; -----
;  Function getIterations()
;	Gets, checks, converts, and returns iteration
;	count and rotation speed from the command line.

;  Function drawChaos()
;	Calculates and plots Chaos algorithm

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
EXIT_NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program constants.

IT_MIN		equ	255
IT_MAX		equ	65535
RS_MAX		equ	32768

; -----
;  Local variables for getIterations() function.

errUsage	db	"Usage: chaos -it <octalNumber> -rs <octalNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL
errITsp		db	"Error, iterations specifier incorrect."
		db	LF, NULL
errITvalue	db	"Error, invalid iterations value."
		db	LF, NULL
errITrange	db	"Error, iterations value must be between "
		db	"377 (8) and 177777 (8)."
		db	LF, NULL
errRSsp		db	"Error, rotation speed specifier incorrect."
		db	LF, NULL
errRSvalue	db	"Error, invalid rotation speed value."
		db	LF, NULL
errRSrange	db	"Error, rotation speed value must be between "
		db	"0 (8) and 100000 (8)."
		db	LF, NULL

; -----
;  Local variables for plotChaos() funcction.

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255

pi		dq	3.14159265358979	; constant
oneEighty	dq	180.0
tmp		dq	0.0

dStep		dq	120.0			; t step
scale		dq	500.0			; scale factor

rScale		dq	100.0			; rotation speed scale factor
rStep		dq	0.1			; rotation step value
rSpeed		dq	0.0			; scaled rotation speed

initX		dq	0.0, 0.0, 0.0		; array of x values
initY		dq	0.0, 0.0, 0.0		; array of y values

x		dq	0.0
y		dq	0.0

seed		dq	987123
qThree		dq	3
fTwo		dq	2.0

A_VALUE		equ	9421			; must be prime
B_VALUE		equ	1

inpString db ""

; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern glutInit, glutInitDisplayMode, glutInitWindowSize
extern glutInitWindowPosition
extern glutCreateWindow, glutMainLoop
extern glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern glutSwapBuffers
extern gluPerspective
extern glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern glClear, glLoadIdentity, glMatrixMode, glViewport
extern glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
extern glutPostRedisplay

; -----
;  c math library funcitons

extern	cos, sin


; ******************************************************************
;  Generic function to display a string to the screen.
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
	push	rbx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; RDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rbx
	ret

; ******************************************************************
;  Function getIterations()
;	Performs error checking, converts ASCII/ternary to integer.
;	Command line format (fixed order):
;	  "-it <ternaryNumber> -rs <ternaryNumber>"

; -----
;  Arguments:
;	1) ARGC, double-word, value 				;rdi
;	2) ARGV, double-word, address 				;rsi
;	3) iterations count, double-word, address	;rdx
;	4) rotate spped, double-word, address		;rcx

;************************************
; 		FUNCTION START
;************************************

global getIterations
getIterations:

	push r12
	push r13
	push r14
	push r15
	push r8
	push r9
	push r11

;	YOUR CODE GOES HERE
	mov r12, rdi ;value
	mov r13, rsi ;address
	push rdi
	push rsi

	mov r14, qword[r13+8]
	mov r15, qword[r13+24]

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;ERROR CHECKING
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;each error checker will terminate the program if triggered


;if(argc == 1)
;display usage message then terminate program

	cmp r12, 1
	jne usageMsgDone
	mov rdi, errUsage
	call printString
	jmp terminate
	usageMsgDone:

;if(argc != 5)
;display error message then terminate
	
	cmp r12, 5
	je error5Done
	mov rdi, errBadCL
	call printString
	jmp terminate
	error5Done:

;if(argv[1] != "-it")
	
	mov r11, 0
	cmp byte[r14+r11], "-"
	jne itErr
	inc r11
	cmp byte[r14+r11], "i"
	jne itErr
	inc r11
	cmp byte[r14+r11], "t"
	jne itErr
	jmp itSpecDone
	itErr:
	mov rdi, errITsp
	call printString
	jmp terminate
	itSpecDone:

;if(argv[3] != "-rs")
	
	;cmp qword [r13+3*8], "-rs"
	cmp byte[r15], "-"
	jne rsErr
	cmp byte[r15+1], "r"
	jne rsErr
	cmp byte[r15+2], "s"
	jne rsErr
	jmp rsSpecDone
	rsErr:
	mov rdi, errRSsp
	call printString
	jmp terminate
	rsSpecDone:

;if(-it value isn't octal)
	;mov rdi, 0
	mov rdi, qword [r13+2*8]
	call checkOct
	cmp rsi, 1
	je itValDone
	mov rdi, errITvalue
	jmp terminate
	itValDone:

;if(-rs value isn't octal)
	;mov rdi, 0
	mov rdi, qword [r13+4*8]
	call checkOct
	cmp rsi, 1
	je rsValDone
	mov rdi, errRSvalue
	jmp terminate
	rsValDone:


;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;END OF ERROR CHECKING
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

;get addresses from arg vector

	mov r8, qword [r13+2*8] ; address of iterations
	mov r9, qword [r13+4*8] ; address of rotate speed

;convert octals to decimals
	mov rdi, qword [r8]
	call octal2decimal
	mov r8, 0
	mov r8d, dword [edi] 	;turn iteration address to value

	mov rdi, qword [r9]
	call octal2decimal
	mov r9, 0
	mov r9d, dword [edi]	;turn rotate speed address to value

;local variables
	mov rbx, 0
	mov ebx, dword [rdx]

	mov rdx, r8 	;iteration
	mov rcx, r9 	;rotate speed

	pop rsi
	pop rdi

	pop r11
	pop r9
	pop r8
	pop r15
	pop r14
	pop r13
	pop r12

jmp skipTerm

;end program UNsuccessfully
	terminate:
	mov rax, SYS_exit
	mov rdi, EXIT_NOSUCCESS
	syscall

skipTerm:

ret






; ******************************************************************
;  Function to draw chaos algorithm.

;  Chaos point calculation algorithm:
;	seed = 7 * 100th of seconds (from current time)
;	for  i := 1 to iterations do
;		s = rand(seed)
;		n = s mod 3
;		x = x + ( (init_x(n) - x) / 2 )
;		y = y + ( (init_y(n) - y) / 2 )
;		color = n
;		plot (x, y, color)
;		seed = s
;	end_for

; -----
;  Global variables (from main) accessed.

common	drawColor	1:4			; draw color
common	degree		1:4			; initial degrees
common	iterations	1:4			; iteration count
common	rotateSpeed	1:4			; rotation speed

; -----

;r8 = iteration
;r9 = rotate speed

;************************************
; 		FUNCTION START
;************************************

global drawChaos
drawChaos:

; -----
;  Save registers...

push r10
push rdx
push rsi
push rdi
push rax
push rbx

mov r8, 0


; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);

	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

; -----
;  Set rotation speed step value.
;	rStep = rotationSpeed / scale

	cvtsi2sd xmm0, r9d ;turn rotation speed into a 64-bit float
	divsd xmm0, qword[scale]
	movsd qword[rStep], xmm0



; -----
;  Plot initial points.

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Calculate and plot initial points.
	

; -----
;  set and plot x[0], y[0]

;::::::::::::::::::::::::::::::
;initX[i] calc, (i = 0)
;::::::::::::::::::::::::::::::

mov rdi, 0
call calcX
call calcY
movsd xmm0, qword[initX+rdi*8]
movsd xmm1, qword[initY+rdi*8]
call glVertex2d

; -----
;  set and plot x[1], y[1]

inc rdi 	;rdi = 1
call calcX
call calcY
movsd xmm0, qword[initX+rdi*8]
movsd xmm1, qword[initY+rdi*8]
call glVertex2d

; -----
;  set and plot x[2], y[2]

inc rdi 	;rdi = 2
call calcX
call calcY
movsd xmm0, qword[initX+rdi*8]
movsd xmm1, qword[initY+rdi*8]
call glVertex2d

; -----
;  Main plot loop.

mainPlotLoop:

;loop ender
cmp dword[iterations], r8d
je endMainPlotLoop

; -----
;  Generate pseudo random number, via linear congruential generator 
;	s = R(n+1) = (A × seed + B) mod 2^16
;	n = s mod 3
;  Note, A and B are constants.

; rax = s
; r10 = n

	;(A * seed)
	mov rax, qword[seed]
	mov rbx, A_VALUE
	mul rbx

	;(A * seed + B)
	add rax, B_VALUE

	;(A * seed + B) mod 2^16
	mov rdx, 0
	mov rbx, 1
	shl rbx, 16
	div rbx
	mov rax, rdx

	;(s mod 3)
	mov rdx, 0
	mov rbx, 3
	div rbx
	mov r10, rdx 	;r10 set as int n



; -----
;  Generate next (x,y) point.
	;set floating 2

	mov rbx, 2
	cvtsi2sd xmm1, rbx

;	x = x + ( (initX[n] - x) / 2 )
	
	;(initX[n]-x)
	movsd xmm0, qword[initX+r10*8]
	subsd xmm0, qword[x]

	;(_/2)
	divsd xmm0, xmm1

	;(x +_)
	addsd xmm0, qword[x]
	movsd qword[x], xmm0

;	y = y + ( (initY[n] - y) / 2 )
	
	;(initY[n]-y)
	movsd xmm0, qword[initY+r10*8]
	subsd xmm0, qword[y]

	;(_/2)
	divsd xmm0, xmm1

	;(x +_)
	addsd xmm0, qword[y]
	movsd qword[y], xmm0

; -----
;  Set draw color (based on n)
;	0 => read
;	1 => blue
;	2 => green

	cmp r10, 0
	jne notRed
	;setred
	mov rdi, 255
	mov rsi, 0
	mov rdx, 0
	jmp colorDone
	notRed:

	cmp r10, 1
	jne notBlue
	;setblue
	mov rdi, 0
	mov rsi, 255
	mov rdx, 0
	jmp colorDone
	notBlue:

	cmp r10, 2
	jne notGreen
	;setgreen
	mov rdi, 0
	mov rsi, 0
	mov rdx, 255
	jmp colorDone
	notGreen:

	colorDone:
	call glColor3ub

	mov rdi, GL_POINTS
	call glBegin

	movsd xmm0, qword[x]
	movsd xmm1, qword[y]
	call glVertex2d

	jmp mainPlotLoop
; -----

	call	glEnd
	call	glFlush

; -----
;  Update rotation speed.
;  Then tell OpenGL to re-draw with new rSpeed value.
	
	movsd xmm3, qword[rSpeed]
	addsd xmm3, qword[rStep]
	movsd qword[rSpeed], xmm3

endMainPlotLoop

	call	glutPostRedisplay

	pop rbx
	pop rax
	pop rdi
	pop rsi
	pop rdx
	pop r10
	ret

; ******************************************************************

;this function checks for non-octal numbers in a string
;returns a 0 in rsi if the number isn't octal
;returns a 1 in rsi if there are no non-octals

global checkOct
checkOct:

	push rcx
	push rax
	push rbx

	mov rbx, rdi

	mov rcx, 0
	mov rsi, 0

	octCheckLoop:
	mov rax, 0
	mov al, byte[rbx+rcx]
	sub al, "0"

	cmp al, 0
	jb badNum
	cmp al, 7
	ja badNum
	mov rsi, 1
	badNum:
	push rax
	inc rcx
	cmp byte [rbx+rcx], NULL
	jne octCheckLoop

	pop rbx
	pop rax
	pop rcx
ret

; ******************************************************************

;this function converts octal numbers into decimal numbers

global octal2decimal
octal2decimal:
	
	push rax
	push rbx
	push rcx
	push r8
	push r9
	push r14

	mov rcx, 1
	pushLoop:
	mov rax, 0
	mov al, byte[rdi+rcx]
	sub al, "0"
	push rax
	inc rcx
	cmp byte[rdi+rcx], NULL
	jne pushLoop

	mov rax, 0
	mov rdi, 0
	mov rbx, 0
	mov r8, 0
	mov r8w, 8
	dec rcx

	cvtLoop:
	pop rdi
	mov rax, 1
	cmp rbx, 0
	je skip
	push rbx
	pop r9
	pow:
	mul r8w
	dec r9
	cmp r9, 0
	jne pow
	skip:
	mul edi
	add r14d, eax
	inc rbx
	loop cvtLoop

	mov rdi, 0
	mov edi, r14d

	pop r14
	pop r9
	pop r8
	pop rcx
	pop rbx
	pop rax

ret

; ******************************************************************

global calcX
calcX:
	push rdi
	push r12; for random shit

	;rdi	;int i
	;xmm3 = dStep
	;xmm4 = i
	;convert int i to float i
	cvtsi2sd xmm4, edi

	; (i * dStep)
	; xmm0 = dStep
	; xmm0 * xmm4
	; xmm0 = (i * dStep)

	movsd xmm0, qword[dStep]
	mulsd xmm0, xmm4

	;(rSpeed + (i * dStep))
	;(rSpeed + xmm0)
	;xmm0 = (rSpeed + (i * dStep))

	addsd xmm0, qword[rSpeed]

	;(pi/180)
	;xmm1 = 180
	;xmm2 = (pi / xmm1)
	;xmm2 = (pi/180)	

	mov r12, 180
	cvtsi2sd xmm1, r12d
	movsd xmm2, qword[pi]
	divsd xmm2, xmm1

	;((rspeed + (i * dStep)) * (pi/180))
	;xmm0 = ((rspeed + (i * dStep)) * (pi/180))
	;xmm0 = xmm0 * xmm2

	mulsd xmm0, xmm2

	;sin((rspeed + (i * dStep)) * (pi/180))
	;sin(xmm0)

	call sin

	;xmm0 = xmm0 * rScale
	mulsd xmm0, qword[rScale]

	movsd qword[initX+rdi*8], xmm0

	pop r12
	pop rdi

ret

global calcY
calcY:

	push rdi
	push r12; for random shit

	;rdi	;int i
	;xmm3 = dStep
	;xmm4 = i
	;convert int i to float i
	cvtsi2sd xmm4, edi

	; (i * dStep)
	; xmm0 = dStep
	; xmm0 * xmm4
	; xmm0 = (i * dStep)

	movsd xmm0, qword[dStep]
	mulsd xmm0, xmm4

	;(rSpeed + (i * dStep))
	;(rSpeed + xmm0)
	;xmm0 = (rSpeed + (i * dStep))

	addsd xmm0, qword[rSpeed]

	;(pi/180)
	;xmm1 = 180
	;xmm2 = (pi / xmm1)
	;xmm2 = (pi/180)	

	mov r12, 180
	cvtsi2sd xmm1, r12d
	movsd xmm2, qword[pi]
	divsd xmm2, xmm1

	;((rspeed + (i * dStep)) * (pi/180))
	;xmm0 = ((rspeed + (i * dStep)) * (pi/180))
	;xmm0 = xmm0 * xmm2

	mulsd xmm0, xmm2

	;sin((rspeed + (i * dStep)) * (pi/180))
	;sin(xmm0)

	call cos

	;xmm0 = xmm0 * rScale
	mulsd xmm0, qword[rScale]

	movsd qword[initX+rdi*8], xmm0

	pop r12
	pop rdi

ret