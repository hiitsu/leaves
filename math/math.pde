import processing.opengl.*;

ArrayList balls;
int W = 128;
int M = 10;
float DEACCELERATION = 0.5;
int distanceThreshold = 100;
ArrayList images;

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
  frameRate(50);
  smooth();
  //noStroke();
  balls = new ArrayList(M);
  for(int i=0; i < M;i++)
    balls.add(new Ball(random(0,width),random(0,height),0,(PImage)images.get(int(random(0,images.size())))));

}

void draw() {
  background(255);

  for (int i = balls.size()-1; i >= 0; i--) { 
    Ball ball = (Ball) balls.get(i);
    float distance = dist(ball.x,ball.y, mouseX, mouseY),
      dx = ball.x-mouseX,
      dy = ball.y-mouseY;
    if( distance < distanceThreshold ) {
      ball.sx += dx/100;
      ball.sy += dy/100;
    }
    ball.move();
    ball.display(this);
  }
  strokeWeight(2.0);
  fill(255,0,0);
  ellipse(mouseX,mouseY,20,20);
}

void mousePressed() {
  // A new ball object is added to the ArrayList (by default to the end)
//  balls.add(new Ball(mouseX, mouseY, W));
}

