;  CS 218 - Assignment #11

; -----
;  Function - getArguments()
;	Read, parse, and check command line arguments.

;  Function - int2octal()
;	Convert an integer to a octal/ASCII string, NULL terminated.

;  Function - countDigits()
;	Check the leading digit for each number and count 
;	each 0, 1, 2, etc...
;	All file buffering handled within this procedure.

;  Function - showGraph()
;	Create graph as per required format and ouput.


; ****************************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20			; space

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation
EXIT_NOSUCCESS	equ	1			; Unsuccessful operation

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

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q

LINEMAX 	equ 5			;lines to skip
CHRMAX 		equ 7			;characters to skip
; -----
;  Variables for getArguments()

usageMsg	db	"Usage: ./benford -i <inputFileName> "
		db	"-o <outputFileName> -d <T/F>", LF, NULL

errMany		db	"Error, too many characters on the "
		db	"command line.", LF, NULL

errFew		db	"Error, too few characters on the "
		db	"command line.", LF, NULL

errDSpec	db	"Error, invalid output display specifier."
		db	LF, NULL

errISpec	db	"Error, invalid input file specifier."
		db	LF, NULL

errOSpec	db	"Error, invalid output file specifier."
		db	LF, NULL

errTF		db	"Error, invalid display option. Must be T or F."
		db	LF, NULL

errOpenIn	db	"Error, can not open input file."
		db	LF, NULL

errOpenOut	db	"Error, can not open output file."
		db	LF, NULL


; -----
;  Variables for countDigits()

BUFFSIZE	equ	500000

SKIP_LINES	equ	5				; skip first 5 lines
SKIP_CHARS	equ	6

nextCharIsFirst	db	TRUE
skipLineCount	dd	0				; count of lines to skip
skipCharCount	dd	0				; count of chars to skip
gotDigit	db	FALSE

bfMax		dq	BUFFSIZE
curr		dq	BUFFSIZE

wasEOF		db	FALSE

errFileRead	db	"Error reading input file."
		db	"Program terminated."
		db	LF, NULL

; -----
;  Variables for showGraph()

SCALE1		equ	100				; for < 100,000
SCALE2		equ	1000				; for >= 100,000 and < 500,000
SCALE3		equ	2500				; for >= 500,000 and < 1,000,000 
SCALE4		equ	5000				; for >= 1,000,000

scale		dd	SCALE1				; initial scaling factor

weight		dd	3

errFileWrite	db	"Error writting output file."
		db	LF, NULL

graphHeader	db	LF, "CS 218 Benfords Law", LF
		db	"Test Results", LF, LF, NULL

graphLine1	db	"Total Data Points: "
tStr1		db	"                     ", LF, LF, NULL

DIGITS_SIZE	equ	15
STARS_SIZE	equ	50

graphLine2	db	"  "				; initial spaces
index2		db	"x"				; overwriten with #
		db	"  "				; spacing
num2		db	"               "		; digit count
		db	"|"				; pipe
stars2		db	"                              "
		db	"                    "
		db	LF, NULL

graphLine3	db	"                     ---------------------------------------------"
		db	LF, LF, NULL

;additional variables

arg2chk 	db 	"-i"
arg4chk 	db 	"-o"
arg6chk 	db  "-d"
arg7chkT	db 	"T"
arg7chkF	db 	"F"


; -------------------------------------------------------

section	.bss

buff		resb	BUFFSIZE+1
tempString   resb    50	;used for parsing args



; ****************************************************************************

section	.text

; ======================================================================
; Read, parse, and check command line paraemetrs.

; -----
;  Assignment #11 requires options for:
;	input file name
;	output file name
;	display results to screen (T/F)

;  For Example:
;	./benford -i <inputFileName> -o <outputFileName> -d <T/F>

; -----
;  Example high-level language call:
;	status = getArguments(ARGC, ARGV, rdFileDesc, wrFileDesc, displayToScreen)

; -----
;  Arguments passed:
;	argc
;	argv ADDRESS
;	address of file descriptor, input file
;	address of file descriptor, output file
;	address of boolean for display to screen


; ARGV should look like:

;   ||---------------------
;[0]||	".benford"
;   ||---------------------
;[1]||  "-i"
;	||---------------------
;[2]||	<inputFileName>
;	||---------------------
;[3]||  "-o"
;	||---------------------
;[4]||  <outputFileName>
;	||---------------------
;[5]||  "-d"
;	||---------------------
;[6]||  <T/F>
;	||---------------------


;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

global getArguments
getArguments:

;rdi arg count, p/moved r10
;rsi arg volume ADDRESS p/moved r11
;rdx input file descriptor ADDRESS p/moved r12
;rcx output file descriptor ADDRESS p/moved r13
;r8 boolean for "display(?)"

	push 	rax
	push 	rbx 	 ;used for a given string from argv
	push 	r9		 ;used to increment through strings
	push 	r10
	mov 	r10, rdi ; set argc
	push 	rdi
	push 	r11
	mov 	r11, rsi ;set argv ADDRESS
	push 	rsi
	push 	r12
	mov 	r12, rdx ; set input file descriptor ADDRESS
	push 	rdx
	push 	r13
	mov 	r13, rcx ; set output file descriptor ADDRESS
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
	mov rdi, usageMsg
	call printString
	jmp termArg
	usageMsgDone:

