;include file for vera for the ti83+


;Memory locations

Stack		= FE00h

ExecutionArea	= FF00h	;not lined up, but realy enough space

MenuPosition	= FF72h
MenuSelected	= FF73h
MenuCharacter	= FF75h	;don't know if enough size

Output		= FF7Ch

Input		= FF7Dh

HP 		= FF7Eh
VP 		= FF7Fh
screen 		= FF80h


;routines

.define lock push af \ in a,(6) \ push af \ ld a,28 \ out (6),a \ call LockRom \ pop af \ out (6),a \ pop af
.define unlock push af \ in a,(6) \ push af \ ld a,28 \ out (6),a \ call UnlockRom \ pop af \ out (6),a \ pop af
.define wait rst 8

.define PrintMap(position) push af \ ld hl,position \ call PrintMap \ pop af
.define PrintCharacter(character) push af \ ld a,character \ call PrintCharacter \ pop af
.define PrintString(string) push hl \ ld hl,string \ call PrintString \ pop hl


;Vera Font

.asciimap ' ',00h
.asciimap 'a',01h
.asciimap 'b',02h
.asciimap 'c',03h
.asciimap 'd',04h
.asciimap 'e',05h
.asciimap 'f',06h
.asciimap 'g',07h
.asciimap 'h',08h
.asciimap 'i',09h
.asciimap 'j',0Ah
.asciimap 'k',0Bh
.asciimap 'l',0Ch
.asciimap 'm',0Dh
.asciimap 'n',0Eh
.asciimap 'o',0Fh

.asciimap 'p',10h
.asciimap 'q',11h
.asciimap 'r',12h
.asciimap 's',13h
.asciimap 't',14h
.asciimap 'u',15h
.asciimap 'v',16h
.asciimap 'w',17h
.asciimap 'x',18h
.asciimap 'y',19h
.asciimap 'z',1Ah
.asciimap 'A',1Bh
.asciimap 'B',1Ch
.asciimap 'C',1Dh
.asciimap 'D',1Eh
.asciimap 'E',1Fh

.asciimap 'F',20h
.asciimap 'G',21h
.asciimap 'H',22h
.asciimap 'I',23h
.asciimap 'J',24h
.asciimap 'K',25h
.asciimap 'L',26h
.asciimap 'M',27h
.asciimap 'N',28h
.asciimap 'O',29h
.asciimap 'P',2Ah
.asciimap 'Q',2Bh
.asciimap 'R',2Ch
.asciimap 'S',2Dh
.asciimap 'T',2Eh
.asciimap 'U',2Fh

.asciimap 'V',30h
.asciimap 'W',31h
.asciimap 'X',32h
.asciimap 'Y',33h
.asciimap 'Z',34h
;.asciimap 'b',35h
;.asciimap 'b',36h
;.asciimap 'b',37h
;.asciimap 'b',38h
;.asciimap 'b',39h
;.asciimap 'b',3Ah
;.asciimap 'b',3Bh
;.asciimap 'b',3Ch
;.asciimap 'b',3Dh
;.asciimap 'b',3Eh
;.asciimap 'b',3Fh

;.asciimap 'b',40h
;.asciimap 'b',41h
;.asciimap 'b',42h
;.asciimap 'b',43h
;.asciimap 'b',44h
;.asciimap 'b',45h
;.asciimap 'b',46h
;.asciimap 'b',47h
;.asciimap 'b',48h
;.asciimap 'b',49h
;.asciimap 'b',4Ah
;.asciimap 'b',4Bh
;.asciimap 'b',4Ch
;.asciimap 'b',4Dh
;.asciimap 'b',4Eh
;.asciimap 'b',4Fh

;.asciimap 'b',80
;.asciimap 'b',81
;.asciimap 'b',82
;.asciimap 'b',83
;.asciimap 'b',84
;.asciimap 'b',85
;.asciimap 'b',86
;.asciimap 'b',87
;.asciimap 'b',88
;.asciimap 'b',89
;.asciimap 'b',90
;.asciimap 'b',91
;.asciimap 'b',92
;.asciimap 'b',93
;.asciimap 'b',94
;.asciimap 'b',95

;.asciimap 'b',96
;.asciimap 'b',97
;.asciimap 'b',98
;.asciimap 'b',99
;.asciimap 'b',100
;.asciimap 'b',101
;.asciimap 'b',102
;.asciimap 'b',103
;.asciimap 'b',104
;.asciimap 'b',105
;.asciimap 'b',106
;.asciimap 'b',107
;.asciimap 'b',108
;.asciimap 'b',109
;.asciimap 'b',110
;.asciimap 'b',111

