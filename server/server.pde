import processing.net.*;
import java.nio.*;

Server server;
Client client;

void setup() {
  size(400,400);
  server = new Server(this, 12345);
  client = new Client(this, "127.0.0.1", 12345);
}

void draw() {
   background(0);
}

void mouseMoved(){
  float v = (float)mouseX;
  println("MouseX is now: "+v);
  server.write(byta(mouseX));
//server.write(mouseY);
  if( client.available() >= 4 ) {
    byte[] data = new byte[4];
    int read = client.readBytes(data);
    println("Read "+ read+ " bytes:"+Arrays.toString(data));
    ByteBuffer buffer = ByteBuffer.allocate(4);
    buffer.put(data); 
    println("Server Says:  "+buffer.getFloat(0));
  }
}


void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
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
