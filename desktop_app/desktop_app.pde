import processing.svg.*;
import java.util.ArrayList;

color[] palette = {
     #171717, //canvas background
    #3b4953, //separation background
    #90ab8b, //textArea background
};

int separation = 200, margin = 25, btnSizeX = 100, spacing = 15, btnSizeY = 50, lyerBoxX = 150, lyerBoxY = 600;

Canvas mainCanvas = new Canvas(0,separation,width,height-separation);

Button createFileBtn = new Button(margin,margin,btnSizeX,btnSizeY,"Create File");
TextArea inputSize = new TextArea(margin,margin+btnSizeY+spacing,btnSizeX,btnSizeY);
ArrayList<TextArea> textAreas = new ArrayList<TextArea>();
int createdSizeX, createdSizeY;

Button openFileBtn = new Button(margin+ btnSizeX+spacing,margin,btnSizeX,btnSizeY,"Open File");

String activeTool = "none"; // "none", "square", "circle", "line", "polygon"

Button squareToolBtn = new Button(margin + btnSizeX*2+2*spacing,margin,btnSizeX,btnSizeY,"Square");
Button circleToolBtn = new Button(margin + btnSizeX*3 + 3*spacing, margin, btnSizeX, btnSizeY, "Circle");
Button lineToolBtn = new Button(margin + btnSizeX*4 + 4*spacing, margin, btnSizeX, btnSizeY, "Line");
Button polygonToolBtn = new Button(margin + btnSizeX*5 + 5*spacing, margin, btnSizeX, btnSizeY, "Polygon");

boolean isMakingShape = false;
float shapeStartX, shapeStartY;
float shapeEndX, shapeEndY;

Button saveFileBtn = new Button(margin + btnSizeX*6 + 6*spacing, margin, btnSizeX, btnSizeY, "Save File");
String savingFilePath = "";

Handle colorHaldle = new Handle(margin + btnSizeX*7 + 7*spacing, margin + btnSizeY/2, 255, 30 );
color currentColor = color(255,0,0);

PrintWriter output;
PShape svgShape;
ArrayList<MyShape> addedShapes = new ArrayList<MyShape>();
ArrayList<Lyer> lyerBtns = new ArrayList<Lyer>();

boolean isDraggingShape = false;
int draggedShapeIndex = -1;
float dragOffsetX, dragOffsetY;
int activeLayerIndex = -1; 

float lineEndX, lineEndY;

ArrayList<PVector> polygonPoints = new ArrayList<PVector>();
boolean isDrawingPolygon = false;

void setup(){
  size(1920,1280);
    textAreas.add(inputSize);
    frameRate(60);
}

// void updateBackground(){
//     background(palette[0]);
    
//     fill(palette[1]);
//     rect(0,0,width,separation);

//     fill(palette[1]);
//     stroke(0);
//     strokeWeight(2);
//     rect( 0, separation, lyerBoxX, lyerBoxY);
    
//     noStroke();
//     fill(0);
//     text("Layers", width - lyerBoxX + 10, separation + 20);
    
//     for(int i = 0; i < lyerBtns.size(); i++){
       
//         if(i == activeLayerIndex) {
//             lyerBtns.get(i).setActive(true);
//         } else {
//             lyerBtns.get(i).setActive(false);
//         }
//         lyerBtns.get(i).display();
//     }

//     createFileBtn.display();

//     if(createFileBtn.isSelected()){
//         inputSize.setActive(true);
//     }
//     if(inputSize.isSelected){
//         inputSize.display();
//     } 
//     if(mainCanvas.isActive){
//         mainCanvas.display();
//     }
//     if (mainCanvas.isActive) {
//     mainCanvas.display();
    
//     if (svgShape != null) {
//       float availableWidth = width - lyerBoxX - 20;
//       float availableHeight = height - separation - 20;
      
//       float scale = min(
//         availableWidth / mainCanvas.sizeX,
//         availableHeight / mainCanvas.sizeY
//       );
      
