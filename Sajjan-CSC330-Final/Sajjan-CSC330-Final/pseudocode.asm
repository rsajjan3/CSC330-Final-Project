/*
 * pseudocode.asm
 *
 *  Created: 11/28/2018 12:05:27 PM
 *   Author: Ravi Sajjan
 */ 

 start: //One time setup
	//Init OLED screen -> Connect using SPI(already done in main.asm)
	//Init joystick -> Connect to ADC 
	//Setup GFX lib
	//Go to setup_game

setup_game: //Setup the intial state of the game
	//Draw blocks in random locations -> Store locations in array
	//Draw helicopter as a dot
	//Go to loop

loop: //Main logic of the game
	//Read y-axis input from joystick -> Move helicopter up/down accordingly
	//Move helicopter right to move the game forward
	//Generate new blocks to keep game going
	//Go to loop
