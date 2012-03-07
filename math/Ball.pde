// Simple bouncing ball class

class Ball {
  
  float x,y,z;
  float sx = 0,sy = 0, sz = 0;
  float w;
  float life = 255;
  String imageFile;
  
  Ball(float tempX, float tempY, float tempW) {
    x = tempX;
    y = tempY;
    w = tempW;
  }
  
    void move() {
      x += sx;
      y += sy;
      z = sx*5+sy*5;
      if( sx != 0 ){
        if( sx > 0 ){
            sx -= DEACCELERATION;
        }
        if( sx < 0 ){
            sx += DEACCELERATION;
        }
      }
      if( sy != 0 ){
        if( sy > 0 ){
            sy -= DEACCELERATION;
        }
        if( sy < 0 ){
            sy += DEACCELERATION;
        }
      }       
  }
  
  boolean finished() {
      return false;
  }
  
  void display() {
    // Display the circle
    fill(0,life);
    //stroke(0,life);
    rect(x,y,w+z,w+z);
    //shape(iamgeDAte,)
  }
}  
