/*
 * division.asm
 *
 *  Created: 11/30/2018 3:07:56 PM
 *  Author: Ravi Sajjan(but actually that Cornell link)
 */ 
 ;https://people.ece.cornell.edu/land/courses/eceprojectsland/STUDENTPROJ/1999to2000/mlk24KATZ/code/avr200.asm
.def drem8u = r15 ;Remainder
.def dres8u = r16 ;Result
.def dd8u = r16 ; dd8u/dv8u
.def dv8u = r20 ; dd8u/dv8u
.def dcnt8u = r21 ;Loop counter

div8u:	
	sub	drem8u,drem8u ;clear remainder and carry
	ldi	dcnt8u,9 ;init loop counter
d8u_1:
	rol	dd8u ;shift left dividend
	dec	dcnt8u ;decrement counter
	brne d8u_2 ;if done
	ret
d8u_2:
	rol	drem8u ;shift dividend into remainder
	sub	drem8u,dv8u ;remainder = remainder - divisor
	brcc d8u_3 ;if result negative
	add	drem8u,dv8u ;restore remainder
	clc ;clear carry to be shifted into result
	rjmp d8u_1 ;else
d8u_3:	
	sec	 ;set carry to be shifted into result
	rjmp d8u_1