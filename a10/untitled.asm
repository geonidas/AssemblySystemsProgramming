
%macro
;args: dStep

%endmacro

global calcX
calcX:

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

	;xmm0 = xmm0 * scale
	mulsd xmm0, qword[scale]

	movsd qword[initX+rdi*8]

ret

global calcY
calcY:

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

	;xmm0 = xmm0 * scale
	mulsd xmm0, qword[scale]

	movsd qword[initX+rdi*8]

ret