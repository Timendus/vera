;interprenter routines:


;6.1-------------------------------------
;routine:	Interprent
;description:
;input:		(hl)=string that needs to be interprented
;output:	
;destroys:
Interprent:

	;check if conditional

	;search Commands with the name user typed

	ld	a,Command
	ld	bc,0
	ld	de,Vera
	;hl=hl
	call	FindFile
	;;;;;check if found
	ld	bc,25
	add	hl,bc
	call	{@}
	ret
@:	jp	(hl)

	Command = AAh
Vera:	.db "Vera",FFh

commando:
	ret
;----------------------------------------