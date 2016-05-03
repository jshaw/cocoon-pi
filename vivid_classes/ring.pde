class Ring {
  int x, y, id, beat;          // X-coordinate, y-coordinate
  float diameter;      // Diameter of the ring
  boolean on = false;  // Turns the display on and off
  boolean visible = false;
  boolean growing = true;
  long lastBeat;
  int pulse;

  Ring(int xpos, int ypos, int idin) {
    x = xpos;
    y = ypos; 
    id = idin;
    int size = rings.size();
    if (size == 0){size = 1;}
    diameter = 400/size;
    on = true;
    beat = int(random(100, 400));
    lastBeat = millis();
    println(beat);
  }

  void update() {
    if (on == true) {    // is it active
      if (growing) {
        diameter += 0.1;
        if (diameter > 10) {
          growing = false;
        }
      } else {
        diameter -= 0.1;
        if (diameter < 4) {
          growing = true;
        }
      }
      if ((millis() - lastBeat) > beat) {     // flash to the beat!
        visible = !visible;                   // we can add interpolation later.
        lastBeat = millis();
      }
    }
  }
    void display() {
      if (on == true) {
        fbo.fill(map(beat, 100, 400, 1, 360), 255, 255, 255);
        fbo.strokeWeight(4);
        fbo.noStroke();
        if (visible) {
          fbo.ellipse(x, y, diameter, diameter);
        }
      }
    }
  }