;
; Sajjan-CSC330-Final.asm
;
; Author : Ravi Sajjan
;

//Lines 8-46, code for connecting to OLED
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
.org 0x0100

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
	set_Pointer XL, XH, pixel_array
	rcall OLED_refresh_screen
.endmacro

.macro clearBlock
	ldi x_location, @0
	ldi y_location, @1

	rcall GFX_set_array_pos
	rcall GFX_draw_blank
	set_Pointer XL, XH, pixel_array
	rcall OLED_refresh_screen
.endmacro

draw_heli:
	set_Pointer ZL, ZH, Char_030
	rcall GFX_set_shape

	mov x_location, heli_location_x
	mov y_location, heli_location_y

	rcall GFX_set_array_pos
	rcall GFX_draw_shape
	set_Pointer XL, XH, pixel_array
	rcall OLED_refresh_screen
	ret

clear_heli:
	mov x_location, heli_location_x
	mov y_location, heli_location_y

	rcall GFX_set_array_pos
	rcall GFX_draw_blank
	set_Pointer XL, XH, pixel_array
	rcall OLED_refresh_screen
	ret

read_joystick: ;No movement: 127, Up: >127, Down: <127
	ldi reg_workhorse, 0b11000111
	sts ADCSRA, reg_workhorse
	wait_adc: 
		lds reg_workhorse, ADCSRA
		andi reg_workhorse, 0b00010000
		breq wait_adc
	store:
		lds reg_workhorse, ADCH
		nop
		ret

start:
	ldi reg_workhorse, 0b01100010 ;Setup ADC to read in thumbstick, LEFT ADJUST ENABLED
	sts ADMUX, reg_workhorse

	rcall read_joystick ;Get random seed through input of joystick
	mov rand_num, reg_workhorse ;Seed the random

	rcall OLED_initialize
	rcall GFX_clear_array
	rcall OLED_refresh_screen
	rjmp setup_game


setup_game:
	ldi heli_location_y, 32
	rcall draw_heli
	drawBlock Char_178, 25
	drawBlock Char_178, 50
	drawBlock Char_178, 80
	drawBlock Char_178, 110
	rjmp loop

loop:
	cpi heli_location_y, 64
	breq reset_location_top
	cpi heli_location_y, 0
	breq reset_location_bottom
	cpi heli_location_x, 127
	breq reset_location_left

	rcall read_joystick ;Result: reg_workhorse
	cpi reg_workhorse, 128
	brsh move_up
	cpi reg_workhorse, 127
	brlt move_down

	rjmp move_right

	rcall delay_100ms
	rjmp loop

move_right:
	rcall clear_heli
	inc heli_location_x
	rcall draw_heli
	rjmp loop

reset_location_left:
	rcall GFX_clear_array
	ldi heli_location_x, 0
	rcall draw_heli
	;drawBlock Char_178, 25
	;drawBlock Char_178, 50
	;drawBlock Char_178, 80
	;drawBlock Char_178, 110
	rjmp loop

move_down:
	rcall clear_heli
	inc heli_location_y
	rcall draw_heli
	rjmp loop

move_up:
	rcall clear_heli
	dec heli_location_y
	rcall draw_heli
	rjmp loop

reset_location_bottom:
	rcall clear_heli
	ldi heli_location_y, 63
	rcall draw_heli
	rjmp loop
reset_location_top:
	rcall clear_heli
	ldi heli_location_y, 1
	rcall draw_heli
	rjmp loop

;loop:

lcg_Rand: ;I probably choose shitty 'a' and 'm', but it works...
	;https://www.eg.bucknell.edu/~xmeng/Course/CS6337/Note/master/node40.html
	;Linear-Congruential Generator: Xn = (a * (Xn-1)) mod m
	push r24
	ldi r24, 3 ; a = 3
	mul rand_num, r24 ; a * Xn-1 <- result stored in r0 and r1
	pop r24
	mov dd8u, r0 ;Keep the high bit
	ldi dv8u, 251 ; m = 251
	rcall div8u ; Perform division, which gives remainder (mod m)
	mov rand_num, drem8u ;drem8u is the remainder (mod)

	;Limit RAND to highest number = 64
	mov dd8u, rand_num
	ldi dv8u, 64 ; RAND_MAX = 64
	rcall div8u
	mov rand_num, drem8u
	ret

.include "lib_delay.asm"
.include "lib_SSD1306_OLED.asm"
.include "lib_GFX.asm"
.include "division.asm"
