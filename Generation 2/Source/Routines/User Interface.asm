;7	user interface routines:


;7.1-------------------------------------
;routine:	Menu
;description: 	Lets the user choose an option out up to 256 posibilities and calls the defined routine
;input:		hl=pointer to menu
;output:	
;destroys:
Menu:
	inc	hl	;skip first two |'s
	inc	hl

	ld	a,(HP)	;save HP&VP
	ld	b,a
	ld	a,(VP)	
	ld	c,a
	push	bc
	
	xor	a	;set up HP&VP
	ld	(HP),a
	inc	a
	ld	(VP),a

	push	hl	;right at the title

@:	ld	a,(hl)	;skip title
	inc	hl
	cp	$FF
	jp	nz,{-1@}

	;gues what, we're gone draw the options

	ld	b,0	;nope first we gone look were to start
@:	ld	a,(MenuPosition)
	cp	b
	jp	z,{2@}
@:	ld	a,(hl)	;next option
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	inc	hl
	inc	hl
	inc	hl
	inc	b
	jp	{-2@}

	;now hl is at the option were we want to start

@:	ld	b,6
@:	call	PrintLine
	ld	a,(hl)
	cp	$FF
	jp	z,{@}
	djnz	{-1@}
	jp	{2@}

@:	call	PrintWhiteLine
	djnz	{-1@}

	;I think now's the right time for a title

	;ld	b,2
@:	pop	hl
	push	hl
	xor	a
	ld	(VP),a
	call	PrintLine
	pop	hl
	push	hl
	xor	a
	ld	(VP),a
	call	PrintWhiteLine
	;djnz	{-1@}
	
	call	GetButton
	cp	1
	jp	z,scrollDown
	cp	4
	jp	z,scrollUp
	cp	9
	jp	z,{+}
	cp	3
	jp	z,{+}
	jp	{-1@}

scrollup:
	ld	a,(MenuSelected)
	cp	0
	jp	z,{@}
	dec	a
	ld	(MenuSelected),a
	jp	{-7@}
@:	ld	a,(MenuPosition)
	cp	0
	jp	z,{@}
	dec	a
	ld	(MenuPosition),a
	jp	{-8@}
@:	call	CountMenuOptions
	ld	a,b
	ld	(MenuPosition),a
	jp	{-9@}

scrolldown:
	call	CountMenuOptions
	ld	c,b
	ld	a,(MenuPosition)
	ld	b,a
	ld	a,c
	sub	b
	ld	b,a
	ld	a,(MenuSelected)
	cp	b
	jp	z,{3@}
	cp	6
	jp	z,{@}
	inc	a
	ld	(MenuSelected),a
	jp	{-9@}
@:	call	CountMenuOptions
	ld	a,(MenuPosition)
	cp	b
	jp	z,{@}
	inc	a
	ld	(MenuPosition),a
	jp	{-10@}
@:	xor	a
	ld	(MenuPosition),a
	jp	{-11@}
@:	xor	a
	ld	(MenuSelected),a
	ld	(MenuPosition),a
	jp	{-12@}

+:	;calculate what to call
	ld	a,(MenuPosition)
	ld	b,a
	ld	a,(MenuSelected)
	add	a,b
	ld	b,a

	pop	hl	;place hl at that position
@:	ld	a,(hl)	;skip title
	inc	hl
	cp	$FF
	jp	nz,{-1@}

@:	ld	a,(hl)	;next option
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	inc	hl
	inc	hl
	inc	hl
	djnz	{-1@}

	ld	de,MenuCharacter+2
	ldd
	ldd
	ldd
	ld	hl,MenuCharacter+3
	ld	(hl),201	;opcode for ret
	
	call	PrintScreen

	pop	bc	;restore HP&VP
	ld	a,b
	ld	(HP),a
	ld	a,c
	ld	(VP),a

	call	MenuCharacter
	ret

CountMenuOptions:	;returs the number of options form a menu in b, hl=start of title after first two |'s
	push	hl
	ld	b,255

@:	ld	a,(hl)	;skip title
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	
@:	ld	a,(hl)
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	inc	b
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	$FF
	jp	nz,{-1@}
	
	pop	hl
	ret
;----------------------------------------


