.binaryrange $0000, $7FFFF

.defpage 00, $00000, $4000, $0000 
.defpage 01, $04000, $4000, $4000
.defpage 02, $08000, $4000, $4000
.defpage 03, $0C000, $4000, $4000
.defpage 04, $10000, $4000, $4000
.defpage 05, $14000, $4000, $4000
.defpage 06, $18000, $4000, $4000
.defpage 07, $1C000, $4000, $4000
.defpage 08, $20000, $4000, $4000
.defpage 09, $24000, $4000, $4000
.defpage 10, $28000, $4000, $4000
.defpage 11, $2C000, $4000, $4000
.defpage 12, $30000, $4000, $4000
.defpage 13, $34000, $4000, $4000
.defpage 14, $38000, $4000, $4000
.defpage 15, $3C000, $4000, $4000
.defpage 16, $40000, $4000, $4000
.defpage 17, $44000, $4000, $4000
.defpage 18, $48000, $4000, $4000
.defpage 19, $4C000, $4000, $4000
.defpage 20, $50000, $4000, $4000
.defpage 21, $54000, $4000, $4000
.defpage 22, $58000, $4000, $4000
.defpage 23, $5C000, $4000, $4000
.defpage 24, $60000, $4000, $4000
.defpage 25, $64000, $4000, $4000
.defpage 26, $68000, $4000, $4000
.defpage 27, $6C000, $4000, $4000
.defpage 28, $70000, $4000, $4000
.defpage 29, $74000, $4000, $4000
.defpage 30, $78000, $4000, $4000
.defpage 31, $7C000, $4000, $4000

;sector 0
.page 00
.include "page0.asm"
.echo "Page 00 = ",$/163.84, "% Full\n"
.page 01
.page 02
.page 03

;sector 1
.page 04
.page 05
.page 06
.page 07

;sector 2
.page 08
.page 09
.page 10
.page 11

;sector 3
.page 12
.page 13
.page 14
.page 15

;sector 4
.page 16
.page 17
.page 18
.page 19

;sector 5
.page 20
.page 21
.page 22
.page 23

;sector 6
.page 24
.page 25
.page 26
.page 27

;sector 7
.page 28
.include "page28.asm"
.echo "Page 28 = ",($-4000h)/163.84, "% Full\n"
.page 29

;sector 8+9
.page 30

;sector 10
.page 31

.end