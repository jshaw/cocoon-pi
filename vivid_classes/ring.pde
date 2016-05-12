class Ring {
  //int x, y, id, beat;
  float x, y; // X-coordinate, y-coordinate
  int id, beat; 
  // Beat movement if initiated
  float xSpeed, ySpeed;
  float diameter;      // Diameter of the ring
  boolean on = false;  // Turns the display on and off
  boolean visible = false;
  boolean growing = true;
  long lastBeat;
  int pulse;
  
  // What key has been pressed
  int state = 48;
  
  // Var for generating x,y random speed
  float speed = 0.5;
  
  //
  float angle = 0.0;

  Ring(int xpos, int ypos, int idin, int s) {
    x = (float)xpos;
    y = (float)ypos;
    id = idin;
    state = s;
    
    xSpeed = (float)random(-speed, speed);
    ySpeed = (float)random(-speed, speed);
    
    print("xSpeed: ");
    println(xSpeed);
    
    print("ySpeed: ");
    println(ySpeed);

    int size = rings.size();
    if (size == 0){size = 1;}
    diameter = 400/size;
    angle = 0.0;
    on = true;
    beat = int(random(700, 1100));
    lastBeat = millis();
    print("beat: ");
    println(beat);
  }

  void update() {
    
    // Key 0 & 3
    if(state == 48 || state == 51 ){
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
    
    // Key 1
    if(state == 49 ){
      if (diameter > 10) {
        diameter -= 0.1;
      }
      on = true;
      visible = true;
    }
    
    // Key 2
    if(state == 50 ){
      
      if (diameter > 10) {
        diameter -= 0.1;
      }
      
      on = true;
      visible = true;
      
      x += xSpeed;
      y += ySpeed;
      
      if ( (x<0) || (x>160)){
       xSpeed = -xSpeed;
      } 
       
      if( (y<0) || (y>10)) {
       ySpeed = -ySpeed; 
      }
    }
  
    // Key 3
    if(state == 51 ){
      
      if (diameter > 10) {
        diameter -= 0.1;
      }
      
      x += xSpeed;
      y += ySpeed;
      
      float r = diameter/2;
      
      if ( (x<r) || (x>160-r)){
       xSpeed = -xSpeed;
      } 
       
      if( (y<r) || (y>10-r)) {
       ySpeed = -ySpeed; 
      }
    }

    // Key 4
    if(state == 52 ){
      
      if (diameter > 10) {
        diameter -= 0.1;
      }
      
      on = true;
      visible = true;

    }
    
    // Key 5
    if(state == 53 ){
      
      if (diameter > 10) {
        diameter -= 0.1;
      }
      
      on = true;
      visible = true;
    }
  }
  
  void display() {
    if (on == true) {
      fbo.fill(map(beat, 700, 1100, 1, 360), 255, 255, 255);
      fbo.strokeWeight(1);
      fbo.noStroke();
      
      // Visible && Key 0 (Blinks)
      if (visible && state == 48) {
        fbo.ellipse(x, y, diameter, diameter);
      }
      
      // Key 1
      if (state == 49){
        //fbo.ellipse(x, y, (sin(angle*2) + sin(angle/2)) + diameter, (sin(angle/2) + sin(angle)) + diameter);
        fbo.ellipse(x, y, (sin(angle*2) + sin(angle/2)) + diameter, (sin(angle*2) + sin(angle/2)) + diameter);
      }
      
      // Key 2
      if (state == 50){
        float diameterWH = constrain(diameter, 10, 1000) + sin(angle) * 5 + (cos(angle/2))* 5;
        
      }
      
      // Key 3
      if (visible && state == 51){
        fbo.ellipse(x, y, diameter/2, diameter/2);
      }
      
      // Visible && Key 4 (Blinks)
      if (visible && state == 52){
        float animationPulse = 10 + (sin(PI*angle/5)+sin(angle*2/5)) * 4;
        
        fbo.stroke(0, 0, 255, 255);
        fbo.ellipse(x, y, animationPulse + 2 , animationPulse + 2);
        noStroke();
        
        fbo.ellipse(x, y, animationPulse, animationPulse);
        
        // working on wrapping circle around       
        float radius = animationPulse / 2;
        
        if (x-radius >= 0){
          println("===== wrap =====");
          println("diamater: ");
          print(animationPulse);
          
          stroke(255,255,255);
          fbo.ellipse(x, y + 10, animationPulse, animationPulse);
          noStroke();
        }
        
        if (x+radius >= 10){
          println("===== wrap =====");
          println("diamater: ");
          print(animationPulse);
          
          stroke(255,255,255);
          fbo.ellipse(x, y - 10, animationPulse, animationPulse);
          noStroke();
        }
        
      }
      
      // Visible && Key 5 (Blinks)
      if (visible && state == 53){
        float animationPulse = 15 + (sin(2-angle) + sin(x/angle)) * -6;
        fbo.ellipse(x, y, animationPulse, animationPulse);
      }

    }
    
    // Consistent rotation for each ring
    //angle += 0.1;
    
    // Pulse the ring based on the provided beat
    angle += float(beat) / float(1000);
    
    print("beat: ");
    println(beat);
    
    print("ANGLE: ");
    println(angle);
  }
  
  void updateState(int s){
    print("State Update: ");
    println(s);
    println("========");
    state = s;
  }
  
}

// Test trig equations
// ===================
//fbo.ellipse(x, y, (sin(diameter/2) + sin(diameter)) * 10 , (sin(diameter/2) + sin(diameter)) * 10);
//fbo.ellipse(x, y, sin(angle/2) + 10, sin(angle/2) + 10);
//fbo.ellipse(x, y, (sin(angle/2) + sin(angle)) + 10, (sin(angle/2) + sin(angle)) + 10);