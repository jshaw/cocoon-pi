import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import eDMX.*; 
import processing.io.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class vivid_classes extends PApplet {

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



//--------------------------------comment out for non-Pi use-----------
    // enable this on the pi.
I2C i2c;
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

// Max number of rings that can be in the sketch
// If any more rings are added start to remove the old rings
int maxNumberOfRings = 30;

boolean editRings = false;
boolean editRingTimer = false;

float ringMap = 0.0f;
float ringMapTimer = 0.0f;

public void setup() {
  
  frameRate(fps);
  rings = new ArrayList();
  colorMode(RGB);
  
  //--------------------------------comment out for non-Pi use-----------
  i2c = new I2C(I2C.list()[0]);
  //---------------------------------------------------------------------

  // Timer so we don't clobber the i2c port
  timer = millis();

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

public void draw() {
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
  
  if ((millis() - lastAddTimer) > purgeRingsTimer && fadeOldRings == false) {
    fadeOldRings = true;
    //println("Fade old rings");
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

public void mousePressed() {
}

public void keyPressed() {
  println(key);

  if (key == 'd') {
    show3d =! show3d;
  } else if (key == 's') {
    saveConfig();
  } else if (key == 'l') {
    loadConfig();
  } else if (key == 'a') {
    // make a new Ring object
    addRing(PApplet.parseInt(random(700, 1100)));
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

public void mouseDragged() {
  float rate = 0.01f;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}

public void buildFbo() {
  fbo.beginDraw();
  fbo.colorMode(RGB);

  // background RED for testing only...
  fbo.background(0, 0, 0, 255);
  fbo.colorMode(HSB);
  fbo.blendMode(blendModeIndex);

  // Checks to see the number if rings and that they don't exceed the max number
  // if the max number is exceeded remove the oldest rings so that the rings size is equal to the max
  // number of rings.
  if (rings.size() > maxNumberOfRings){
    int rs = rings.size();
    int sizeDifference = rs - maxNumberOfRings; 
    for (int j = 0; j < sizeDifference; j++) {
      rings.remove(j);
    }
  }

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

public void mapPixels() {
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

public char gamma(char input) {
  return gammaLUT[input];
}

public void drawCylinder( int sides, float r, float h) {
  float angle = 360.0f / (float)sides;
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

public void drawEnds(float halfHeight, float angle, int sides, float r, float h) {
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
 public int getBeat(int address) {
 int newbeat = 0;
 if (I2C.list() != null)
 {
   i2c.beginTransmission(address);
   i2c.write(address);

   try
    {
      byte[] in = i2c.read(4);
      String beatString = new String(in);
      int beat = PApplet.parseInt(trim(beatString));
      
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


public void addRing(int inbeat) {
  ringCount++; 
  rings.add(new Ring((int)random(0, imgWidth), (int)random(0, imgHeight), ringCount, (int)state, inbeat));
  lastAddTimer = millis();
  ringCount = rings.size();
}

public void drawFrameRate(){
  float fr = frameRate;
  textSize(18);
  fill(255);
  text("FPS: " + fr, 20, 38); 
}

public void drawEditRings(){
  int rr = remainingRings;
  ringMap = map(rr, 0, 15, 0, imgWidth);
  textSize(18);
  fill(255);
  text("Remaining Rings: " + rr, 175, 38);
}

public void drawEditRingTimer(){
  int prt = purgeRingsTimer;
  ringMapTimer = map(prt, 0, 205000, 0, imgWidth);
  textSize(18);
  fill(255);
  text("Purge Ring Timer: " + prt, 350, 38);
}

public void loadConfig(){
  config = loadStrings(configFileName);
  
  for(int i = 0; i < config.length; i++) {
    String[] pieces = split(config[i], ' ');
    println(pieces[0] + ": " + pieces[1]);
    
    // Sets the config file to appropriate variables in the app
    switch(pieces[0]) {
      case "showRingGradient": 
        showRingGradient = PApplet.parseBoolean(pieces[1]);
        break;
      case "showRingStroke": 
        showRingStroke = PApplet.parseBoolean(pieces[1]);
        break;
      case "blendModeIndex": 
        blendModeIndex = PApplet.parseInt(pieces[1]);
        break;
      case "pulseMode": 
        pulseMode = PApplet.parseBoolean(pieces[1]);
        break;
      case "amplitude": 
        amplitude = PApplet.parseInt(pieces[1]);
        break;
      case "verticalChange": 
        verticalChange = PApplet.parseInt(pieces[1]);
        break;
      case "remainingRings": 
        remainingRings = PApplet.parseInt(pieces[1]);
        break;
      case "purgeRingsTimer": 
        purgeRingsTimer = PApplet.parseInt(pieces[1]);
        break;
    }
  }
}

public void saveConfig(){
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
  class Ring {
  
  int fps = 30;
  float x, y; // X-coordinate, y-coordinate
  int id, beat; 
  
  // Beat movement if initiated
  float xSpeed, ySpeed;
  float diameter;      // Diameter of the ring
  float animationPulse; // the dynamic and updated diameter or the pulsing circle
  
  boolean on = true;  // Turns the display on and off
  boolean visible = false;
  boolean growing = true;
  long lastBeat;
  int pulse;
  
  int beatMin = 700;
  int beatMax = 1100;
  int imgWidth = 10;
  int imgHeight = 160;
  
  // Used in the ring class
  // amplitude is scaling the height of the pulsing (left/right)
  // verticalChange is moving the sine animation up the y axis so all the numbers are positive (up/down)
  // this can be changed via up/down or left/right keys
  int amplitude = 5;
  int verticalChange = 10;
  
  //Size of flair
  float flair = 0.0f;
  
  // Flair growing speed
  float flairSpeed = 1.0f;
  
  // flair start tranparency
  float transparency = 255.0f;
  
  // flair transparency increase speed
  float transparencySpeed = 5.0f;
  
  // What key has been pressed
  int state;
  
  // Var for generating x,y random speed
  float speed = 0.5f;
  
  // track maths increment angle for sin/cos equations
  float angle = 0.0f;
  
  // state tracking for showing ring gradient
  boolean showRingGradient = true;
  
  boolean showRingStroke = true;
  
  // To pulse or not to pulse
  boolean pulseMode = true;
  
  int alphaFillVal = 255;
  int initDefaultFill = 50;

  Ring(int xpos, int ypos, int idin, int s, int b) {
    x = (float)xpos;
    y = (float)ypos;
    id = idin;
    state = s;
    beat = b;

    xSpeed = (float)random(-speed, speed);
    ySpeed = (float)random(-speed, speed);

    print("xSpeed: ");
    println(xSpeed);

    print("ySpeed: ");
    println(ySpeed);

    int size = rings.size();
    if (size == 0) {
      size = 1;
    }
    diameter = 100/size;
    angle = 0.0f;
    on = true;
    lastBeat = millis();
    
    print("beat: ");
    println(beat);
  }

  public void update() {
    noStroke();

    // Key 0 & 3
    if (state == 48 || state == 51) {
      if (on == true) {    // is it active
        if (growing) {
          diameter += 0.1f;
        } else {
          diameter -= 0.1f;
          if (diameter < 400/rings.size()-10) {
            growing = true;
          }
        }
        
        if (diameter > 400/rings.size()+10) {
          growing = false;
        }
        if (diameter < 400/rings.size()-10) {
          growing = true;
        }
        if ((millis() - lastBeat) > beat) {     // flash to the beat!
          visible = !visible;                   // we can add interpolation later.
          lastBeat = millis();
        }
      }
    }

    // Visible && Key 0 (Blinks)
    if (visible && state == 48) {
      animationPulse = diameter;
    }
    
    // Key 1
    if(state == 49 ){
      on = true;
      visible = true;
      decreaseDiameter();
      animationPulse = (sin(angle*2) + sin(angle/2)) + diameter;
    }

    // Key 2
    if(state == 50 ){
      on = true;
      visible = true;
      decreaseDiameter();
      updateSpeed();
      animationPulse = constrain(diameter, 10, 1000) + sin(angle) * 5 + (cos(angle/2))* 5;
    }

    // Key 3
    if(state == 51 ){
      decreaseDiameter();
      updateSpeed();
      animationPulse = diameter/2;
    }

    // Key 4
    if(state == 52 ){
      //on = true;
      visible = true;
      decreaseDiameter();
      
      // Toggles PulseMode. Controlled by 'p' on the keyboard
      if(pulseMode == true){
        //animationPulse = 10 + (sin(radians(angle/2)) + sin(radians(angle)))*-5;
        animationPulse = verticalChange + (sin(radians(angle/2)) + sin(radians(angle)))*(amplitude*-1);
      } else{
        //animationPulse = 10 + sin(radians(angle))*5;
        animationPulse = verticalChange + sin(radians(angle))*amplitude;
      }
      
    }
    
    // Key 5
    if(state == 53 ){
      on = true;
      visible = true;
      decreaseDiameter();
      animationPulse = 15 + (sin(2-angle) + sin(x/angle)) * -6;
    }
    
    // Key 6
    if(state == 54 ){
      if (on == true) {    // is it active
        decreaseDiameter();
        animationPulse = diameter + (2*sin(angle/2)/2) - (sin(1+angle)/2);
      }
    }
  }

  public void display() {
    if (on == true) {
      // Sets the default circle fill color 
      setRingFill(alphaFillVal);
      fbo.noStroke();

      // Visible && Key 4 (Blinks) || Key 6
      if (visible && state == 52 || state == 54){
        
        // Draws bursting flair visual behind the ring
        drawFlair(animationPulse);       
        
        // Sets ring default fill color after drawing the flair 
        setRingFill(alphaFillVal);
        
        // working on wrapping circle around
        drawWrappedShapes(animationPulse);        
      }
      
      // Draws the main ring / circle that represents the beat
      // =================
      if(showRingGradient == true){       
        drawEllipseGradient(x, y, animationPulse);
      }
      
      setRingFill(alphaFillVal);
      fbo.ellipse(x, y, animationPulse, animationPulse * 2);

    }
    
    // Pulse the ring based on the provided beat
    // Calculates the number of degrees that needs to made per frame
    // What we are doing here is calculating how much time we have to to turn a full 360degrees 
    // within one second in the app 
    // degrees in a circle / (frames per second ( beat millisecond / second in milliseconds ))
    // 360 / (30 * (beat/1000))
    // 360 / #of seconds to rotate
    // = #degrees to make per frame
    // ==================================
    angle += degrees(TWO_PI) / ((float)fps * (PApplet.parseFloat(beat) / PApplet.parseFloat(1000)));    
    
    // ========== angle debugging for pulsing ring ============
    //print("new angle: ");
    //print(degrees(TWO_PI) / ((float)fps * (float(beat) / float(1000))));
    
    //print("angle: ");
    //println(angle);
    
    //print("beat: ");
    //println(beat);
    // ========== END debugging ============
  }
  
  // Updates the state of the visuals (what version to display)
  public void updateState(int s){
    state = s;
  }
  
  public void setRingFill(int alpha){   
    fbo.fill(map(beat, beatMin, beatMax, 1, 255), 255, 255, alpha);
  }
  
  public void drawFlair(float animationPulse){
    if(transparency > 0){
      float flairOffset = 0.0f;
      fbo.fill(0, 0, 255, transparency - transparencySpeed);
      
      if(showRingStroke){
        fbo.strokeWeight(3);
        fbo.stroke(0, 0, 0, transparency - transparencySpeed);
      } else {
        fbo.noStroke();
      }
      
      if(showRingGradient == true){
        flairOffset = 12.0f;      
      }
      
      fbo.ellipse(x, y, animationPulse + flairOffset + flair, (animationPulse + flairOffset) * 2 + flair);
      fbo.noStroke();
      
      flair += flairSpeed;
      transparency -= transparencySpeed;
    }
  }
  
  public void drawWrappedShapes(float animationPulse){
    float radius = animationPulse / 2;
        
    // Removed conditional to draw wrapped rings all of the time
    // They always wrap at somepoint due to pulsing + gradient
    if(showRingGradient == true){
      drawEllipseGradient((x-10), y, animationPulse);
    }
    
    setRingFill(alphaFillVal);
    fbo.ellipse(x-10, y, animationPulse, animationPulse * 2);
    
    fbo.noStroke();
    
    if(showRingGradient == true){
      drawEllipseGradient((x+10), y, animationPulse);
    }
    
    setRingFill(alphaFillVal);
    fbo.ellipse(x+10, y, animationPulse, animationPulse * 2);
    
    fbo.noStroke();
  }

  public void drawEllipseGradient(float x, float y, float animationPulse){
    int initFill = initDefaultFill;
    float initPulseIncrement = 9.0f;
    
    for (int i = 0; i <= 2; i++){
     float aP = animationPulse + initPulseIncrement;
     setRingFill(initFill);
     fbo.ellipse(x, y, aP, aP * 2);
      
     initFill+=initFill;
     initPulseIncrement -= 3.0f;
    }
  }

  public void decreaseDiameter(){
    if (diameter > 10) {
      diameter -= 0.1f;
    }
  }
  
  public void toggleRingGradient(boolean showGradient){
    showRingGradient = showGradient;
  }
  
  public void updatePulseMode(boolean pm){
    pulseMode = pm;
  }
  
  public void toggleRingStroke(boolean showStroke){
    showRingStroke = showStroke;
  }
  
  public boolean returnOnValue(){
    return on;
  }
  
  // After a time of inactivity. No new beats
  public void fadeAway(){
    // fade away the actual ring via alpha
    if(alphaFillVal > 0){
      alphaFillVal -= 1;
    } 
    
    // when alpha is at 0, mark as ready to be removed from array list
    if(alphaFillVal == 0){
      on = false;
    }
    
    // fade away the gradient alpha rings around the original ring
    if(initDefaultFill > 0){
     initDefaultFill -= 1;
    }
  }
    
  public void updateVerticalChangeAmplitude(int a, int vc){
    // Controls the distance or spread between the highest and lowest parts of the curve
    if(a > 1){
      amplitude = a;
    }
    
    // Move the sin way up the y axis.
    // this controls if the smallest number will ever be below 0. 
    if(vc > 1){
      verticalChange = vc;
    }    
  }
    
  public void updateSpeed(){
    x += xSpeed;
    y += ySpeed;
      
    float radius = diameter / 2;
    
    if ( (x < radius) || (x > imgWidth - radius)){
     xSpeed = -xSpeed;
    } 
     
    if( (y < radius) || (y > imgHeight - radius)) {
     ySpeed = -ySpeed; 
    }
  }
}

// Test trig equations
// ===================
//fbo.ellipse(x, y, (sin(diameter/2) + sin(diameter)) * 10 , (sin(diameter/2) + sin(diameter)) * 10);
//fbo.ellipse(x, y, sin(angle/2) + 10, sin(angle/2) + 10);
//fbo.ellipse(x, y, (sin(angle/2) + sin(angle)) + 10, (sin(angle/2) + sin(angle)) + 10);

// Other decent equations
// ===================
// float animationPulse = diameter + 2*sin(angle/2) - sin(1+angle);
// float animationPulse = diameter + 2*sin((angle/2)/2) - sin(1+angle/x);
// float animationPulse = diameter + 2*sin(angle/2) - (sin(1+angle)/2);
  public void settings() {  size(600, 600, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "vivid_classes" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
