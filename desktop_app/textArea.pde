class TextArea{
  int x, y, width, height;
  String text = "Set Text...";
  boolean isSelected = false;

  color c = palette[2];

  TextArea(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  void display() {
    fill(c);
    rect(x, y, width, height);
    fill(0);
    textAlign(CENTER, CENTER);
    text(text, x + width/2, y + height/2);
  }

  void setText(String newText) {

        this.text = newText;
        

    }


  boolean isMouseOver(int mx, int my) {
    return mx > x && mx < x + width && my > y && my < y + height;
  }

    void setActive(boolean active) {
        isSelected = active;
    }
}