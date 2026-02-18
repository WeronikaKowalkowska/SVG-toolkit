
class Button {
  int x, y, w, h;
  String label;

  boolean isToolActive = false;
  
  Button(int x_pos, int y_pos, int width, int height, String lbl) {
    x = x_pos;
    y = y_pos;
    w = width;
    h = height;
    label = lbl;
  }

  color c=#e9c2f2;
  
  boolean isSelected() {
    if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h) {
      if (mousePressed && (mouseButton == LEFT)) {
       c = color(255,0,0);
      
        return true;
      }
    }
    return false;
  }

void setToolActive(boolean active){
        this.isToolActive = active;
    }

  void setBtnColor(color new_c){

    c = new_c;
  }
  
  void display() {
if(isToolActive){
            fill(100, 200, 100); 
        } else if(mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h){
            fill(150); 
        } else {
            fill(200);
        }
        
        rect(x,y,w,h);
        fill(0);
        textAlign(CENTER, CENTER);
        text(label, x + w/2, y + h/2);
  }
}