//       scale = min(scale, 1.0); 
      
//       float scaledWidth = mainCanvas.sizeX * scale;
//       float scaledHeight = mainCanvas.sizeY * scale;
      
//       float x = lyerBoxX + (availableWidth - scaledWidth) / 2;
//       float y = separation + (availableHeight - scaledHeight) / 2;
      
//       pushMatrix();
      
//       translate(x, y);
//       scale(scale);
      
//       fill(255);
//       noStroke();
//       rect(0, 0, mainCanvas.sizeX, mainCanvas.sizeY);
      
//       if (svgShape != null) {
//         shape(svgShape, 0, 0, mainCanvas.sizeX, mainCanvas.sizeY);
//       }
      
//       for (MyShape shape : addedShapes) {
//         pushMatrix();
//         shape.display();
//         popMatrix();
//       }
      
//       popMatrix();
      
//       stroke(100);
//       noFill();
//       rect(x, y, scaledWidth, scaledHeight);
//     }
//   }
    
//     openFileBtn.display();

//     if(mainCanvas.isActive){
//         squareToolBtn.setToolActive(activeTool.equals("square"));
//         squareToolBtn.display();
//         circleToolBtn.setToolActive(activeTool.equals("circle"));
//         circleToolBtn.display();
//         lineToolBtn.setToolActive(activeTool.equals("line"));
//         lineToolBtn.display();
//         polygonToolBtn.setToolActive(activeTool.equals("polygon"));
//         polygonToolBtn.display();

//         saveFileBtn.display();

//         colorHaldle.update();
//         colorHaldle.display();
//     }
// }
void updateBackground(){
    background(palette[0]);
    
    fill(palette[1]);
    rect(0,0,width,separation);

    // Narysuj obszar warstw z tłem
    fill(palette[1]);
    stroke(0);
    strokeWeight(2);
    rect( 0, separation, lyerBoxX, lyerBoxY);
    
    noStroke();
    fill(0);
    text("Layers", width - lyerBoxX + 10, separation + 20);
    
    // Rysuj warstwy tylko w widocznym obszarze
    for(int i = 0; i < lyerBtns.size(); i++){
        // Podświetl aktywną warstwę
        if(i == activeLayerIndex) {
            lyerBtns.get(i).setActive(true);
        } else {
            lyerBtns.get(i).setActive(false);
        }
        lyerBtns.get(i).display();
    }

    createFileBtn.display();

    if(createFileBtn.isSelected()){
        inputSize.setActive(true);
    }
    if(inputSize.isSelected){
        inputSize.display();
    } 
    if(mainCanvas.isActive){
        mainCanvas.display();
    }
    if(mainCanvas.isActive){
        if(svgShape != null){
            // Oblicz skalę, aby zmieścić cały canvas w oknie (z marginesem)
            float availableWidth = width - lyerBoxX - 20;
            float availableHeight = height - separation - 20;
            
            float scale = min(
                availableWidth / mainCanvas.sizeX,
                availableHeight / mainCanvas.sizeY
            );
            
            // Ogranicz skalę do maksymalnie 1.0, aby nie powiększać ponad oryginalny rozmiar
            scale = min(scale, 1.0);
            
            float scaledWidth = mainCanvas.sizeX * scale;
            float scaledHeight = mainCanvas.sizeY * scale;
            
            // Wyśrodkuj skalowany podgląd
            float x = lyerBoxX + (availableWidth - scaledWidth) / 2;
            float y = separation + (availableHeight - scaledHeight) / 2;
            
            // Zapisz oryginalną transformację
            pushMatrix();
            
            // Przesuń i przeskaluj
            translate(x, y);
            scale(scale);
            
            // Narysuj tło dla podglądu
            fill(255);
            noStroke();
            rect(0, 0, mainCanvas.sizeX, mainCanvas.sizeY);
            
            // Narysuj SVG w oryginalnym rozmiarze (będzie przeskalowane przez scale())
            shape(svgShape, 0, 0, mainCanvas.sizeX, mainCanvas.sizeY);
            
            // Narysuj dodane kształty
            for (MyShape shape : addedShapes) {
                shape.display();
            }
            
            // Przywróć transformację
            popMatrix();
            
            // Narysuj obramowanie podglądu
            stroke(100);
            noFill();
            rect(x, y, scaledWidth, scaledHeight);
            
        } else {
            // Bez SVG, rysuj tylko kształty
            for (MyShape shape : addedShapes) {
                pushMatrix();
                translate(mainCanvas.posX, mainCanvas.posY);
                shape.display();
                popMatrix();
            }
        }
    }
    
    openFileBtn.display();

    if(mainCanvas.isActive){
        squareToolBtn.setToolActive(activeTool.equals("square"));
        squareToolBtn.display();
        circleToolBtn.setToolActive(activeTool.equals("circle"));
        circleToolBtn.display();
        lineToolBtn.setToolActive(activeTool.equals("line"));
        lineToolBtn.display();
        polygonToolBtn.setToolActive(activeTool.equals("polygon"));
        polygonToolBtn.display();

        saveFileBtn.display();

        colorHaldle.update();
        colorHaldle.display();
    }
}


