import processing.net.*;
import java.nio.*;

Server server;
Client client;
float ox, oy;
void setup() {
  size(400,400);
  frameRate(50);
  server = new Server(this, 12345);
  client = new Client(this, "127.0.0.1", 12345);
}

void draw() {
   background(0);
}

void mouseMoved(){
  if( sqrt(pow(ox-mouseX,2)+pow(oy-mouseY,2)) > 24 ) {
    sendVector(ox,oy,mouseX,mouseY);
  //receiveVector();
    ox = mouseX;
    oy = mouseY;
  }
}


void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
}
void sendVector(float x1,float y1, float x2, float y2) {
   server.write(byta(map(x1,0,width,0,1024)));
   server.write(byta(map(y1,0,height,0,768)));
   server.write(byta(map(x2,0,width,0,1024)));
   server.write(byta(map(y2,0,height,0,768)));
}
PVector receiveVector() {
  if( client.available() >= 16 ) {
    byte[] data = new byte[16];
    int read = client.readBytes(data);
    //println("Read "+ read+ " bytes:"+Arrays.toString(data));
    ByteBuffer buffer = ByteBuffer.allocate(16);
    buffer.put(data); 
    PVector v = new PVector(buffer.getFloat(0)-buffer.getFloat(8),buffer.getFloat(4)-buffer.getFloat(12),0);
    //println("Received vector:  "+v.toString());
    return v;
  }
  return null;
}

byte[] byta(float v){
  int i = Float.floatToRawIntBits(v);
    return new byte[] {
        (byte)((i >> 24) & 0xff),
        (byte)((i >> 16) & 0xff),
        (byte)((i >> 8) & 0xff),
        (byte)((i >> 0) & 0xff),
    };
}
