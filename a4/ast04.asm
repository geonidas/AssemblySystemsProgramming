;	Giovanni Mueco
;	assignment 4
;   section 1001

; -----


; *****************************************************************
          
section	.data

; -----
;  Define standard constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation

SYS_exit	equ	60			; call code for terminate

; -----

lst		dd	 1246,  1116,  1542,  1240,  1677
		dd	 1635,  2426,  1820,  1246, -2333
		dd	 2317, -1115,  2726,  2140,  2565
		dd	 2871,  1614,  2418,  2513,  1422
		dd	-2119,  1215, -1525, -1712,  1441
		dd	-3622,  -731, -1729,  1615,  1724
		dd	 1217, -1224,  1580,  1147,  2324
		dd	 1425,  1816,  1262, -2718,  2192
  		dd	-1432,  1235,  2764, -1615,  1310
		dd	 1765,  1954,  -967,  1515,  3556
		dd	 1342,  7321,  1556,  2727,  1227
		dd	-1927,  1382,  1465,  3955,  1435
		dd	-1225, -2419, -2534, -1345,  2467
		dd	 1315,  1961,  1335,  2856,  2553
  		dd	-1032,  1835,  1464,  1915, -1810
		dd	 1465,  1554, -1267,  1615,  1656
		dd	 2192, -1825,  1925,  2312,  1725
		dd	-2517,  1498, -1677,  1475,  2034
		dd	 1223,  1883, -1173,  1350,  1415
		dd	  335,  1125,  1118,  1713,  3025
len		dd	100

lstMin		dd	0
lstMid		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

posCnt		dd	0
posSum		dd	0
posAve		dd	0

threeCnt	dd	0
threeSum	dd	0
threeAve	dd	0


; *****************************************************************

section	.text
global _start
_start:

; -----
;CODE STUFF


	mov eax, dword [lst]
	mov dword [lstMin], eax
	mov dword [lstMax], eax
	mov dword [lstSum], 0
	mov rbx, lst
	mov rcx, 0
	mov ecx, dword [len]

calcLp:
	mov eax, dword [rbx]
	add dword [lstSum], eax
	cmp eax, dword[lstMin]
	jge minDone
	mov dword[lstMin], eax

minDone:
	cmp eax, dword [lstMax]
	jle maxDone
	mov dword [lstMax], eax

maxDone:
	cmp eax, 0
	jl posDone
	inc dword [posCnt]
	add dword [posSum], eax

posDone:
	mov r9, rax
	mov r8, 3
	cdq
	idiv r8d
	cmp edx, 0
	jne threeDone
	inc dword [threeCnt]
	add dword [threeSum], r9d

threeDone:
	add rbx, 4
	dec rcx
	cmp rcx, 0
	jne calcLp

;find ave
	mov eax, dword [lstSum]
	cdq
	idiv dword [len]
	mov dword [lstAve], eax

;find posAve
	mov eax, dword [posSum]
	cdq
	idiv dword [posCnt]
	mov dword [posAve], eax

;find threeAve
	mov eax, dword [threeSum]
	cdq
	idiv dword [threeCnt]
	mov dword [threeAve], eax

;find lstMid
	mov r8, 2
	mov rdx, 0
	mov eax, dword [len]
	div r8d

	cmp rdx, 0
	jne oddLen

;evenLen
	mov r9d, dword [lst+eax*4]
	dec eax
	add r9d, dword [lst+eax*4]
	mov eax, r9d
	cdq
	idiv r8d
	mov dword [lstMid], eax
	jmp midDone

oddLen:
	inc eax
	mov r9d, dword [lst+eax*4]
	mov dword [lstMid], r9d

midDone:




; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS
	syscall