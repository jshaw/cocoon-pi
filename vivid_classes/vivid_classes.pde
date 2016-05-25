// click 'a' to generate objects

// Behaviours controlled by keyboard keypressed. 
// States reference number on keyboard 
// 0:  blinking per supplied beat
// 1: pulsates at a specific time (need to add the beat into this)
// 2: pulsates + moves
// 3: blinks to beat + moves
// 4: pulsates more quickly
// 5: blinks + pulsates more quickly
// 6: decreases diameter + pulsates in a hearbeat pattern
//
//
// Control for the sketch is done with the below keys:
// * s: will save current config settings
// * l: will load the saved config file
// * a: add a new beat to the sketch
// * x: clear all of the current beats
// * g: will toggle between the gradient on the rings to help with color blending
// * k: will toggle between showing a dark stroke ring around the flair
// * m: pressing `m` multiple times will cycle through the different blendModes
// * d: will toggle the visibility of the 3d simulation
// * f: toggles FPS log
// * p: toggles Pulse Mode on default visual key =# 4 key code = 52
// * left/right: changes amplitude of sine wave / ring
// * down/up: changes vertical change on y axis of sine wave / ring
// * left mouse: click and hold the left mouse button will rotate the 3d simulation

// * t then up/down then t: activates increase / decrease purge ring timer. Press t again to exit that config. 
// * r then up/down: increase / decrease number of rings left after purge. Press r again to exit that config.


import eDMX.*;
//--------------------------------comment out for non-Pi use-----------
//import processing.io.*;    // enable this on the pi.
//I2C i2c;
//---------------------------------------------------------------------

int val = 0;
int fps = 30;

// Config settings storage
String[] config;
String configFileName = "config.txt";

// Used in the ring class
// amplitude is scaling the height of the pulsing (left/right)
// verticalChange is moving the sine animation up the y axis so all the numbers are positive (up/down)
// this can be changed via up/down or left/right keys
int amplitude = 5;
int verticalChange = 10;

boolean showFPS = true;
boolean pulseMode = true;

int beat4;
int beat5;
int timer;

ArrayList<Ring> rings;
int ringCount = 0;
PGraphics fbo;
PImage img;



sACNSource source;
sACNUniverse[] universe;
int numUniverses = 10;


String blendMode[] = {"BLEND", "ADD", "SUBTRACT", "DARKEST", "LIGHTEST", 
  "DIFFERENCE", "EXCLUSION", "MULTIPLY", "SCREEN", "REPLACE"};
int blendModeIndex = 1;

// Default to #4 key
int state = 52;

// number of 
int tubeRes = 32;

int imgWidth = 10;
int imgHeight = 160;

float rotx = PI/4;
float roty = PI/4;

// display the 3d simulation of the cocoon
boolean show3d = true;

// state tracking for showing ring gradient
boolean showRingGradient = true;

// state tracking for showing ring stroke
boolean showRingStroke = true;

int lastAddTimer = 0;
boolean fadeOldRings = false;
int purgeRingsTimer = 5000;
int remainingRings = 4;

boolean editRings = false;
boolean editRingTimer = false;

float ringMap = 0.0;
float ringMapTimer = 0.0;

void setup() {
  size(600, 600, P3D);
  frameRate(fps);
  rings = new ArrayList();
  colorMode(RGB);
  
  //--------------------------------comment out for non-Pi use-----------
  //i2c = new I2C(I2C.list()[0]);
  //---------------------------------------------------------------------

  // Timer so we don't clobber the i2c port
  int timer = millis();

  // Change color mode to be 
  fbo = createGraphics(imgWidth, imgHeight);

  // img for testing and debugging texture mapping
  //img = loadImage("vividTestTextures_2.jpg");

  // initialize eDMX stuff 10 universes

  source = new sACNSource(this, "Vivid sACN");
  universe = new sACNUniverse[numUniverses];
  for (int i = 0; i < numUniverses; i++) {
    universe[i] = new sACNUniverse(source, (short)(i+1));
  }
}

void draw() {
  background(100, 255);
  if(showFPS == true){
    drawFrameRate();
  }
  
  if(editRings == true){
    drawEditRings();
  }
  
  if(editRingTimer == true){
    drawEditRingTimer();
  }
  
  colorMode(RGB);

  //--------------------------------comment out for non-Pi use-----------
  // check console 4

  //if ((millis() - timer) > 2000) {
  //  beat4 = getBeat(4);
  //  if (beat4>0) {
  //    addRing(beat4);
  //  }

  //  // check console 5
  //  beat5 = getBeat(5);

  //  if (beat5>0) {
  //    addRing(beat5);
  //  }
  //  timer = millis();
  //}
  //---------------------------------------------------------------------
  
  if ((millis() - lastAddTimer) > purgeRingsTimer && fadeOldRings == false) {
    fadeOldRings = true;
    println("Fade old rings");
  }

  buildFbo();
  mapPixels();
  image(fbo, 60, 60, imgWidth * 3, imgHeight * 3);

  translate(width / 2, height / 2);

  if (show3d) {
    noStroke();
    rotateX(rotx);
    rotateY(roty);

    pushMatrix();
    // 32, 10 * 3, 160 * 3
    drawCylinder(tubeRes, imgWidth * 3, imgHeight * 3);
    popMatrix();
  }
}