;if argc > 7
;many error check

	cmp r10, 7
	jbe manyChkDone
	mov rdi, errMany
	call printString
	jmp termArg 
	manyChkDone:

;if argc < 7
;few error check

	cmp r10, 7
	jae fewChkDone
	mov rdi, errFew 
	call printString
	jmp termArg 
	fewChkDone:

;erorr check for "-i"
	mov 	r15, 1   ;rcx as an index for argv
	mov 	r9, 0
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-i" for success

arg2Lp:
	cmp 	byte[rbx+r9], NULL ;ends loop when we hit null
	je 	arg2LpEnd
	
	mov 	r14b, byte[arg2chk+r9] ;takes char from string variable containing "-i"
	cmp 	byte [rbx+r9], r14b
	jne 	arg2err
	
	inc 	r9
	jmp arg2Lp
arg2LpEnd:
	cmp 	r9, 2
	jne 	arg2err
	jmp arg2ChkEnd
arg2err:
	mov 	rdi, errISpec
	call 	printString
	jmp termArg 	;terminate program
arg2ChkEnd:


;error check for <inputFileName>
	inc 	r15		;r15 = 2
	mov 	rbx, qword[r11+r15*8] ; rbx = <inputFileName>

	push r11
	mov 	rax, SYS_open  
	mov 	rdi, rbx
	mov 	rsi, O_RDONLY
	syscall
	pop r11

	mov qword[r12], rax ;move file descriptor into input file descriptor variable address

	cmp rax, 0 ;check for successful file read
	jge	arg3End
	mov rdi, errOpenIn
	call printString
	jmp termArg
arg3End:

;try to open file

;error check for "-o"

	inc 	r15		;r15 = 3
	mov 	r9, 0 	;reset r9 to 0 to loop through arg4 string
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-o" for success

arg4Lp:
	cmp 	byte[rbx+r9], NULL ;ends loop when we hit null
	je 	arg4LpEnd
	
	mov 	r14b, byte[arg4chk+r9] ;takes char from string variable containing "-o"
	cmp 	byte [rbx+r9], r14b
	jne 	arg4err
	
	inc 	r9
	jmp arg4Lp
arg4LpEnd:
	cmp 	r9, 2
	jne 	arg4err
	jmp arg4ChkEnd
arg4err:
	mov 	rdi, errOSpec
	call 	printString
	jmp termArg 	;terminate program
arg4ChkEnd:

;error check for <outputFileName>

	inc 	r15		;r15 = 4
	mov 	rbx, qword[r11+r15*8] ; rbx = <outputFileName>

	push 	r11
	mov 	rax, SYS_creat  
	mov 	rdi, rbx
	mov 	rsi, S_IRUSR | S_IWUSR
	syscall
	pop 	r11

	mov 	qword[r13], rax	;move file descriptor into output file descriptor variable address
	cmp 	rax, 0		;check for successful file read
	jge arg5End

	mov 	rdi, errOpenOut
	call 	printString
	jmp termArg		

arg5End:

;error check for "-d"

	inc 	r15		;r15 = 5
	mov 	r9, 0 	;reset r9 to 0 to loop through arg4 string
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-d" for success

arg6Lp:
	cmp 	byte[rbx+r9], NULL ;ends loop when we hit null
	je 	arg6LpEnd
	
	mov 	r14b, byte[arg6chk+r9] ;takes char from string variable containing "-d"
	cmp 	byte [rbx+r9], r14b
	jne 	arg6err
	
	inc 	r9
	jmp arg6Lp

arg6err:
	mov 	rdi, errDSpec 	;<< outputs error message
	call 	printString  	;<<
	jmp termArg 	;terminate program

arg6LpEnd:

; error check for T or F (T/F)

	inc 	r15		;r15 = 5
	mov 	r9, 0 	;reset r9 to 0 to loop through arg4 string
	mov 	rbx, qword[r11+r15*8]	; rbx should equal "-d" for success

arg7Lp:
	cmp 	byte[rbx+r9], NULL ;ends loop when we hit null
	je 	arg7LpEnd
	
	mov 	r14b, byte[arg7chkT+r9] ;takes char from string variable containing "T"
	cmp 	byte [rbx+r9], r14b
	je 	arg7LpCont						;if the current char is T, continue loop to find NULL
	
	cmp 	r14b, byte[arg7chkF+r9] 	;check for "F"
	jne arg7err

arg7LpCont:
	inc 	r9
	cmp 	r9, 2
	je arg7err 

	jmp arg7Lp

arg7err:
	mov 	rdi, errTF 	;<< outputs error message
	call 	printString  	;<<
	jmp termArg 	;terminate program

arg7LpEnd:

;ends the program if error is found
	jmp skipTermArg
termArg:
	mov rax, SYS_exit
	mov rdi, EXIT_NOSUCCESS 
	syscall
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
	pop 	rax

