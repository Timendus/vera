;3	memory routines:


;3.1-------------------------------------
;routine:	FindFile
;description:
;input:		a=filetype, bc=number of hit to output (0 is the first), (de)=folder, (hl)=name
;output:	z set=not found z not set=found bc=size, hl=start position of file
;destroys:

.define	stack_up dec sp \ dec sp \ dec sp \ dec sp \ dec sp \ dec sp
.define stack_down inc sp \ inc sp \ inc sp \ inc sp \ inc sp \ inc sp

FindFile:
	push	hl
	push	de
	push	af

	ld	hl,8002h
-:	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	dec	hl
	push	hl
	inc	hl \ inc hl
	push	de
	push	bc


	;type check
	stack_down
	pop	af	;a=type
	dec	sp \ dec sp
	stack_up

	cp	FFh	;check filetype
	jp	z,{+}	;if FFh/doesn't matter what filetype check folder
	cp	(hl)
	jp	nz,FindFile_Next	;if not the same next file



+:	;folder check
	stack_down
	pop	de
	pop	de	;de=folder
	dec	sp \ dec sp \ dec sp \ dec sp
	stack_up

	inc	hl
	ld	c,11	;counter=11
	ld	a,(de)	;a=first leter of folder
	cp	FFh	;if that's  FFh,
	jp	z,{+}	;move onto name check
@:	ld	a,(de)	;a=first leter of folder again
	cp	(hl)	;cp with folder
	jp	nz,FindFile_Next
	cp	FFh	;last token the same?
	jp	z,{+}	;move on to name
	inc	hl
	inc	de
	dec	c
	jp	{-1@}	;next character





+:	;name check
	stack_down
	pop	de
	pop	de
	pop	de	;de=file
	dec	sp \ dec sp \ dec sp \ dec sp \ dec sp \ dec sp
	stack_up

@:	xor	a	;set hl to right position
@:	cp	c
	jp	z,{@}
	dec	c
	inc	hl
	jp	{-1@}


	inc	hl
	ld	a,(de)	;a=first leter of name
	cp	FFh	;if that's  FFh,
	jp	z,{+}	;move onto number check
@:	ld	a,(de)	;a=first leter of name again
	cp	(hl)	;cp with name
	jp	nz,FindFile_Next
	cp	FFh	;last token the same?
	jp	z,{+}	;move on to number
	inc	hl
	inc	de
	jp	{-1@}	;next character









+:	;number check
	pop	bc
	xor	a
	cp	b
	jp	nz,{@}
	cp	c
	jp	nz,{@}
	jp	{+}

@:	dec	bc
	jp	FindFile_NextHit





+:	;HIT
	pop	bc	;size
	pop	hl	;start of file
	stack_down
	cp	1	;check if a is 1, what is not the case
	ret







FindFile_Next:
	pop	bc
FindFile_NextHit
	pop	de
	pop	hl
	add	hl,de

	;check with (8000h)
	ld	a,(8001h)
	cp	h
	jp	z,{@}
	jp	nc,{-}
@:	ld	a,(8000h)
	cp	l
	jp	z,{@}
	jp	nc,{-}
@:	;not found ret with z set
	stack_down
	ret
;----------------------------------------


;3.2-------------------------------------
;routine:	NewFile
;description:
;input:		a=type, bc=size, (de)=folder, (hl)=name
;output:	
;destroys:
NewFile:
	push	hl	;push pointer to filename
	ld	hl,(8000h)

	push	hl	;check if there is room (nog niet gedacht aan stack)
	add	hl,bc

	;push	bc	;compensate for stack and metadata size
	;ld	bc,25+MaxStackSize
	;add	hl,bc
	;pop	bc

	bit	7,h
	pop	hl

	jp	z,{@}	;ret if too big
	pop	hl
	ret

@:	set	7,h	;add 8000h
	inc	hl	;skip fs size
	inc	hl

	push	hl	;add metadatasize
	ld	h,b
	ld	l,c
	ld	bc,25
	add	hl,bc
	ld	b,h
	ld	c,l
	ld	hl,(8000h)	;write new fs size
	add	hl,bc
	ld	(8000h),hl
	pop	hl	;go on with file size
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl

	ld	(hl),a	;write type
	inc	hl

	ld	b,0
	ld	c,11	;write folder
	ld	a,FFH
	ex	de,hl
@:	ldi
	cp	(hl)
	jp	nz,{-1@}
	ld	a,FFh
	ld	(de),a
	inc	de
	dec	c
	xor	a
@:	ld	(de),a
	inc	de
	dec	c
	cp	c
	jp	nz,{-1@}

	pop	hl	;write title
	ld	b,0
	ld	c,11
	ld	a,FFH
@:	ldi
	cp	(hl)
	jp	nz,{-1@}
	ld	a,FFh
	ld	(de),a
	inc	de
	dec	c
	xor	a
@:	ld	(de),a
	inc	de
	dec	c
	cp	c
	jp	nz,{-1@}

	ret
;----------------------------------------


;3.3-------------------------------------
;routine:	DeleteFile
;description:
;input:		(hl)=name, (de)=folder, a=type
;output:	
;destroys:
DeleteFile:
	;locate file
	ld	bc,0
	call	FindFile
	;set up:
	;de=top of file
	;hl=end of file
	ld	d,h
	ld	e,l
	add	hl,bc

	ld	bc,(8000h)
	set	7,b	;add 8000h to bc
	inc	bc
	inc	bc	;add another 2
-:	ld	a,b
	cp	h
	jp	nz,{@}
	ld	a,c
	cp	l
	jp	z,{+}	;hl is at the end of the filesystem

@:	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	jp	{-}

	;time to fill the rest up with zeros
+:	;halt

	ex	de,hl	;hl=end of filesystem
	push	hl	;needed later to update filessystem size
@:	ld	(hl),0

	;cp hl,bc
	ld	a,h
	cp	b
	jp	nz,{@}
	ld	a,l
	cp	c
	jp	nz,{@}

	pop	hl	;update filesystem size
	res	7,h	;sub 8000h
	dec	hl
	dec	hl	;sub another 2
	ld	(8000h),hl
	ret		;done, file is gone

@:	inc	hl
	jp	{-2@}
;----------------------------------------