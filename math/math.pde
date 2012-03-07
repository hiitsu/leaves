import processing.opengl.*;

int W = 128;
int M = 10;
float DEACCELERATION = 0.5;
int distanceThreshold = 100;
float updateIntervalMillis = 100, lastUpdateMillis = millis();
ArrayList images; // of PImages
Leaf[] leaves = new Leaf[M];

void setup() {
  size(800, 600,OPENGL);
  hint(DISABLE_DEPTH_TEST);
//  hint(ENABLE_DEPTH_SORT);
  images = new ArrayList();
  for(int c=1;;c++) {
    PImage img = loadImage("/../../resources/leaves/highres/leaves_"+nf(c,2)+".png");
    if( img != null )
      images.add(img);
    else
      break;
  }
  frameRate(30);
  smooth();
  //noStroke();
  for(int i=0; i < M;i++)
    leaves[i] = new Leaf(random(0,width),random(0,height),0.0,(PImage)images.get(int(random(0,images.size()))));

}

void draw() {
  background(255);
  float now = millis();
  if( now - lastUpdateMillis > updateIntervalMillis ) {
    lastUpdateMillis = now;
  }
  for (int i = leaves.length-1; i >= 0; i--) { 
    Leaf leaf = (Leaf) leaves[i];
    float distance = dist(leaf.location.x,leaf.location.y, mouseX, mouseY),
      dx = leaf.location.x-mouseX,
      dy = leaf.location.y-mouseY;
    if( distance < distanceThreshold ) {
      leaf.velocity.x += dx/100;
      leaf.velocity.y += dy/100;
    }
    leaf.move();
    leaf.display(this);
  }
  strokeWeight(2.0);
  fill(255,0,0);
  ellipse(mouseX,mouseY,20,20);
}

void mouseMoved(){
  
}

void mousePressed() {

}

