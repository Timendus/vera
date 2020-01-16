;2	input routines:


;2.1-------------------------------------
;routine:	GetButton
;description: 	Get the button that is pressed on the keypad to a
;input:
;output:	a=pressed button ($FF=no button pressed)
;destroys:	bc,de
GetButton:
	ld 	a,$ff
	out 	(1),a	;reset
	ld 	e,$fe	;first group
	ld 	c,$01	;key port
	ld 	d,0	;l holds key pressed
--:
	out	(1),a
	out 	(c),e	;set keygroup
	ld	b,8
	in 	a,(c)	;read key
-:
	inc 	d	;inc to get key pressed
	rra 		;if key pressed done
	jp 	nc,{+}
	djnz	{-} 	;loop 8
	rlc 	e	;next key group
	jp 	m,{--}	;if bit 7 set loop
	ld 	d,$FF	;if no key pressed $FF
+:
	ld	a,d
	cp	4
	jp	nc,{2@}
	ld	b,255
@:	wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait
	wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait
	wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait
	wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait \ wait
	djnz	{-1@}
	ret	
@:
	ld 	a,$ff
	out 	(1),a	;reset
	out 	(c),e	;set keygroup
	in 	a,(c)	;read key
	cp	$FF
	jp	nz,{-1@}
	ld	a,d
	ret
;----------------------------------------


;2.2-------------------------------------
;routine:	GetString
;description: 	gets a string form the user into hl
;input:		hl=string storage
;output:
;destroys:
GetString:
	push	hl
	ld	d,h \ ld e,l	;de=hl

-:	push	de
	call	GetButton
	pop	de
	ld	hl,Input
	cp	37h \ jp z,ChangeMode
	cp	36h \ jp z,Change2nd
	cp	30h \ jp z,ChangeAlpha
	cp	28h \ jp z,ChangeFont
	cp	09h \ jp z,Return
	cp	38h \ jp z,Delete
	cp	FFh
	jp	z,{-}

	ld	hl,Input
	ld	b,(hl)
	bit	7,(hl)	;bit 7 is 1 if 2nd is on
	jp	z,{@}
	ld	hl,2nd
	jp	doit
@:	bit	6,(hl)	;bit 6 indicates the mode 1=text
	jp	nz,{@}
	ld	hl,math
	jp	doit
@:	bit	5,(hl)	;bit 5 is 1 for greek tokens
	jp	z,{@}
	ld	hl,greek
	jp	selectsize
@:	bit	4,(hl)	;bit 4 is 1 for bold tokens
	jp	z,{@}
	ld	hl,bold
	jp	selectsize
@:	ld	hl,characters

selectsize:
	bit	3,b	;bit 3 is 1 for capital tokens
	jp	z,doit
	ld	bc,40
	add	hl,bc
doit:
	sub	9
	ld	c,a
	ld	b,0
	add	hl,bc
	ld	a,(hl)
	cp	FFh	;check if there is a token for the key pressed
	jp	nz,gotsome

	;if there is no token for the key that is pressed
	add	a,9
	ld	hl,Input
	bit	7,(hl)	;bit 7 is 1 if 2nd is on
	jp	nz,2ndbuttons
	bit	6,(hl)	;bit 6 indicates the mode 1=text
	jp	z,{@}
	ld	hl,mathbuttons


2ndbuttons:
	;a=a key
	;do menu's for the keys you want
	jp	gotsome
mathbuttons:
	jp	gotsome





gotsome:
	cp	FFh	;see if it is a token or a string
	jp	z,{@}	;if string move on, else do the code down here
	ld	(de),a	;add it to the record
	inc	de
	call	PrintCharacter	;and print it
	jp	{-}

@:	;call	z,PrintString
	jp	{-}



characters:
	.db $FF,$B9,$17,$12,$0D,$08,$FF,$FF	;-"wrmh--
	.db $FF,$FF,$16,$11,$0C,$07,$FF,$FF	;?-vqlg--
	.db $B3,$1A,$15,$10,$0B,$06,$03,$FF	;:zupkfc-
	.db $00,$19,$14,$0F,$0A,$05,$02,$FF	; ytojeb-
	.db $FF,$18,$13,$0E,$09,$04,$01,$FF	;-xsnida-
capital:
	.db $FF,$B9,$31,$2C,$27,$22,$FF,$FF	;-"WRMH--
	.db $FF,$FF,$30,$2B,$26,$21,$FF,$FF	;?-VQLG--
	.db $B3,$34,$2F,$2A,$25,$20,$1D,$FF	;:ZUPKFC-
	.db $00,$33,$2E,$29,$24,$1F,$1C,$FF	; YTOJEB-
	.db $FF,$32,$2D,$28,$23,$1E,$1B,$FF	;-XSNIDA-
