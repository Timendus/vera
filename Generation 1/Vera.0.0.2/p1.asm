textmem = $8000
curcol = $8100
currow = $8102
keymem = $8104
buffer = $8106


#define WAIT rst 8

.org $00
	jp startup
.org $08
	jp delay
.org $10
	jp putstring
.org $18
	jp Display
.org $20
	jp putchar
.org $28
	jp puthex
.org $30
	jp getk
.org $38
	jp startup
.org $53
	jp startup
	.db $5A,$A5 ; thanks moody
.org $0064
	.db "Vera OS",0
	.db "TI-83 Plus",0
startup:
	di
	ld sp,$FFF8
	ld a,0
	out (0),a
	ld a,$ff
	out (1),a
	ld a,$08
	out (3),a
	ld a,0
	out (3),a
	ld a,$08
	out (3),a
	ld a,6
	out (4),a
	ld a,0
	out (6),a
	ld a,$41
	out (7),a
	WAIT 
	ld a,00
	out ($10),a
	WAIT 
	ld a,3
	out ($10),a
	WAIT 
	ld a,5
	out ($10),a
	WAIT 
	ld a,8
	out ($10),a
	WAIT 
	ld a,$10
	out ($10),a
	WAIT 
	ld a,$18
	out ($10),a
	WAIT 
	ld a,$40
	out ($10),a
	WAIT 
	ld a,$f0
	out ($10),a
	WAIT 
	ld hl,$8000
	ld (hl),0
	ld de,$8001
	ld bc,$7fff
	ldir
	ld hl,$8000
	ld (hl),$20
	ld de,$8001
	ld bc,$7f
	ldir
	
	ld hl,welcome_str
	call putstring
	call newline
	jp CLI_start
	
welcome_str:
	;    1234567890123456
	.db "   Welcome to  ",255
	.db "    ",248,242,243,244,245,246,247,248,$0a
	.db "A calclover's OS",0
	
; ========================
; Command line interface
; ========================
	
CLI_start:
	
loop:

	ld a,'>'
	call putchar
	ld a,(curcol)
	inc a
	ld (curcol),a
	ld a,' '
	call putchar
	ld a,(curcol)
	inc a
	ld (curcol),a
	call Display
	
	call readPrompt		; Reads user input, stores in buffer
	call newline
	call parse				; Parses string in buffer
	
	jp loop
	
; ========================
; Text input routine
; ========================

readPrompt:
	ld hl,buffer
	push hl
readPrompt_waitKey:
	call getk			; Get a key
	or a
	jr z,readPrompt_waitKey
	
	cp 9					; Is it Enter?
	jp nz,evalKey
	pop hl
	ld (hl),0
	ret					; Then return
	
evalKey:
	call mapGetkToAscii
	or a
	jp z,readPrompt_waitKey
	
	pop hl
	ld (hl),a			; Store character
	inc hl				; For later parsing
	push hl
	
	call putchar
	call Display
	
	ld a,(curcol)
	inc a
	and 15
	ld (curcol),a
	jp nz,readPrompt_waitKey
	call newline
	jp readPrompt_waitKey

; ========================
; Command parser
; ========================
	
parse:
	ld hl,buffer
	ld de,clear_str
	call stringCompare
	jp z,clearScreen
	
	ld hl,buffer
	ld de,base_str
	call stringCompare
	jp z,areBelong
	
	ld hl,unknown_str
	call putstring
	call newline
	ret
	
clearScreen:
	ld hl,$8000
	ld (hl),$20
	ld de,$8001
	ld bc,$7f
	ldir
	xor a
	ld (curcol),a
	ld (currow),a
	ret
	
areBelong:
	ld hl,belong_str
	call putstring
	call newline
	ret
	
clear_str:
	.db "clear",0
base_str:
	.db "all your base",0
belong_str:
	.db "are belong      to us!",0
unknown_str:
			;1234567890123456
	.db "Unrecognized    command",0
	
stringCompare:		; From the API
   ; hl = str1
   ; de = str2
   ; Return z = equal, nz = not equal

   ld a,(de)
   or a
   jr z,string_compare_end
   xor (hl)
   ret nz   ; Nonidentical
   inc hl
   inc de
   jr stringCompare
string_compare_end:
   or (hl)
   ret 
	
; ========================
; Get ascii value from getk
; ========================

mapGetkToAscii:
	push hl
	dec a
	ld hl,keytable
	ld c,a
	ld b,0
	add hl,bc
	ld a,(hl)
	pop hl
	ret
	
