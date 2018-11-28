/*
 * pseudocode.asm
 *
 *  Created: 11/28/2018 12:05:27 PM
 *   Author: Ravi Sajjan
 */ 

 start: //One time setup
	//Init OLED screen -> Connect using SPI(already done in main.asm)
	//Init joystick -> Connect using TWI
	//Setup GFX lib
	//Go to setup_game

setup_game: //Setup the intial state of the game
	//Draw 4x4 blocks in random locations -> Store locations in array
	//Draw helicopter as a dot
	//Set distance register to 0
	//Go to loop

loop: //Main logic of the game
	//Read y-axis input from joystick -> Move helicopter up/down accordingly
	//Move helicopter right to move the game forward
	//Detect collisions from 1px away -> Go back to setup_game if collision
	//Generate new blocks to keep game going
	//Increment distance register
	//Go to loop
