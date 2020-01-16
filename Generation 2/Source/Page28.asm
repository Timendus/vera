;called routines:

UnlockRom:
	ld	a,1	;unlock
	di
	nop
	nop
	im	1
	di
	out	(14h),a
	ret
LockRom:
	xor	a	;lock
	di
	nop
	nop
	im	1
	di
	out	(14h),a
	ret

;copied routines:

ClearSector_start:
	out	(6),a
	ld	a,AAh
	ld	(AAAh),a
	ld	a,55h
	ld	(555h),a
	ld	a,80h
	ld	(AAAh),a
	ld	a,AAh
	ld	(AAAh),a
	ld	a,55h
	ld	(555h),a
	ld	a,30h
	ld	(4000h),a

@:	ld	a,(4000h)
	bit	7,a
	jr	nz,{@}
	bit	5,a
	jr	z,{-1@}
@:	ret
ClearSector_end:
.echo "ClearSector = ",ClearSector_end-ClearSector_start," Bytes\n"

MovePage_start:
	ld	hl,8000h	;bank a is source
	ld	de,4000h	;bank b is destination
	ld	bc,4000h	;counts to zero
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
MovePage_end:
.echo "MovePage = ",MovePage_end-MovePage_start," Bytes\n"