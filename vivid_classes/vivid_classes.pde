// Behaviours controlled by keyboard keypressed. 
// States reference number on keyboard 
// 0:  blinking per supplied beat
// 1: pulsates at a specific time (need to add the beat into this)
// 2: pulsates + moves
// 3: blinks to beat + moves
// 4: pulsates more quickly
// 5: blinks + pulsates more quickly
// 6: decreases diameter + pulsates in a hearbeat pattern

ArrayList<Ring> rings;
int ringCount = 0;
PGraphics fbo;
PImage img;
// Default to #4 key
int state = 54;
int tubeRes = 32;

float rotx = PI/4;
float roty = PI/4;

boolean show3d = false;

void setup() {
  size(600, 600, P3D);
  rings = new ArrayList();
  colorMode(RGB);
  fbo = createGraphics(10, 160);
  //img = loadImage("berlin-1.jpg");
  img = loadImage("vividTestTextures_2.jpg");
}

void draw() {
  
  background(100,255);
  colorMode(HSB);
  //lights();
  //ambientLight(102, 102, 102);
  
  //directionalLight(255, 255, 255, 1, 1, 1);
  
  buildFbo();
  image(fbo, 60, 60, 30, 480);
  
  translate(width / 2, height / 2);
  
  if(show3d){
    rotateX(rotx);
    rotateY(roty);
    
    fbo.colorMode(RGB);
    fill(255, 255, 255);
    pushMatrix();
    //drawCylinder(32, 10, 160);
    drawCylinder(32, 30, 480);
    popMatrix();
  }
}

void mousePressed() {
  ringCount++; 
  rings.add(new Ring((int)random(0,10), (int)random(0,160), ringCount, (int)state));
  println(rings.size());
}

void keyPressed() {
  println(key);
  if(key == 's'){
    println("*******");
    println(show3d);
    println("*******");
    show3d =! show3d;
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
  fbo.background(0,255);
  fbo.colorMode(HSB);
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
    
    //translate(100.0, 0.0);
    //rotateX(-80.1);

    //// draw top of the tube
    //beginShape();
    //for (int i = 0; i <= sides; i++) {
    //   float x = cos( radians( i * angle ) ) * r;
    //   float y = sin( radians( i * angle ) ) * r;
    //   vertex( x, y, -halfHeight);
    //}
    //endShape(CLOSE);

    ////// draw bottom of the tube
    //beginShape();
    //for (int i = 0; i < sides; i++) {
    //   float x = cos( radians( i * angle ) ) * r;
    //   float y = sin( radians( i * angle ) ) * r;
    //   vertex( x, y, halfHeight);
    //}
    //endShape(CLOSE);
    
    // draw sides
    beginShape(TRIANGLE_STRIP);
    texture(fbo);
    //texture(img);
    for (int i = 0; i < sides + 1; i++) {
    //for (int i = 0; i < 10; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        //float u = fbo.width / tubeRes * i;
        
        //println("=========");
        //println(img.width);
        
        float u = (float)img.width / (float)tubeRes * (float)i;
        
        //println(u);
        //println("=========");
        
        vertex( x, y, halfHeight, u, 0);
        vertex( x, y, -halfHeight, u, img.height);
    }
    endShape(CLOSE);
}