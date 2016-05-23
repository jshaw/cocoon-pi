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
// a: simulates new heartbeat from sensors with a random value between 700 and 1100
// x: kills all objects and creates a blank canvas.
// g: will toggle between the gradient on the rings to help with color blending
// t: will toggle between showing a dark stroke ring around the flair
// m: pressing m multiple times will cycle through the different blendModes
// s: will toggle the visibility of the 3d simulation
// left mouse: click and hold the left mouse button will rotate the 3d simulation


import eDMX.*;
//--------------------------------comment out for non-Pi use-----------
import processing.io.*;    // enable this on the pi.
I2C i2c;
//---------------------------------------------------------------------

int val = 0;

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

void setup() {
  size(600, 600, P3D);
  rings = new ArrayList();
  colorMode(RGB);

  //--------------------------------comment out for non-Pi use-----------
  i2c = new I2C(I2C.list()[0]);
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
  colorMode(RGB);

  // Messing around with lighting
  //lights();
  //ambientLight(102, 102, 102);
  //directionalLight(255, 255, 255, 1, 1, 1);

  //--------------------------------comment out for non-Pi use-----------
  // check console 4

  if ((millis() - timer) > 2000) {
    beat4 = getBeat(4);
    if (beat4>0) {
      addRing(beat4);
    }

    // check console 5
    beat5 = getBeat(5);

    if (beat5>0) {
      addRing(beat5);
    }
    timer = millis();
  }
  //---------------------------------------------------------------------

  buildFbo();
  mapPixels();
  image(fbo, 60, 60, imgWidth * 3, imgHeight * 3);

  translate(width / 2, height / 2);

  if (show3d) {
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

  if (key == 's') {
    show3d =! show3d;
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
  } else if (key == 't') {
    showRingStroke =! showRingStroke;
  } else {
    // setting this here actually pauses the animations
    //state =(int)key;
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
    r.toggleRingGradient(showRingGradient);
    r.toggleRingStroke(showRingStroke);
    r.update();
    r.display();
    if (r.on == false) {
      rings.remove(i);
      println(rings.size());
    }
  }
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
int getBeat(int address) {
  int newbeat = 0;
  if (I2C.list() != null)
  {
    i2c.beginTransmission(address);
    i2c.write(address);

    try
    {
      byte[] in = i2c.read(4);

      int beat = in[0];
      if (beat<0) {
        beat = beat +256;
      }
      newbeat = beat;
      print("Address: " + address + " beat: ");
      println(beat);
    }
    catch(Exception e)
    {
      i2c.endTransmission();
    }
  }
  return(newbeat);
}
//----------------------------------------------------------------------


void addRing(int inbeat) {
  ringCount++; 
  rings.add(new Ring((int)random(0, imgWidth), (int)random(0, imgHeight), ringCount, (int)state, inbeat));
  ringCount = rings.size();
}