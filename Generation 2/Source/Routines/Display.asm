;1 	display routines:


;1.1	Text


;1.1.1-----------------------------------
;routine:	PrintMap
;description:	Prints a 8*6 map from a 8 byte map out of the memory 
;input:		hl=pointer to map, HP=Horizontal Position (0,15), VP=Vertical Position (0,7), Output=draw inverted if bit 7 is set
;output:	hl=pointer to next map
;destroys:	a,b
PrintMap:
	;check 6 bit & x-inc mode (text)
	ld	a,(VP)
	rlc	a
	rlc	a
	rlc	a
	add	a,80h
	out	($10),a
	WAIT
	ld	a,(HP)
	add	a,20h
	out	($10),a
	WAIT

	ld	a,(Output)
	bit	7,a
	jp	nz,{+}
 
	;normal
	ld	b,8
@:	ld	a,(hl)
	out	($11),a
	WAIT
	inc	hl
	djnz	{-1@}
	ret

	;inverted
+:	ld	b,8
@:	ld	a,(hl)
	xor	FFh
	out	($11),a
	WAIT
	inc	hl
	djnz	{-1@}
	ret
;----------------------------------------


;1.1.2-----------------------------------
;routine:	PrintLine
;description:
;input:		
;output:	
;destroys:
PrintLine:
	push	hl	;character to fontoffset
	ld	l,(hl)
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,font
	add	hl,de

@:	call	PrintMap
	pop	hl
	inc	hl
	ld	a,(HP)
	inc	a
	ld	(HP),a
	cp	$10
	jp	z,{@}
	ld	a,(hl)
	cp	$FF
	jp	nz,PrintLine
	dec	hl
	push	hl
	ld	hl,Font
	jp	{-1@}
@:	ld	a,(VP)
	inc	a
	ld	(VP),a
	xor	a
	ld	(HP),a
	ret
;----------------------------------------


;1.1.3-----------------------------------
;routine:	PrintWhiteLine
;description:	Prints a whole line blank/cleared
;input:		VP=line to paint white (0,7)
;output:	VP=updated, HP=0
;destroys:	a
PrintWhiteLine:
	push	hl
	xor	a
	ld	(HP),a
@:	ld	hl,Font
	call	PrintMap
	ld	a,(HP)
	inc	a
	ld	(HP),a
	cp	$10
	jp	nz,{-1@}
	xor	a
	ld	(HP),a
	ld	a,(VP)
	inc	a
	ld	(VP),a
	pop	hl
	ret
;----------------------------------------


;1.2 	Screen


;1.1.2-----------------------------------
;routine:	PrintCharacter
;description:	Prints a character from the vera font
;input:		a=character (0,255), HP=Horizontal Position (0,15), VP=Vertical Position (0,7)
;output:	Updated HP/VP
;destroys:	af,bc,de
PrintCharacter:
	push	af
	push	hl
	ld	a,(VP)
	cp	8
	jp	nz,{@}
	ld	hl,screen+10h
	ld	de,screen
	ld	bc,70h
	ldir
	ld	hl,screen+70h
	ld	(hl),0
	ld	de,screen+71h
	ld	bc,0Fh
	ldir
	call	PrintScreen
	ld	a,7
	ld	(VP),a
	xor	a
	ld	(HP),a
@:	pop	hl
	pop	af

	push	hl
	push	af	;write to screen
	ld	a,(VP)
	rlc	a
	rlc	a
	rlc	a
	rlc	a
	ld	b,a
	ld	a,(HP)
	add	a,b
	ld	l,a
	ld	h,0
	ld	bc,screen
	add	hl,bc
	pop	af
	ld	(hl),a
	
	ld	l,a	;write to lcd
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	bc,font
	add	hl,bc
	call	PrintMap

	ld	a,(HP)	;update position
	cp	15
	jp	nz,{@}
	ld	a,(VP)
	inc	a
	ld	(VP),a
	xor	a
	ld	(HP),a
	pop	hl
	ret
@:	inc	a
	ld	(HP),a
	pop	hl
	ret
;----------------------------------------


;1.1.3-----------------------------------
;routine:	PrintString
;description:	Prints a FFh or '|' terminated string
;input:		hl=pointer to string, HP=Horizontal Position (0,15), VP=Vertical Position (0,7)
;output:	Updated HP/VP, hl=pointer to FFh/'|' byte of string
;destroys:	a
PrintString:
	ld	a,(hl)
	cp	FFh
	ret	z
	call	PrintCharacter
	inc	hl
	jp	PrintString	
;----------------------------------------


;1.1.4-----------------------------------
;routine:	PrintScreen
;description:	Prints the whole screen
;input:
;output:
;destroys:
PrintScreen:
	xor	a
	ld	(HP),a
	ld	(VP),a
	ld	hl,screen
-:
	push	hl
	ld	l,(hl)
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,font
	add	hl,de
	call	PrintMap

	ld	a,(HP)
	cp	15
	jp	nz,{+}
	ld	a,(VP)
	inc	a
	cp	8
	jp	z,{@}
	ld	(VP),a
	ld	a,FFh
+:	inc	a
	ld	(HP),a
	pop	hl

	inc	hl
	jp	{-}

@:	pop	hl
	xor	a
	ld	(VP),a
	ld	(HP),a
	ret	
;----------------------------------------