ret

;getArguments end

;EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE

; ======================================================================
;  Simple function to convert an integer to a NULL terminated
;	octal string.
;	NOTE, may change arguments as desired.

; -----
;  HLL Call
;	bool = int2octal(int, &str);

; -----
;  Arguments passed:
;	1) integer value
;	2) string, address

; -----
;  Returns
;	1) string (via passed address)
;	2) bool, TRUE if valid conversion, FALSE for error

;SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

global int2oct
int2oct:

	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push 	r8
	mov		r8, rdi ;			*r8 is the int val (arg1)*
	push	rdi
	push 	r9
	mov 	r9, rsi ;			*r9 is the string address (arg2)*
	push	r10

;divide num by 8 loop
;push remainders onto stack

	mov eax, r8d

	mov r14, r9
	mov rdi, 0

	mov rdx, 0
	mov rcx, 0

i2oLp:
	cmp rax, 0
	je exi2oLp

	mov ebx, 8
	cdq
	idiv ebx

	push rdx
	inc rcx
	jmp i2oLp

exi2oLp:

popLoop:
	pop rax
	add al, "0"
	mov byte [r14+rdi], al
	inc rdi
	loop popLoop

mov byte [r14+rdi], NULL

	pop r10
	pop r9
	pop	rdi
	pop r8
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

ret
;end int2oct

;EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE

; ======================================================================
; Count leading digits....
;	Check the leading digit for each number and count 
;	each 0, 1, 2, etc...
;	The counts (0-9) are stored in an array.

; -----
;  High level language call:
;	countDigits (rdFileDesc, digitCounts)

; -----
;  Arguments passed:
;	value for input file descriptor 	rdi
;	address for digits array			rsi

global countDigits
countDigits:

;	YOUR CODE GOES HERE
push 	rax
push 	rbx
mov 	rbx, rdi	;rdFileDesc
push 	rdi
push 	r8		
mov 	r8, rsi		;digitCounts
push 	rsi
push 	rdx
push 	r9
push 	r10
push 	r11
	

mainLp: 	

;	if(curr > bfMax)
;	{
	mov 	r10, qword[bfMax]
	cmp 	qword[curr], r10
	jae endOfcurrChk

;		if(was EOF)
;			jump to exit

;		readFile
		mov 	rax, SYS_read 
		mov 	rdi, qword[rbx]
		mov 	rsi, buff 
		mov 	rdx, BUFFSIZE

;		if(read error)
		cmp 	rax, 0
		jge skipReadErrMsg
;		{
;			display msg
			mov 	rdi, errFileRead 
			call 	printString
;			exit
			jmp exit_program
;		}	
		skipReadErrMsg:
;		if(actualRead == 0)
;			jmp to exit
		cmp 	rax, 0
		je exit_program 

;		if(actual < requested)
;		{
		cmp 	rax, BUFFSIZE 
		jge skipEOFcheck
;			wasEOF = true
			mov 	byte[wasEOF], TRUE 
;			bfMax = actual
			mov 	qword[bfMax], rax
;		} 
		skipEOFcheck:
	endOfcurrChk:

	mov qword[curr], 0
;	}//end first if

;   get character from buffer
; 	ch = buffer[curr]
	mov 	r11, qword[curr]
	mov 	r9b, byte[buff+r11]	;r9 = ch 

;	//dealing with the count
;	if(lineCnt < LINEMAX)
	cmp 	dword[skipLineCount], LINEMAX
	jbe dontSkipLines
;	{
;		if(ch == LF)
		cmp r9b, LF 
		jne noLineCntInc
;			lineCnt++
			inc dword[skipLineCount]
		dontSkipLines:

;		curr++
		inc dword[curr]
;		goto mainLp
		jmp mainLp 
;	}
	lineCheckSkip:

;	if(chrCnt < CHRMAX)	
	cmp dword[skipCharCount], CHRMAX
	jbe dontSkipChar
;	{
;		chrCnt++
		inc dword[skipCharCount]
;		curr++
		inc dword[curr]
		jmp mainLp
;	}
	dontSkipChar:

pop 	r11
pop 	r10
pop 	r9
pop 	rdx
pop 	rsi 
pop 	r8
pop 	rdi
pop 	rbx
pop 	rax

ret
; ======================================================================
;  Create graph as per required format.
;	write graph to file
;	if requested, also show graph to output screen

;  High-level language call:
;	showGraph (wrFileDesc, digitCounts, displayToScreen)

; -----
;  Arguments passed:
;	file descriptor, output file - value
;	address for digits array - address
;	display to screen option, T or F - value



;	YOUR CODE GOES HERE
global showGraph
showGraph:

ret


; ======================================================================
;  Generic function to write a string to an already opened file.
;  Similar to printString(), but must handle possible file write error.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters to file

;  Arguments:
;	file descriptor, value
;	address, string
;  Returns:
;	nothing


;	YOUR CODE GOES HERE



; ======================================================================
;  Generic function to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.

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
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************

exit_program:
	mov rax, SYS_exit
	mov rdi, EXIT_NOSUCCESS 
	syscall