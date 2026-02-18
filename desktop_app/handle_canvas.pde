class Canvas{

    int posX, posY, sizeX, sizeY;
    color bgColor = (255);
    boolean isActive = false;

    Canvas(int posX, int posY, int sizeX, int sizeY){
        this.posX = posX;
        this.posY = posY;
        this.sizeX = sizeX;
        this.sizeY = sizeY;
    }

    void setSize(int newSizeX, int newSizeY){
    this.sizeX = newSizeX;
    this.sizeY = newSizeY;
    
    this.posX = (width - this.sizeX) / 2;
}

    void display(){
        fill(bgColor);
        rect(posX, posY, sizeX, sizeY);
    }
}