import processing.video.*;  // playing background
import java.nio.*;          // for the bytebuffer
import processing.net.*;    // getting vectors over the network
import controlP5.*;         // GUI control library
import processing.opengl.*; // draw utilizing opengl rendering engine

int leafCount = 1000,
    leafSize = 3,
    fps = 50;
float distanceThreshold = 100,     // maximum distance when movement vector is applied to leaves
      movementThreshold = 20,      // distance blob has to move before it movement vector gets applied to leaves
      updateInterval = 25,         // how often leaves should be update
      lastUpdateMillis = millis(), // timing helper variable
      topVelocity = 10,            // leaf max XY speed
      topSpinSpeed = 0.2,           // leaf max rotation speed
      backgroundZ = -50;           // background image place in z-axis
      
PVector gravity = new PVector(0,0,4);                // how fast the leaves come down
     
float lastMouseX = -1,
      lastMouseY = -1;
ArrayList forceCoordinates = new ArrayList(); // of float[]
ArrayList images; // of PImages- objects
ArrayList leaves; // of Leaf- objects
ControlP5 controlP5;
PImage overlayImage;
Movie backgroundMovie;
Client client;
boolean debug = true;

// profiling variables
float averageTime = 0;
int averageCounter = 0;
int averageResetInterval = 100;
boolean drawMovie = true, drawLeaves = true, drawOverlay = true;

void setup() {
	size(1024, 768,OPENGL);
	frameRate(fps);
	hint(DISABLE_DEPTH_TEST);
	overlayImage = loadImage("overlay.png");
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
	controlP5.addSlider("leafCount",1,1500,leafCount,width-50,110,30,80);
	controlP5.addSlider("leafSize",1,10,leafSize,width-50,210,30,80);
        controlP5.addToggle("drawMovie",drawMovie,width-50,310,30,30);
        controlP5.addToggle("drawLeaves",drawLeaves,width-50,360,30,30);
        controlP5.addToggle("drawOverlay",drawOverlay,width-50,410,30,30);

	setLeaves(leafCount);
        backgroundMovie = new Movie(this,"background.mov");
        backgroundMovie.frameRate(fps);
        backgroundMovie.loop();
}

void draw() {
        float now = millis();
        
	// draw video frame
        if( drawMovie ) 
              image(backgroundMovie,0,0,width,height);
        else 
           background(0); 
	// draw leaves
        if( drawLeaves ) {
        float elapsed = now - lastUpdateMillis;
	  if( elapsed > updateInterval ) { // enough time elapsed from last update ?
              lastUpdateMillis = now;
              float[] coordinates = inputCoordinates();
              if( coordinates != null ){
                //println("force coords:"+Arrays.toString(coordinates));
                applyForce(coordinates[0],coordinates[1],coordinates[2],coordinates[3]);
                forceCoordinates.add(coordinates);
              }
           }
         // keep force history short
           while( forceCoordinates.size() > 5 ) {
             forceCoordinates.remove(0);
           }	
          for (int i = leaves.size()-1; i >= 0; i--) {
		((Leaf)leaves.get(i)).update();
		((Leaf)leaves.get(i)).display();
	  }
        }
       
	// draw mask
        if( drawOverlay )
            image(overlayImage,0,0,width,height);        
        
	// drawing debug stuff, depth sort not needed
	if( debug ) {
		stroke(0,0,255);
		strokeWeight(2.0);
		text("use 'S' to save and 'L' load settings, 'H' to show/hide controls",20,20);
                text("leafCount: "+leaves.size(),20,40);
		fill(255,0,0);
                for(int i =0; i < forceCoordinates.size(); i++ ) {
                    float[] a = (float[])forceCoordinates.get(i);
		    line(a[0],a[1],0,a[2],a[3],0);
                    ellipse(a[2],a[3],20,20);
                }
		//text("movement angle:"+nf(degrees(movementAngle),1,2),50+mouseX,mouseY);
		//text("force angle:"+nf(degrees(forceAngle),1,2),50+mouseX,40+mouseY);
		//text("normalized force angle:"+nf(degrees(normalizedForceAngle),1,2),50+mouseX,80+mouseY);
		//strokeWeight(2.0);
		//fill(255,0,0);
		
	}
        averageCounter++;
        if( averageCounter == averageResetInterval ) {
          averageCounter = 0;
          averageTime = 0;
        }
        averageTime += (millis()-now);
        text("Average frame generation time in milliseconds:"+(int)(averageTime/averageCounter),50,50);
 //popMatrix();
}
void drawBackground() {
	/*textureMode(NORMALIZED);
	pushMatrix();
	translate(width/2,height/2,backgroundZ);
	beginShape(PConstants.QUADS);
	texture(backgroundMovie);
	int w = backgroundMovie.width,
		h = backgroundMovie.height;
	vertex(-w/2,-h/2,0,0,0);
	vertex(w/2,-h/2,0,w,0);
	vertex(w/2,h/2,0,w,h);
	vertex(-w/2,h/2,0,0,h);
	endShape();
	popMatrix();*/
        
}
float[] inputCoordinates() {
	PVector movementVector;
	if( client != null ){
		return receiveCoordinates();
	} else {
		float[] arr = new float[] { lastMouseX, lastMouseY, mouseX, mouseY };
		lastMouseX = mouseX;
		lastMouseY = mouseY;
		return arr;
	}
}

