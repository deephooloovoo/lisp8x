.binarymode ti8x
.variablename "LISP8X"
.org 9d93h
.db 0BBh,6Dh
.include ti83plus.inc
.INCLUDE 8klisp.def
.echo $
.echo "\n"
.include 8klisp.mac
.include string.asm
.include inout.mac
.include subr.mac
.include garbage.mac
.include prim.mac
.include fsubr.mac
;.include inout.mac



.include systab.mac

