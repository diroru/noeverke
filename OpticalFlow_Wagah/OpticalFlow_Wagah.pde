import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Movie video;

void setup() {
  size(1280, 360);
  video = new Movie(this, "wagah_short.mov");
  opencv = new OpenCV(this, 640, 360);
  video.loop();
  video.play();
}

void draw() {
  background(0);


  image(video, 0, 0);
  translate(video.width, 0);
  //float r = random(0,200);
  //stroke(100, 0, 100);
  //opencv.drawOpticalFlow();

  //PVector aveFlow = opencv.getTotalFlow(); //getAverageFlow();
  //int flowScale = 10;
  //stroke(0, 255, 0);
  strokeWeight(2);
  //drawFlow params:
  //1: x coordinate
  //2: y coordinate
  //3: flowScale
  //4: minFlow
  //5: maxFlow
  beginShape(LINES);
  for (int j=0; j<video.height; j++) {
    for (int i=0; i<video.width; i++) {
      drawFlowAt(i, j, 2, 1, 10, color(255, 0, 0, 42), color(0, 255, 0, 42));
      //line(video.width/2, video.height/2, video.width/2 + aveFlow.x*flowScale, video.height/2 + aveFlow.y*flowScale);
    }
  }
  endShape();
}

void drawFlowAt(int pixelX, int pixelY, float flowScale, float minFlow, float maxFlow, color minColor, color maxColor) {
  try {
    PVector flowVector =  opencv.getFlowAt(pixelX, pixelY);
    float flowMagnitude = flowVector.mag(); //sqrt(x*x +  y*y + z*z)
    // && logical AND operator
    // || logical OR operator
    // ! logical NO operator
    if (flowMagnitude >= minFlow && flowMagnitude <= maxFlow) {
      float x1 = flowVector.x*flowScale+pixelX;
      float y1 = flowVector.y*flowScale+pixelY;
      float colorMix = norm(flowMagnitude, minFlow, maxFlow); // same as: map(flowMagnitude, minFlow, maxFlow, 0, 1);
      color c = lerpColor(minColor, maxColor, colorMix);
      stroke(c);
      //line(pixelX, pixelY, x1, y1);
      vertex(pixelX, pixelY);
      vertex(x1, y1);
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

void movieEvent(Movie m) {
  m.read();
  opencv.loadImage(video);
  opencv.calculateOpticalFlow();
}
