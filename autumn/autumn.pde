import processing.video.*;  // playing background
import java.nio.*;          // for the bytebuffer
import processing.net.*;    // getting vectors over the network
import controlP5.*;         // GUI control library
import processing.opengl.*; // draw utilizing opengl rendering engine

int leafCount = 500,
    leafSize = 4,
    fps = 50,
    movieFps = 25;
float distanceThreshold = 100,     // maximum distance when movement vector is applied to leaves
      movementThreshold = 20,      // distance blob has to move before it movement vector gets applied to leaves
      updateInterval = 25,         // how often leaves should be update
      lastUpdateMillis = millis(), // timing helper variable
      lastMovementMillis = millis(), // last time network send something or mouse was moved
      movieStartedMillis = millis(), // when was the movie started
      stopThreshold = 5000,        // how much waiting before the movie stops
      topVelocity = 10,            // leaf max XY speed
      topSpinSpeed = 0.2,           // leaf max rotation speed
      backgroundZ = -50;           // background image place in z-axis
      
PVector gravity = new PVector(0,0,4);                // how fast the leaves come down
     
float lastMouseX = -1,
      lastMouseY = -1;
ArrayList<float[]> forceCoordinates = new ArrayList(); // of float[]
ArrayList images; // of PImages- objects
ArrayList leaves; // of Leaf- objects
ControlP5 controlP5;
PImage overlayImage;
Movie backgroundMovie;
Client client;

// profiling variables
float averageTime = 0;
int averageCounter = 0;
int averageResetInterval = 100;

// flags to optionally enable/disable drawing or feature
boolean drawMovie = true, 
  drawLeaves = true, 
  drawOverlay = true, 
  enableFluctuation = true,
  drawDebug = true, 
  isPlaying = false,
  wind = true;

void setup() {
	size(1024, 768,OPENGL);
	frameRate(fps);
	hint(DISABLE_DEPTH_TEST);
	overlayImage = loadImage("overlay.png");
	// call this before setLeaves
	loadImages(50);

	controlP5 = new ControlP5(this);
	controlP5.setAutoInitialization(true);

	// controls on the left side
	controlP5.addSlider("distanceThreshold",50,200,distanceThreshold,20,60,30,80);
	controlP5.addSlider("movementThreshold",1,100,movementThreshold,20,160,30,80);
	controlP5.addSlider("updateInterval",5,100,updateInterval,20,260,30,80);
	controlP5.addSlider("topSpinSpeed",0.001,1.0,topSpinSpeed,20,360,30,80);
	controlP5.addSlider("topVelocity",5,50,topVelocity,20,460,30,80);
        controlP5.addSlider("stopThreshold",500,20000,stopThreshold,20,560,30,80);
        
	// controls on the right side
	controlP5.addToggle("network",false,width-50,10,30,30);
        controlP5.addToggle("wind",wind,width-50,50,30,30);
	controlP5.addSlider("leafCount",1,1500,leafCount,width-50,110,30,80);
	controlP5.addSlider("leafSize",1,10,leafSize,width-50,210,30,80);
        controlP5.addToggle("drawMovie",drawMovie,width-50,310,30,30);
        controlP5.addToggle("drawLeaves",drawLeaves,width-50,360,30,30);
        controlP5.addToggle("drawOverlay",drawOverlay,width-50,410,30,30);
        controlP5.addToggle("enableFluctuation",enableFluctuation,width-50,460,30,30);

	setLeaves(leafCount);
        backgroundMovie = new Movie(this,"background.mp4");
        backgroundMovie.frameRate(movieFps);
        backgroundMovie.noLoop();
}

