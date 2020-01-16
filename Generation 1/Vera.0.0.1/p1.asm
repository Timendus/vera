textmem = $8000
curcol = $8100
currow = $8102
keymem = $8104


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
	.db "OMFGSPLOSION OS",0
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
	rst $10
	.db "Hello World!!",$0a,"Welcome to",$0a,"OMGSPLOSION OS",0
loop:
	call getk
	or a
	jr z,loop
	call puthex
	call newline
	jp loop


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
	call Display
	pop hl
	ret

Putstring:
	pop hl
putstringloop
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
	call newline
	jp (hl)
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
	pop de
	pop af
	ret

#include "font.asm"
