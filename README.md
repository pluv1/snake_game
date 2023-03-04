# Snake_game
Snake game made in Vivado for the Nexys4 FPGA board. 

Game Description
--------
Upon compilation and running of the game, a header and snake will appear on the screen (red square for head and green for body). 
Progress through the game by collecting 'apples' (white squares) and your snake will grow in size. 
The length of the snake can be seen on the 7-segment displays on the board. When the snake reaches a length of 22 (eats 20 apples) then you win the game!
But if the snake head hits its body then you will lose the game. Reset to start again. 


Controls
--------
The snake moves automatically around the screen depending on the direction chosen by the user.
This direction is specified using the buttons on the FPGA board: M18 = up, P18 = down, P17 =
left, M17 = right. If the snake hits a wall then it will continue through to the other end of the screen. 
The snake cannot reverse its direction as this would invoke a game loss. 
The last of the five buttons on the board (N17) is used to reset the game. 

Download
--------
All files can be loaded in using an editor (Xilinix Vivado) or by placing them in the correct project files:
  The constraints file (nexys4.xdc) must go in the "__.srcs\constrs_1\new" folder.
  The verilog files (all files with file extension .v) must go in the "___.srcs\sources_1\new" folder. 