void draw(){
    updateBackground();
    currentColor = colorHaldle.getColor();
    
    if(isMakingShape && activeTool.equals("square")){
        float constrainedMouseX = constrain(mouseX, mainCanvas.posX, mainCanvas.posX + mainCanvas.sizeX);
        float constrainedMouseY = constrain(mouseY, mainCanvas.posY, mainCanvas.posY + mainCanvas.sizeY);
        
        float rectX = min(shapeStartX, constrainedMouseX);
        float rectY = min(shapeStartY, constrainedMouseY);
        float rectWidth = abs(constrainedMouseX - shapeStartX);
        float rectHeight = abs(constrainedMouseY - shapeStartY);
        noFill();
        stroke(currentColor);
        strokeWeight(2);
        rect(rectX, rectY, rectWidth, rectHeight);
    }
    
    if(isMakingShape && activeTool.equals("circle")){
        float dx = mouseX - shapeStartX;
        float dy = mouseY - shapeStartY;
        float radius = sqrt(dx*dx + dy*dy);
        
        float maxRadiusX = min(
            shapeStartX - mainCanvas.posX,
            mainCanvas.posX + mainCanvas.sizeX - shapeStartX
        );
        
        float maxRadiusY = min(
            shapeStartY - mainCanvas.posY,
            mainCanvas.posY + mainCanvas.sizeY - shapeStartY
        );
        
        float maxRadius = min(maxRadiusX, maxRadiusY);
        if (radius > maxRadius) {
            radius = maxRadius;
        }
        
        float diameter = radius * 2;
        noFill();
        stroke(currentColor);
        strokeWeight(2);
        ellipse(shapeStartX, shapeStartY, diameter, diameter);
    }
    
    if(isMakingShape && activeTool.equals("line")){
        float constrainedMouseX = constrain(mouseX, mainCanvas.posX, mainCanvas.posX + mainCanvas.sizeX);
        float constrainedMouseY = constrain(mouseY, mainCanvas.posY, mainCanvas.posY + mainCanvas.sizeY);
        
        stroke(currentColor);
        strokeWeight(2);
        line(shapeStartX, shapeStartY, constrainedMouseX, constrainedMouseY);
    }
    
    if(isDrawingPolygon && polygonPoints.size() > 0){
        stroke(currentColor);
        strokeWeight(2);
        noFill();
        
        for(int i = 0; i < polygonPoints.size() - 1; i++){
            PVector p1 = polygonPoints.get(i);
            PVector p2 = polygonPoints.get(i + 1);
            line(p1.x, p1.y, p2.x, p2.y);
        }
        
        if(polygonPoints.size() > 0){
            PVector lastPoint = polygonPoints.get(polygonPoints.size() - 1);
            line(lastPoint.x, lastPoint.y, mouseX, mouseY);
        }
        
        fill(currentColor);
        noStroke();
        for(PVector point : polygonPoints){
            ellipse(point.x, point.y, 6, 6);
        }
    }
    
    if(isDraggingShape && draggedShapeIndex >= 0 && draggedShapeIndex < addedShapes.size()){
        MyShape draggedShape = addedShapes.get(draggedShapeIndex);
        float newX = mouseX - mainCanvas.posX - dragOffsetX;
        float newY = mouseY - mainCanvas.posY - dragOffsetY;
        
        newX = constrain(newX, 0, mainCanvas.sizeX - draggedShape.w);
        newY = constrain(newY, 0, mainCanvas.sizeY - draggedShape.h);
        
        pushMatrix();
        translate(mainCanvas.posX, mainCanvas.posY);
        fill(draggedShape.col, 150);
        noStroke();
        
        if(draggedShape.type.equals("rectangle")){
            rect(newX, newY, draggedShape.w, draggedShape.h);
        } else if(draggedShape.type.equals("ellipse")){
            ellipse(newX + draggedShape.w/2, newY + draggedShape.h/2, draggedShape.w, draggedShape.h);
        } else if(draggedShape.type.equals("line")){
            stroke(draggedShape.col, 150);
            strokeWeight(2);
            line(newX, newY, newX + draggedShape.w, newY + draggedShape.h);
        } else if(draggedShape.type.equals("polygon")){
            noFill();
            stroke(draggedShape.col, 150);
            strokeWeight(2);
            beginShape();
            for(PVector point : draggedShape.polygonPoints){
                vertex(newX + point.x, newY + point.y);
            }
            endShape(CLOSE);
        }
        popMatrix();
    }
}

