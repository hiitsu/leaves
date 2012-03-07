ArrayList balls;
int W = 48;
int M = 50;
float DEACCELERATION = 0.5;
int distanceThreshold = 100;

void setup() {
  size(800, 800);
  frameRate(50);
  smooth();
  noStroke();
  balls = new ArrayList(M);
  for(int i=0; i < M;i++)
    balls.add(new Ball(random(0,500),random(0,500),W));

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
    ball.display();
    if (ball.finished()) {
      balls.remove(i);
    }
  }
  strokeWeight(20.0);
  stroke(0, 100);
  rect(mouseX,mouseY,20,20);
}

void mousePressed() {
  // A new ball object is added to the ArrayList (by default to the end)
  balls.add(new Ball(mouseX, mouseY, W));
}

