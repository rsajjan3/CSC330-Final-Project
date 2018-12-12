;
; Sajjan-CSC330-Final.asm
;
; Author : Ravi Sajjan
;
.cseg

.def reg_SPI_data = r17
.def x_location = r18
.def y_location = r19
.def reg_workhorse = r22
.def rand_num = r23
.def heli_location_x = r24
.def heli_location_y = r25
	
.org 0x0000
rjmp start
.org 0x002A
	rjmp read_joystick

.macro	set_Pointer
ldi @0, low(@2<<1)
ldi @1, high(@2<<1)
.endmacro

.macro drawBlock
	set_Pointer ZL, ZH, @0
	rcall GFX_set_shape
	rcall lcg_Rand ;Generate a random number for block locations

	ldi x_location, @1
	mov y_location, rand_num

	rcall GFX_set_array_pos
	rcall GFX_draw_shape
.endmacro

draw_heli:
	set_Pointer ZL, ZH, Char_030
	rcall GFX_set_shape

	mov x_location, heli_location_x
	mov y_location, heli_location_y

	rcall GFX_set_array_pos
	rcall GFX_draw_shape
	ret

clear_heli:
	mov x_location, heli_location_x
	mov y_location, heli_location_y

	rcall GFX_set_array_pos
	rcall GFX_draw_blank
	ret

read_joystick: ;No movement: 127, Up: >127, Down: <127
	ldi reg_workhorse, 0b11001111
	sts ADCSRA, reg_workhorse
	lds reg_workhorse, ADCH
	reti

;WHEN STARTING THE PROGRAM MOVE THE JOYSTICK IN A RANDOM LOCATION TO SEED THE RANDOM
start:
	ldi reg_workhorse, 0b01100010 ;Setup ADC to read in thumbstick, LEFT ADJUST ENABLED
	sts ADMUX, reg_workhorse

	ldi reg_workhorse, 0b11001111 ;Setup ADC in interupt mode
	sts ADCSRA, reg_workhorse
	sei ;Enable interupts

	mov rand_num, reg_workhorse ;Seed the random

	rcall OLED_initialize
	rcall GFX_clear_array
	rcall OLED_refresh_screen
	rjmp setup_game

setup_game:
	ldi heli_location_x, 1
	ldi heli_location_y, 32
	rcall draw_heli
	drawBlock Char_178, 25
	drawBlock Char_178, 50
	drawBlock Char_178, 80
	drawBlock Char_178, 110
	rjmp loop

loop:
	rcall delay_16ms ;~60fps. Don't know how long it actually takes to go through all the instructions below, so it's not a real 60fps

	rcall draw_heli
	set_Pointer XL, XH, pixel_array
	rcall OLED_refresh_screen ;Draw to screen every time the game loops.

	rcall clear_heli ;Clear the heli so that it can be redrawn according to user input
	cpi heli_location_y, 64 ;Reached the bottom of the screen
	breq reset_location_top ;Loop the helicopter to the top
	cpi heli_location_y, 0 ;Reached the top of the screen
	breq reset_location_bottom ;Loop the helicopter to the bottom
	cpi heli_location_x, 127 ;Reached the right end of the screen
	breq reset_location_left ;Loop to the left end of the screen

	inc heli_location_x ;Move the heli right
	cpi reg_workhorse, 128 ;Up movement detected
	brsh move_up
	cpi reg_workhorse, 127 ;Down movement detected
	brlt move_down

	rjmp loop

move_down:
	inc heli_location_y
	rjmp loop
move_up:
	dec heli_location_y
	rjmp loop

reset_location_left:
	rcall GFX_clear_array ;Clear out screen
	ldi heli_location_x, 1
	drawBlock Char_178, 25 ;Redraw blocks
	drawBlock Char_178, 50
	drawBlock Char_178, 80
	drawBlock Char_178, 110
	rjmp loop
reset_location_bottom:
	ldi heli_location_y, 63
	rjmp loop
reset_location_top:
	ldi heli_location_y, 1
	rjmp loop

lcg_Rand: ;I probably choose shitty 'a' and 'm', but it works...
	;https://www.eg.bucknell.edu/~xmeng/Course/CS6337/Note/master/node40.html
	;Linear-Congruential Generator: Xn = (a * (Xn-1)) mod m
	push r24
	ldi r24, 3 ; a = 3
	mul rand_num, r24 ; a * Xn-1 <- result stored in r0 and r1
	mov dd8u, r0
	ldi dv8u, 64 ; m = 64(0-63 is the range)
	rcall div8u ; Perform division, which gives remainder (mod m)
	mov rand_num, drem8u ;drem8u is the remainder (mod)
	pop r24
	ret

.include "lib_delay.asm"
.include "lib_SSD1306_OLED.asm"
.include "lib_GFX.asm"
.include "division.asm"
