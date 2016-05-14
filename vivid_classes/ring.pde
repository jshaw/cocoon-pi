class Ring {
  
  float x, y; // X-coordinate, y-coordinate
  int id, beat; 
  
  // Beat movement if initiated
  float xSpeed, ySpeed;
  float diameter;      // Diameter of the ring
  float animationPulse; // the dynamic and updated diameter or the pulsing circle
  
  boolean on = false;  // Turns the display on and off
  boolean visible = false;
  boolean growing = true;
  long lastBeat;
  int pulse;
  
  int beatMin = 700;
  int beatMax = 1100;
  int imgWidth = 10;
  int imgHeight = 160;
  
  //Size of flair
  float flair = 0.0;
  
  // Flair growing speed
  float flairSpeed = 1.0;
  
  // flair start tranparency
  float transparency = 255.0;
  
  // flair transparency increase speed
  float transparencySpeed = 5.0;
  
  // What key has been pressed
  int state;
  
  // Var for generating x,y random speed
  float speed = 0.5;
  
  // track maths increment angle for sin/cos equations
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
    if (size == 0) {
      size = 1;
    }
    diameter = 100/size;
    angle = 0.0;
    on = true;
    beat = int(random(beatMin, beatMax));
    lastBeat = millis();
    
    print("beat: ");
    println(beat);
  }

  void update() {

    // Key 0 & 3
    if (state == 48 || state == 51 ) {
      if (on == true) {    // is it active
        if (growing) {
          diameter += 0.1;
        } else {
          diameter -= 0.1;
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

    // Key 1
    if(state == 49 ){
      on = true;
      visible = true;
      
      decreaseDiameter();
    }

    // Key 2
    if(state == 50 ){
      on = true;
      visible = true;
      
      decreaseDiameter();
      updateSpeed();
    }

    // Key 3
    if(state == 51 ){
      decreaseDiameter();
      updateSpeed();
    }

    // Key 4
    if(state == 52 ){
      on = true;
      visible = true;
      
      decreaseDiameter();
    }
    
    // Key 5
    if(state == 53 ){
      on = true;
      visible = true;
      
      decreaseDiameter();
    }
    
    // Key 6
    if(state == 54 ){
      if (on == true) {    // is it active
        decreaseDiameter();
      }
    }
  }

  void display() {
    if (on == true) {
      // Sets the default circle fill color 
      setRingFill();
      //fbo.strokeWeight(1);
      fbo.noStroke();

      // Visible && Key 0 (Blinks)
      if (visible && state == 48) {
        animationPulse = diameter;
      }

      // Key 1
      if (state == 49){
        animationPulse = (sin(angle*2) + sin(angle/2)) + diameter;
      }

      // Key 2
      if (state == 50){
        animationPulse = constrain(diameter, 10, 1000) + sin(angle) * 5 + (cos(angle/2))* 5;
      }

      // Key 3
      if (visible && state == 51){
        animationPulse = diameter/2;
      }

      // Visible && Key 4 (Blinks)
      if (visible && state == 52){
        
        noStroke();
        animationPulse = 10 + (sin(PI*angle/10)+sin(angle*2/10)) * 4;
        
        // Draws bursting flair visual behind the ring
        drawFlair(animationPulse);       
        
        // Sets ring default fill color after drawing the flair 
        setRingFill();
        
        // working on wrapping circle around
        drawWrappedShapes(animationPulse);
        
      }

      if (visible && state == 53){
        animationPulse = 15 + (sin(2-angle) + sin(x/angle)) * -6;
      }

      // Visible && Key 6 (Blinks)
      if (state == 54){
        noStroke();
        // Decent Tests
        // ===================
        //float animationPulse = diameter + 2*sin(angle/2) - sin(1+angle);
        // float animationPulse = diameter + 2*sin((angle/2)/2) - sin(1+angle/x);
        // float animationPulse = diameter + 2*sin(angle/2) - (sin(1+angle)/2);
        
        animationPulse = diameter + (2*sin(angle/2)/2) - (sin(1+angle)/2);
        drawFlair(animationPulse);
        setRingFill();
        
        // working on wrapping circle around
        drawWrappedShapes(animationPulse);
        
      }
      
      // Draws the main ring / circle that represents the beat
      // =================
      fbo.ellipse(x, y, animationPulse, animationPulse * 2);

    }
    
    // Pulse the ring based on the provided beat
    // Default angle for consistent toration is 0.1
    angle += float(beat) / float(1000);
    
    //print("beat: ");
    //println(beat);
    
    //print("ANGLE: ");
    //println(angle);
    
  }
  
  void updateState(int s){
    //print("State Update: ");
    //println(s);
    //println("========");
    state = s;
  }
  
  void setRingFill(){   
    fbo.fill(map(beat, beatMin, beatMax, 1, 360), 255, 255, 255);
  }
  
  void drawFlair(float animationPulse){
    if(transparency > 0){
      fbo.fill(0, 0, 255, transparency - transparencySpeed);
      fbo.ellipse(x, y, animationPulse + flair, animationPulse * 2 + flair);
      
      flair += flairSpeed;
      transparency -= transparencySpeed;
    }
  }
  
  void drawWrappedShapes(float animationPulse){
    float radius = animationPulse / 2;
        
    if (x - radius >= 0.0){
      fbo.ellipse(x - 10.0, y, animationPulse, animationPulse * 2);
      fbo.noStroke();
    }
    
    if (x - radius <= 0.0){
      fbo.ellipse(x + 10.0, y, animationPulse, animationPulse * 2);
      fbo.noStroke();
    }
  }

  void decreaseDiameter(){
    if (diameter > 10) {
      diameter -= 0.1;
    }
  }
  
  void updateSpeed(){
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