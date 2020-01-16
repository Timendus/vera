;4	Storage Routines:


;Some routines in this file use the stack_up and stack_down definitions from FindFile


;4.1-------------------------------------
;routine:	FindFlashFile
;description:
;input:		a=filetype, bc=number of hit to output (0 is the first), (de)=folder, (hl)=name
;output:	z:not found nz:found a=page, (hl)=start of the file, bc=size of file
;destroys:
FindFlashFile:

	push	hl
	push	de
	push	af

	ld	a,1	;first page to be checked
	out	(6),a	;swap in bank a

--:	;the check nextpagelabel
	ld	hl,4000h

-:	;the check nextfilelabel
	ld	e,(hl)	;ld de,(hl) de=size
	inc	hl
	ld	d,(hl)
	dec	hl
	ld	a,FFh	;check if de=FFFFh that means last file
	cp	e	;if e<>FFh
	jp	nz,{@}	;then this is not the last file
	cp	d	;if d=FFh and we are here this is the last file
	jp	z,FindFlashFile_NextPage	;so check out the next page
@:	push	hl	;push start of file
	inc	hl \ inc hl	;so hl points to filetype
	push	de	;push filesize
	push	bc	;push number of hits to skip

	;this is comented out cause fragmented files are not yet implemented
	;if they were bit 7 of d would be set if this was a fragment without metadata
	;bit	7,d
	;res	7,d
	;jp	z,FindFileFlash_NextFile

	;the big checking starts right here
	;type check
	stack_down
	pop	af	;a=type
	dec	sp \ dec sp
	stack_up

	cp	FFh	;check filetype
	jp	z,{+}	;if FFh/doesn't matter what filetype check folder
	cp	(hl)
	jp	nz,FindFlashFile_Next	;if not the same next file

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
	jp	nz,FindFlashFile_Next
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


@:	ld	a,(de)	;a=first leter of name
	cp	FFh	;if that's  FFh,
	jp	z,{+}	;move onto number check
@:	ld	a,(de)	;a=first leter of name again
	cp	(hl)	;cp with name
	jp	nz,FindFlashFile_Next
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

@:	dec	bc	;we've had a hit
	push	bc	;store bc again
	jp	FindFlashFile_Next

+:	;HIT
	pop	bc	;size
	pop	hl	;start of file
	in	a,(6)	;page of file
	stack_down
	cp	FFh	;reset zero flag so we return nz, there is no way we found somethin on page FFh
	ret

FindFlashFile_Next:
	pop	bc
	pop	de
	pop	hl
	add	hl,de
	;ld	a,h	;check if h>=40h just for safety
	;cp	40h
	;jp	c,{-}	;if h<40h check the next file, else next page
	jp	{-}

FindFlashFile_NextPage
	Stack_down	;in case this was the last page and we have to ret
	in	a,(6)
	inc	a
	cp	20
	ret	z	;we have had al available pages but found nothing so ret with zero flag set
	out	(6),a
	Stack_up	;we didn't have to ret so put the stack back up
	jp	{--}
;----------------------------------------


;4.2-------------------------------------
;routine:	StoreFile
;description:
;input:		a=filetype, (de)=folder, (hl)=name
;output:	z:file not found in ram
;destroys:
StoreFile:
	push	af
	push	de
	push	hl

	ld	bc,0	;we want the first hit
	call	FindFile
	ret	z	;return if file is not found in RAM

	pop	hl	;refresh hl, de and af
	pop	de
	pop	af
	Stack_Up

	ld	bc,0
	call	FindFlashFile
	jp	z,{+}	;if not found, continue to store
	;else, when the file already exists in flash, set some flag and return watch out for the stack
	ret

+:	;Search for the page with the most space
	ld	de,FFFFh
	push	de	;stack holds the end of the files at the page with the most spave
	ld	b,0	;b holds the page we check at the moment

-:	inc	b
	ld	a,20	;page after last usable page
	cp	b	;compare with the page we're wana check
	jp	z,{+}	;if b=20 go to the next +, to check if the space is big enough
	ld	a,b
	out	(6),a	;load page in bank a
	ld	hl,4000h

@:	ld	e,(hl)	;ld de,(hl) de=size
	inc	hl
	ld	d,(hl)
	dec	hl
	ld	a,FFh	;check if de=FFFFh that means last file
	cp	e	;if e<>FFh
	jp	nz,{@}	;then this is not the last file
	cp	d	;if d=FFh and we are here this is the last file
	jp	z,{2@}	;so we can check out how much space is left
@:	add	hl,de
	jp	{-2@}	;next file

@:	pop	de	;de=end of files on biggest page seen
	ld	a,d	;cp de,hl
	cp	h
	jp	nc,{@}
	ld	a,l
	cp	e
	jp	c,{-}
@:	in	a,(6)	;remember biggest page
	ld	c,a
	push	hl
	jp	{-}

+:	;space check
	ld	a,c
	out	(6),a

	pop	bc
	pop	hl
	pop	de
	pop	af
	Stack_Up
	push	bc
	ld	bc,0
	call	FindFile
	ex	de,hl
	pop	hl
	push	hl
	push	de
	push	bc
	add	hl,bc	;add start and size of file
	ld	a,h
	cp	80h	;if we keep under the 8000h
	jp	c,{+}	;we can go on and store the file

	;zet stack goed
	ccf
	ret	c	;return if the file doesn't fit at the page with most free space

+:	;load up ExecutionArea
	ld	hl,StoreFile_FlashEm_start
	ld	de,ExecutionArea
	ld	bc,StoreFile_FlashEm_end-StoreFile_FlashEm_start
	ldir

	pop	bc
	pop	hl
	pop	de
	Stack_Down
	call	ExecutionArea
	ret

StoreFile_FlashEm_start:
@:	ld	a,AAh
	ld	(AAAh),a
	ld	a,55h
	ld	(555h),a
	ld	a,A0h
	ld	(AAAh),a
	ldi
	nop \ nop \ nop \ nop \ nop \ nop \ nop \ nop
	ret	po
	jr	{-1@}
StoreFile_FlashEm_end:
.echo "StoreFile_FlashEm = ",StoreFile_FlashEm_end-StoreFile_FlashEm_start," Bytes\n"
;----------------------------------------


;4.3-------------------------------------
;routine:	LoadFile
;description:
;input:		a=filetype, bc=number of hit to load (0 is the first), (de)=folder, (hl)=name
;output:	found/space
;destroys:
LoadFile:
	push	af
	push	de
	push	hl

	call	FindFlashFile
	ret	z	;if not foud ret, stack ain't ok

	push	af
	push	hl
	push	bc
	Stack_Down

	pop	hl
	pop	de
	pop	af
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc

	call	NewFile

	;ret if necesary

	;NewFile returns de as pointer to tha space
	Stack_Up
	Stack_Up
	pop	bc
	pop	hl
	pop	af
	Stack_Down
	out	(6),a
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	dec bc \ dec bc \ dec bc \ dec bc \ dec bc
	inc hl \ inc hl \ inc hl \ inc hl \ inc hl
	inc hl \ inc hl \ inc hl \ inc hl \ inc hl
	inc hl \ inc hl \ inc hl \ inc hl \ inc hl
	inc hl \ inc hl \ inc hl \ inc hl \ inc hl
	inc hl \ inc hl \ inc hl \ inc hl \ inc hl
	ldir
	ret
;----------------------------------------


;4.4-------------------------------------
;routine:	DeleteFlashFile
;description:
;input:		a=filetype, bc=number of hit to load (0 is the first), (de)=folder, (hl)=name
;output:	found/space
;destroys:
DeleteFlashFile:

;----------------------------------------