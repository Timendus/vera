;; Vera - the calc lover's OS,
;; copyright (C) 2007 The Vera Development Team.
;;
;; This file provides memory allocation routines for handling the RAM.
;; It doesn't handle the Flash memory, in spite of it's name.
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


; =====================
; The header structure is as follows:
;
;     byte status;   // Either MEM_TAKEN, MEM_FREE or MEM_END
;     word size;     // Also offset to next header
;
; Followed by <size> bytes of data. So an example of the data after
; RAMSTART would be:
;
; .db MEM_TAKEN  ; Mark beginning of allocated memory
; .dw $XXXX      ; Number of bytes allocated (also offset to next)
; .db <XXXX bytes of data>
;
; .db MEM_FREE   ; Mark beginning of freed memory, but not end of list
; .dw $XXXX      ; Number of freed bytes, offset to next
; .db <XXXX bytes of noise>
;
; .db MEM_TAKEN  ; Mark beginnen of second block
; .dw $XXXX      ; Number of bytes allocated (also offset to end)
; .db <XXXX bytes of data>
;
; .db MEM_END    ; Anything other than FREE or TAKEN will do
;
; This assumes that three blocks have been allocated, and the second
; has yet been freed.
; ======================


MEM_TAKEN      = $AA      ; %10101010
MEM_FREE       = $55      ; %01010101
MEM_END        = $00      ; Anything other than FREE or TAKEN will do

MEM_EXECSTART  = $8000
MEM_RAMSTART   = $C000
MEM_RAMEND     = STACKSTART - 300  ; Stay 300 bytes away from stack start

MIN_SPLIT_SIZE = 10       ; 3 bytes header + some payload


;; === memory_init ===
;;
;; Initialize the RAM for use (currently just clears it all, we could
;; consider doing something useful with it ;-))
;;
;; Authors:
;;   Tim Franssen (mail@timendus.com)

memory_init:
   push af
   push hl
   push de
   push bc
   ld hl,MEM_RAMSTART
   ld de,MEM_RAMSTART+1
   ld bc,MEM_RAMEND - MEM_RAMSTART - 1
   xor a
   ld (hl),a
   ldir
   pop bc
   pop de
   pop hl
   pop af
   ret


;; === memory_allocate ===
;;
;; Allocate a chunk of memory for data storage. The pointer you receive
;; can point to a memory block larger than you requested, but you can
;; not count on that. You also have no guarantee that the memory will be
;; executable (stored before $C000) or that it will be reset to zero (so
;; make sure you initialize it properly before using it).
;;
;; Also, make sure you store the received pointer away carefully, because
;; you'll be needing it to free the memory later.
;;
;; Authors:
;;   Tim Franssen (mail@timendus.com)
;;
;; Pre:
;;   bc = number of bytes that you want allocated
;;
;; Post:
;;   c = set if memory was not available
;;   hl = pointer to allocated memory if c is reset
;;   The accumulator will be destroyed

memory_allocate:
   push de
   ld hl,MEM_RAMSTART              ; Start searching for free space from
memory_allocate_search:                 ; beginning of data RAM
   ld a,(hl)
   cp MEM_TAKEN
   jp z,memory_allocate_next       ; No space free here
   cp MEM_FREE
   jp z,memory_allocate_checksize  ; Space free here, but is it enough?

   ; It's neither taken nor freed, so we've reached the end of the list

memory_allocate_found:
   ; Allocate memory at hl as ours!
   ; TODO: Check if we've crossed MEM_RAMEND!
   ld a,MEM_TAKEN
   ld (hl),a                       ; Mark it as taken
   inc hl
   ld (hl),b                       ; Store it's size
   inc hl
   ld (hl),c
   inc hl
   push hl
   add hl,bc                       ; Get a pointer to the next node
   ld (hl),MEM_END                 ; And mark it as the end of the list
   pop hl
   or a                            ; Clear carry flag
   pop de
   ret                             ; Return pointer in hl

memory_allocate_next:
   ; This one is taken, advance pointer to next
   inc hl
   ld d,(hl)                       ; Get it's size
   inc hl
   ld e,(hl)
memory_allocate_next_go:                ; Label used by checksize
   inc hl
   add hl,de                       ; Add it to the pointer
   jp memory_allocate_search       ; and move on

memory_allocate_checksize:
   ; We've found a freed space, is it big enough?

   inc hl                          ; Get it's size
   ld d,(hl)
   inc hl
   ld e,(hl)

;   "cp de,bc"                      ; Compare it to requested size
   ex de,hl
   or a
   sbc hl,bc
   add hl,bc
   ex de,hl

   jp c,memory_allocate_next_go    ; It doesn't fit, find next

   ; It does fit, mark it as taken
   dec hl
   dec hl
   ld a,MEM_TAKEN
   ld (hl),a
   inc hl

   ; Split it up or use it whole?
   ; de = size of block
   ; bc = requested size
   push hl
   ld hl,MIN_SPLIT_SIZE-1
   add hl,bc
   sbc hl,de                       ; We know carry is reset
   pop hl

   ; c = de >= bc+10 = split
   ; nc = de < bc+10 = use whole
   jp c,memory_allocate_checksize_split

   ; Allocate the entire block, don't change it's size
   inc hl
   inc hl                          ; Fix pointer to return
   pop de
   ret                             ; We know carry is reset

