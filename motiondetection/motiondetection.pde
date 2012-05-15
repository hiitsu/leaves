import codeanticode.gsvideo.*;
import processing.net.*;
import controlP5.*;
import processing.net.*;
import processing.video.*;
import s373.flob.*;

ControlP5 controlP5;
Server server;
GSCapture cam;
Flob flob;
ArrayList blobs; 
int videotex = 3; //case 0: videotex = videoimg;//case 1: videotex = videotexbin; 
//case 2: videotex = videotexmotion//case 3: videotex = videoteximgmotion; 
int fade = 40;
int edgeThreshold = 40;
int minimumArea = 32,
    maximumArea = 160*120;
Slider2D leftTop,bottomRight;
float updateIntervalMillis = 20;
float lastUpdateMillis = -1;
float cx,cy,ox,oy;

ArrayList previousPositions; 
int MAX_TRACKED = 10;
int FPS = 25;

void setup() {

  String[] cameras = GSCapture.list();
  
  if (cameras.length == 0)
  {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new GSCapture(this, 160, 120, cameras[0]);
    cam.start();    

    
    // You can get the resolutions supported by the
    // capture device using the resolutions() method.
    // It must be called after creating the capture 
    // object. 
    int[][] res = cam.resolutions();
    for (int i = 0; i < res.length; i++) {
      println(res[i][0] + "x" + res[i][1]);
    } 
    
  
    
    // You can also get the framerates supported by the
    // capture device:
    String[] fps = cam.framerates();
    for (int i = 0; i < fps.length; i++) {
      println(fps[i]);
    } 
       
  }
  size(500,600);

  server = new Server(this, 12345);
  //cam = new Capture(this,160,120,FPS);
  frameRate(FPS);
  // setup the detection parameters
  flob = new Flob(cam, 160,120);
  flob.setSrcImage(videotex);
  //flob.setBackground(cam);
  flob.setBlur(0);
  flob.setOm(1);
  flob.setFade(fade);
  flob.setMirror(true,true);

        controlP5 = new ControlP5(this);
	controlP5.setAutoInitialization(true);

	// controls on the left side
	controlP5.addSlider("updateIntervalMillis",5,1000,updateIntervalMillis,20,60,30,80);
	controlP5.addSlider("minimumArea",4,300,minimumArea,20,160,30,80);
	controlP5.addSlider("maximumArea",10,19200,maximumArea,20,260,30,80);
	controlP5.addSlider("edgeThreshold",1,200,edgeThreshold,20,360,30,80);
	controlP5.addSlider("fade",5,200,fade,20,460,30,80);

	// controls on the right side
	leftTop = controlP5.addSlider2D("leftTop",0,160,0,120,10,10,width-90,110,80,80);
	bottomRight = controlP5.addSlider2D("bottomRight",160,320,120,240,width-10,height-10,width-90,210,80,80);

        previousPositions = new ArrayList();

}

void draw() {
  if (cam.available() == true) {
    flob.setThresh(edgeThreshold);
    cam.read();
    blobs = flob.calc(flob.binarize(cam));
  
    float currentMillis = millis();
    background(0);
    image(flob.getSrcImage(),80,320-30,320,240); // absolute difference image
    
    // go through blobs to validate them that they are proper size and on correct area
    pushMatrix();
    translate(80,290);
    ArrayList validIndices = new ArrayList();
    for( int i=0; i<blobs.size(); i++ ) {
        ABlob blob = (ABlob)blobs.get(i);
        
        // area validations
        float area = blob.dimx * blob.dimy;
        fill(0,255,0,64);
        stroke(0,255,0,64);
        rectMode(CENTER);
        rect(blob.cx,blob.cy,blob.dimx,blob.dimy);
        rectMode(CORNER);
        if( area < minimumArea || area > maximumArea ) {
           //println("area too big or small");
           continue;
        }

        // location validations 
        float leftPosition    = blob.cx-blob.dimx/2;
        float rightPosition   = blob.cx+blob.dimx/2;
        float topPosition     = blob.cy-blob.dimy/2;
        float bottomPosition  = blob.cy+blob.dimy/2;
        float leftLimit       = leftTop.getArrayValue()[0];
        float topLimit        = leftTop.getArrayValue()[1];
        float rightLimit      = bottomRight.getArrayValue()[0];
        float bottomLimit     = bottomRight.getArrayValue()[1];
        if( leftPosition >= leftLimit && rightPosition <= rightLimit &&
            topPosition >= topLimit && bottomPosition <= bottomLimit ) {
            
            validIndices.add(i);
            // ok we are tracking this blob, so draw a box around it
            //float mappedX = map(blob.cx,0,
            fill(0,0,255,64);
            stroke(0,0,255,64);
            rectMode(CENTER);            
            rect(blob.cx,blob.cy,blob.dimx,blob.dimy);
            
            rectMode(CORNER);
         }
    } // end validations
    popMatrix();
    
    ArrayList currentPositions = new ArrayList();
    float elapsed = currentMillis - lastUpdateMillis;
    if( validIndices.size()> 0 ) { // some blobs passed validations?
       if( elapsed > updateIntervalMillis ) { // and enough time between the updates
         for(int i = validIndices.size()-1; i >=0; i--){
             int index = (Integer)validIndices.get(i);
             ABlob b = (ABlob) blobs.get(index);
             float cx = b.cx;
             float cy = b.cy;
              // match to previous positions
             currentPositions.add(new float[] { cx,cy});
             for(int j = previousPositions.size()-1; j >= 0; j--) {
                  float[] coordinates = (float[])previousPositions.get(j);
                  // distance with pythagoras
                  float ox = coordinates[0];
                  float oy = coordinates[1];
                  float d = sqrt( pow(ox-cx,2) + pow(oy-cy,2) );
                  
                  if( d < 20 && d > 1.0 ) {
                      //println("sending coords:");
                      sendVector(ox,oy,cx,cy);
                      
                  }
             }
         }
         previousPositions = currentPositions;
         lastUpdateMillis = millis();
      }
    }
    
    image(cam,80,10,320,240);
    stroke(255,0,0);
    
    /* mapping limiter coordinates from window space to the 320x240 tile
    float mappedLeft = map(leftTop.getArrayValue()[0],0,width,0,320);
    float mappedRight = map(bottomRight.getArrayValue()[0],0,width,0,320);
    float mappedTop = map(leftTop.getArrayValue()[1],0,width,0,240);
    float mappedBottom = map(bottomRight.getArrayValue()[0],0,width,0,240);
    */
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
	edgeThreshold = v;
	println("edgeThreshold set to: "+v);
}
void minimumArea(int v){
	minimumArea = v;
	println("minimumArea set to: "+v);
}
void maximumArea(int v){
	maximumArea = v;
	println("maximumArea set to: "+v);
}
void fade(int v){
	fade = v;
	println("fade set to: "+v);
        flob.setFade(fade);
}
void sendVector(float x1,float y1, float x2, float y2) {
   server.write(byta(map(x1,0,160,0,1024)));
   server.write(byta(map(y1,0,120,0,768)));
   server.write(byta(map(x2,0,160,0,1024)));
   server.write(byta(map(y2,0,120,0,768)));
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
    if( leftTop != null )
	println("leftTop set to: "+Arrays.toString(leftTop.getArrayValue()));
}
*/


