class MyShape {
    String type;
    float x, y, w, h;
    color col;
    ArrayList<PVector> polygonPoints; 
    
    MyShape(String type, float x, float y, float w, float h, color col) {
        this.type = type;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.col = col;
        this.polygonPoints = null;
    }
    
    MyShape(String type, float x, float y, float w, float h, color col, ArrayList<PVector> points) {
        this.type = type;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.col = col;
        this.polygonPoints = new ArrayList<PVector>();
        for(PVector p : points){
            this.polygonPoints.add(new PVector(p.x, p.y));
        }
    }
    
    void display() {
        fill(col);
        noStroke();
        
        if(type.equals("rectangle")) {
            rect(x, y, w, h);
        } else if(type.equals("ellipse")) {
            ellipse(x + w/2, y + h/2, w, h);
        } else if(type.equals("line")) {
            stroke(col);
            strokeWeight(2);
            noFill();
            line(x, y, x + w, y + h);
        } else if(type.equals("polygon") && polygonPoints != null) {
            noFill();
            stroke(col);
            strokeWeight(2);
            beginShape();
            for(PVector point : polygonPoints){
                vertex(x + point.x, y + point.y);
            }
            endShape(CLOSE);
        }
    }
    
    boolean isPointInside(float px, float py) {
        if(type.equals("rectangle")) {
            return px >= x && px <= x + w && py >= y && py <= y + h;
        } else if(type.equals("ellipse")) {
            float centerX = x + w/2;
            float centerY = y + h/2;
            float radiusX = w/2;
            float radiusY = h/2;
            float normalizedX = (px - centerX) / radiusX;
            float normalizedY = (py - centerY) / radiusY;
            return (normalizedX * normalizedX + normalizedY * normalizedY <= 1);
        } else if(type.equals("line")) {
            float endX = x + w;
            float endY = y + h;
            
            float A = endY - y;
            float B = x - endX;
            float C = endX * y - x * endY;
            
            float distance = abs(A * px + B * py + C) / sqrt(A * A + B * B);
            
            float minX = min(x, endX) - 5;
            float maxX = max(x, endX) + 5;
            float minY = min(y, endY) - 5;
            float maxY = max(y, endY) + 5;
            
            return distance < 10 && px >= minX && px <= maxX && py >= minY && py <= maxY;
        } else if(type.equals("polygon") && polygonPoints != null) {
            boolean inside = false;
            
            for(int i = 0, j = polygonPoints.size() - 1; i < polygonPoints.size(); j = i++) {
                float viX = x + polygonPoints.get(i).x;
                float viY = y + polygonPoints.get(i).y;
                float vjX = x + polygonPoints.get(j).x;
                float vjY = y + polygonPoints.get(j).y;
                
                if(((viY > py) != (vjY > py)) &&
                   (px < (vjX - viX) * (py - viY) / (vjY - viY) + viX)) {
                    inside = !inside;
                }
            }
            return inside;
        }
        return false;
    }
}