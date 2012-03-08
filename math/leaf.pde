// Simple bouncing ball class

class Leaf {
	PImage img;
	PVector velocity ,location, acceleration;
	float angle,spin;
	float TOPSPEED = 10.0;

	Leaf(float x, float y, float z,PImage img) {
		this.location = new PVector(x,y,z);
		this.velocity  = new PVector(0,0,0);
		this.acceleration  = new PVector(0.5,0.5,0.0);
		this.angle = 0;
		this.spin = 0.01;
		this.img = img;
	}

	void move() {
		velocity.limit(TOPSPEED);
		location.add(velocity);
		if( velocity.x > 0 )
			velocity.x -= acceleration.x;
		if( velocity.x < 0 )
			velocity.x += acceleration.x;
		if( velocity.y > 0 )
			velocity.y -= acceleration.y;
		if( velocity.y < 0 )
			velocity.y += acceleration.y;
		if( abs(velocity.mag()) < 0.01 )
			velocity = new PVector(0,0,0);
		angle += spin;
		println(velocity);
	}

	boolean finished() {
		false;
	}

	void display(PApplet view) {
		view.textureMode(NORMALIZED);
		view.pushMatrix();
		view.translate(location.x,location.y,location.z);
		view.rotate(angle);
		view.noStroke();
		view.beginShape(PConstants.QUADS);
		view.texture(img);
		int w = img.width/4,
			h = img.height/4;
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
