import processing.video.*;
import controlP5.*;

Movie mov;
ControlP5 cp5;

Range redRange, blueRange, greenRange;
float redMin = 0, redMax = 1, blueMin = 0, blueMax = 1, greenMin = 0, greenMax = 1;

PGraphics buffer, filteredBuffer;
PGraphics lookupCubeFront, lookupCubeBack;
PShape lookupCube;
int BUFFER_SIZE = 2048;

int SLICE_COUNT = 100;
float SCALE_FACTOR = 1;
int ROW_COUNT, COL_COUNT;

boolean movieInit = false;
int currentIndex = 0;
boolean scheduleBufferUpdate = false;

float deltaZ = 2; //distance between two slices
float SLICE_WIDTH = 160;
float SLICE_HEIGHT = 90;

float angleX = radians(-15);
float angleY = radians(210);
float zoom = 100;

boolean displayBuffer = false;
PShape bufferQuad,sketchQuad;
PShader filter, rayTracer;

void setup() {
  size(1600, 900, P3D);
  initGraphics(BUFFER_SIZE, BUFFER_SIZE);

  mov = new Movie(this, "mov/bbb.mp4");
  mov.loop();

  initGUI();
  //bufferQuad = initQuad(BUFFER_SIZE, BUFFER_SIZE);
  bufferQuad = initQuad(buffer.width, buffer.height);
  sketchQuad = initQuad(width, height);
  initShaders();
  initLookupCube(SLICE_WIDTH, SLICE_HEIGHT, deltaZ * SLICE_COUNT);
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
    rayTracer.set("currentIndex", currentIndex + 0f);
    scheduleBufferUpdate = false;
    filteredBuffer.beginDraw();
    filteredBuffer.background(0, 0);
    filteredBuffer.shader(filter);
    filteredBuffer.shape(bufferQuad);
    filteredBuffer.endDraw();
  }

  updateShaders();
  drawLookupCube(angleX, angleY, zoom);

  if (displayBuffer) {
    background(0, 255, 0);
    float scale = min(float(width) / buffer.width, float(height) / buffer.height);
    image(filteredBuffer, 0, 0, filteredBuffer.width*scale, filteredBuffer.height*scale);
  } else {
    background(0);
    shader(rayTracer);
    shape(sketchQuad);
    resetShader();
  }

  if (drawGUI) {
    drawGUI();
  }

  /*
  image(lookupCubeFront, 0, 0, width*0.5, height*0.5);
   image(lookupCubeBack, width*0.5, 0, width*0.5, height*0.5);
   */
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

void initGraphics(int w, int h) {
  buffer = createGraphics(w, h, P2D);
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();
  filteredBuffer = createGraphics(w, h, P3D);
  filteredBuffer.beginDraw();
  filteredBuffer.background(0);
  filteredBuffer.endDraw();
  lookupCubeBack = createGraphics(width, height, P3D);
  lookupCubeBack.beginDraw();
  lookupCubeBack.background(0);
  lookupCubeBack.endDraw();
  lookupCubeFront = createGraphics(width, height, P3D);
  lookupCubeFront.beginDraw();
  lookupCubeFront.background(0);
  lookupCubeFront.endDraw();
}

void initShaders() {
  filter = loadShader("glsl/filter.frag", "glsl/filter.vert");
  filter.set("srcTex", buffer);
  rayTracer = loadShader("glsl/rayTracer.frag", "glsl/rayTracer.vert");
  rayTracer.set("lookupTexBack", lookupCubeBack);
  rayTracer.set("lookupTexFront", lookupCubeFront);
  rayTracer.set("sliceTex", filteredBuffer);
  rayTracer.set("sliceCount", SLICE_COUNT + 0f);
  rayTracer.set("sliceColCount", COL_COUNT + 0f);
  //rayTracer.set("sliceRowCount",  ROW_COUNT + 0f);
  float sliceNormWidth = mov.width * SCALE_FACTOR / float(buffer.width);
  float sliceNormHeight = mov.height * SCALE_FACTOR / float(buffer.height);
  rayTracer.set("sliceNormWidth", sliceNormWidth);
  rayTracer.set("sliceNormHeight", sliceNormHeight);
  println(sliceNormWidth, sliceNormHeight);
  println(sliceNormWidth * COL_COUNT * SLICE_WIDTH, sliceNormHeight * ROW_COUNT * SLICE_HEIGHT);
  println(buffer.width, buffer.height);
}

