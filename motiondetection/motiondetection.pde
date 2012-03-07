import processing.net.*;
import processing.video.*;
import s373.flob.*;

Server server;
Capture cam;
Flob flob;
ArrayList blobs; 
int videotex = 2; //case 0: videotex = videoimg;//case 1: videotex = videotexbin; 
//case 2: videotex = videotexmotion//case 3: videotex = videoteximgmotion; 
int fade = 25;
int threshold = 55;
int minimumArea = 16*16,
    maximumArea = 320*240; // quarter screen blob is still valid

float updateIntervalMillis = 100;
float lastUpdateMillis = 0,currentMillis = 0;
float cx,cy,ox,oy;
int leftLimit = 0, rightLimit = 640;

void setup() {
//  if( enableServer ) {    server = new Server(this,12345);  }
  println(Capture.list());
  size(640,480);
  rightLimit = width;
  int FPS = 60;
  cam = new Capture(this,160,120, FPS);

  // setup the detection parameters
  flob = new Flob(160,120, width, height);
  flob.setSrcImage(videotex);
  flob.setBackground(cam);
  flob.setBlur(0);
  flob.setOm(1);
  flob.setFade(fade);
  flob.setMirror(false,false);

  lastUpdateMillis = millis();
  currentMillis = millis();
}

void draw() {
  if (cam.available() == true) {
    flob.setThresh(threshold);
    cam.read();
    blobs = flob.calc(flob.binarize(cam));
  
    currentMillis = millis();
    background(0);
    image(flob.getSrcImage(),0,0,width,height); // absolute difference image
    
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
    
    image(cam,0,140,160,120);

    strokeWeight(3);
    fill(0,255,0,122);
    stroke(0,255,0,122);
    float l = map(leftLimit,0,width,0,160);
    line(l,140,l,260);
    line(leftLimit,0,leftLimit,height);
    text("leftLimit",leftLimit,height/2+20);
    stroke(0,111,255,172);
    fill(0,111,255,172);
    line(rightLimit,0,rightLimit,height);
    float r = map(rightLimit,0,width,0,160);
    line(r,140,r,260);
    text("rightLimit",rightLimit,height/2+40);
  
    fill(255,0,0,122);
    stroke(255,0,0,122);
    strokeWeight(8);
    textAlign(CENTER);
    line(cx,0,cx,height);
    text("poster",cx,height/2);
      
    strokeWeight(1);
    rectMode(CORNER);
    noFill();
    textAlign(LEFT);
    drawThreshold(0,0);
    drawMinArea(0,20);
    drawMaxArea(0,40);
    drawUpdateIntervalMillis(0,60);
  }

}

void mousePressed() {
    if(mouseY > 0 && mouseY < 20) {
        threshold = mouseX;
    }
    if(mouseY > 20 && mouseY < 40) {
        minimumArea = mouseX*40;
    }
    if(mouseY > 40 && mouseY < 60) {
        maximumArea = mouseX*480;
    }
    if( mouseY > 60 && mouseY < 80) {
        updateIntervalMillis = mouseX;
    }
    if( mouseY > 140 ) {
        if( mouseButton == LEFT ) {
          if( mouseX < rightLimit )
            leftLimit = mouseX;
        }
        else if( mouseButton == RIGHT ) {
          if( mouseX > leftLimit )
            rightLimit = mouseX;
        }
    }
}


void drawThreshold(int x,int y) {
  pushMatrix();
  translate(x,y);
  fill(0,123,155,122);
  rect(0,0,threshold,20);
  fill(255,0,0);
  text("Luminance Threshold: "+threshold,0,10);
  popMatrix();
}
void drawMinArea(int x,int y) {
  pushMatrix();
  translate(x,y);
  fill(0,123,0,122);
  rect(0,0,minimumArea/40,20);
  fill(255,0,255);
  text("Minimum Area (px): "+minimumArea+", sqrt (px): "+int(sqrt(minimumArea)),0,10);
  popMatrix();
}
void drawMaxArea(int x,int y) {
  pushMatrix();
  translate(x,y);
  fill(0,123,155,122);
  rect(0,0,maximumArea/480,20);
  fill(255,0,0);
  text("Maximum Area (px): "+maximumArea+", sqrt (px): "+int(sqrt(maximumArea)),0,10);
  popMatrix();
}
void drawUpdateIntervalMillis(int x,int y) {
  pushMatrix();
  translate(x,y);
  fill(0,123,0,122);
  rect(0,0,updateIntervalMillis,20);
  fill(255,0,255);
  text("Update Client Interval (ms): "+updateIntervalMillis,0,10);
  popMatrix();
}


