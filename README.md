# cocoon-pi

All this stuff goes in the sketchbook folder on the pi. 

I'll add another folder with the compatible arduino sketch.

### Saving + Loading
When the sketch is loaded the defaults will be used. To save any changes to the behaviour use the 's' key to save to the config file. On the restart of the sketch press the 'l' key to load the saved config settings.

The reason for this workflow is that the sketchs default settings are always available when the sketch starts up incause the config file ends up with wonky settings or diviate from what looks good. It will be just a matter of restarting the sketch and saving before any changes are made to reset the config file.


Control for the sketch is done with the below keys:
* s: will save current config settings
* l: will load the saved config file
* a: add a new beat to the sketch
* x: clear all of the current beats
* g: will toggle between the gradient on the rings to help with color blending
* t: will toggle between showing a dark stroke ring around the flair
* m: pressing `m` multiple times will cycle through the different blendModes
* d: will toggle the visibility of the 3d simulation
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