;7.2-------------------------------------
;routine:	InputMenu
;description:
;input:		hl=pointer to start of menu
;output:	a=button that's not for menucontrol (if a=FFh hl points to the entered option)
;destroys:
InputMenu:
	inc	hl	;skip first two |'s
	inc	hl

	ld	a,(HP)	;save HP&VP
	ld	b,a
	ld	a,(VP)	
	ld	c,a
	push	bc
	
	xor	a	;set up HP&VP
	ld	(HP),a
	inc	a
	ld	(VP),a

	push	hl	;right at the title

	;skip title
	ld	c,FFh
	ld	a,FFh
	cpir
	
	;gues what, we're gone draw the options

;	ld	b,0	;nope first we gone look were to start
;@:	inc	hl
;	ld	a,(MenuPosition)
;	cp	b
;	jp	z,{@}
;	ld	a,FFh
;	cpir
;	inc	b
;	jp	{-1@}

	;now hl is at the option were we want to start

@:	ld	b,6
@:	call	PrintLine
	ld	a,(hl)
	cp	$FF
	jp	z,{@}
	djnz	{-1@}
	jp	{2@}

@:	halt
	call	PrintWhiteLine
	djnz	{-1@}

	;I think now's the right time for a title

@:	pop	hl
	push	hl
	xor	a
	ld	(VP),a
	call	PrintLine
	pop	hl
	push	hl
	xor	a
	ld	(VP),a
	call	PrintWhiteLine
	
	call	GetButton
	cp	1
	jp	z,scrollDown
	cp	4
	jp	z,scrollUp
	cp	9
	jp	z,{+}
	cp	3
	jp	z,{+}
	jp	{-1@}

scrollupInputMenu:
	ld	a,(MenuSelected)
	cp	0
	jp	z,{@}
	dec	a
	ld	(MenuSelected),a
	jp	{-7@}
@:	ld	a,(MenuPosition)
	cp	0
	jp	z,{@}
	dec	a
	ld	(MenuPosition),a
	jp	{-8@}
@:	call	CountMenuOptions
	ld	a,b
	ld	(MenuPosition),a
	jp	{-9@}

scrolldownInputMenu:
	call	CountMenuOptions
	ld	c,b
	ld	a,(MenuPosition)
	ld	b,a
	ld	a,c
	sub	b
	ld	b,a
	ld	a,(MenuSelected)
	cp	b
	jp	z,{3@}
	cp	6
	jp	z,{@}
	inc	a
	ld	(MenuSelected),a
	jp	{-9@}
@:	call	CountMenuOptions
	ld	a,(MenuPosition)
	cp	b
	jp	z,{@}
	inc	a
	ld	(MenuPosition),a
	jp	{-10@}
@:	xor	a
	ld	(MenuPosition),a
	jp	{-11@}
@:	xor	a
	ld	(MenuSelected),a
	ld	(MenuPosition),a
	jp	{-12@}

+:	;calculate what to call
	ld	a,(MenuPosition)
	ld	b,a
	ld	a,(MenuSelected)
	add	a,b
	ld	b,a

	pop	hl	;place hl at that position
@:	ld	a,(hl)	;skip title
	inc	hl
	cp	$FF
	jp	nz,{-1@}

@:	ld	a,(hl)	;next option
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	inc	hl
	inc	hl
	inc	hl
	djnz	{-1@}

	ld	de,MenuCharacter+2
	ldd
	ldd
	ldd
	ld	hl,MenuCharacter+3
	ld	(hl),201	;opcode for ret
	
	call	PrintScreen

	pop	bc	;restore HP&VP
	ld	a,b
	ld	(HP),a
	ld	a,c
	ld	(VP),a

	call	MenuCharacter
	ret

CountInputMenuOptions:	;returs the number of options form a menu in b, hl=start of title after first two |'s
	push	hl
	ld	b,255

@:	ld	a,(hl)	;skip title
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	
@:	ld	a,(hl)
	inc	hl
	cp	$FF
	jp	nz,{-1@}
	inc	b
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	cp	$FF
	jp	nz,{-1@}
	
	pop	hl
	ret



TestInputMenu:
	.asc	"||TestMenu|"
	.asc	"Option 1|"
	.asc	"Option 2|"
	.asc	"Last Option||"
;----------------------------------------