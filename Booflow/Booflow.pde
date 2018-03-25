import processing.video.*;

// Compares two images from a sequence and finds the motion of each pixel from the first
// image to the second image

import boofcv.processing.*;
import boofcv.struct.image.*;

PGraphics ping, pong;
PImage outputFlow;
boolean pingPong = false;
PImage lastImage;

Movie video;
SimpleDenseOpticalFlow flow;

boolean doUpdate = false;
int currentFrame = 1;

void setup() {
  size(1136, 320);
  ping = createGraphics(width/2, height);
  pong = createGraphics(width/2, height);

  ping.beginDraw();
  ping.background(0);
  ping.endDraw();
  pong.beginDraw();
  pong.background(0);
  pong.endDraw();

  video = new Movie(this, "sample1.mov");
  video.play();
  video.jump(0);
  video.pause();

  flow = Boof.flowHornSchunckPyramid(null, ImageDataType.F32);
  // flow = Boof.flowBroxWarping(null,ImageDataType.F32);
  // flow = Boof.flowKlt(null,6,ImageDataType.F32);
  // flow = Boof.flowRegion(null,ImageDataType.F32);
  //flow = Boof.flowHornSchunck(null, ImageDataType.F32);
  //frameRate(1);

  // process and visualize the results.  The optical flow data can be access via getFlow()
}

void draw() {
  background(0);

  if (doUpdate) {
    /*
    if (pingPong) {
     pong.beginDraw();
     pong.background(0);
     pong.image(video, 0, 0);
     pong.endDraw();
     //flow.process(ping, pong);
     } else {
     println("foo");
     ping.beginDraw();
     ping.background(0);
     ping.image(video, 0, 0);
     ping.endDraw();
     lastImage = video.copy();
     //flow.process(pong, ping);
     //pingPong = !pingPong;
     }
     */
    if (lastImage != null) {
      int w = lastImage.width / 8;
      int h = lastImage.height / 8;
      PImage i0 = lastImage.copy();
      i0.resize(w, h);
      PImage i1 = video.copy();
      i1.resize(w,h);
      flow.process(i0, i1);
    }
    outputFlow = flow.visualizeFlow();
    lastImage = video.copy();
    doUpdate = false;
    nextFrame();
  }


  try {
    image(video, 0, 0);
    translate(width / 2, 0);

    image(outputFlow, 0, 0, width/2, height);
    //image(lastImage, 0, 0, lastImage.width*0.5, lastImage.height*0.5);

    //image(ping, 0, 0, ping.width*0.5, ping.height*0.5);
    //image(pong, ping.width*0.5, 0, pong.width*0.5, pong.height*0.5);
  } 
  catch (Exception e) {
  }
  println(getFrame());
}
