import processing.opengl.*;

int M = 1;
float distanceThreshold = 100,
      movementThreshold = 20;
float updateIntervalMillis = 50, lastUpdateMillis = millis();

float lastMouseX = -1,
      lastMouseY = -1;
ArrayList images; // of PImages
Leaf[] leaves = new Leaf[M];

boolean debug = true;
float movementAngle,forceAngle;

void setup() {
	size(800, 600,OPENGL);
	frameRate(30);
	hint(DISABLE_DEPTH_TEST);
	//hint(ENABLE_DEPTH_SORT);
	images = new ArrayList();
	for(int c=1;;c++) {
		PImage img = loadImage("/../../resources/leaves/highres/leaves_"+nf(c,2)+".png");
		if( img == null )
			break;
		images.add(img);
	}
	for(int i=0; i < M;i++) {
		leaves[i] = new Leaf(
			random(0,width),
			random(0,height),
			0.0,
			(PImage)images.get(int(random(0,images.size())))
		);
	}
}

void draw() {
	background(255);
	float now = millis();

	// update data
        PVector movementVector = new PVector(lastMouseX-mouseX,lastMouseY-mouseY,0);
        float movementMagnitude = movementVector.mag();
	if( now - lastUpdateMillis > updateIntervalMillis && 
                movementMagnitude > movementThreshold ) {
		
                lastUpdateMillis = now;
		lastMouseX = mouseX;
		lastMouseY = mouseY;
		movementAngle = atan2(movementVector.x,movementVector.y);

		for (int i = leaves.length-1; i >= 0; i--) { 
			Leaf leaf = (Leaf) leaves[i];
                        PVector vect = new PVector(leaf.location.x-mouseX,leaf.location.y-mouseY);
			float distance = dist(leaf.location.x,leaf.location.y, mouseX, mouseY),
				dx = (leaf.location.x-mouseX),
				dy = (leaf.location.y-mouseY);
                        float normalizedForceAngle = forceAngle = PVector.angleBetween(movementVector,vect);
                        if( forceAngle > (PI/2) )
                            normalizedForceAngle = (PI/2)-(forceAngle%(PI/2));
                            
                        // closer the angle is to 90 apply more rotation
                        float rotationFactor = map(abs(degrees(normalizedForceAngle)),0,90,0,1);
                        float zFactor = map(90-abs(degrees(normalizedForceAngle)),0,90,0,10);
                        if( distance < distanceThreshold ) {
                                float distanceFactor = map(distance,0,distanceThreshold,1,2);
				leaf.velocity.x += (dx/30)*distanceFactor;
				leaf.velocity.y += (dy/30)*distanceFactor;
                                leaf.spin += (rotationFactor/4)*distanceFactor;
                                leaf.location.z += zFactor*distanceFactor;
			}
			
		}
	}
	
	// draw video frame, leaves, and mask
	for (int i = leaves.length-1; i >= 0; i--) {
                 leaves[i].move();
		leaves[i].display(this);
        }
		
	// drawing debug stuff
	if( !debug )
		return;
	stroke(0,0,255);
	strokeWeight(5.0);
	fill(255,0,0);
	line(lastMouseX,lastMouseY,0,mouseX,mouseY,0);
	text("movement angle:"+nf(degrees(movementAngle),1,2),50+mouseX,mouseY);
	text("force angle:"+nf(degrees(forceAngle),1,2),50+mouseX,40+mouseY);
	strokeWeight(2.0);
	fill(255,0,0);
	ellipse(mouseX,mouseY,20,20);
}

void mouseMoved(){

}

void mousePressed() {

}

