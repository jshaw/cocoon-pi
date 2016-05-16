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
// S: toggles visualization
// a: simulates new heartbeat from sensors with a random value between 700 and 1100
// x: kills all objects and creates a blank canvas.

ArrayList<Ring> rings;
int ringCount = 0;
PGraphics fbo;
PImage img;

// Default to #6 key
int state = 54;

// number of 
int tubeRes = 32;

int imgWidth = 10;
int imgHeight = 160;

float rotx = PI/4;
float roty = PI/4;

// display the 3d simulation of the cocoon
boolean show3d = true;

void setup() {
  size(600, 600, P3D);
  rings = new ArrayList();
  colorMode(RGB);

  // Change color mode to be 
  fbo = createGraphics(imgWidth, imgHeight);

  // img for testing and debugging texture mapping
  //img = loadImage("vividTestTextures_2.jpg");
}

void draw() {

  background(100, 255);
  colorMode(HSB);

  // Messing around with lighting
  //lights();
  //ambientLight(102, 102, 102);
  //directionalLight(255, 255, 255, 1, 1, 1);

  buildFbo();
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
  }
  else if (key == 'a') {
    ringCount++; 
    rings.add(new Ring((int)random(0, imgWidth), (int)random(0, imgHeight), ringCount, (int)state));
    println(rings.size());
  }
  else if (key == 'x') {   // clear all objects
    rings.clear();
  } else {
    state =(int)key;
  }
}

void mouseDragged() {
  float rate = 0.01;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}

void buildFbo() {
  fbo.beginDraw();
  fbo.background(0, 255);
  fbo.colorMode(HSB);
  fbo.blendMode(ADD);

  for (int i = 0; i < rings.size(); i++) {
    Ring r = rings.get(i);
    r.updateState(state);
    r.update();
    r.display();
    if (r.on == false) {
      rings.remove(i);
      println(rings.size());
    }
  }
  fbo.endDraw();
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