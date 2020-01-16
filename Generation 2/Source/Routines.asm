;Vera Subroutines


;index:

;1 	display routines:
;1.1	text
;1.1.1	PrintMap
;1.1.2	PrintLine
;1.1.3	PrintWhiteLine
;1.2	screen
;1.2.1	PrintCharacter
;1.2.2	PrintString
;1.2.3	PrintScreen
;1.3	graphic

;2	input routines:
;2.1	GetButton
;2.2	InterpretButton
;2.3	GetString

;3	memory routines:
;3.1	ram routines:
;3.1.1	FindFile
;3.1.2	NewFile
;3.1.3	DeleteFile

;5	mathematical routines:

;6	interpreter routines:

;7	user interface routines:
;7.1	Menu
;7.2	InputMenu

;8	other routines:
;8.1	delay
;8.2	CalculateStringLength
;8.3	CompareString
;8.4	BackupRam
;8.5	RestoreRam
;8.6	ClearSector
;8.7	MovePage

;routines:

	.include "Routines\Display.asm"

	.include "Routines\Input.asm"

	.include "Routines\Memory.asm"

	.include "Routines\Storage.asm"

	;?

	;math

	.include "Routines\Interprenter.asm"

	.include "Routines\User Interface.asm"

	.include "Routines\Other.asm"