void mousePressed(){
    if(mouseButton == RIGHT && activeTool.equals("polygon") && isDrawingPolygon && polygonPoints.size() >= 3){
        completePolygon();
        return;
    }
    
    if(mouseButton == LEFT){
        if(openFileBtn.isSelected()){
            openFile();
            mainCanvas.isActive = true;
            addedShapes.clear();
            lyerBtns.clear();
            polygonPoints.clear();
            isDrawingPolygon = false;
            if(svgShape != null){
                int maxWidth = width - 100;
                int maxHeight = height - separation - 100;
                
                float scale = min(
                    (float)maxWidth / svgShape.width,
                    (float)maxHeight / svgShape.height
                );
                
                int displayWidth = (int)(svgShape.width * scale);
                int displayHeight = (int)(svgShape.height * scale);
                
                mainCanvas.setSize(displayWidth, displayHeight);
            }
            else print("No SVG loaded");
        }

        if(saveFileBtn.isSelected()){
            saveCreatedFile();
        }

        if(squareToolBtn.isSelected()){
            println("Square tool selected");
            activeTool = "square";
            isDrawingPolygon = false;
            polygonPoints.clear();
            activeLayerIndex = -1; 
            isDraggingShape = false; 
            return;
        }
        
        if(circleToolBtn.isSelected()){
            activeTool = "circle";
            isDrawingPolygon = false;
            polygonPoints.clear();
            activeLayerIndex = -1; 
            isDraggingShape = false; 
            return;
        }
        
        if(lineToolBtn.isSelected()){
            println("Line tool selected");
            activeTool = "line";
            isDrawingPolygon = false;
            polygonPoints.clear();
            activeLayerIndex = -1; 
            isDraggingShape = false; 
            return;
        }
        
        if(polygonToolBtn.isSelected()){
            println("Polygon tool selected");
            activeTool = "polygon";
            isDrawingPolygon = false;
            polygonPoints.clear();
            activeLayerIndex = -1; 
            isDraggingShape = false; 
            return;
        }
        
        for(int i = 0; i < lyerBtns.size(); i++){
            if(lyerBtns.get(i).isMouseOver(mouseX, mouseY)){
                if(activeLayerIndex == i) {
                    activeLayerIndex = -1;
                    draggedShapeIndex = -1;
                } else {
                    activeLayerIndex = i;
                    draggedShapeIndex = i;
                }
                return;
            }
        }
        
        if(mainCanvas.isActive && mouseX >= mainCanvas.posX && mouseX <= mainCanvas.posX + mainCanvas.sizeX && mouseY >= mainCanvas.posY && mouseY <= mainCanvas.posY + mainCanvas.sizeY){
            
            if(activeLayerIndex >= 0 && activeLayerIndex < addedShapes.size()) {
                MyShape shape = addedShapes.get(activeLayerIndex);
                if(shape.isPointInside(mouseX - mainCanvas.posX, mouseY - mainCanvas.posY)) {
                    draggedShapeIndex = activeLayerIndex;
                    
                    float shapeScreenX = mainCanvas.posX + shape.x;
                    float shapeScreenY = mainCanvas.posY + shape.y;
                    
                    dragOffsetX = mouseX - shapeScreenX;
                    dragOffsetY = mouseY - shapeScreenY;
                    
                    isDraggingShape = true;
                    activeTool = "none";
                    return;
                } else {
                    return;
                }
            }
            
            if(activeTool.equals("square") || activeTool.equals("circle") || activeTool.equals("line")){
                isMakingShape = true;
                shapeStartX = mouseX;
                shapeStartY = mouseY;
            } 
            else if(activeTool.equals("polygon")){
                if(!isDrawingPolygon){
                    isDrawingPolygon = true;
                    polygonPoints.clear();
                }
                
                polygonPoints.add(new PVector(mouseX, mouseY));
            }
        }
        
        colorHaldle.pressEvent();
    }
}