keytable:
	.fill 9,0
	
	; start at 10
	.db $22		; "
	.db $77		; w
	.db $72		; r
	.db $6d		; m
	.db $68		; h
	
	.fill 2,0
	
	; start at 17
	.db $3f		; ?
	.db $5b		; theta
	.db	$76		; v
	.db $71		; q
	.db $6c		; l
	.db $67		; g
	
	.fill 2,0
	
	; start at 25
	.db $3a		; :
	.db $7a		; z
	.db $75		; u
	.db $70		; p
	.db $6b		; k
	.db $66		; f
	.db $63		; c
	
	.db 0
	
	; start at 33
	.db $20		; space
	.db $79		; y
	.db $74		; t
	.db $6f		; o
	.db $6a		; j
	.db $65		; e
	.db $62		; b
	
	.fill 2,0
	
	; start at 42
	.db $78		; x
	.db $73		; s
	.db $6e		; n
	.db $69		; i
	.db $64		; d
	.db $61		; a
	
	.fill 4,0

; ========================
; Jim's stuff :)
; ========================

GetK:
	push hl
	push de
	push bc
	ld a,$ff		;
	out (1),a		;reset keyport
	ld e,$fe		;frist group
	ld c,$01		;key port
	ld l,0		;l holds key pressed
cscloop:
	out (c),e		;set keygroup
	ld b,8		;loop, Delay needed when work with key driver
	in a,(c)		;read key
cscbit:
	inc l			;inc to get key pressed
	rra 			; if key pressed done
	jp nc,donecsc
	djnz cscbit 	;loop 8
	rlc e			;next key group
	jp m,cscloop	;if bit 7 set loop
	ld l,0		;if no key pressed 0
donecsc:
	ld a,(keymem)
	cp l
	jr z,norepeat
	ld a,l
	ld (keymem),a
	pop bc
	pop de
	pop hl
	ret
norepeat:
	xor a
	pop bc
	pop de
	pop hl
	ret

delay:
	push bc
	ld bc,$10
delayloop:
	in f,(c)
	jp p,delaydone
	djnz delayloop
delaydone:
	pop bc
	ret

Display:
	push af
	push ix
	WAIT 
	xor a
	out ($10),a
	WAIT 
	ld a,$80
	out ($10),a
	ld ix,textmem
	ld a,$20
col:
	WAIT 
	out ($10),a
	push af
	ld a,(ix)
	call Character
	ld a,(ix+16)
	call Character
	ld a,(ix+16*2)
	call Character
	ld a,(ix+16*3)
	call Character
	ld a,(ix+16*4)
	call Character
	ld a,(ix+16*5)
	call Character
	ld a,(ix+16*6)
	call Character
	ld a,(ix+16*7)
	call Character
	pop af
	inc a
	inc ix
	cp $30
	jp nz,col
	WAIT
	pop ix
	pop af
	ret

Character:
	push af
	push hl
	push de
	push bc
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,font
	add hl,de
	ld b,8
row:
	WAIT 
	ld a,(hl)
	rrca
	rrca
	out ($11),a
	inc hl
	djnz row
	pop bc
	pop de
	pop hl
	pop af
	ret

newline:
	push af
	xor a
	ld (curcol),a
	ld a,(currow)
	inc a
	and 7
	jr z,shiftline
	ld (currow),a
	pop af
	ret
shiftline:
	push hl
	push de
	push bc
	ld hl,$8010
	ld de,$8000
	ld bc,128-16
	ldir
	ld hl,$8070
	ld (hl),$20
	ld de,$8071
	ld bc,$F
	ldir
	call Display
	pop bc
	pop de
	pop hl
	pop af
	ret

putchar:
	push hl
	push af
	ld a,(currow)
	and 7
	add a,a
	add a,a
	add a,a
	add a,a
	ld l,a
	ld a,(curcol)
	and 15
	or l
	ld l,a
	ld h,$80
	pop af
	ld (hl),a
	pop hl
	ret

putstring:
;	pop hl
putstringloop:
	ld a,(hl)
	inc hl
	or a
	jp z,donestr
	cp $0a
	jp nz,nonewline
	call newline
	jr putstringloop
nonewline:
	call putchar
	ld a,(curcol)
	inc a
	and 15
	ld (curcol),a
	jp nz,putstringloop
	call newline
	jp putstringloop
donestr:
	;call newline
	call Display
;	jp (hl)
	ret
	
puthex:
	push af
	push de

	ld d,a
	rra
	rra
	rra
	rra
	or $F0
	daa
	add a,$A0
	adc a,$40
	call putchar
	ld a,(curcol)
	inc a
	and 15
	ld (curcol),a
	ld a,d
	or $F0
	daa
	add a,$A0
	adc a,$40
	call putchar
	ld a,(curcol)
	inc a
	and 15
	ld (curcol),a
	call Display
	
	pop de
	pop af
	ret

#include "font3.asm"
