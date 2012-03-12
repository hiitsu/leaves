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
int leftLimit = 0, rightLimit = 640, topLimit = 0, bottomLimit = 0;
float updateIntervalMillis = 100;
float lastUpdateMillis = 0,currentMillis = 0;
float cx,cy,ox,oy;


void setup() {
//  if( enableServer ) {    server = new Server(this,12345);  }
  println(Capture.list());
  size(800,600);
  rightLimit = width;
  topLimit = height;
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
	controlP5.addSlider2D("leftTop",0,width/2,0,height/2,10,10,width-90,110,80,80);
	controlP5.addSlider2D("bottomRight",width/2,width,height/2,height,width-10,height-10,width-90,210,80,80);
        
  lastUpdateMillis = millis();
  currentMillis = millis();
}

void draw() {
  if (cam.available() == true) {
    flob.setThresh(edgeThreshold);
    cam.read();
    blobs = flob.calc(flob.binarize(cam));
  
    currentMillis = millis();
    background(0);
    image(flob.getSrcImage(),80,320-30,320,240); // absolute difference image
    
    int tracked = -1;
    
    for( int i=0; i<blobs.size(); i++ ) {
        ABlob blob = (ABlob)blobs.get(i);
        float area = blob.dimx * blob.dimy;
        if( area < minimumArea || area > maximumArea )
           continue;
 
        float leftSide = blob.cx-blob.dimx/2;
        float rightSide = blob.cx+blob.dimx/2;
        
        if( tracked == -1 ) {
          if( leftSide <= cx && cx <= rightSide ) {
               tracked = i;
          } else if ( abs(leftSide-cx) < 100 ) {
              tracked = i;
          } else if ( abs(rightSide-cx) < 100 ) {
              tracked = i;
          }
        }

        //box
        fill(0,255,255,100);
        stroke(0,255,0,64);
        rectMode(CENTER);
        rect(blob.cx,blob.cy,blob.dimx,blob.dimy);
        rectMode(CORNER);
    }
    if( tracked == -1 && blobs.size() > 0 ) {
        tracked = 0;
    }
    
    float elapsed = currentMillis - lastUpdateMillis;
    if( tracked != -1 ) {
       if( elapsed > updateIntervalMillis ) { // and enough time between the updates
         ox = cx;
         oy = cy;
         cx = ((ABlob)blobs.get(tracked)).cx;
         cy = ((ABlob)blobs.get(tracked)).cy;
         lastUpdateMillis = millis();
         //String position = str(int(map(cx,leftLimit,rightLimit,start,end)));
         //println(currentMillis+",elapsed:"+elapsed+", x: " +cx+" mapped to "+position);
      }
    }
    
    image(cam,80,10,320,240);
 
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

