.org $00
	jp startup
.org $08
	jp delay
.org $10
.org $18
.org $20
.org $28
.org $30
.org $38
	jp startup
.org $53
	jp startup
	.db $5A,$A5 	;thanks moody

.include "vera83+.inc"

.include "font.asm"

startup:
	di
	ld 	sp,Stack;place stack pointer
	ld 	a,0	;reset linkport
	out 	(0),a
	ld 	a,FFh	;reset keyboard
	out 	(1),a
	ld 	a,08h	;reset every interupt exept the autodim
	out 	(3),a
	ld	a,0	;map memory
	out	(4),a
	ld 	a,0	;bank A
	out 	(6),a
	ld 	a,65	;bank B 
	out 	(7),a

	WAIT 		;set up the lcd
	ld 	a,00	;6 bit mode
	out 	(10h),a
	WAIT 
	ld 	a,3	;enable the lcd
	out 	(10h),a
	WAIT 
	ld 	a,5	;set X auto increment
	out 	(10h),a
	WAIT 
	ld 	a,8
	out 	(10h),a
	WAIT 
	ld 	a,10h
	out 	(10h),a
	WAIT 
;	ld 	a,18h	;cancel test mode
;	out 	(10h),a
;	WAIT 
	ld 	a,40h	;first mem location is same as first LCD line
	out 	(10h),a
	WAIT 
	ld 	a,f0h	;contrast
	out 	(10h),a
	WAIT

.include "Behavior.asm"
	
.include "Routines.asm"