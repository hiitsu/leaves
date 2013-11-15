import processing.net.*;
import controlP5.*;
import processing.net.*;
import processing.video.*;
import s373.flob.*;

Server server;
ControlP5 controlP5;
Capture video;    // processing video capture
Flob flob;        // flob tracker instance
PImage videoinput;// a downgraded image to flob as input
int tresh = 10;   // adjust treshold value here or keys t/T
int fade = 55;
int om = 1;
int videores=128;//64//256
String info="";
PFont font;
float fps = 60;
int videotex = 3;
    
Slider2D leftTop,bottomRight;
float updateIntervalMillis = 20;
float lastUpdateMillis = -1;
ArrayList previousPositions; 
ArrayList validIndices;

void setup() {

  /*String[] cameras = Capture.list();
  
  if (cameras.length == 0)
  {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  }*/
  size(500,600);

  server = new Server(this, 12345);
  frameRate(fps);
  video = new Capture(this, 320, 240, 30); 
  video.start();
  videoinput = createImage(videores, videores, RGB);
  flob = new Flob(this, videoinput);
  flob.setOm(0); //flob.setOm(flob.STATIC_DIFFERENCE);
  flob.setOm(1); //flob.setOm(flob.CONTINUOUS_DIFFERENCE);
  flob.setThresh(tresh).setSrcImage(videotex).setBackground(videoinput)
  .setBlur(0).setOm(1).setFade(fade).setMirror(false,false);
  
  controlP5 = new ControlP5(this);
  
  // controls on the left side
  controlP5.addSlider("updateIntervalMillis",5,1000,updateIntervalMillis,20,60,30,80);
  controlP5.addSlider("edgeThreshold",1,200,tresh,20,360,30,80);
  controlP5.addSlider("fade",5,200,fade,20,460,30,80);

  // controls on the right side
  bottomRight = controlP5.addSlider2D("bottomRight",160,320,120,240,width-10,height-10,width-90,210,80,80);
  leftTop = controlP5.addSlider2D("leftTop",0,160,0,120,10,10,width-90,110,80,80);

  previousPositions = new ArrayList();
  textFont(createFont("monaco",18));
  println("video w,h is "+video.width + ","+video.height);
  validIndices = new ArrayList();
  
  try {
    controlP5.loadProperties();
  } catch(Exception e){
    println("no saved values file found");
  }
}

