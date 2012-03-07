import processing.opengl.*;

int W = 128;
int M = 20;
float DEACCELERATION = 0.5;
int distanceThreshold = 100;
ArrayList images;
ArrayList leaves;

void setup() {
  size(800, 600,OPENGL);
  hint(DISABLE_DEPTH_TEST);
//  hint(ENABLE_DEPTH_SORT);
  images = new ArrayList();
  for(int c=1;c<50;c++) {
    PImage img = loadImage("/../../resources/leaves/highres/leaves_"+nf(c,2)+".png");
    if( img != null )
      images.add(img);
    else
      break;
  }
  frameRate(30);
  smooth();
  //noStroke();
  leaves = new ArrayList(M);
  for(int i=0; i < M;i++)
    leaves.add(new Leaf(random(0,width),random(0,height),0.0,(PImage)images.get(int(random(0,images.size())))));

}

void draw() {
  background(255);

  for (int i = leaves.size()-1; i >= 0; i--) { 
    Leaf leaf = (Leaf) leaves.get(i);
    float distance = dist(leaf.x,leaf.y, mouseX, mouseY),
      dx = leaf.x-mouseX,
      dy = leaf.y-mouseY;
    if( distance < distanceThreshold ) {
      leaf.sx += dx/100;
      leaf.sy += dy/100;
    }
    leaf.move();
    leaf.display(this);
  }
  strokeWeight(2.0);
  fill(255,0,0);
  ellipse(mouseX,mouseY,20,20);
}

void mousePressed() {

}

