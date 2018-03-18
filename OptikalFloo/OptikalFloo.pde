import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Movie video;
PImage flowImage;
float maxFlow = Float.MIN_VALUE;
float maxFlowRadius = Float.MIN_VALUE;

void setup() {
  size(1136, 320);
  video = new Movie(this, "sample1.mov");
  opencv = new OpenCV(this, 568, 320);
  flowImage = createImage(video.width, video.height, RGB);
  video.loop();
  video.play();
}

void draw() {
  background(0);
  opencv.loadImage(video);
  opencv.calculateOpticalFlow();

  image(video, 0, 0);
  translate(video.width, 0);
  stroke(255, 0, 0);
  //opencv.drawOpticalFlow();

  //1st method
  /*
  for (int i = 0; i < video.width; i++) {
   for (int j = 0; j < video.height; j++) {
   PVector v = opencv.getFlowAt(i, j);
   float r = map(v.x, -1, 1, 0, 255);
   float g = map(v.y, -1, 1, 0, 255);
   float b = map(v.z, -1, 1, 0, 255);
   stroke(r, g, b);
   point(i, j);
   }
   }
   */
  //2nd method
  PImage flowImage = createImage(video.width, video.height, RGB);
  flowImage.loadPixels();
  for (int i = 0; i < video.width; i++) {
    for (int j = 0; j < video.height; j++) {
      PVector v = opencv.getFlowAt(i, j);
      maxFlow = max(abs(v.x), abs(maxFlow));
      maxFlow = max(abs(v.y), abs(maxFlow));      
      maxFlow = max(abs(v.z), abs(maxFlow));
      maxFlow = max(v.x, maxFlow);
      maxFlow = max(v.y, maxFlow);
      maxFlow = max(v.z, maxFlow);
      maxFlowRadius = max(sqrt(v.x * v.x + v.y * v.y + v.z * v.z), maxFlowRadius);
      float r = map(v.x, -maxFlow, maxFlow, 0, 255);
      float g = map(v.y, -maxFlow, maxFlow, 0, 255);
      float b = map(v.z, -maxFlow, maxFlow, 0, 255);
      int pixelIndex = flowImage.width * j + i;
      flowImage.pixels[pixelIndex] = color(r, g, b);
    }
  }
  flowImage.updatePixels();
  image(flowImage, 0, 0);
  println("max: ", maxFlow, "max r: ", maxFlowRadius);
  /*
  PVector aveFlow = opencv.getAverageFlow();
   int flowScale = 50;
   
   stroke(255);
   strokeWeight(2);
   line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);
   */
}

void movieEvent(Movie m) {
  m.read();
}