memory_allocate_checksize_split:
   ; Split the block up in a TAKEN and a FREE block

   ; de = old block size
   ; bc = requested size
   ; hl = pointer to old block+1
   ; new FREE block size = old block size - requested size - 3

   ld (hl),b                       ; Change size of old block
   inc hl
   ld (hl),c
   inc hl
   push hl                         ; Save pointer to data
   add hl,bc                       ; Pointer to new FREE block
   ld a,MEM_FREE
   ld (hl),a

   ex de,hl
   dec hl                          ; hl = old block size - 3
   dec hl
   dec hl                          ; Carry should be reset by add hl,bc
   sbc hl,bc                       ; hl -= requested size
   ex de,hl

   inc hl
   ld (hl),d                       ; Store calculated size of new FREE block
   inc hl
   ld (hl),e
   pop hl                          ; Restore pointer to return
   pop de
   ret                             ; Carry should be reset by sbc


;; === memory_allocate_exec ===
;;
;; Allocate a chunk of memory for a RAM application - TODO
;;
;; Authors:
;;   Tim Franssen (mail@timendus.com)
;;
;; Pre:
;;   hl = number of bytes that you want allocated
;;
;; Post:
;;   c = set if memory was not available
;;   specified number of bytes have been allocated for you at $8000 if c is reset

memory_allocate_exec:
   or a   ; clear carry flag
   ret


;; === memory_free ===
;;
;; Free a chunk of previously allocated memory
;;
;; Authors:
;;   Tim Franssen (mail@timendus.com)
;;
;; Pre:
;;   hl = pointer to memory to free
;;
;; Post:
;;   The accumulator will be destroyed
;;
;; Warning:
;;   hl needs to point to the beginning of the allocated
;;   memory, as you got it from memory_allocate, or
;;   $8000 in case of memory_allocate_exec! Give it a wrong
;;   pointer and things will go wrong badly! (Or, to use the
;;   proper terminology: "the result is undefined" :-P)

memory_free:
   ; TODO: Check for allocate_exec memory

memory_free_RAM:
   ; Mark my block as FREE
   dec hl
   dec hl
   dec hl
   ld a,MEM_FREE
   ld (hl),a
   ; And defragment the linked list
   push de
   push bc
   call memory_defragment
   pop bc
   pop de
   ret

; === memory_defragment ===
; Defragment the list from the start, joining adjecent FREE nodes
; Destroys de and bc

memory_defragment:
   ld hl,MEM_RAMSTART
memory_defragment_loop:
   ld a,(hl)                       ; What is my type?
   inc hl
   ld d,(hl)                       ; Already fetch the size while we're at it
   inc hl
   ld e,(hl)
   inc hl
   cp MEM_TAKEN                    ; If it's a TAKEN node, just skip it
   jp z,memory_defragment_next
   cp MEM_FREE                     ; If it's a FREE node, go and check it
   jp z,memory_defragment_checknode

   ; It's neither taken nor freed, so we've reached the end of the list
   ; and we know that it's defragmented, so we're done

   ret

memory_defragment_next:
   ; This node is taken, advance pointer to next
   add hl,de
   jp memory_defragment_loop

memory_defragment_checknode:
   ; This node is free, what about the next one?
   push hl
   add hl,de
   ld a,(hl)                       ; What is the type of the next node?
   cp MEM_TAKEN                    ; If it's taken, there's nothing more to
   jp z,memory_defragment_checknode_done                 ; join here
   cp MEM_FREE                     ; If it's free, join with this one
   jp z,memory_defragment_checknode_join

   ; Otherwise, we've found the end of the list, so there's only empty space
   ; after us, and we should become empty space too

   pop hl                          ; Get pointer to block type
   dec hl
   dec hl
   dec hl
   ld a,MEM_END                    ; Mark it as the end of the list
   ld (hl),a
   ret                             ; Done!

memory_defragment_checknode_done:
   ; We've added as many sizes to de as we can, and we should continue our
   ; main loop from the last checked place (hl)

   ld b,h                          ; Save pointer to the next taken node
   ld c,l
   pop hl                          ; Restore pointer to the checked node
   dec hl
   ld (hl),e                       ; Store new calculated size of checked node
   dec hl
   ld (hl),d
   ld h,b                          ; Restore pointer to next node
   ld l,c
   jp memory_defragment_loop       ; And move on from there

memory_defragment_checknode_join:
   ; hl points to a node that is free, and that comes after us; calculate it's
   ; size and add it to our own size

   inc hl
   ld b,(hl)                       ; Get block size
   inc hl
   ld c,(hl)
   inc bc                          ; Add header size
   inc bc
   inc bc
   ex de,hl
   add hl,bc                       ; Add it to our size
   ex de,hl
   pop hl                          ; Go and check the node that is now
   jp memory_defragment_checknode  ; after us, given the new size


; ===================
; End of file
; ===================