void mouseDragged(){
    if(isDraggingShape && draggedShapeIndex >= 0 && draggedShapeIndex < addedShapes.size()){
        MyShape shape = addedShapes.get(draggedShapeIndex);
        
        float newX = mouseX - mainCanvas.posX - dragOffsetX;
        float newY = mouseY - mainCanvas.posY - dragOffsetY;
        
        if(shape.type.equals("rectangle")){
            newX = constrain(newX, 0, mainCanvas.sizeX - shape.w);
            newY = constrain(newY, 0, mainCanvas.sizeY - shape.h);
            shape.x = newX;
            shape.y = newY;
        } else if(shape.type.equals("ellipse")){
            float radiusX = shape.w/2;
            float radiusY = shape.h/2;
            newX = constrain(newX, radiusX, mainCanvas.sizeX - radiusX);
            newY = constrain(newY, radiusY, mainCanvas.sizeY - radiusY);
            shape.x = newX;
            shape.y = newY;
        } else if(shape.type.equals("line")){
            float endX = newX + shape.w;
            float endY = newY + shape.h;
            
            if(endX < 0 || endX > mainCanvas.sizeX || endY < 0 || endY > mainCanvas.sizeY ||
               newX < 0 || newX > mainCanvas.sizeX || newY < 0 || newY > mainCanvas.sizeY){
                float minX = min(newX, endX);
                float maxX = max(newX, endX);
                float minY = min(newY, endY);
                float maxY = max(newY, endY);
                
                float offsetX = 0, offsetY = 0;
                
                if(minX < 0) offsetX = -minX;
                else if(maxX > mainCanvas.sizeX) offsetX = mainCanvas.sizeX - maxX;
                
                if(minY < 0) offsetY = -minY;
                else if(maxY > mainCanvas.sizeY) offsetY = mainCanvas.sizeY - maxY;
                
                newX += offsetX;
                newY += offsetY;
            }
            
            shape.x = newX;
            shape.y = newY;
        } else if(shape.type.equals("polygon")){
            float minX = Float.MAX_VALUE, minY = Float.MAX_VALUE;
            float maxX = Float.MIN_VALUE, maxY = Float.MIN_VALUE;
            
            for(PVector point : shape.polygonPoints){
                float px = newX + point.x;
                float py = newY + point.y;
                minX = min(minX, px);
                minY = min(minY, py);
                maxX = max(maxX, px);
                maxY = max(maxY, py);
            }
            
            float width = maxX - minX;
            float height = maxY - minY;
            
            if(minX < 0) newX += -minX;
            else if(maxX > mainCanvas.sizeX) newX += mainCanvas.sizeX - maxX;
            
            if(minY < 0) newY += -minY;
            else if(maxY > mainCanvas.sizeY) newY += mainCanvas.sizeY - maxY;
            
            shape.x = newX;
            shape.y = newY;
        } else {
            shape.x = newX;
            shape.y = newY;
        }
    }
    
    colorHaldle.update();
}