void updateShaders() {
  filter.set("redMin", redMin);
  filter.set("redMax", redMax);
  filter.set("blueMin", blueMin);
  filter.set("blueMax", blueMax);
  filter.set("greenMin", greenMin);
  filter.set("greenMax", greenMax);
}

void initLookupCube(float w, float h, float d) {
  lookupCube = createShape();
  lookupCube.beginShape(QUADS);
  lookupCube.noStroke();
  colouredVertex(lookupCube, w, h, d, 0, 1, 0);
  colouredVertex(lookupCube, w, h, d, 1, 1, 0);
  colouredVertex(lookupCube, w, h, d, 1, 0, 0);
  colouredVertex(lookupCube, w, h, d, 0, 0, 0);

  colouredVertex(lookupCube, w, h, d, 0, 0, 1);
  colouredVertex(lookupCube, w, h, d, 1, 0, 1);
  colouredVertex(lookupCube, w, h, d, 1, 1, 1);
  colouredVertex(lookupCube, w, h, d, 0, 1, 1);

  colouredVertex(lookupCube, w, h, d, 0, 0, 0);
  colouredVertex(lookupCube, w, h, d, 1, 0, 0);
  colouredVertex(lookupCube, w, h, d, 1, 0, 1);
  colouredVertex(lookupCube, w, h, d, 0, 0, 1);

  colouredVertex(lookupCube, w, h, d, 0, 1, 1);
  colouredVertex(lookupCube, w, h, d, 1, 1, 1);
  colouredVertex(lookupCube, w, h, d, 1, 1, 0);
  colouredVertex(lookupCube, w, h, d, 0, 1, 0);

  colouredVertex(lookupCube, w, h, d, 0, 0, 1);
  colouredVertex(lookupCube, w, h, d, 0, 1, 1);
  colouredVertex(lookupCube, w, h, d, 0, 1, 0);
  colouredVertex(lookupCube, w, h, d, 0, 0, 0);

  colouredVertex(lookupCube, w, h, d, 1, 0, 0);
  colouredVertex(lookupCube, w, h, d, 1, 1, 0);
  colouredVertex(lookupCube, w, h, d, 1, 1, 1);
  colouredVertex(lookupCube, w, h, d, 1, 0, 1);

  lookupCube.endShape(CLOSE);
}

void colouredVertex(PShape sh, float w, float h, float d, float nx, float ny, float nz) {
  sh.fill(nx * 255, ny * 255, nz * 255);
  sh.vertex(w*(nx - 0.5), h*(ny - 0.5), d*(nz - 0.5));
}

void drawLookupCube(float rx, float ry, float z) {
  lookupCubeFront.beginDraw();
  PGL pgl = lookupCubeFront.beginPGL();
  pgl.enable(PGL.CULL_FACE);
  pgl.cullFace(PGL.BACK);
  lookupCubeFront.background(0,0);
  lookupCubeFront.translate(width*0.5, height*0.5, z);
  lookupCubeFront.rotateX(rx);
  lookupCubeFront.rotateY(ry);
  lookupCubeFront.shape(lookupCube);
  lookupCubeFront.endDraw();
  lookupCubeBack.beginDraw();
  PGL pgl2 = lookupCubeBack.beginPGL();
  pgl2.enable(PGL.CULL_FACE);
  pgl2.cullFace(PGL.FRONT);
  lookupCubeBack.background(0,0);
  lookupCubeBack.translate(width*0.5, height*0.5, z);
  lookupCubeBack.rotateX(rx);
  lookupCubeBack.rotateY(ry);
  lookupCubeBack.shape(lookupCube);
  lookupCubeBack.endDraw();
  // draw your geometry, using either Processing calls or GL calls...
  endPGL(); // restores the GL defaults for Processing
}

PShape initQuad(int theW, int theH) {
  PShape quad = createShape();
  quad.beginShape();
  quad.fill(255, 255, 0);
  quad.textureMode(NORMAL);
  quad.noStroke();
  quad.vertex(0, 0, 0, 0, 1);
  quad.vertex(theW, 0, 0, 1, 1);
  quad.vertex(theW, theH, 0, 1, 0);
  quad.vertex(0, theH, 0, 0, 0);
  quad.endShape();
  return quad;
}

void movieEvent(Movie m) {
  m.read();
  if (!movieInit) {
    initScaleFactor();
    initShaders();
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