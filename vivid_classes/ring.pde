  class Ring {
  
  int fps = 30;
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
  
  // Used in the ring class
  // amplitude is scaling the height of the pulsing (left/right)
  // verticalChange is moving the sine animation up the y axis so all the numbers are positive (up/down)
  // this can be changed via up/down or left/right keys
  int amplitude = 5;
  int verticalChange = 10;
  
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
  
  // state tracking for showing ring gradient
  boolean showRingGradient = true;
  
  boolean showRingStroke = true;
  
  // To pulse or not to pulse
  boolean pulseMode = true;
  
  int alphaFillVal = 255;
  int initDefaultFill = 50;
  //float initPulseIncrement = 9.0;

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
    angle = 0.0;
    on = true;
    lastBeat = millis();
    
    print("beat: ");
    println(beat);
  }

  void update() {
    noStroke();

    // Key 0 & 3
    if (state == 48 || state == 51) {
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
      on = true;
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

  void display() {
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
    angle += degrees(TWO_PI) / ((float)fps * (float(beat) / float(1000)));    
    
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
  void updateState(int s){
    state = s;
  }
  
  void setRingFill(int alpha){   
    fbo.fill(map(beat, beatMin, beatMax, 1, 255), 255, 255, alpha);
  }
  
  void drawFlair(float animationPulse){
    if(transparency > 0){
      float flairOffset = 0.0;
      fbo.fill(0, 0, 255, transparency - transparencySpeed);
      
      if(showRingStroke){
        fbo.strokeWeight(3);
        fbo.stroke(0, 0, 0, transparency - transparencySpeed);
      } else {
        fbo.noStroke();
      }
      
      if(showRingGradient == true){
        flairOffset = 12.0;      
      }
      
      fbo.ellipse(x, y, animationPulse + flairOffset + flair, (animationPulse + flairOffset) * 2 + flair);
      fbo.noStroke();
      
      flair += flairSpeed;
      transparency -= transparencySpeed;
    }
  }
  
  void drawWrappedShapes(float animationPulse){
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

  void drawEllipseGradient(float x, float y, float animationPulse){
    int initFill = initDefaultFill;
    float initPulseIncrement = 9.0;
    
    for (int i = 0; i <= 2; i++){
     float aP = animationPulse + initPulseIncrement;
     setRingFill(initFill);
     fbo.ellipse(x, y, aP, aP * 2);
      
     initFill+=initFill;
     initPulseIncrement -= 3.0;
    }
  }

  void decreaseDiameter(){
    if (diameter > 10) {
      diameter -= 0.1;
    }
  }
  
  void toggleRingGradient(boolean showGradient){
    showRingGradient = showGradient;
  }
  
  void updatePulseMode(boolean pm){
    pulseMode = pm;
  }
  
  void toggleRingStroke(boolean showStroke){
    showRingStroke = showStroke;
  }
  
  void fadeAway(){
    println("FADE AWAY!");
    if(alphaFillVal >= 0){
      alphaFillVal -= 1;
      
      println(alphaFillVal);
    }
    
    if(initDefaultFill >= 0){
     initDefaultFill -= 1;
    }
  }
    
  void updateVerticalChangeAmplitude(int a, int vc){
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

// Other decent equations
// ===================
// float animationPulse = diameter + 2*sin(angle/2) - sin(1+angle);
// float animationPulse = diameter + 2*sin((angle/2)/2) - sin(1+angle/x);
// float animationPulse = diameter + 2*sin(angle/2) - (sin(1+angle)/2);