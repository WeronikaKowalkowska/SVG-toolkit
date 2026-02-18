void createFile(){
  selectOutput("Select a file to create:", "fileCreated");
}


void saveCreatedFile(){
  if (savingFilePath.equals("")) {
    selectOutput("Select a file to save:", "fileSaved");
  } else {
    saveCanvasToSVG(savingFilePath);
  }
}

void fileSaved(File selection) {
  if (selection == null) {
    return;
  }
  savingFilePath = selection.getAbsolutePath();
  if (!savingFilePath.endsWith(".svg")) {
    savingFilePath += ".svg";
  }

  saveCanvasToSVG(savingFilePath);
}

void fileCreated(File selection){
  if (selection == null) {
  } else {
    savingFilePath = selection.getAbsolutePath();
    if (!savingFilePath.endsWith(".svg")) {
      savingFilePath += ".svg";
    }
  }
}

float originalSvgWidth = 0;
float originalSvgHeight = 0;

void fileOpened(File selection) {
  if (selection == null) {
    return;
  }
  
  String filePath = selection.getAbsolutePath();
  println("User selected " + filePath);
  
  if (filePath.endsWith(".svg")) {
    svgShape = loadShape(filePath);
    if (svgShape != null) {
      
      originalSvgWidth = svgShape.width;
      originalSvgHeight = svgShape.height;
      
      mainCanvas.setSize((int)originalSvgWidth, (int)originalSvgHeight);
      mainCanvas.isActive = true;
      
      savingFilePath = filePath;
      
      addedShapes.clear();
      lyerBtns.clear();
      
    } else {
      println("Failed to load SVG file.");
    }
  } else {
    println("Selected file is not .svg");
  }
}

void saveCanvasToSVG(String filePath) {
  if (filePath == null || filePath.equals("")) {
    println("No file path specified for saving.");
    return;
  }
  
  if (!mainCanvas.isActive) {
    println("No active canvas to save.");
    return;
  }
  
  println("Saving canvas to: " + filePath);
  
  try {
    PGraphicsSVG svg = (PGraphicsSVG) createGraphics(mainCanvas.sizeX, mainCanvas.sizeY, SVG, filePath);
    
    svg.beginDraw();
    
    svg.background(255);
    
    if (svgShape != null) {
      svg.shape(svgShape, 0, 0, mainCanvas.sizeX, mainCanvas.sizeY);
    }
    
    for (MyShape shape : addedShapes) {
      svg.fill(shape.col);
      svg.noStroke();
      
      if (shape.type.equals("rectangle")) {
        svg.rect(shape.x, shape.y, shape.w, shape.h);
      } else if (shape.type.equals("ellipse")) {
        svg.ellipse(shape.x + shape.w/2, shape.y + shape.h/2, shape.w, shape.h);
      } else if (shape.type.equals("line")) {
        svg.stroke(shape.col);
        svg.strokeWeight(2);
        svg.line(shape.x, shape.y, shape.x + shape.w, shape.y + shape.h);
      } else if (shape.type.equals("polygon")) {
        svg.beginShape();
        for (PVector point : shape.polygonPoints) {
          svg.vertex(shape.x + point.x, shape.y + point.y);
        }
        svg.endShape(CLOSE);
      }
    }
    
    svg.endDraw();
    svg.dispose();
    
    println("Canvas saved successfully to: " + filePath + " with size: " + mainCanvas.sizeX + "x" + mainCanvas.sizeY);
  } catch (Exception e) {
    println("Error saving SVG file: " + e.getMessage());
  }
}

void openFile(){
  selectInput("Select a file to open:", "fileOpened");
}