void draw() {
  if(video.available()) {
     video.read();
     videoinput.copy(video,0,0,320,240,0,0,videores,videores);
     flob.calc(flob.binarize(videoinput));
  }
    float currentMillis = millis();
    background(0);
    image(flob.getImage(),80,290,320,240); // absolute difference image
    image(video,80,10,320,240);
    
    // go through blobs to validate them that they are proper size and on correct area
    pushMatrix();
    translate(80,10);
    rectMode(CENTER);
    
    validIndices.clear();
  for(int i = 0; i < flob.getNumBlobs(); i++) {
        ABlob blob = (ABlob)flob.getABlob(i); 
        float bx = map(blob.cx,0,500,0,320);
        float by = map(blob.cy,0,600,0,240);
        float dimx = blob.dimx*(320.0/500.0);
        float dimy = blob.dimy*(240.0/600.0);
        fill(0,0,255,64);
        stroke(0,0,255);
        rect(bx,by,dimx,dimy);
        fill(0,255,0);
        String info = int(bx)+","+int(by);
        text(info,bx,by+20);
        float leftLimit       = leftTop.getArrayValue()[0];
        float topLimit        = leftTop.getArrayValue()[1];
        float rightLimit      = bottomRight.getArrayValue()[0];
        float bottomLimit     = bottomRight.getArrayValue()[1];
        if( bx >= leftLimit && bx <= rightLimit &&
            by >= topLimit && by <= bottomLimit ) {
            validIndices.add(i);
        } else {
            fill(255,0,0);
            text("out of tracking area",bx+10,by);
        }
    } // end validations
    popMatrix();
    
    pushMatrix();
    translate(80,290);
    ArrayList currentPositions = new ArrayList();
    float elapsed = currentMillis - lastUpdateMillis;
    if( validIndices.size()> 0 ) { // some blobs passed validations?
       if( elapsed > updateIntervalMillis ) { // and enough time between the updates
         for(int i = validIndices.size()-1; i >=0; i--){
             int index = (Integer)validIndices.get(i);
             ABlob b = (ABlob) (ABlob)flob.getABlob(index);
             float bx = map(b.cx,0,500,0,320);
             float by = map(b.cy,0,600,0,240);
             float dimx = b.dimx*(320.0/500.0);
             float dimy = b.dimy*(240.0/600.0);
             fill(0,0,255,64);
             stroke(0,0,255);
             rect(bx,by,dimx,dimy);
             fill(0,255,0);
              // match to previous positions
             currentPositions.add(new float[] { bx,by});
             for(int j = previousPositions.size()-1; j >= 0; j--) {
                  float[] coordinates = (float[])previousPositions.get(j);
                  // distance with pythagoras
                  float ox = coordinates[0];
                  float oy = coordinates[1];
                  float d = sqrt( pow(ox-bx,2) + pow(oy-by,2) );
                  if( d < 20 && d > 1.0 ) {
                      sendVector(ox,oy,bx,by);
                  }
             }
         }
         previousPositions = currentPositions;
         lastUpdateMillis = millis();
      }
    }
    popMatrix();
    
    stroke(255,0,0); 
    rectMode(CORNER);
    float mappedLeft = leftTop.getArrayValue()[0];
    float mappedRight = bottomRight.getArrayValue()[0];
    float mappedTop = leftTop.getArrayValue()[1];
    float mappedBottom = bottomRight.getArrayValue()[1];
    line(80+mappedLeft,10,80+mappedLeft,240);
    line(80+mappedRight,10,80+mappedRight,240);
    line(80,10+mappedTop,400,10+mappedTop);
    line(80,10+mappedBottom,400,10+mappedBottom);
    
    // draw the frame for edged image
    noFill();
    rect(80,320-30,320,240);
    text("use 'S' to save and 'L' load settings",20,20);
    text("FPS:"+frameRate,20,40);
}

void keyPressed() {
  if( key == 's' || key == 'S' ) {
    controlP5.saveProperties();
  } else if( key == 'l' || key == 'L' ) {
    controlP5.loadProperties();
  }
}

void updateIntervalMillis(float v){
  updateIntervalMillis = v;
  println("updateIntervalMillis set to: "+v);
}
void edgeThreshold(int v){
  tresh = v;
  flob.setThresh(v);
  println("edgeThreshold set to: "+v);
}
void fade(int v){
  fade = v;
  println("fade set to: "+v);
  flob.setFade(fade);
}
void sendVector(float x1,float y1, float x2, float y2) {
   println("Sending vector:  "+x1+","+y1+","+x2+","+y2);
   server.write(byta(map(x1,0,320,0,1024)));
   server.write(byta(map(y1,0,240,0,768)));
   server.write(byta(map(x2,0,320,0,1024)));
   server.write(byta(map(y2,0,240,0,768)));
   server.write(new byte[]{13,13,13});
}

byte[] byta(float v){
  int i = Float.floatToRawIntBits(v);
    return new byte[] {
        (byte)((i >> 24) & 0xff),
        (byte)((i >> 16) & 0xff),
        (byte)((i >> 8) & 0xff),
        (byte)((i >> 0) & 0xff),
    };
}

/*
void leftTop(){
  println("leftTop set to: ");
   if( leftTop != null )
    println(leftTop.getArrayValue());
}

void bottomRight(){
  println("bottomRight set to: ");
   if( bottomRight != null )
    println(bottomRight.getArrayValue());
}*/

