# FPGA-Robot-solves-puzzle
This is the school final project for my FPGA course

When switch power up the zedboard FPGA:
- Press BTNC button to refresh the oled screen 
- You might have to press it a feel time until the screen show up "Finding..."


Input x and y coordinate
- SW0, SW1, SW2 represent the x
- SW4, SW5, Sw6 represent the y


Assign the start and goal coordinate:
- Assign for the start position with the switches
- Then press BTNU button to save the start position
- With the same switches, assign for the goal position
- Then press BTND button to save the goal position
- Press BTNL button for the robot to start go through the maze


Output:
- If all the LD0 -> LD7 light up, the robot reach the goal:
	+ Press BTNC button again, and the oled screen will show the all the path that the robot took
		Ex: 00 01 02 03 04
	+ If you see that the screen was filled but dd not show the goal yet
	+ Flip SW7 up, then press BTNC button again, the screen will show the second screen, 
	  which should contain the goal coordinate

- If only LD0 light up, the robot cannot reach the goal:
	+ Press BTNC button again, and the oled screen will show "ERROR"

Reset:
- Press BTNR button to reset everything.
