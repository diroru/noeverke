boolean drawGUI = false;

void initGUI() {
  cp5 = new ControlP5(this);
  redRange = cp5.addRange("RED Range")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(20, 20)
    .setSize(400, 30)
    .setHandleSize(20)
    .setRange(0, 255)
    .setRangeValues(0, 255)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    //.setColorForeground(color(255,40))
    //.setColorBackground(color(255,40))  
    ;
  greenRange = cp5.addRange("GREEN Range")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(20, 60)
    .setSize(400, 30)
    .setHandleSize(20)
    .setRange(0, 255)
    .setRangeValues(0, 255)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    //.setColorForeground(color(255,40))
    //.setColorBackground(color(255,40))  
    ;
  blueRange = cp5.addRange("BLUE Range")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(20, 100)
    .setSize(400, 30)
    .setHandleSize(20)
    .setRange(0, 255)
    .setRangeValues(0, 255)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    //.setColorForeground(color(255,40))
    //.setColorBackground(color(255,40))  
    ;

  cp5.setAutoDraw(false);
}

void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("RED Range")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    redMin = int(theControlEvent.getController().getArrayValue(0)) / 255f;
    redMax = int(theControlEvent.getController().getArrayValue(1)) / 255f;
    scheduleBufferUpdate = true;
  }
  if (theControlEvent.isFrom("BLUE Range")) {
    blueMin = int(theControlEvent.getController().getArrayValue(0)) / 255f;
    blueMax = int(theControlEvent.getController().getArrayValue(1)) / 255f;
    scheduleBufferUpdate = true;
  }
  if (theControlEvent.isFrom("GREEN Range")) {
    greenMin = int(theControlEvent.getController().getArrayValue(0)) / 255f;
    greenMax = int(theControlEvent.getController().getArrayValue(1)) / 255f;
    scheduleBufferUpdate = true;
  }
}


void drawGUI() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  if (drawGUI) {
    cp5.draw();
    cursor();
  } else {
    noCursor();
  }
  hint(ENABLE_DEPTH_TEST);
}