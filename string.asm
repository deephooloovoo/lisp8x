StringInput:
.echoln "si ",$
				;Input
				;hl -> where to save input
				;b = max characters
				;currow,curcol = cursor location
				;Output
				;hl is preserved
				;bc = number of characters inputted

	push	hl
	ld	de,(curRow)
	push	de
	set	curAble,(IY+curFlags)
	ld	c,b		;c = backup of max chars
	ld	d,0		;d = how many chars after current cursor location
				; last inpuuted char is
	ld	(hl),d      
	ld	a,Lspace
	ld	(curUnder),a  ;curUnder is the character that is shown during
				;cursor blink
	B_CALL(_PutMap)
siLoop:
	push	hl
	push	de
	push	bc
    B_CALL(_GetKey)
	ld hl, siKeyJpTable
	ld bc, siJpTable-siKeyJpTable
	cpir
	jr nz, siTryChars
	inc c
	sla c
	ld hl, siKeyTable
	sbc hl,bc
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	pop bc
	pop de
	ex (sp),hl ;jp to hl while preserving hl
	ret
siTryChars:
	ld hl,siKeyTable
	ld bc,siCharTable-siKeyTable
	push bc
	cpir
	pop bc
	jr nz,siCheckLetter
	add hl,bc
	dec hl
	ld a,(hl)
	pop bc
	pop de
	pop hl
	jp siLetCont




siCheckLetter:
	pop bc
	pop de
	pop hl
	sub	k0
	cp	10
	jp	c,siNumber
	sub	kCapA-k0
	cp	26
	jp	c,siLetter
	jr	siLoop   



	pop	bc
	pop	de
	pop	hl
siDel:						;delete a character
	inc	d
	dec	d				;are we at the end of the string?
	jr	z,siLoop
	push	de
	push	bc
	push	hl
	ld	b,d
	ld	de,(curRow)
	push	de  
	ld	d,h
	ld	e,l
	inc	de 
	dec	b				;are we deleting the last character?
	ld	c,Lspace
	jr	z,siDelLoopSkip  		;if so, we want to have curUnder=Lspace
						;and we don't need to display shifted
						;characters

;	ld	c,(hl)				;else, we want curUnder=next character
       ld     a,(de)
       ld     c,a                         ;err, actually, don't we want this?

siDelLoop:					;This loop displays all the remaining
						;characters after the one we're deleting,
						;but shifted back one position
	ld	a,(de)
	B_CALL(_PutC)
	ld	(hl),a
	inc	hl
	inc	de
	djnz	siDelLoop 
siDelLoopSkip:
       ld     (hl),0               ;needs to be zero terminated, right?
	ld	a,Lspace
	B_CALL(_PutC)
	ld	a,c
	ld	(curUnder),a
	pop	de
	ld	(curRow),de
	pop	hl
	pop	bc
	pop	de
	dec	d
	jp	siLoop

siClear:					;clear all characters
	ld	a,c
	sub	b
	add	a,d
	or	a				;nothing to clear?
	jp	z,siLoop
	ld	e,d
	ld	d,0
	add	hl,de
	ld	(hl),0				;zero terminate current text
	pop	de
	ld	(curRow),de			;restore original cursor location
	pop	hl
	push	bc
	B_CALL(_StrLength)			;get length of string
	inc	c				;need to erase cursor too
	push	hl
	push	de
siClearLoop:					;clear all previously entered text
	ld	a,Lspace
	B_CALL(_PutC)
	dec	c
	jr	nz,siClearLoop
	pop	de
	ld	(curRow),de
	pop	hl
	pop	bc
	ld	b,c				;restore backup of max # of chars
	jp	StringInput 

siEnter:
	ld	a,(curUnder)
	B_CALL(_PutMap)				;Display character under cursor, so we
						;don't get a black box
;	ld	e,d
;	ld	d,0
;	add	hl,de   ;wait...what was this for?
       ld     hl,curRow
       dec    d
       inc    d
       jr     z,siEnterLoopSkip
siEnterLoop:                              ;Updates cursor position to end
       ld     a,(curCol)
       inc    a
       and    15
       ld     (curCol),a
       or     a
       jr     nz,siEnterLoopCont
       inc    (hl)
siEnterLoopCont:
       dec    d
       jr     nz,siEnterLoop
siEnterLoopSkip:
	pop	de
;	ld	(curRow),de			;restore original cursor location
	pop	hl
	B_CALL(_StrLength)			;find string length
