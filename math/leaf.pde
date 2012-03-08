// Simple bouncing ball class

class Leaf {
	PImage img;
	PVector velocity ,location, acceleration,gravity;
	float angle,spin;
	float TOPSPEED = 10.0;

	Leaf(float x, float y, float z,PImage img) {
		this.location = new PVector(x,y,z);
		this.velocity  = new PVector(0,0,0);
		this.acceleration  = new PVector(0.5,0.5,0.0);
                this.gravity  = new PVector(0.0,0.0,0.5);
		this.angle = 0;
		this.spin = 0.01;
		this.img = img;
	}

	void move() {
		velocity.limit(TOPSPEED);
		location.add(velocity);
                if( location.z > 0 )
                   location.sub(gravity);
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

                // default spin deacceleration
                if( spin > 0 ) spin -= 0.01;
                if( spin < 0 ) spin += 0.01;
                
                // stop spinning if very small number
                if( abs(spin)*1000 < 10 ) spin = 0;
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
                view.text("angle:"+nf(angle,2,1),20,0,10);
                view.text("spin:"+nf(spin,1,5),20,40,10);
                view.popMatrix();
		view.noTint();
	}
}  
