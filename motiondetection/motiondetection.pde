import processing.net.*;
import controlP5.*;
import processing.net.*;
import processing.video.*;
import s373.flob.*;

ControlP5 controlP5;
Server server;
Capture cam;
Flob flob;
ArrayList blobs; 
int videotex = 2; //case 0: videotex = videoimg;//case 1: videotex = videotexbin; 
//case 2: videotex = videotexmotion//case 3: videotex = videoteximgmotion; 
int fade = 25;
int edgeThreshold = 55;
int minimumArea = 16*16,
    maximumArea = 320*240; // quarter screen blob is still valid
Slider2D leftTop,bottomRight;
float updateIntervalMillis = 100;
float lastUpdateMillis = -1;
float cx,cy,ox,oy;

ArrayList previousPositions; 
int MAX_TRACKED = 5;

void setup() {
  println(Capture.list());
  size(800,600);
  int FPS = 20;
  server = new Server(this, 12345);
  cam = new Capture(this,160,120, FPS);

  // setup the detection parameters
  flob = new Flob(160,120, width, height);
  flob.setSrcImage(videotex);
  flob.setBackground(cam);
  flob.setBlur(0);
  flob.setOm(1);
  flob.setFade(fade);
  flob.setMirror(false,false);

        controlP5 = new ControlP5(this);
	controlP5.setAutoInitialization(true);

	// controls on the left side
	controlP5.addSlider("updateIntervalMillis",20,300,updateIntervalMillis,20,60,30,80);
	controlP5.addSlider("minimumArea",10,300,minimumArea,20,160,30,80);
	controlP5.addSlider("maximumArea",20,1000,maximumArea,20,260,30,80);
	controlP5.addSlider("edgeThreshold",1,200,edgeThreshold,20,360,30,80);
	controlP5.addSlider("fade",5,200,fade,20,460,30,80);

	// controls on the right side
	leftTop = controlP5.addSlider2D("leftTop",0,width/2,0,height/2,10,10,width-90,110,80,80);
	bottomRight = controlP5.addSlider2D("bottomRight",width/2,width,height/2,height,width-10,height-10,width-90,210,80,80);

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
    ArrayList validIndices = new ArrayList();
    for( int i=0; i<blobs.size(); i++ ) {
        ABlob blob = (ABlob)blobs.get(i);
        
        // area validations
        float area = blob.dimx * blob.dimy;
        if( area < minimumArea || area > maximumArea ) {
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
        if( leftPosition >= leftLimit && rightLimit <= rightLimit &&
            topPosition >= topLimit && bottomPosition <= bottomLimit ) {
            validIndices.add(i);
            // ok we are tracking this blob, so draw a box around it
            fill(0,255,255,100);
            stroke(0,255,0,64);
            rectMode(CENTER);
            rect(blob.cx,blob.cy,blob.dimx,blob.dimy);
            rectMode(CORNER);
         }
    } // end validations
    
    float elapsed = currentMillis - lastUpdateMillis;
    if( validIndices.size()> 0 ) { // some blobs passed validations?
       if( elapsed > updateIntervalMillis ) { // and enough time between the updates
         for(int i = validIndices.size()-1; i >=0; i--){
             int index = (Integer)validIndices.get(i);
             ABlob b = (ABlob) blobs.get(index);
             float cx = b.cx;
             float cy = b.cy;
              // match to previous positions
             for(int j = previousPositions.size()-1; j >= 0; j--) {
                  float[] coordinates = (float[])previousPositions.get(j);
                  // distance with pythagoras
                  float d = sqrt( pow(coordinates[0]-cx,2) + pow(coordinates[1]-cy,2));
             }
         }
         lastUpdateMillis = millis();
      }
    }
    
    image(cam,80,10,320,240);
     text("use 'S' to save and 'L' load settings",20,20);
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
void keyPressed() {
       if( key == 's' || key == 'S' ) {
		controlP5.saveProperties();
	} else if( key == 'l' || key == 'L' ) {
		controlP5.loadProperties();
	}
}

/*
void leftTop(){
    if( leftTop != null )
	println("leftTop set to: "+Arrays.toString(leftTop.getArrayValue()));
}
*/
