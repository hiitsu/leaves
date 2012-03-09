import processing.net.*;
import controlP5.*;
import processing.opengl.*;

int leafCount = 100,leafSize = 5;
float distanceThreshold = 100,     // maximum distance when movement vector is applied to leaves
      movementThreshold = 20,      // distance blob has to move before it movement vector gets applied to leaves
      updateInterval = 25,         // how often leaves should be update
      lastUpdateMillis = millis(), // timing helper variable
      windWaitMillis = 2000,        // waiting period before wind kicks in
      topVelocity = 10,            // leaf max XY speed
      topSpinSpeed = 0.2,           // leaf max rotation speed
      backgroundZ = -50;           // background image place in z-axis
PVector gravity = new PVector(0,0,4);                // how fast the leaves come down
     
float lastMouseX = -1,
      lastMouseY = -1;
ArrayList images; // of PImages- objects
ArrayList leaves; // of Leaf- objects
ControlP5 controlP5;
PImage backgroundImage,overlayImage;
Client client;

boolean debug = true, wind = true;
float windGenerator = 0.0;
float movementAngle,
      forceAngle,
      normalizedForceAngle;

void setup() {
	size(1024, 768,OPENGL);
	frameRate(30);
	hint(DISABLE_DEPTH_TEST);
        backgroundImage = loadImage("/../../resources/background.jpg");
        overlayImage = loadImage("/../../resources/overlay.png");
	// call this before setLeaves
	loadImages(10);

	controlP5 = new ControlP5(this);
	controlP5.setAutoInitialization(true);

	// controls on the left side
	controlP5.addSlider("distanceThreshold",50,200,distanceThreshold,20,60,30,80);
	controlP5.addSlider("movementThreshold",1,100,movementThreshold,20,160,30,80);
	controlP5.addSlider("updateInterval",5,100,updateInterval,20,260,30,80);
	controlP5.addSlider("topSpinSpeed",0.001,1.0,topSpinSpeed,20,360,30,80);
	controlP5.addSlider("topVelocity",5,50,topVelocity,20,460,30,80);

	// controls on the right side
	controlP5.addToggle("network",false,width-50,10,30,30);
	controlP5.addToggle("wind",wind,width-50,60,30,30);
	controlP5.addSlider("leafCount",1,500,leafCount,width-50,110,30,80);
	controlP5.addSlider("leafSize",1,10,leafSize,width-50,210,30,80);

	setLeaves(leafCount);
}

void draw() {
        //pushMatrix();
        //camera(width/2,height/2,1000.0,width/2,height/2,0.0,0,1,0);
	background(0);
        textureMode(NORMALIZED);
        pushMatrix();
	translate(width/2,height/2,backgroundZ);
	beginShape(PConstants.QUADS);
	texture(backgroundImage);
	int w = backgroundImage.width,
		h = backgroundImage.height;
	vertex(-w/2,-h/2,0,0,0);
	vertex(w/2,-h/2,0,w,0);
	vertex(w/2,h/2,0,w,h);
	vertex(-w/2,h/2,0,0,h);
	endShape();
        popMatrix();
        
	float now = millis();

	// update data
	PVector movementVector = new PVector(lastMouseX-mouseX,lastMouseY-mouseY,0);
	float movementMagnitude = movementVector.mag();

        // enough time elapsed from last update and big enough movement happening?
	if( now - lastUpdateMillis > updateInterval && movementMagnitude > movementThreshold ) {
		lastUpdateMillis = now;
		lastMouseX = mouseX;
		lastMouseY = mouseY;
		movementAngle = atan2(movementVector.x,movementVector.y);

		for (int i = leaves.size()-1; i >= 0; i--) { 
			Leaf leaf = (Leaf) leaves.get(i);
			PVector vect = new PVector(leaf.location.x-mouseX,leaf.location.y-mouseY);
			float distance = dist(leaf.location.x,leaf.location.y, mouseX, mouseY),
				dx = (leaf.location.x-mouseX),
				dy = (leaf.location.y-mouseY);
			normalizedForceAngle = forceAngle = PVector.angleBetween(movementVector,vect);
			if( forceAngle > (PI/2) )
				normalizedForceAngle = (PI/2)-(forceAngle%(PI/2));
			
			// determine the rotation direction
			float rotationDirection = 1;
			if( leaf.location.x < mouseX && leaf.location.y < mouseY && movementAngle < 0 && movementAngle > -90 )
				rotationDirection = -1;
			else if( leaf.location.x < mouseX && leaf.location.y > mouseY && movementAngle > 0 && movementAngle < 90 )
				rotationDirection = -1;
			else if( leaf.location.x > mouseX && leaf.location.y > mouseY && movementAngle > 90 && movementAngle < 180 )
				rotationDirection = -1;
			else if( leaf.location.x > mouseX && leaf.location.y < mouseY && movementAngle > -180 && movementAngle < -90 )
				rotationDirection = -1;
				
			// apply more rotation when closer to 90degree angle
			float rotationFactor = map(abs(degrees(normalizedForceAngle)),0,90,0,1);
			float zFactor = map(90-abs(degrees(normalizedForceAngle)),0,90,0,25);
			if( distance < distanceThreshold ) {
					float distanceFactor = map(distance,0,distanceThreshold,1,2);
					leaf.velocity.x += (dx/30.0)*distanceFactor;
					leaf.velocity.y += (dy/30.0)*distanceFactor;
					leaf.spinSpeed += (rotationFactor/6)*rotationDirection;
					leaf.location.z += zFactor*distanceFactor;
					leaf.increaseFluctuation(distanceFactor*5);
			}
		}
	}
        else if( wind && now - lastUpdateMillis > windWaitMillis ) {
              windGenerator += 0.0001;
              for (int i = leaves.size()-1; i >= 0; i--) {
                  Leaf leaf = (Leaf)leaves.get(i);
                  float forceRandomizer = random(0.01,0.1);
                  float lx = leaf.location.x;
                  float ly = leaf.location.y;
                  float dx = (width/2-lx);
                  float dy = (height/2-ly);
                  if( dx*dy > 20 ) {
                    PVector v = new PVector(dx,dy,0);
                    v.normalize();
                    v.mult((sin(windGenerator)+1)*forceRandomizer);
                    //v.z = random(0.1,1);
                    leaf.velocity.add(v);
                    //leaf.increaseFluctuation(forceRandomizer);
                  }
              }
        }

	// draw video frame, leaves, and mask
	for (int i = leaves.size()-1; i >= 0; i--) {
		((Leaf)leaves.get(i)).update();
		((Leaf)leaves.get(i)).display();
	}
      
	// draw mask
        textureMode(NORMALIZED);
        pushMatrix();
	translate(width/2,height/2,backgroundZ);
	beginShape(PConstants.QUADS);
	texture(overlayImage);
	int ww = overlayImage.width,
		hh = overlayImage.height;
	vertex(-ww/2,-hh/2,100,0,0);
	vertex(ww/2,-hh/2,100,ww,0);
	vertex(ww/2,hh/2,100,ww,hh);
	vertex(-ww/2,hh/2,100,0,hh);
	endShape();
        popMatrix();        
        
	// drawing debug stuff, depth sort not needed
	if( debug ) {
    	stroke(0,0,255);
    	strokeWeight(5.0);
        text("use 'S' to save and 'L' load settings, 'H' to show/hide controls",20,20);
    	fill(255,0,0);
    	line(lastMouseX,lastMouseY,0,mouseX,mouseY,0);
    	text("mouse Y:"+mouseY,50+mouseX,-40+mouseY);
    	text("movement angle:"+nf(degrees(movementAngle),1,2),50+mouseX,mouseY);
    	text("force angle:"+nf(degrees(forceAngle),1,2),50+mouseX,40+mouseY);
    	text("normalized force angle:"+nf(degrees(normalizedForceAngle),1,2),50+mouseX,80+mouseY);
    	strokeWeight(2.0);
    	fill(255,0,0);
    	ellipse(mouseX,mouseY,20,20);
        }
  //popMatrix();
}