void mousePressed() {
}

void keyPressed() {
  println(key);

  if (key == 'd') {
    show3d =! show3d;
  } else if (key == 's') {
    saveConfig();
  } else if (key == 'l') {
    loadConfig();
  } else if (key == 'a') {
    // make a new Ring object
    addRing(int(random(700, 1100)));
  } else if (key == 'x') {   // clear all objects
    rings.clear();
  } else if (key == 'm') {
    // rotate through blendmode options
    if (blendModeIndex < blendMode.length - 1) {
      blendModeIndex++;
    } else {
      blendModeIndex = 0;
    }
  } else if (key == 'g') {
    showRingGradient =! showRingGradient;
  } else if (key == 'k') {
    showRingStroke =! showRingStroke;
  } else if (key == 'f') {
    showFPS =! showFPS;
  } else if (key == 'p') {
    pulseMode =! pulseMode;
  } else if (key == 'r') {
    editRings =! editRings;
  } else if (key == 't') {
    editRingTimer =! editRingTimer;
  } else {  
    // setting this here actually pauses the animations
    //state =(int)key;
        
    if (key == CODED) {
      if (keyCode == UP) {
        if(editRings == true){
          if(remainingRings <= 14){
            remainingRings += 1;
          }
        } else if (editRingTimer == true) {
          if(purgeRingsTimer <= 155000){
            purgeRingsTimer += 50000;
          }
        } else {
          verticalChange += 1;
        }
      } else if (keyCode == DOWN) {
        if(editRings == true){
          if(remainingRings > 1){
            remainingRings -= 1;
          }
        } else if (editRingTimer == true) {
          if(purgeRingsTimer > 5000){
            purgeRingsTimer -= 50000;
          }
        } else {
          verticalChange -= 1;
        }
      } else if (keyCode == RIGHT) {
        amplitude += 1;
      } else if (keyCode == LEFT) {
        if(amplitude > 0){
          amplitude -= 1;
        }
      }
    }
    
    // ====== Debuging for the customization of the ring sizes 
    //println("amplitude: ");
    //println(amplitude);
      
    //println("verticalChange: ");
    //println(verticalChange);
    
  }
}

void mouseDragged() {
  float rate = 0.01;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}

void buildFbo() {
  fbo.beginDraw();
  fbo.colorMode(RGB);

  // background RED for testing only...
  fbo.background(100, 0, 0, 255);
  fbo.colorMode(HSB);
  fbo.blendMode(blendModeIndex);

  for (int i = 0; i < rings.size(); i++) {
    Ring r = rings.get(i);
    r.updateState(state);
    r.updateVerticalChangeAmplitude(amplitude, verticalChange);
    r.updatePulseMode(pulseMode);
    r.toggleRingGradient(showRingGradient);
    r.toggleRingStroke(showRingStroke);
    
    // fade away the rings except the most recent rings added
    if (i < (rings.size() - remainingRings) && fadeOldRings == true){
      r.fadeAway();
    }
    
    r.update();
    r.display();
        
    if (r.returnOnValue() == false) {
      rings.remove(i);
      println("NUMBER OF RINGS NOW" + rings.size());
    }
  }
  
  // Draws the ring timer / remaining rings as visuals on the instal for reference of value
  fbo.noStroke();
  if(editRings == true){
    fbo.fill(0, 102, 204);
    fbo.rect(90, fbo.height - 4, ringMap, 4);
  } else if (editRingTimer == true) {
    fbo.fill(127, 102, 204);
    fbo.rect(0, fbo.height - 4, ringMapTimer, 4);
  }
  
  fadeOldRings = false;
  fbo.endDraw();
}

void mapPixels() {
  // let's put the pixel stuff here
  // loadpixel array, then figure out where each pixel goes in the LED map

  fbo.loadPixels();

  // Run through the pixels and map them to the DMX universes
  // Also run the number through the gamma LUT for better look
  for (int s = 0; s < 1600; s ++) {
    universe[s%10].setSlot((160-s/10)*3, (byte)gamma((char)red(fbo.pixels[s]))); 
    universe[s%10].setSlot(((160-s/10)*3+1), (byte)gamma((char)green(fbo.pixels[s]))); 
    universe[s%10].setSlot(((160-s/10)*3+2), (byte)gamma((char)blue(fbo.pixels[s])));
  }

  // Send out the data to each universe
  try {
    for (int i = 0; i < numUniverses; i++) {
      universe[i].sendData();
    }
  }
  catch (Exception e) {
    e.printStackTrace();
    exit();
  }
}

