import processing.opengl.*;
import processing.video.*;
import s373.flob.*;

Capture video;    // processing video capture
Flob flob;        // flob tracker instance
ArrayList blobs;  // an optional ArrayList to hold the gathered blobs
PImage videoinput;// a downgraded image to flob as input

int tresh = 10;   // adjust treshold value here or keys t/T
int fade = 55;
int om = 1;
int videores=128;//64//256
String info="";
PFont font;
float fps = 60;
int videotex = 3;

void setup() {
  size(700,500,OPENGL);
  frameRate(fps);
  video = new Capture(this, 320, 240, (int)fps); 
  video.start(); // if on processing 151, comment this line 
  videoinput = createImage(videores, videores, RGB);
  flob = new Flob(this, videoinput);
  flob.setOm(0); //flob.setOm(flob.STATIC_DIFFERENCE);
  flob.setOm(1); //flob.setOm(flob.CONTINUOUS_DIFFERENCE);
  flob.setThresh(tresh).setSrcImage(videotex).setBackground(videoinput)
  .setBlur(0).setOm(1).setFade(fade).setMirror(true,false);;
  font = createFont("monaco",16);
  textFont(font);
  blobs = new ArrayList();
}



void draw() {
  if(video.available()) {
     video.read();
     videoinput.copy(video,0,0,320,240,0,0,videores,videores);
     blobs = flob.calc(flob.binarize(videoinput));
  }
  background(0);
  image(flob.getImage(), 0, 0, width, height);
  rectMode(CENTER);
  for(int i = 0; i < flob.getNumBlobs(); i++) {
    ABlob ab = (ABlob)flob.getABlob(i); 
    fill(0,0,255,100);
    rect(ab.cx,ab.cy,ab.dimx,ab.dimy);
    fill(0,255,0,200);
    rect(ab.cx,ab.cy, 5, 5);
    info = ""+ab.id+" "+ab.cx+" "+ab.cy;
    text(info,ab.cx,ab.cy+20);
  }
  fill(255,152,255);
  rectMode(CORNER);
  rect(5,5,flob.getPresencef()*width,10);
  String stats = ""+frameRate+"\nflob.numblobs: "+flob.getNumBlobs()+"\nflob.thresh:"+tresh+
    " <t/T>"+"\nflob.fade:"+fade+"   <f/F>"+"\nflob.om:"+flob.getOm()+
    "\nflob.image:"+videotex+"\nflob.presence:"+flob.getPresencef();
  fill(0,255,0);
  text(stats,5,25);
}


