class Lyer {
    float x, y, w, h;
    String label;
    String type;
    boolean isActive;
    
    Lyer(float x, float y, float w, float h, String label, String type) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.label = label;
        this.type = type;
        this.isActive = false;
    }
    
    void display() {
        if(isActive) {
            fill(200, 200, 100);
        } else {
            fill(200);
        }
        rect(x, y, w, h);
        fill(0);
        textAlign(LEFT, CENTER);
        text(label, x + 5, y + h/2);
    }
    
    void setActive(boolean active) {
        this.isActive = active;
    }
    
    boolean isMouseOver(float mx, float my) {
        return mx >= x && mx <= x + w && my >= y && my <= y + h;
    }
}