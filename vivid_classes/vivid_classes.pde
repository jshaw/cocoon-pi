ArrayList<Ring> rings;
int ringCount = 0;
PGraphics fbo;

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
  rings.add(new Ring((int)random(0,160), (int)random(0,10), ringCount));
  println(rings.size());
}


void buildFbo() {
  fbo.beginDraw();
  fbo.background(0,255);
  fbo.colorMode(HSB);
  for (int i = 0; i < rings.size(); i++) {
    Ring r = rings.get(i);
    r.update();
    r.display();
    if (r.on == false) {
      rings.remove(i);
      println(rings.size());
    }
  }
  fbo.endDraw();
}