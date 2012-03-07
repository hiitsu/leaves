// Simple bouncing ball class

class Leaf {
  PImage img;
  float x,y,z,angle,spin;
  float sx = 0,sy = 0, sz = 0;
  float w;
  float life = 255;
  String imageFile;
  
  Leaf(float x, float y, float z,PImage img) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.angle = 0;
    this.spin = 0.5;
    this.img = img;
  }
  
    void move() {
      x += sx;
      y += sy;
      z = sx*5+sy*5;
      angle += spin;
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
      if( spin != 0 ){
        if( spin > 0 ){
            spin -= 0.01;
        }
      }      
  }
  
  boolean finished() {
      return false;
  }
  
  void display(PApplet view) {
                view.textureMode(NORMALIZED);
		view.pushMatrix();
		view.translate(x,y,z);
		view.rotate(angle);
		view.noStroke();
                view.beginShape(PConstants.QUADS);
		view.texture(img);
		int w = img.width/2,
			h = img.height/2;
		view.vertex(-w/2,-h/2,0,0,0);
		view.vertex(w/2,-h/2,0,w,0);
		view.vertex(w/2,h/2,0,w,h);
		view.vertex(-w/2,h/2,0,0,h);
		view.endShape();
             view.fill(255,0,0);
              view.sphere(2);
		view.popMatrix();
		view.noTint();

  }
}  