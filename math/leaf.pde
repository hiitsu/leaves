// Simple bouncing ball class

class Leaf {
  PImage img;
  PVector velocity ,location, deacceleration;
  float angle,spin;
  
  Leaf(float x, float y, float z,PImage img) {
    this.location = new PVector(x,y,z);
    this.velocity  = new PVector(0,0,0);
    this.deacceleration  = new PVector(0.1,0.1,0.0);
    this.angle = 0;
    this.spin = 0.01;
    this.img = img;
  }
  
    void move() {
      location.add(velocity);
      float magnitude = velocity.mag();
      if( magnitude > 0 )
        velocity.sub(deacceleration);
      else if( magnitude < 0 )
        velocity = new PVector(0,0,0);
      angle += spin;
  }
  
  boolean finished() {
      return false;
  }
  
  void display(PApplet view) {
                view.textureMode(NORMALIZED);
		view.pushMatrix();
		view.translate(location.x,location.y,location.z);
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
