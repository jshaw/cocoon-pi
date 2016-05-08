// Behaviours controlled by keyboard keypressed. 
// States reference number on keyboard 
// 0:  blinking per supplied beat
// 1: pulsates at a specific time (need to add the beat into this)
// 2: pulsates + moves
// 3: blinks to beat + moves
// 4: pulsates more quickly
// 5: blinks + pulsates more quickly

ArrayList<Ring> rings;
int ringCount = 0;
PGraphics fbo;
int state = 48;

void setup() {
  size(600, 300);
  rings = new ArrayList();
  colorMode(RGB);
  fbo = createGraphics(160, 10);
}

void draw() {
  background(100,255);
  colorMode(HSB);
  buildFbo();
  image(fbo, 60, 100, 480, 30);
}

void mousePressed() {
  ringCount++; 
  rings.add(new Ring((int)random(0,160), (int)random(0,10), ringCount, (int)state));
  println(rings.size());
}

void keyPressed() {
  println(key);
  state =(int)key;
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