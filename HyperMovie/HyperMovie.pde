import processing.video.*;
import controlP5.*;

Movie mov;
ControlP5 cp5;

Range redRange, blueRange, greenRange;
float redMin = 0, redMax = 1, blueMin = 0, blueMax = 1, greenMin = 0, greenMax = 1;

PGraphics buffer, filteredBuffer;
int BUFFER_SIZE = 2048;

int SLICE_COUNT = 300;
float SCALE_FACTOR = 1;
int ROW_COUNT, COL_COUNT;

boolean movieInit = false;
int currentIndex = 0;
boolean scheduleBufferUpdate = false;

float deltaZ = 2; //distance between two slices
float SLICE_WIDTH = 160;
float SLICE_HEIGHT = 90;

float angleX = radians(-15);;
float angleY = radians(210);
float zoom = 100;

boolean displayBuffer = false;
PShape quad;
PShader filter;

void setup() {
  size(1600, 900, P3D);
  buffer = createGraphics(BUFFER_SIZE, BUFFER_SIZE, P2D);
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();
  filteredBuffer = createGraphics(BUFFER_SIZE, BUFFER_SIZE, P3D);
  filteredBuffer.beginDraw();
  filteredBuffer.background(0);
  filteredBuffer.endDraw();

  mov = new Movie(this, "mov/bbb.mp4");
  mov.loop();

  initGUI();
  initShape(BUFFER_SIZE, BUFFER_SIZE);
  initShaders();
  hint(DISABLE_DEPTH_TEST);
}

void draw() {

  //write new slice into "buffer"
  if (scheduleBufferUpdate) {
    int currentCol = currentIndex % COL_COUNT;
    int currentRow = floor(currentIndex / COL_COUNT);
    float x = currentCol * mov.width * SCALE_FACTOR;
    float y = currentRow * mov.height * SCALE_FACTOR;
    float w =  mov.width * SCALE_FACTOR;
    float h =  mov.height * SCALE_FACTOR;
    buffer.beginDraw();
    buffer.image(mov, x, y, w, h);
    buffer.endDraw();
    currentIndex = (currentIndex+1) % SLICE_COUNT;
    scheduleBufferUpdate = false;
    filteredBuffer.beginDraw();
    filteredBuffer.background(0, 0);
    filteredBuffer.shader(filter);
    filteredBuffer.shape(quad);
    filteredBuffer.endDraw();
  }

  updateShaders();

  if (displayBuffer) {
    background(0, 255, 0);
    float scale = min(float(width) / buffer.width, float(height) / buffer.height);
    image(filteredBuffer, 0, 0, filteredBuffer.width*scale, filteredBuffer.height*scale);
  } else {
    background(31);
    translate(width*0.5, height*0.5, zoom);
    rotateX(angleX);
    rotateY(angleY);
    displaySlices(deltaZ);
  }

  if (drawGUI) {
    drawGUI();
  }
}

void mouseDragged() {
  if (!drawGUI) {
    angleX += (pmouseY-mouseY) * 0.01;
    angleY += (mouseX-pmouseX) * 0.01;
  }
}

void mouseWheel(MouseEvent event) {
  zoom += event.getCount();
}

void keyPressed() {
  switch(key) {
  case ' ':
    displayBuffer = !displayBuffer;
    break;
  case 'g':
  case 'G':
    drawGUI = !drawGUI;
    break;
  }
}

void initShaders() {
  filter = loadShader("glsl/filter.frag", "glsl/filter.vert");
  filter.set("srcTex", buffer);
}

void updateShaders() {
  filter.set("redMin", redMin);
  filter.set("redMax", redMax);
  filter.set("blueMin", blueMin);
  filter.set("blueMax", blueMax);
  filter.set("greenMin", greenMin);
  filter.set("greenMax", greenMax);
}

void initShape(int theW, int theH) {
  quad = createShape();
  quad.beginShape();
  quad.fill(255, 255, 0);
  quad.textureMode(NORMAL);
  quad.noStroke();
  quad.vertex(0, 0, 0, 0, 1);
  quad.vertex(theW, 0, 0, 1, 1);
  quad.vertex(theW, theH, 0, 1, 0);
  quad.vertex(0, theH, 0, 0, 0);
  quad.endShape();
}

void movieEvent(Movie m) {
  m.read();
  if (!movieInit) {
    initScaleFactor();
    movieInit = true;
  }
  scheduleBufferUpdate = true;
}

void displaySlices(float deltaZ) {
  textureMode(IMAGE);
  beginShape(QUADS);
  noStroke();
  texture(filteredBuffer);
  float z0 = -SLICE_COUNT * deltaZ * 0.5;
  float x0 = -SLICE_WIDTH * 0.5;
  float y0 = -SLICE_HEIGHT * 0.5;
  for (int i = SLICE_COUNT-1; i >= 0; i--) {
    int texelIndex = (currentIndex - i - 1 + SLICE_COUNT) % SLICE_COUNT;
    float texelCol = (texelIndex % COL_COUNT) * mov.width * SCALE_FACTOR;
    float texelRow = floor(texelIndex / COL_COUNT) * mov.height * SCALE_FACTOR;
    float texelWidth =  mov.width * SCALE_FACTOR;
    float texelHeight =  mov.height * SCALE_FACTOR;
    float z = z0 + deltaZ * i;
    vertex(x0, y0, z, texelCol, texelRow);
    vertex(x0 + SLICE_WIDTH, y0, z, texelCol + texelWidth, texelRow);
    vertex(x0 + SLICE_WIDTH, y0 + SLICE_HEIGHT, z, texelCol + texelWidth, texelRow + texelHeight);
    vertex(x0, y0 + SLICE_HEIGHT, z, texelCol, texelRow + texelHeight);
  }
  endShape(CLOSE);
}

void initScaleFactor() {
  float movAspectRatio = mov.width / float(mov.height);
  float bufferAspectRatio = buffer.width / float(buffer.height);
  //println(movAspectRatio, bufferAspectRatio);
  ROW_COUNT = ceil(sqrt(SLICE_COUNT / bufferAspectRatio * movAspectRatio));
  COL_COUNT = ceil(sqrt(SLICE_COUNT / movAspectRatio * bufferAspectRatio));
  float SCALE_FACTOR0 = (float(buffer.height) / (float(ROW_COUNT) * float(mov.height)));
  float SCALE_FACTOR1 = (float(buffer.width) / (float(COL_COUNT) * float(mov.width)));
  if (SCALE_FACTOR0 < SCALE_FACTOR1) {
    SCALE_FACTOR = SCALE_FACTOR0;
  } else {
    SCALE_FACTOR = SCALE_FACTOR1;
  }
  COL_COUNT = floor(buffer.width / (mov.width * SCALE_FACTOR));
  ROW_COUNT = floor(buffer.height / (mov.height * SCALE_FACTOR));
  println("rows", ROW_COUNT, "cols", COL_COUNT, "actual count", ROW_COUNT*COL_COUNT, "target count", SLICE_COUNT, "scale factor", SCALE_FACTOR);
  SLICE_COUNT = min(ROW_COUNT * COL_COUNT, SLICE_COUNT);
}