// This lookup table adjust led levels to have better perceived ramping
// at the expense of colour depth
char gammaLUT[] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 
  2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 
  5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 
  10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16, 
  17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25, 
  25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36, 
  37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50, 
  51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68, 
  69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89, 
  90, 92, 93, 95, 96, 98, 99, 101, 102, 104, 105, 107, 109, 110, 112, 114, 
  115, 117, 119, 120, 122, 124, 126, 127, 129, 131, 133, 135, 137, 138, 140, 142, 
  144, 146, 148, 150, 152, 154, 156, 158, 160, 162, 164, 167, 169, 171, 173, 175, 
  177, 180, 182, 184, 186, 189, 191, 193, 196, 198, 200, 203, 205, 208, 210, 213, 
  215, 218, 220, 223, 225, 228, 231, 233, 236, 239, 241, 244, 247, 249, 252, 255
};

char gamma(char input) {
  return gammaLUT[input];
}

void drawCylinder( int sides, float r, float h) {
  float angle = 360.0 / (float)sides;
  float halfHeight = h / 2;

  // draw top + bottom of the tube
  drawEnds(halfHeight, angle, sides, r, h);

  // draw sides
  beginShape(TRIANGLE_STRIP);

  // Texture the cylinder
  // Use img for debugging image mapping w/ a static image 
  // texture(img);
  texture(fbo);

  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    //float u = fbo.width / tubeRes * i;
    float u = (float)fbo.width / (float)tubeRes * (float)i;

    vertex( x, y, halfHeight, u, 0);
    vertex( x, y, -halfHeight, u, fbo.height);
  }
  endShape(CLOSE);
}

void drawEnds(float halfHeight, float angle, int sides, float r, float h) {
  // draw top of the tube  
  beginShape();
  for (int i = 0; i <= sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);

  // draw bottom of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, halfHeight);
  }
  endShape(CLOSE);
}


//--------------------------------comment out for non-Pi use-----------
//int getBeat(int address) {
//  int newbeat = 0;
//  if (I2C.list() != null)
//  {
//    i2c.beginTransmission(address);
//    i2c.write(address);

//    try
//    {
//      byte[] in = i2c.read(4);

//      int beat = in[0];
//      if (beat<0) {
//        beat = beat +256;
//      }
//      newbeat = beat;
//      print("Address: " + address + " beat: ");
//      println(beat);
//    }
//    catch(Exception e)
//    {
//      i2c.endTransmission();
//    }
//  }
//  return(newbeat);
//}
//----------------------------------------------------------------------


void addRing(int inbeat) {
  ringCount++; 
  rings.add(new Ring((int)random(0, imgWidth), (int)random(0, imgHeight), ringCount, (int)state, inbeat));
  lastAddTimer = millis();
  ringCount = rings.size();
}

void drawFrameRate(){
  float fr = frameRate;
  textSize(18);
  fill(255);
  text("FPS: " + fr, 20, 38); 
}

void drawEditRings(){
  int rr = remainingRings;
  ringMap = map(rr, 0, 15, 0, imgWidth);
  textSize(18);
  fill(255);
  text("Remaining Rings: " + rr, 175, 38);
}

void drawEditRingTimer(){
  int prt = purgeRingsTimer;
  ringMapTimer = map(prt, 0, 205000, 0, imgWidth);
  textSize(18);
  fill(255);
  text("Purge Ring Timer: " + prt, 350, 38);
}

void loadConfig(){
  config = loadStrings(configFileName);
  
  for(int i = 0; i < config.length; i++) {
    String[] pieces = split(config[i], ' ');
    println(pieces[0] + ": " + pieces[1]);
    
    // Sets the config file to appropriate variables in the app
    switch(pieces[0]) {
      case "showRingGradient": 
        showRingGradient = boolean(pieces[1]);
        break;
      case "showRingStroke": 
        showRingStroke = boolean(pieces[1]);
        break;
      case "blendModeIndex": 
        blendModeIndex = int(pieces[1]);
        break;
      case "pulseMode": 
        pulseMode = boolean(pieces[1]);
        break;
      case "amplitude": 
        amplitude = int(pieces[1]);
        break;
      case "verticalChange": 
        verticalChange = int(pieces[1]);
        break;
      case "remainingRings": 
        remainingRings = int(pieces[1]);
        break;
      case "purgeRingsTimer": 
        purgeRingsTimer = int(pieces[1]);
        break;
    }
  }
}

void saveConfig(){
  String words = "showRingGradient "+ showRingGradient +"\n";
          words += "showRingStroke " + showRingStroke + "\n";
          words += "blendModeIndex " + blendModeIndex + "\n";
          words += "pulseMode " + pulseMode + "\n";
          words += "amplitude " + amplitude + "\n";
          words += "verticalChange " + verticalChange + "\n";
          words += "remainingRings " + remainingRings + "\n";
          words += "purgeRingsTimer " + purgeRingsTimer;
  String[] list = split(words, '\n');
  
  // Writes the behaviour variables to the config file 
  saveStrings("data/" + configFileName, list);
}