;.asciimap 'b',112
;.asciimap 'b',113
;.asciimap 'b',114
;.asciimap 'b',115
;.asciimap 'b',116
;.asciimap 'b',117
;.asciimap 'b',118
;.asciimap 'b',119
;.asciimap 'b',120
;.asciimap 'b',121
;.asciimap 'b',122
;.asciimap 'b',123
;.asciimap 'b',124
;.asciimap 'b',125
;.asciimap 'b',126
;.asciimap 'b',127

;.asciimap ' ',128
;.asciimap ' ',129
;.asciimap ' ',130
;.asciimap ' ',131
;.asciimap ' ',132
;.asciimap ' ',133
;.asciimap ' ',134
;.asciimap ' ',135
;.asciimap ' ',136
;.asciimap ' ',137
;.asciimap ' ',138
;.asciimap ' ',139
;.asciimap ' ',140
;.asciimap ' ',141
;.asciimap ' ',142
;.asciimap ' ',143

;.asciimap ' ',144
;.asciimap ' ',145
;.asciimap ' ',146
;.asciimap ' ',147
;.asciimap ' ',148
;.asciimap ' ',149
;.asciimap ' ',150
;.asciimap ' ',151
;.asciimap ' ',152
;.asciimap ' ',153
;.asciimap ' ',154
;.asciimap ' ',155
;.asciimap ' ',156
;.asciimap ' ',157
;.asciimap ' ',158
;.asciimap ' ',159

;.asciimap ' ',A0h
;.asciimap ' ',A1h
;.asciimap ' ',A2h
.asciimap '0',A3h
.asciimap '1',A4h
.asciimap '2',A5h
.asciimap '3',A6h
.asciimap '4',A7h
.asciimap '5',A8h
.asciimap '6',A9h
.asciimap '7',AAh
.asciimap '8',ABh
.asciimap '9',ACh
;.asciimap ' ',ADh
;.asciimap ' ',AEh
;.asciimap ' ',AFh

;.asciimap ' ',B0h
;.asciimap ' ',B1h
;.asciimap ' ',B2h
;.asciimap ' ',B3h
;.asciimap ' ',B4h
;.asciimap ' ',B5h
;.asciimap ' ',B6h
;.asciimap ' ',B7h
;.asciimap ' ',B8h
;.asciimap ' ',B9h
.asciimap '.',BAh
;.asciimap ' ',BBh
;.asciimap ' ',BCh
;.asciimap ' ',BDh
;.asciimap ' ',BEh
;.asciimap ' ',BFh

;.asciimap ' ',192
;.asciimap ' ',193
.asciimap '=',194
.asciimap '>',195
.asciimap '<',196
.asciimap '(',197
.asciimap ')',198
;.asciimap ' ',199
;.asciimap ' ',200
;.asciimap ' ',201
;.asciimap ' ',202
.asciimap '.',203
;.asciimap ' ',204
;.asciimap ' ',205
;.asciimap ' ',206
;.asciimap ' ',207

;.asciimap ' ',208
;.asciimap ' ',209
;.asciimap ' ',210
;.asciimap ' ',211
;.asciimap ' ',212
;.asciimap ' ',213
;.asciimap ' ',214
;.asciimap ' ',215
;.asciimap ' ',216
;.asciimap ' ',217
;.asciimap ' ',218
;.asciimap ' ',219
;.asciimap ' ',220
;.asciimap ' ',221
;.asciimap ' ',222
;.asciimap ' ',223

;.asciimap ' ',224
;.asciimap ' ',225
;.asciimap ' ',226
;.asciimap ' ',227
;.asciimap ' ',228
;.asciimap ' ',229
;.asciimap ' ',230
;.asciimap ' ',231
;.asciimap ' ',232
;.asciimap ' ',233
;.asciimap ' ',234
;.asciimap ' ',235
;.asciimap ' ',236
;.asciimap ' ',237
;.asciimap ' ',238
;.asciimap ' ',239

;.asciimap ' ',240
;.asciimap ' ',241
;.asciimap ' ',242
;.asciimap ' ',243
;.asciimap ' ',244
;.asciimap ' ',245
;.asciimap ' ',246
;.asciimap ' ',247
;.asciimap ' ',248
;.asciimap ' ',249
;.asciimap ' ',250
;.asciimap ' ',251
;.asciimap ' ',252
;.asciimap ' ',253
;.asciimap ' ',254
.asciimap '|',255