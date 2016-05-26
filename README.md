# cocoon-pi

All this stuff goes in the sketchbook folder on the pi. 

I'll add another folder with the compatible arduino sketch.

### Saving + Loading
When the sketch is loaded the defaults will be used. To save any changes to the behaviour use the `s` key to save to the config file. On the restart of the sketch press the `l` key to load the saved config settings.

The reason for this workflow is that the sketchs default settings are always available when the sketch starts up incase the config file ends up with wonky settings or deviate from what looks good. It will be just a matter of restarting the sketch and saving before any changes are made to reset the config file.

### Configure Inactivity Time 
The inactivity time before we start to purge old rings is by default 5000ms (5 seconds). This is done for testing purposes. This can be customized by pressing the `t` key then up/down arrow keys. Press `t` again to exit this time configuration. The min inactivity time is 5 seconds. Each increment goes up by 50000ms or 5 minutes. The max inactivity time is 20 minutes.

The timer bar graph is a bluish colour.

### Configure Remaining Rings After a Ring Purge
The inactivity time dtermines when a purge of the old rings should happen. The remaining rings setting determins how many rings should be left after the purge. Note, that the rings that are left are the most recent ones added. The minimum number of rings left is 1 ring and the maximum number of rings is 15 left over.

The remaining rings bar graph is a greenish colour.

### Control
To configure the sketch / install use the following key commands belowfor the sketch is done with the below keys:

 * s: will save current config settings
 * l: will load the saved config file
 * a: add a new beat to the sketch
 * x: clear all of the current beats
 * g: will toggle between the gradient on the rings to help with color blending
 * k: will toggle between showing a dark stroke ring around the flair
 * m: pressing `m` multiple times will cycle through the different blendModes
 * d: will toggle the visibility of the 3d simulation
 * f: toggles FPS log
 * p: toggles Pulse Mode on default visual key =# 4 key code = 52
 * left/right: changes amplitude of sine wave / ring
 * down/up: changes vertical change on y axis of sine wave / ring
 * left mouse: click and hold the left mouse button will rotate the 3d simulation 

* **IMPORTANT**

 * t then up/down then t: activates increase / decrease purge ring timer. Press t again to exit that config. 
 * r then up/down: increase / decrease number of rings left after purge. Press r again to exit that config.


Behaviours controlled by keyboard keypressed. The state reference number on keyboard. 

* 0: blinking per supplied beat
* 1: pulsates at a specific time (need to add the beat into this)
* 2: pulsates + moves
* 3: blinks to beat + moves
* 4: pulsates more quickly
* 5: blinks + pulsates more quickly
* 6: decreases diameter + pulsates in a hearbeat pattern

