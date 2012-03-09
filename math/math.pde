import processing.net.*;
import controlP5.*;
import processing.opengl.*;

int leafCount = 100;
float distanceThreshold = 100,     // maximum distance when movement vector is applied to leaves
      movementThreshold = 20,      // distance blob has to move before it movement vector gets applied to leaves
      updateInterval = 25,         // how often leaves should be update
      lastUpdateMillis = millis(), // timing helper variable
      topVelocity = 10,            // leaf max XY speed
      topSpinSpeed = 0.2;           // leaf max rotation speed
 
PVector gravity = new PVector(0,0,4);                // how fast the leaves come down
     
float lastMouseX = -1,
      lastMouseY = -1;
ArrayList images; // of PImages- objects
ArrayList leaves; // of Leaf- objects
ControlP5 controlP5;

Client client;

boolean debug = true;
float movementAngle,
      forceAngle,
      normalizedForceAngle;

void setup() {
	size(1024, 768,OPENGL);
	frameRate(30);
	hint(DISABLE_DEPTH_TEST);

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
	controlP5.addSlider("leafCount",1,500,leafCount,width-50,60,30,80);

	setLeaves(leafCount);
}

void draw() {
	background(111);
	float now = millis();

	// update data
	PVector movementVector = new PVector(lastMouseX-mouseX,lastMouseY-mouseY,0);
	float movementMagnitude = movementVector.mag();
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
				
			// closer the angle is to 90 apply more rotation
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

	// draw video frame, leaves, and mask
	for (int i = leaves.size()-1; i >= 0; i--) {
		((Leaf)leaves.get(i)).update();
		((Leaf)leaves.get(i)).display();
	}
      
	// draw mask
        
        
	// drawing debug stuff, depth sort not needed
	if( !debug )
		return;
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
	if( leaves == null )
		leaves = new ArrayList(count);
	while( leaves.size() > 0 && leaves.size() > count )
		leaves.remove(0);
	while( leaves.size() < count ) 
		leaves.add(new Leaf(
			random(width/4,3*width/4),
			random(height/4,3*height/4),
			0.0,
			(PImage)images.get(int(random(0,images.size())))
		));
}

void clientEvent(Client c) {
  int data = client.read();
  println("Server Says:  "+data);
}
