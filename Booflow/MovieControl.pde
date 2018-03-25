void movieEvent(Movie m) {
  m.read();
  doUpdate = true;
}

void nextFrame() {
  int nextFrame = getFrame() + 1;
  setFrame(nextFrame);
}

int getFrame() {    
  return ceil(video.time() * video.frameRate) - 1;
}

void setFrame(int n) {
  video.play();
    
  // The duration of a single frame:
  float frameDuration = 1.0 / video.frameRate;
    
  // We videoe to the middle of the frame by adding 0.5:
  float where = (n + 0.5) * frameDuration; 
    
  // Taking into account border effects:
  float diff = video.duration() - where;
  if (diff < 0) {
    where += diff - 0.25 * frameDuration;
  }
    
  video.jump(where);
  video.pause();  
}  

int getLength() {
  return int(video.duration() * video.frameRate);
}