void draw() {
        background(0);
        float now = millis();
        
        // determine if movie should still be played
        float idleTime = (now-lastMovementMillis);
        if( idleTime < stopThreshold ) {
            if( !isPlaying ) {
              isPlaying = true;
              backgroundMovie.play();
              movieStartedMillis = millis();
            }
        } else {
           isPlaying = false;
           backgroundMovie.stop();
        }
        
	// draw video frame
        if( drawMovie && isPlaying ) {
            //if( now-movieStartedMillis < stopThreshold )
            //  tint(map(now-movieStartedMillis,0,stopThreshold,0,255));
            //else tint(map(idleTime,0,stopThreshold,255,0));
            image(backgroundMovie,0,0,width,height);
        }

        
	// draw leaves
        float leafUpdate = -1, leafDraw = -1;
        if( drawLeaves ) {
          float elapsed = now - lastUpdateMillis;
	  if( elapsed > updateInterval ) { // enough time elapsed from last update ?
              lastUpdateMillis = now;
              float[] coordinates = inputCoordinates();
              if( coordinates != null ){
                lastMovementMillis = now;
                //println("force coords:"+Arrays.toString(coordinates));
                applyForce(coordinates[0],coordinates[1],coordinates[2],coordinates[3]);
              }
           }
        if( wind && idleTime > stopThreshold ) {
              for (int i = leaves.size()-1; i >= 0; i--) {
                  Leaf leaf = (Leaf)leaves.get(i);
                  leaf.increaseFluctuation(0.1);
                  // randomize point around the center where the wind is blowing the leaf
                  float px = random(0,width);
                  float py = random(0,height);
                  float force = random(0.00001,0.0001);
                  float lx = leaf.location.x;
                  float ly = leaf.location.y;
                  PVector v = new PVector((px-lx)*force,(py-ly)*force,random(0.01,0.1));
                  leaf.velocity.add(v);
              }
         }
          stroke(255);
          float before = millis();
          for (int i = leaves.size()-1; i >= 0; i--) {
		((Leaf)leaves.get(i)).update();
	  }
          leafUpdate = millis() -before;
          
          before = millis();
          for (int i = leaves.size()-1; i >= 0; i--) {
		((Leaf)leaves.get(i)).display();
	  }
          leafDraw = millis()-before;

        }
       
	// draw mask
        if( drawOverlay )
            image(overlayImage,0,0,width,height);        
        
	// drawing debug stuff, depth sort not needed
	if( drawDebug ) {
		stroke(255);
                fill(255);
  		text("use 'S' to save, and 'L' load settings, 'H' to show/hide controls, 'D' to show/hide FPS",20,20);
                averageCounter++;
                if( averageCounter == averageResetInterval ) {
                  averageCounter = 0;
                  averageTime = 0;
                }
                float generationTime = (millis()-now);
                averageTime += generationTime;
                
                text("Average frame generation time in milliseconds:"+(int)(averageTime/averageCounter),100,100);
                text("Current frame generation time in milliseconds:"+(int)(generationTime),100,140);
                text("FPS: " + Math.floor(frameRate),100,180);
                text("Milliseconds to draw leaves:"+(int)(leafDraw),100,220);
                text("Milliseconds to update leaves:"+(int)(leafUpdate),100,240);
                text("Last movement:"+(int)(idleTime),100,260);
               
	}
}

float[] inputCoordinates() {
	PVector movementVector;
	if( client != null ){
		return receiveCoordinates();
	} else {
                // return null in case mouse outside window
                if( mouseX == lastMouseX && mouseY == lastMouseY )
                  return null;
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
                                // TODO: invert z-factor which will recude XY movement
				float distanceFactor = map(distance,0,distanceThreshold,1,2);
				leaf.velocity.x += (dx/30.0)*distanceFactor;
				leaf.velocity.y += (dy/30.0)*distanceFactor;
                                leaf.location.z += zFactor*distanceFactor;
				leaf.spinSpeed += (rotationFactor/6)*rotationDirection;
				leaf.increaseFluctuation(distanceFactor*5);
		}
	}
}

void keyPressed() {
  	if( key == 'd' || key == 'D' )
		drawDebug = drawDebug ? false : true;
	if( key == 'h' || key == 'H' ) {
		if( controlP5.isVisible() ) {
			controlP5.hide();
		} else {
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
void stopThreshold(float v){
	stopThreshold = v;
	println("stopThreshold set to: "+v);
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
void enableFluctuation(boolean v){
	enableFluctuation = v;
	println("enableFluctuation set to: "+v);
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
                img.resize(256,256);
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






