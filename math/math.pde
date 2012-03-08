import processing.opengl.*;

int W = 128;
int M = 1;
float DEACCELERATION = 0.5;
int distanceThreshold = 50;
float updateIntervalMillis = 50, lastUpdateMillis = millis();
float lastX = -1,lastY = -1, angle = 0;
ArrayList images; // of PImages
Leaf[] leaves = new Leaf[M];
boolean debug = true;

void setup() {
	size(800, 600,OPENGL);
	frameRate(30);
	hint(DISABLE_DEPTH_TEST);
	//hint(ENABLE_DEPTH_SORT);
	images = new ArrayList();
	for(int c=1;;c++) {
		PImage img = loadImage("/../../resources/leaves/highres/leaves_"+nf(c,2)+".png");
		if( !img != null )
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
	if( now - lastUpdateMillis > updateIntervalMillis ) {
		lastUpdateMillis = now;
		PVector magnitude = new PVector(lastX-mouseX,lastY-mouseY,0);
		angle = atan2(magnitude.x,magnitude.y);
		lastX = mouseX;
		lastY = mouseY;
		for (int i = leaves.length-1; i >= 0; i--) { 
			Leaf leaf = (Leaf) leaves[i];
			float distance = dist(leaf.location.x,leaf.location.y, mouseX, mouseY),
				dx = (leaf.location.x-mouseX),
				dy = (leaf.location.y-mouseY);
			if( distance < distanceThreshold ) {
				leaf.velocity.x += dx/50;
				leaf.velocity.y += dy/50;
			}
			leaf.move();
		}
	}
	
	// draw video frame, leaves, and mask
	for (int i = leaves.length-1; i >= 0; i--)
		leaves[i].display(this);
		
	// drawing debug stuff
	if( !debug )
		return;
	stroke(0,0,255);
	strokeWeight(5.0);
	fill(255,0,0);
	line(lastX,lastY,0,mouseX,mouseY,0);
	text("angle:"+nf(angle,1,2),50+mouseX,mouseY);
	strokeWeight(2.0);
	fill(255,0,0);
	ellipse(mouseX,mouseY,20,20);
}

void mouseMoved(){

}

void mousePressed() {

}