void applyForce(float x1, float y1, float x2, float y2) {
	PVector movementVector = new PVector(x2-x1,y2-y1,0);
	float headX = x2;
	float headY = y2;
	float movementAngle = atan2(movementVector.x,movementVector.y);
	for (int i = leaves.size()-1; i >= 0; i--) { 
		Leaf leaf = (Leaf) leaves.get(i);
		PVector vect = new PVector(leaf.location.x-headX,leaf.location.y-headY);
		float distance = dist(leaf.location.x,leaf.location.y, headX, headY),
			dx = (leaf.location.x-headX),
			dy = (leaf.location.y-headY);
		float normalizedForceAngle;
                float forceAngle = normalizedForceAngle = PVector.angleBetween(movementVector,vect);
		if( forceAngle > (PI/2) )
			normalizedForceAngle = (PI/2)-(forceAngle%(PI/2));
		
		// determine the rotation direction
		float rotationDirection = 1;
		if( leaf.location.x < headX && leaf.location.y < headY && movementAngle < 0 && movementAngle > -90 )
			rotationDirection = -1;
		else if( leaf.location.x < headX && leaf.location.y > headY && movementAngle > 0 && movementAngle < 90 )
			rotationDirection = -1;
		else if( leaf.location.x > headX && leaf.location.y > headY && movementAngle > 90 && movementAngle < 180 )
			rotationDirection = -1;
		else if( leaf.location.x > headX && leaf.location.y < headY && movementAngle > -180 && movementAngle < -90 )
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
void drawMovie(boolean v){
	drawMovie = v;
	println("drawMovie set to: "+v);
}
void drawOverlay(boolean v){
	drawOverlay = v;
	println("drawOverlay set to: "+v);
}
void drawLeaves(boolean v){
	drawLeaves = v;
	println("drawLeaves set to: "+v);
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
		PImage img = loadImage("leaves/highres/leaves_"+nf(c,2)+".png");
		if( img == null )
			break;
                img.resize(128,128);
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
          addLeaf();
    }
}

synchronized void addLeaf() {
  float x = random(0,width);
  float y = random(0,height);
  float z = random(10,50);
  leaves.add(new Leaf(x,y,z,random(5,20),(PImage)images.get(int(random(0,images.size())))));
}

float[] receiveCoordinates() {
  if( client.available() >= 16 ) {
    byte[] data = new byte[16];
    int read = client.readBytes(data);
    //println("Read "+ read+ " bytes:"+Arrays.toString(data));
    ByteBuffer buffer = ByteBuffer.allocate(16);
    buffer.put(data);
    float x1 = buffer.getFloat(0);
    float y1 = buffer.getFloat(4);
    float x2 = buffer.getFloat(8);
    float y2 = buffer.getFloat(12);
    //println("Received vector:  "+v.toString());
    return new float[]{x1,y1,x2,y2};
  }
  return null;
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  // some issues regarding processing 1.5.1, opengl and video seem to have been resolved by manually calling these
  //m.loadPixels();
  //m.updatePixels();
}






