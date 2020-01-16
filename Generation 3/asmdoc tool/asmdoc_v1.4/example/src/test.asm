;; Vera - the calc lover's OS,
;; copyright (C) 2007 The Vera Development Team.
;; 
;; This is a test assembly file to test the reference implementation
;; asmdoc tool.
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; ===================
; We'll put in a fake console routine here

;; === console.printline ===
;;
;; Print a null terminated string to the display
;; using some crappy display port writes
;;
;; Don't use it too often, it'll fry your screen :-)
;;
;; Authors:
;;   John Doe (j.doe@mycompany.com)
;;   The President (president@whitehouse.gov)
;;
;; Pre:
;;   hl = pointer to string
;;
;; Post:
;;   String displayed on screen
;;   hl,bc,a destroyed
;;
;; SeeAlso:
;;   console.putchar, console.set_cursor_x, console.set_cursor_y
;;
;; Warning:
;;   Do not call this function if you have manually
;;   set console_cursor_x or console_cursor_y outside
;;   the console boundaries.
;;
;; Example:
;;    	ld hl,str_welcome
;;    	call console.printline
;;    	ret
;;   str_welcome:
;;    	.db "Welcome to Vera",0

console.printline:
	ret

;; === console.newline ===
;;
;; Print a newline to the console
;;
;; Post:
;;   Updated cursor position, scrolled screen if necessary
;;   hl,a destroyed
;;
;; SeeAlso:
;;   console.printline, console.set_cursor_x, console.set_cursor_y
;;
;; Example:
;;    	call console.newline
;;
;; Authors:
;;   John Doe (j.doe@mycompany.com)
;;   The President (president@whitehouse.gov)

console.newline:
	ret

; === console.putchar ===
;
; Internally used routine, just one semicolon
;
; Pre:
;   a = character
;
; Post:
;   Character put on display
;   hl,a destroyed
;
; SeeAlso:
;   console.printline
;
; Example:
;   	ld a,'F'
;    	call console.putchar

console.putchar:
	ret

; ===================
; End of file
; ===================