void mouseReleased(){
    if(mouseButton == LEFT){
        if(isMakingShape){
            float constrainedMouseX = constrain(mouseX, mainCanvas.posX, mainCanvas.posX + mainCanvas.sizeX);
            float constrainedMouseY = constrain(mouseY, mainCanvas.posY, mainCanvas.posY + mainCanvas.sizeY);
            
            if(activeTool.equals("square")){
                float rectX = min(shapeStartX, constrainedMouseX);
                float rectY = min(shapeStartY, constrainedMouseY);
                float rectWidth = abs(constrainedMouseX - shapeStartX);
                float rectHeight = abs(constrainedMouseY - shapeStartY);
                
                if(rectWidth > 5 && rectHeight > 5){
                    float relativeRectX = rectX - mainCanvas.posX;
                    float relativeRectY = rectY - mainCanvas.posY;
                    color currentColor = colorHaldle.getColor();
                    
                    addedShapes.add(new MyShape("rectangle", relativeRectX, relativeRectY, 
                                                rectWidth, rectHeight, currentColor));
                    
                    int lyerY = separation + 30 + (lyerBtns.size() * 40);
                    lyerBtns.add(new Lyer(10, lyerY, lyerBoxX - 20, 30, 
                                          "rect " + (lyerBtns.size() + 1), "square"));
                }
            } 
            else if(activeTool.equals("circle")){
                float dx = constrainedMouseX - shapeStartX;
                float dy = constrainedMouseY - shapeStartY;
                float radius = sqrt(dx*dx + dy*dy);
                
                float maxRadiusX = min(
                    shapeStartX - mainCanvas.posX,
                    mainCanvas.posX + mainCanvas.sizeX - shapeStartX
                );
                
                float maxRadiusY = min(
                    shapeStartY - mainCanvas.posY,
                    mainCanvas.posY + mainCanvas.sizeY - shapeStartY
                );
                
                float maxRadius = min(maxRadiusX, maxRadiusY);
                if (radius > maxRadius) {
                    radius = maxRadius;
                }
                
                float diameter = radius * 2;

                if(diameter > 5){
                    float centerX = shapeStartX - mainCanvas.posX;
                    float centerY = shapeStartY - mainCanvas.posY;
                    
                    addedShapes.add(new MyShape("ellipse", centerX - diameter/2, centerY - diameter/2, 
                                                diameter, diameter, colorHaldle.getColor()));
                    int lyerY = separation + 30 + (lyerBtns.size() * 40);
                    lyerBtns.add(new Lyer( 10, lyerY, lyerBoxX - 20, 30, 
                                          "circle " + (lyerBtns.size() + 1), "circle"));
                }
            }
            else if(activeTool.equals("line")){
                float lineEndX = constrainedMouseX;
                float lineEndY = constrainedMouseY;
                
                float dx = lineEndX - shapeStartX;
                float dy = lineEndY - shapeStartY;
                float length = sqrt(dx*dx + dy*dy);
                
                if(length > 5){
                    float relativeStartX = shapeStartX - mainCanvas.posX;
                    float relativeStartY = shapeStartY - mainCanvas.posY;
                    float relativeEndX = lineEndX - mainCanvas.posX;
                    float relativeEndY = lineEndY - mainCanvas.posY;
                    
                    addedShapes.add(new MyShape("line", relativeStartX, relativeStartY,
                                                relativeEndX - relativeStartX, 
                                                relativeEndY - relativeStartY,
                                                colorHaldle.getColor()));
                    
                    int lyerY = separation + 30 + (lyerBtns.size() * 40);
                    lyerBtns.add(new Lyer(10, lyerY, lyerBoxX - 20, 30, 
                                          "line " + (lyerBtns.size() + 1), "line"));
                }
            }
            
            isMakingShape = false;
        }
        
        if(isDraggingShape){
            isDraggingShape = false;
        }
        
        colorHaldle.releaseEvent();
    }
}

