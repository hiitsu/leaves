// Simple bouncing ball class

class Leaf {
	PImage img;
	PVector velocity ,location, acceleration;
	float angle,spinSpeed;
        int sizeFactor;
        float[][] fluctuations = new float[4][3]; // four corners, phase, shift speed, and z-range

	Leaf(float x, float y, float z,PImage img) {
		this.location = new PVector(x,y,z);
		this.velocity  = new PVector(0,0,0);
		this.acceleration  = new PVector(0.5,0.5,0.0);
                this.sizeFactor = (int)random(1+(int)leafSize/2,leafSize*2);
		this.angle = 0;
		this.spinSpeed = 0.01;
		this.img = img;
                randomizeFluctuation();
	}
        
        void randomizeFluctuation(){
          for(int i=0; i <4; i++){
            fluctuations[i][0] = random(0,PI/2);
            fluctuations[i][1] = random(0.01,0.20);
            fluctuations[i][2] = random(5,20);
          }
        }
        void increaseFluctuation(float factor){
           for(int i=0; i <4; i++) {
              float v = fluctuations[i][2];
              v += factor;
              if( v > 10 ) v = 10;
              fluctuations[i][2] = v;
           }
        }
        void reduceFluctuation(){
           for(int i=0; i <4; i++) {
              float v = fluctuations[i][2];
              if( v > 0 ) v -= 0.1;
              fluctuations[i][2] = v;
           }
        }        
	void update() {
		velocity.limit(topVelocity);
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
		if( abs(velocity.x*velocity.y)*1000 < 200 )
			velocity = new PVector(0,0,0);
                
                reduceFluctuation();
                
                // change phase by adding shift increment
                for(int i=0; i <4; i++)
                  fluctuations[i][0] += fluctuations[i][1];

                // dont spin too fast
                if( abs(spinSpeed) > topSpinSpeed ) {
                  if( spinSpeed < 0 )  
                    spinSpeed = -1*topSpinSpeed;
                  else
                    spinSpeed = topSpinSpeed;
                }

		angle += spinSpeed;
                
                // default spin deacceleration
                if( spinSpeed > 0 ) spinSpeed -= 0.01;
                if( spinSpeed < 0 ) spinSpeed += 0.01;
                
                // stop spinning if very small number
                if( abs(spinSpeed)*1000 < 10 ) spinSpeed = 0;
	}

	void display() {
                textureMode(NORMALIZED);
		pushMatrix();
		translate(location.x,location.y,location.z);
		rotate(angle);
		noStroke();
		beginShape(PConstants.QUADS);
		texture(img);
		int w = img.width/sizeFactor,
			h = img.height/sizeFactor;
		vertex(-w/2,-h/2,map(sin(fluctuations[0][0]),-1,1,-fluctuations[0][2],fluctuations[0][2]),0,0);
		vertex(w/2,-h/2,map(sin(fluctuations[1][0]),-1,1,-fluctuations[1][2],fluctuations[1][2]),w,0);
		vertex(w/2,h/2,map(sin(fluctuations[2][0]),-1,1,-fluctuations[2][2],fluctuations[2][2]),w,h);
		vertex(-w/2,h/2,map(sin(fluctuations[3][0]),-1,1,-fluctuations[3][2],fluctuations[3][2]),0,h);
		endShape();
/*
                if( debug ) {
  		  fill(255,0,0);
  		  sphere(2);
                  text("angle:"+nf(angle,2,1),20,0,10);
                  text("spin:"+nf(spinSpeed,1,5),20,40,10);
                  text("velocity:"+velocity,20,60,10);
                }
*/              popMatrix();
		noTint();
	}
}  
