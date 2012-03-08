import processing.opengl.*;

int M = 10;
float distanceThreshold = 100,
      movementThreshold = 20;
float updateIntervalMillis = 25, lastUpdateMillis = millis();

float lastMouseX = -1,
      lastMouseY = -1;
ArrayList images; // of PImages
Leaf[] leaves = new Leaf[M];

boolean debug = true;
float movementAngle,
      forceAngle,
      normalizedForceAngle;

void setup() {
	size(800, 600,OPENGL);
	frameRate(30);
	hint(DISABLE_DEPTH_TEST);
	//hint(ENABLE_DEPTH_SORT);
	images = new ArrayList();
	for(int c=1;c < 5;c++) {
		PImage img = loadImage("/../../resources/leaves/highres/leaves_"+nf(c,2)+".png");
		if( img == null )
			break;
		images.add(img);
	}
	for(int i=0; i < M;i++) {
		leaves[i] = new Leaf(
			random(width/4,3*width/4),
			random(height/4,3*height/4),
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
				leaf.velocity.x += (dx/30)*distanceFactor;
				leaf.velocity.y += (dy/30)*distanceFactor;
                                leaf.spin += (rotationFactor/6)*rotationDirection;
                                leaf.location.z += zFactor*distanceFactor;
			}
			
		}
	}
	
	// draw video frame, leaves, and mask
	for (int i = leaves.length-1; i >= 0; i--) {
                leaves[i].update();
		leaves[i].display(this);
        }
		
	// drawing debug stuff
	if( !debug )
		return;
	stroke(0,0,255);
	strokeWeight(5.0);
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

void mouseMoved(){

}

void mousePressed() {

}