void completePolygon(){
    if(polygonPoints.size() >= 3){
        ArrayList<PVector> relativePoints = new ArrayList<PVector>();
        for(PVector point : polygonPoints){
            relativePoints.add(new PVector(point.x - mainCanvas.posX, 
                                           point.y - mainCanvas.posY));
        }
        
        float minX = Float.MAX_VALUE, minY = Float.MAX_VALUE;
        float maxX = Float.MIN_VALUE, maxY = Float.MIN_VALUE;
        
        for(PVector point : relativePoints){
            minX = min(minX, point.x);
            minY = min(minY, point.y);
            maxX = max(maxX, point.x);
            maxY = max(maxY, point.y);
        }
        
        float width = maxX - minX;
        float height = maxY - minY;
        
        ArrayList<PVector> normalizedPoints = new ArrayList<PVector>();
        for(PVector point : relativePoints){
            normalizedPoints.add(new PVector(point.x - minX, point.y - minY));
        }
        
        addedShapes.add(new MyShape("polygon", minX, minY, width, height,
                                    colorHaldle.getColor(), normalizedPoints));
        
        int lyerY = separation + 30 + (lyerBtns.size() * 40);
        lyerBtns.add(new Lyer(10, lyerY, lyerBoxX - 20, 30, 
                              "polygon " + (lyerBtns.size() + 1), "polygon"));
        
        polygonPoints.clear();
        isDrawingPolygon = false;
        println("Polygon completed with " + normalizedPoints.size() + " points");
    }
}

void keyPressed(){
    if(inputSize.isMouseOver(mouseX, mouseY)){
        inputSize.setActive(true);
    }
    
    for(int i = 0; i < textAreas.size(); i++){
        if(textAreas.get(i).isSelected){
            if(key == BACKSPACE){
                if(textAreas.get(i).text.length() > 0){
                    textAreas.get(i).setText(textAreas.get(i).text.substring(0, textAreas.get(i).text.length() - 1));
                }
            } else if(key == ENTER || key == RETURN){
                createdSizeX = int(textAreas.get(i).text);
                print("Created Size: " + createdSizeX);
                textAreas.get(i).setActive(false);
                createFile();
                mainCanvas.setSize(createdSizeX, createdSizeX);
                mainCanvas.isActive = true;
            } else if(key != CODED){
                textAreas.get(i).setText(textAreas.get(i).text + key);
            }
        }
    }
    
    if(key == ' ') {
        if(activeTool.equals("polygon") && isDrawingPolygon){
            polygonPoints.clear();
            isDrawingPolygon = false;
        }
    } else if(key == ENTER || key == RETURN) {
        if(activeTool.equals("polygon") && isDrawingPolygon && polygonPoints.size() >= 3){
            completePolygon();
        }
    } else if(key == BACKSPACE) {
        if(activeTool.equals("polygon") && isDrawingPolygon && polygonPoints.size() > 0){
            polygonPoints.remove(polygonPoints.size() - 1);
            if(polygonPoints.size() == 0){
                isDrawingPolygon = false;
            }
        }
    }
}