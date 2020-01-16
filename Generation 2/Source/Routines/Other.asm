;8	other routines:


;8.1-------------------------------------
;routine:	delay
;description: 	gives a short delay, can be called with "wait"
;input:
;output:
;destroys:	f
delay:
	push bc
	ld bc,$10
@:
	in f,(c)
	jp p,{@}
	djnz {-1@}
@:
	pop bc
	ret
;----------------------------------------


;8.2-------------------------------------
;routine:	CalculateStringLength
;description: 	calculates the length of the string pointed to
;input:		hl=pointer to string
;output:	a=length of the string (0,255)
;destroys:
CalculateStringLength:
	push	bc
	ld	b,0
@:	ld	a,(hl)
	cp	$FF
	jp	z,{@}
	inc	hl
	inc	b
	jp	{-1@}
@:	ld	a,b
	pop	bc
	ret
;---------------------------------------- 


;8.3-------------------------------------
;routine:	CompareStrings
;description: 	checks if 2 strings are the same or not
;input:		hl=pointer to the fitst string, de=pointer to the other string
;output:	zero flag=set if the same
;destroys:
CompareStrings:
	ld	a,(de)
	cpi
	inc	de
	ret	nz
	cp	FFh
	ret	z
	jp	CompareStrings
;----------------------------------------


;8.4-------------------------------------
;routine:	BackupRam
;description:	moves page 64 (ram page zero) to page 29 (ram backup), ram data is not cleared
;input:
;output:
;destroys:
BackupRam:
	ld	b,64
	ld	c,29
	call	MovePage
	ret
;----------------------------------------


;8.5-------------------------------------
;routine:	RestoreRam
;description:	moves page 29 (ram backup) to page 64 (ram page zero), rom data is cleared
;input:
;output:
;destroys:
RestoreRam:
	ld	b,29
	ld	c,64
	call	MovePage

	;clear page 29 (ram backup)
	ld	b,28	;page 28 to BackupSector
	ld	c,24
	call	MovePage

	ld	a,7	;clear sector 7
	call	ClearSector
	
	ld	b,24	;restore page 28 from BackupSector
	ld	c,28
	call	MovePage

	ld	a,6	;clear BackupSector
	call	ClearSector	
	ret
;----------------------------------------


;8.6-------------------------------------
;routine:	ClearSector
;description:	clears a sector
;input:		a=sector to clear (0,7)
;output:
;destroys:
ClearSector:
	push	af
	unlock
	pop	af

	rlc	a	;execute from ram
	rlc	a
	ld	hl,ClearSector_start
	ld	de,ExecutionArea
	ld	bc,ClearSector_end-ClearSector_start
	ldir
	
	out	(7),a
	ld	a,b
	out	(6),a

	call	ExecutionArea

	lock
	
	ret
;----------------------------------------


;8.7-------------------------------------
;routine:	MovePage
;description:	moves a page from source to destination, source is left intact
;input:		b=source (0,31/64/65), c=destination (0,29/64/65)
;output:
;destroys:
MovePage:
	bit	6,c
	jp	nz,MovePageRam
	
	push	bc
	unlock
	ld	hl,MovePage_start
	ld	de,ExecutionArea
	ld	bc,MovePage_end-MovePage_start
	ldir
	pop	bc

	ld	a,b	;bank b is source
	out	(7),a
	ld	a,c	;bank a is destination
	out	(6),a

	call	ExecutionArea
	lock
	ret

MovePageRam:
	ld	a,b	;bank b is source
	out	(7),a
	ld	a,c	;bank a is destination
	out	(6),a
	ld	hl,8000h
	ld	de,4000h
	ld	bc,4000h
	ldir
;----------------------------------------