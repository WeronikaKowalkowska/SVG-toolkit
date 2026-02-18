class Handle {
  int x, y;
  int boxx, boxy;
  float stretch; 
  int size;
  int maxStretch;
  boolean over;
  boolean press;
  boolean locked = false;
  color currentColor = color(255, 0, 0); 
  
  Handle(int ix, int iy, int il, int is) {
    x = ix;
    y = iy;
    stretch = il/2;
    maxStretch = il;
    size = is;
    boxx = (int)(x + stretch - size/2);
    boxy = y - size/2;
  }
  
  void update() {
    if (press) {
      float newStretch = constrain(mouseX - x, 0, maxStretch);
      stretch = newStretch;
      boxx = (int)(x + stretch - size/2);
      updateColor();
    }
    
    boxx = (int)(x + stretch - size/2);
    boxy = y - size/2;
    
    over = overRect(x, y - size/2, maxStretch, size);
  }
  
  void pressEvent() {
    if (over && !locked) {
      press = true;
      locked = true;
    }
  }
  
  void releaseEvent() {
    press = false;
    locked = false;
  }
  
  void updateColor() {
    float hue = map(stretch, 0, maxStretch, 0, 360);
    
    colorMode(HSB, 360, 100, 100);
    currentColor = color(hue, 100, 100);
    colorMode(RGB, 255); 
  }
  
  color getColor() {
    return currentColor;
  }
  
  void display() {
    int currentMode = g.colorMode;
    float max1 = g.colorModeX;
    float max2 = g.colorModeY;
    float max3 = g.colorModeZ;
    
    colorMode(HSB, 360, 100, 100);
    
    noStroke();
    for (int i = 0; i < maxStretch; i++) {
      float hue = map(i, 0, maxStretch, 0, 360);
      fill(hue, 100, 100);
      rect(x + i, y - size/2, 1, size);
    }
    
    colorMode(currentMode, max1, max2, max3);
    
    stroke(100);
    noFill();
    rect(x, y - size/2, maxStretch, size);
    
    fill(currentColor);
    stroke(0);
    strokeWeight(2);
    ellipse(boxx + size/2, boxy + size/2, size, size);
    
    fill(currentColor);
    noStroke();
    rect(boxx + size/2 - 2, boxy + size/2 + 5, 4, 8);
  }
}

boolean overRect(int x, int y, int width, int height) {
  return (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height);
}