bold:
	.db $FF,$B9,$4B,$46,$41,$3C,$FF,$FF
	.db $FF,$FF,$4A,$45,$40,$3B,$FF,$FF
	.db $B3,$4E,$49,$44,$3F,$3A,$37,$FF
	.db $00,$4D,$48,$43,$3E,$39,$36,$FF
	.db $FF,$4C,$47,$42,$3D,$38,$35,$FF
boldcapital:
	.db $FF,$B9,$65,$60,$5B,$56,$FF,$FF
	.db $FF,$FF,$64,$5F,$5A,$55,$FF,$FF
	.db $B3,$68,$63,$5E,$59,$54,$51,$FF
	.db $00,$67,$62,$5D,$58,$53,$50,$FF
	.db $FF,$66,$61,$5C,$57,$52,$4F,$FF
greek:
	.db $FF,$B9,$7F,$7A,$75,$70,$FF,$FF
	.db $FF,$FF,$7E,$79,$74,$6F,$FF,$FF
	.db $FF,$FF,$7D,$78,$73,$6E,$6B,$FF
	.db $00,$FF,$7C,$77,$72,$6D,$6A,$FF
	.db $FF,$80,$7B,$76,$71,$6C,$69,$FF
greekcapital:
	.db $FF,$B9,$97,$92,$8D,$88,$FF,$FF
	.db $FF,$FF,$96,$91,$8C,$87,$FF,$FF
	.db $FF,$FF,$95,$90,$8B,$86,$83,$FF
	.db $00,$FF,$94,$8F,$8A,$85,$82,$FF
	.db $FF,$98,$93,$8E,$89,$84,$81,$FF
math:
	.db $FF,$B0,$B1,$B2,$B3,$B4,$FF,$FF	;-+-*/^--
	.db $AF,$A6,$A9,$AC,$C4,$FF,$FF,$FF	;_369)---
	.db $BA,$A5,$A8,$AB,$C3,$FF,$FF,$FF	;.258(---
	.db $A3,$A4,$A7,$AA,$AE,$FF,$FF,$FF	;0147,---
	.db $FF,$BC,$FF,$FF,$FF,$FF,$FF,$FF	;->------
2nd:
	.db $FF,$FF,$CB,$CB,$CB,$FF,$FF,$FF	;--][e--- kan wel anders hoop ik
	.db $FF,$FF,$FF,$CB,$CB,$FF,$FF,$FF	;---w}---
	.db $CB,$FF,$FF,$CB,$CB,$FF,$FF,$FF	;i--v{---
	.db $FF,$FF,$FF,$CB,$CB,$FF,$FF,$FF	;---uE---
	.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	;--------

;return routine

Return:	pop	hl
	ld	a,FFh
	ld	(de),a
	ret

;delete a token routine

Delete:
	;dec position
	ld	a,(HP)
	cp	0
	jp	nz,{@}
	ld	a,(VP)
	cp	0
	jp	z,{-}
	dec	a
	ld	(VP),a
	ld	a,16
@:	dec	a
	ld	(HP),a

	ld	a,0
	call	PrintCharacter

	;dec position
	ld	a,(HP)
	cp	0
	jp	nz,{@}
	ld	a,(VP)
	cp	0
	jp	z,{-}
	dec	a
	ld	(VP),a
	ld	a,16
@:	dec	a
	ld	(HP),a

	;adjust buffer
	dec	de
	jp	{-}	;and get back
;some subs for GetString:

ChangeMode:
	bit	6,(hl)
	jp	z,{@}
	res	6,(hl)
	jp	{-}
@:	set	6,(hl)
	ld	a,$FF
	ret
Change2nd:
	bit	7,(hl)
	jp	z,{@}
	res	7,(hl)
	jp	{-}
@:	set	7,(hl)
	ld	a,$FF
	ret
ChangeAlpha:
	bit	3,(hl)
	jp	z,{@}
	res	3,(hl)
	jp	{-}
@:	set	3,(hl)
	ld	a,$FF
	ret
ChangeFont:
	ld	hl,FontMenu
	call	menu
	ld	a,$FF
	ret
FontMenu:
	.asc	"||Select Font|"
	.asc	"Normal|"
	jp	normalfont
	.asc	"Bold|"
	jp	boldfont
	.asc	"Greek|"
	jp	greekfont
	.db	255
normalfont:
	ld	hl,input
	res	4,(hl)
	res	5,(hl)
	ret
boldfont:
	ld	hl,input
	set	4,(hl)
	res	5,(hl)
	ret
greekfont:
	ld	hl,input
	res	4,(hl)
	set	5,(hl)
	ret
;----------------------------------------