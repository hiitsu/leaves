// Simple bouncing ball class

class Leaf {
	PImage img;
	PVector velocity ,location, acceleration,gravity;
	float angle,spin,cornerFluctuation;
	float TOPSPEED = 10.0;

	Leaf(float x, float y, float z,PImage img) {
		this.location = new PVector(x,y,z);
		this.velocity  = new PVector(0,0,0);
		this.acceleration  = new PVector(0.5,0.5,0.0);
                this.gravity  = new PVector(0.0,0.0,4.0);
		this.angle = this.cornerFluctuation = 0;
		this.spin = 0.01;
		this.img = img;
	}

	void update() {
		velocity.limit(TOPSPEED);
		location.add(velocity);

                // if leaf in the air pull it down
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

                // stop movement if very small number
		if( abs(velocity.x*velocity.y)*1000 < 100 )
			velocity = new PVector(0,0,0);
                
                cornerFluctuation += 0.07;

		angle += spin;
                
                // default spin deacceleration
                if( spin > 0 ) spin -= 0.01;
                if( spin < 0 ) spin += 0.01;
                
                // stop spinning if very small number
                if( abs(spin)*1000 < 10 ) spin = 0;
	}

	void display() {
                textureMode(NORMALIZED);
		pushMatrix();
		translate(location.x,location.y,location.z);
		rotate(angle);
		noStroke();
		beginShape(PConstants.QUADS);
		texture(img);
		int w = img.width/4,
			h = img.height/4;
		vertex(-w/2,-h/2,map(sin(cornerFluctuation),-1,1,-10,10),0,0);
		vertex(w/2,-h/2,map(sin(cornerFluctuation+1.5),-1,1,-10,10),w,0);
		vertex(w/2,h/2,map(sin(cornerFluctuation+2.4),-1,1,-10,105),w,h);
		vertex(-w/2,h/2,map(sin(cornerFluctuation-1.5),-1,1,-10,10),0,h);
		endShape();
                if( debug ) {
  		  fill(255,0,0);
  		  sphere(2);
                  text("angle:"+nf(angle,2,1),20,0,10);
                  text("spin:"+nf(spin,1,5),20,40,10);
                  text("velocity:"+velocity,20,60,10);
                }
                popMatrix();
		noTint();
	}
}  
