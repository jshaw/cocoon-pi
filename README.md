# cocoon-pi

All this stuff goes in the sketchbook folder on the pi. 

I'll add another folder with the compatible arduino sketch.

Control for the sketch is done with the below keys:
* a: add a new beat to the sketch
* x: clear all of the current beats
* g: will toggle between the gradient on the rings to help with color blending
* t: will toggle between showing a dark stroke ring around the flair
* m: pressing `m` multiple times will cycle through the different blendModes
* s: will toggle the visibility of the 3d simulation
* f: toggles FPS log
* p: toggles Pulse Mode on default visual key =# 4 key code = 52
* left/right: changes amplitude of sine wave / ring
* down/up: changes vertical change on y axis of sine wave / ring
* left mouse: click and hold the left mouse button will rotate the 3d simulation 


Behaviours controlled by keyboard keypressed. The state reference number on keyboard. 

* 0: blinking per supplied beat
* 1: pulsates at a specific time (need to add the beat into this)
* 2: pulsates + moves
* 3: blinks to beat + moves
* 4: pulsates more quickly
* 5: blinks + pulsates more quickly
* 6: decreases diameter + pulsates in a hearbeat pattern