;	push hl
	add hl,bc
	ld (hl),13
	ld (LBP),hl
	ld a,13
;	pop hl
	inc	bc  				;add one for zero terminator
	res	curAble,(IY+curFlags)	;turn of cursor
;	ld a,(hl)

	ret

siNumber:
	add	a,L0	
	jr	siLetCont  
siLetter: 
	add	a,LcapA
siLetCont:
	dec	b
	inc	b				;Have we displayed the maximum # of
						;characters?
	jp	z,siLoop
	ld	(hl),a 
	B_CALL(_PutC)
	inc	hl    
	ld	a,d  
	dec	d
	dec	b
	or	a
	ld	a,(hl)
	ld	(curUnder),a			;reset curUnder to next character
	jp	nz,siLoop
	inc	d
	ld	a,Lspace
	ld	(curUnder),a      
	ld	(hl),0
	jp	siLoop
siSpace:
       ld     a,' '
       jr     siLetCont
siComma:
       ld     a,','
       jr     siLetCont
siLeft:					;move left
	ld	a,b
	cp	c				;are we all the way to the left?
	jp	z,siLoop
	inc	b
	ld	a,d
	inc	d				;we've moved farther away from the end
	call	siLDAHL
	B_CALL(_PutMap)
	dec	hl
	ld	a,(hl)
	ld	(curUnder),a

	ld	a,(curCol)
	dec	a				;cursor location one to the left
	ld	(curCol),a
	jp	p,siLoop			;jumps if there was no overflow			
	ld	a,15
	ld	(curCol),a
	ld	a,(curRow)
	dec	a
	ld	(curRow),a
	jp	siLoop 

siUp: 						;move up
	ld	a,b
	add	a,15
	cp	c				;have we typed more than 15 characters?
	jp	nc,siLoop			;if not, we can't move up
	ld	b,a  
	inc	b
	ld	a,d
	add	a,16
	ld	d,a
	call	siLDAHL
	B_CALL(_PutMap)
	push	de
	ld	de,16
	sbc	hl,de				;text pointer up a row (row=16 bytes)
	pop	de
	ld	a,(curRow)
	dec	a				;move cursor up a row
	ld	(curRow),a
	ld	a,(hl)  
	ld	(curUnder),a
	jp	siLoop    

siLDAHL:
						;loads a character from (hl) and
						;converts it to Lspace if it is 0
	ld	a,(hl)
	or	a
	ret	nz
	ld	a,Lspace
	ret

siDown:       				;move down     
	ld	e,16
	ld	a,d
	sub	e				;are there are least 16 after cursor?
	jp	c,siLoop			;if not, we can't move down
	ld	d,a
	ld	a,b
	sub	e
	ld	b,a
	ld	a,(hl)
	B_CALL(_PutMap)
	push	de
	ld	d,0
	add	hl,de
	pop	de  
	call	siLDAHL
	ld	(curUnder),a
	ld	a,(curRow)
	inc	a
	ld	(curRow),a
	jp	siLoop

siRight:					;move right
	ld	a,d
	or	a				;are there any more chars after cursor?
	jp	z,siLoop
	dec	b
	ld	a,(hl)
	B_CALL(_PutMap)
	inc	hl
	dec	d 
	call	siLDAHL
	ld	(curUnder),a 
	ld	a,(curCol)
	inc	a				;move cursor over
	ld	(curCol),a
	cp	16				;did we scroll
	jp	nz,siLoop
	xor	a
	ld	(curCol),a
	ld	a,(curRow)
	inc	a
	ld	(curRow),a
	jp	siLoop

siKeyJpTable:
	.db kDel
	.db kClear
	.db kEnter
	.db kLeft
	.db kRight
	.db kDown
	.db kUp
siJpTable
	.dw siDel
	.dw siClear
	.dw siEnter
	.dw siLeft
	.dw siRight
	.dw siDown
	.dw siUp
siKeyTable:
	.db	kSpace
	.db	kQuote
	.db	kLParen
	.db	kRParen
	.db	kLBrace
	.db	kRBrace
	.db	kAdd
	.db	kSub
	.db	kMul
	.db	kDiv
	.db	kDecPnt
siCharTable:
	.db	Lspace
	.db	Lapostrophe
	.db	LlParen
	.db	LrParen
	.db	LLT
	.db	LGT
	.db	LplusSign
	.db	Ldash
	.db	Lasterisk
	.db	Lslash
	.db	Lperiod
