import processing.io.*;
import eDMX.*;

sACNSource source;
sACNUniverse universe1;
sACNUniverse universe2;
int count = 0;

I2C i2c;
int val = 0;

int beat4;
int beat5;

void setup() {
  i2c = new I2C(I2C.list()[0]);
  source = new sACNSource(this, "Test Source");
  universe1 = new sACNUniverse(source, (short)15);
}

void draw () {
  beat4 = getBeat(4);
  beat5 = getBeat(5);
  //
  
  sendDMX();
  

  delay(200);
}

void sendDMX(){
  
  universe1.fillSlots(byte(beat4));

  try {
    universe1.sendData();
  } catch (Exception e) {
    e.printStackTrace();
  }
}

int getBeat(int address) {
  int newbeat = 0;
  if (I2C.list() != null)
  {
    i2c.beginTransmission(address);
    i2c.write(address);

    try
    {
      byte[] in = i2c.read(4);
      String beatString = new String(in);
      int beat = int(trim(beatString));
      
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