void keyPressed() {
	if( key == 'h' || key == 'H' ) {
		if( controlP5.isVisible() ) {
			debug = false;
			controlP5.hide();
		} else {
			debug = true;
			controlP5.show();
		}
	} else if( key == 's' || key == 'S' ) {
		controlP5.saveProperties();
	} else if( key == 'l' || key == 'L' ) {
		controlP5.loadProperties();
	}
}
void mouseMoved(){}

void mousePressed() {}

void distanceThreshold(float v){
	distanceThreshold = v;
	println("distanceThreshold set to: "+v);
}

void movementThreshold(float v){
	movementThreshold = v;
	println("movementThreshold set to: "+v);
}
void updateInterval(float v){
	updateInterval = v;
	println("updateInterval set to: "+v);
}
void topSpinSpeed(float v){
	topSpinSpeed = v;
	println("topSpinSpeed set to: "+v);
}
void topVelocity(float v){
	topVelocity = v;
	println("topVelocity set to: "+v);
}
void leafCount(int v){
	leafCount = v;
	setLeaves(leafCount);
	println("leafCount set to: "+v);
}
void leafSize(int v){
	leafSize = v;
	setLeaves(leafCount);
	println("leafSize set to: "+v);
}
void wind(boolean flag){
	println("wind set to: "+flag);
        wind = flag;
}
void network(boolean flag){
	println("network set to: "+flag);
	if( flag ) {
		client = new Client(this, "127.0.0.1", 12345);
	} else {
		if( client == null )
			return;
		client.clear();
		client.stop();
		client = null;
	}
}
// read images files from disk into ArrayList<PImage> images
void loadImages(int maxImages) {
	// create list object if its not yet created
	if( images == null )
		images = new ArrayList();
	// otherwise clear it
	else
		images.clear();
	// read up to maxImages
	for(int c=1;c <maxImages;c++) {
		PImage img = loadImage("/../../resources/leaves/highres/leaves_"+nf(c,2)+".png");
		if( img == null )
			break;
		images.add(img);
	}
}

// create leaves, random location around center of the area, pick random image from preloaded images
synchronized void setLeaves(int count){
	if( leaves == null ) {
	        leaves = new ArrayList(count);
        }
	leaves.clear();
	while( leaves.size() < count ) {
                float x = random(0,width);
                float y = random(0,height);
		leaves.add(new Leaf(x,y,random(10,1000),random(5,20),(PImage)images.get(int(random(0,images.size())))));
    }
}

void clientEvent(Client c) {
  int data = client.read();
  println("Server Says:  "+data);
}
