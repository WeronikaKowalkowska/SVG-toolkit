package com.example.android_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.*
import androidx.annotation.RequiresApi
import com.example.processingandroidapp.*
import processing.core.*
import java.io.*
import java.text.*
import java.util.*


class MySketch : PApplet() {

    private var androidActivity: Activity? = null

    fun setAndroidActivity(activity: Activity) {
        this.androidActivity = activity
    }

    private val points = mutableListOf<PVector>()
    private var currentColor = 0xFFFF0000.toInt()
    private var strokeWidth = 5f
    private var svgShape: PShape? = null
    private var loadedSVGPath: String? = null

    enum class DrawingMode {
        LINE, RECTANGLE, ELLIPSE, SELECT, DELETE, CURVE, SVG_LOAD, POLYGON
    }

    private val shapes = mutableListOf<Shape>()
    private var currentMode = DrawingMode.LINE
    private var selectedShape: Shape? = null
    private var isDrawing = false
    private var startPoint = PVector()
    private var endPoint = PVector()
    private var polygonPoints = mutableListOf<PVector>()

    private var fillEnabled = true
    private var curveFinished = false
    private var polygonFinished = false

    private val colorPalette = arrayOf(
        color(255, 0, 0),
        color(0, 255, 0),
        color(0, 0, 255),
        color(255, 255, 0),
        color(255, 0, 255),
        color(0, 255, 255),
        color(255, 255, 255),
        color(0, 0, 0)
    )

    private var currentStrokeColor = color(255)
    private var currentFillColor = color(255, 0, 0, 150)
    private var currentStrokeWeight = 3f
    private var showMessage = false
    private var messageText = ""
    private var messageTime: Int = 0
    private var messageColor = color(0, 255, 0)

    private val modeButtons = mutableListOf<Button>()
    private val colorButtons = mutableListOf<Button>()
    private val propertyButtons = mutableListOf<Button>()

    data class Button(val x: Float, val y: Float, val w: Float, val h: Float,
                      val label: String, val action: () -> Unit)

    override fun settings() {
        fullScreen()
    }

    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    override fun setup() {
        orientation(PConstants.LANDSCAPE)
        textSize(24f)
        setupUI()
       // showMessage("Aplikacja gotowa. Narysuj coś!", color(0, 255, 0))
    }

    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    private fun setupUI() {
        val buttonWidth = width / 10f
        val buttonHeight = 60f

        modeButtons.clear()

        modeButtons.add(Button(0f, 0f, buttonWidth, buttonHeight, "Linia") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.LINE
            clearSelection()
        })
        modeButtons.add(Button(buttonWidth, 0f, buttonWidth, buttonHeight, "Prostokąt") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.RECTANGLE
            clearSelection()
        })
        modeButtons.add(Button(buttonWidth * 2, 0f, buttonWidth, buttonHeight, "Elipsa") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.ELLIPSE
            clearSelection()
        })
        modeButtons.add(Button(buttonWidth * 3, 0f, buttonWidth, buttonHeight, "Wielokąt") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.POLYGON
            clearSelection()
            polygonPoints.clear()
            polygonFinished = false
        })
        modeButtons.add(Button(buttonWidth * 4, 0f, buttonWidth, buttonHeight, "Krzywa") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.CURVE
            clearSelection()
            curveFinished = false
        })
        modeButtons.add(Button(0f, buttonHeight + 10f, buttonWidth, buttonHeight, "Wybierz") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.SELECT
            clearSelection()
        })
        modeButtons.add(Button(buttonWidth, buttonHeight + 10f, buttonWidth, buttonHeight, "Usuń") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.DELETE
            clearSelection()
        })
        modeButtons.add(Button(buttonWidth * 2, buttonHeight + 10f, buttonWidth, buttonHeight, "Wczytaj SVG") {
            finishCurve()
            finishPolygon()
            currentMode = DrawingMode.SVG_LOAD
            clearSelection()
            openFilePicker()
        })

        colorButtons.clear()
        val colorButtonX = width - buttonWidth
        for (i in colorPalette.indices) {
            val yPos = buttonHeight * 3 + (i * buttonHeight)
            if (yPos < height - buttonHeight) {
                colorButtons.add(Button(colorButtonX, yPos.toFloat(), buttonWidth, buttonHeight, "") {
                    finishCurve()
                    finishPolygon()
                    if (selectedShape != null) {
                        selectedShape!!.strokeColor = colorPalette[i]
                        selectedShape!!.fillColor = color(
                            red(colorPalette[i]),
                            green(colorPalette[i]),
                            blue(colorPalette[i])
                        )
                    }
                    currentStrokeColor = colorPalette[i]
                    currentColor = colorPalette[i]
                    currentFillColor = color(
                        red(colorPalette[i]),
                        green(colorPalette[i]),
                        blue(colorPalette[i])
                    )
                })
            }
        }

        propertyButtons.clear()
        propertyButtons.add(Button(width - buttonWidth, buttonHeight * 2, buttonWidth, buttonHeight, "Grubość+") {
            finishCurve()
            finishPolygon()
            if (selectedShape != null) {
                selectedShape!!.strokeWeight += 1
            }
            currentStrokeWeight += 1
            strokeWidth += 1
        })
        propertyButtons.add(Button(width - buttonWidth, buttonHeight * 3, buttonWidth, buttonHeight, "Grubość-") {
            finishCurve()
            finishPolygon()
            if (selectedShape != null && selectedShape!!.strokeWeight > 1) {
                selectedShape!!.strokeWeight -= 1
            }
            if (currentStrokeWeight > 1) currentStrokeWeight -= 1
            if (strokeWidth > 1) strokeWidth -= 1
        })
        propertyButtons.add(Button(width - buttonWidth * 2, buttonHeight * 2, buttonWidth, buttonHeight, "Wypełnienie") {
            finishCurve()
            finishPolygon()
            fillEnabled = !fillEnabled
            if (selectedShape != null) {
                selectedShape!!.fillColor = if (fillEnabled)
                    color(red(currentStrokeColor), green(currentStrokeColor), blue(currentStrokeColor))
                else color(0, 0, 0, 0)
            }
            currentFillColor = if (fillEnabled)
                color(red(currentStrokeColor), green(currentStrokeColor), blue(currentStrokeColor))
            else color(0, 0, 0, 0)
           // showMessage(if (fillEnabled) "Wypełnienie włączone" else "Wypełnienie wyłączone",
                if (fillEnabled) color(0, 200, 0) else color(200, 0, 0)
        })
        propertyButtons.add(Button(width - buttonWidth * 2, buttonHeight * 3, buttonWidth, buttonHeight, "Cofnij") {
            finishCurve()
            finishPolygon()
            if (shapes.isNotEmpty()) {
                shapes.removeLast()
               // showMessage("Cofnięto ostatni kształt", color(255, 255, 0))
            }
        })
        propertyButtons.add(Button(width - buttonWidth * 2, buttonHeight * 4, buttonWidth, buttonHeight, "Wyczyść") {
            finishCurve()
            finishPolygon()
            shapes.clear()
            points.clear()
            polygonPoints.clear()
            selectedShape = null
            svgShape = null
           // showMessage("Wyczyszczono wszystko", color(255, 100, 100))
        })
        propertyButtons.add(Button(width - buttonWidth * 2, buttonHeight * 5, buttonWidth, buttonHeight, "Zapisz SVG") {
            finishCurve()
            finishPolygon()
            saveSVG()
        })

        propertyButtons.add(Button(width - buttonWidth * 2, buttonHeight * 7, buttonWidth, buttonHeight, "Zakończ krzywą") {
            finishCurve()
        })
        propertyButtons.add(Button(width - buttonWidth * 2, buttonHeight * 8, buttonWidth, buttonHeight, "Zakończ wielokąt") {
            finishPolygon()
        })
    }

    private fun finishCurve() {
        if (currentMode == DrawingMode.CURVE && points.size >= 2 && !curveFinished) {
            val polyline = Polyline(points.toMutableList())
            polyline.strokeColor = currentColor
            polyline.strokeWeight = strokeWidth
            shapes.add(polyline)
            points.clear()
            curveFinished = true
          //  showMessage("Zakończono rysowanie krzywej", color(0, 255, 255))
        }
    }

    private fun finishPolygon() {
        if (currentMode == DrawingMode.POLYGON && polygonPoints.size >= 3 && !polygonFinished) {
            val polygon = Polygon(polygonPoints.toMutableList())
            polygon.strokeColor = currentStrokeColor
            polygon.fillColor = currentFillColor
            polygon.strokeWeight = currentStrokeWeight
            shapes.add(polygon)
            polygonPoints.clear()
            polygonFinished = true
         //   showMessage("Zakończono rysowanie wielokąta", color(0, 255, 255))
        }
    }

    override fun draw() {
        background(23f, 23f, 23f)
        //drawGrid()

        if (svgShape != null) {
            pushMatrix()
            val svgWidth = svgShape!!.width * 0.8f
            val svgHeight = svgShape!!.height * 0.8f
            val x = (width - svgWidth) / 2
            val y = (height - svgHeight) / 2

            //fill(255f, 255f, 255f, 30f)
           // stroke(100f, 100f, 200f, 100f)
           // strokeWeight(1f)
           // rect(x - 10, y - 10, svgWidth + 20, svgHeight + 20, 10f)

            shape(svgShape, x, y, svgWidth, svgHeight)
            popMatrix()
        }

        for (shape in shapes) {
            shape.draw(this)
        }

        if (isDrawing) {
            stroke(currentStrokeColor)
            strokeWeight(currentStrokeWeight)
            if (fillEnabled && currentMode != DrawingMode.LINE) {
                fill(currentFillColor)
            } else {
                noFill()
            }

            when (currentMode) {
                DrawingMode.LINE -> {
                    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y)
                }
                DrawingMode.RECTANGLE -> {
                    rect(
                        min(startPoint.x, endPoint.x),
                        min(startPoint.y, endPoint.y),
                        abs(endPoint.x - startPoint.x),
                        abs(endPoint.y - startPoint.y)
                    )
                }
                DrawingMode.ELLIPSE -> {
                    ellipse(
                        (startPoint.x + endPoint.x) / 2,
                        (startPoint.y + endPoint.y) / 2,
                        abs(endPoint.x - startPoint.x),
                        abs(endPoint.y - startPoint.y)
                    )
                }
                else -> {}
            }
        }

        if (currentMode == DrawingMode.POLYGON && polygonPoints.isNotEmpty() && !polygonFinished) {
            stroke(currentStrokeColor)
            strokeWeight(currentStrokeWeight)
            if (fillEnabled) {
                fill(currentFillColor)
            } else {
                noFill()
            }

            beginShape()
            for (point in polygonPoints) {
                vertex(point.x, point.y)
            }
            if (polygonPoints.size > 2) {
                endShape(PConstants.CLOSE)
            } else {
                endShape()
            }

            fill(currentStrokeColor)
            noStroke()
            for (point in polygonPoints) {
                ellipse(point.x, point.y, 10f, 10f)
            }

            if (polygonPoints.size > 1) {
                stroke(currentStrokeColor)
                strokeWeight(1f)
                for (i in 0 until polygonPoints.size - 1) {
                    line(polygonPoints[i].x, polygonPoints[i].y,
                        polygonPoints[i + 1].x, polygonPoints[i + 1].y)
                }
            }
        }

        if (points.isNotEmpty() && !curveFinished) {
            stroke(currentColor)
            strokeWeight(strokeWidth)
            noFill()

            if (points.size > 1) {
                beginShape()
                for (point in points) {
                    vertex(point.x, point.y)
                }
                endShape()
            }

            fill(currentColor)
            noStroke()
            for (point in points) {
                ellipse(point.x, point.y, 10f, 10f)
            }
        }

        drawUI()

//        fill(255)
//        noStroke()
//        textAlign(PConstants.LEFT, PConstants.TOP)
//        text("Tryb: ${currentMode.name}", 20f, height - 180f)
//        text("Kształtów: ${shapes.size}", 20f, height - 150f)
//        if (currentMode == DrawingMode.POLYGON) {
//            text("Punkty wielokąta: ${polygonPoints.size}", 20f, height - 120f)
//            text("Stan: ${if (polygonFinished) "Zakończony" else "W trakcie"}", 20f, height - 90f)
//        } else if (currentMode == DrawingMode.CURVE) {
//            text("Punkty krzywej: ${points.size}", 20f, height - 120f)
//            text("Stan: ${if (curveFinished) "Zakończona" else "W trakcie"}", 20f, height - 90f)
//        }
//        if (selectedShape != null) {
//            text("Wybrano kształt", 20f, height - 60f)
//        }
//        if (loadedSVGPath != null) {
//            val fileName = File(loadedSVGPath!!).name
//            text("SVG: $fileName", 20f, height - 30f)
//        }
//        text("Wypełnienie: ${if (fillEnabled) "ON" else "OFF"}", 20f, height - 210f)

        if (showMessage) {
//            fill(messageColor)
//            textSize(28f)
//            textAlign(PConstants.CENTER, PConstants.CENTER)
//
//            fill(0f, 0f, 0f, 200f)
//            val textWidth = textWidth(messageText) + 40
//            rect(width/2 - textWidth/2, height/2f - 30f, textWidth, 60f, 15f)
//
//            fill(messageColor)
//            text(messageText, width / 2f, height / 2f)
//            textSize(24f)
//
//            if (millis() - messageTime > 3000) {
//                showMessage = false
//            }
        }
    }

//    private fun drawGrid() {
//        stroke(100f, 100f, 100f, 50f)
//        strokeWeight(1f)
//
//        for (x in 0..width step 50) {
//            line(x.toFloat(), 0f, x.toFloat(), height.toFloat())
//        }
//
//        for (y in 0..height step 50) {
//            line(0f, y.toFloat(), width.toFloat(), y.toFloat())
//        }
//    }

    private fun drawUI() {
        for (button in modeButtons) {
            val isActive = getModeFromLabel(button.label) == currentMode
            fill(if (isActive) color(144, 171, 139, 200) else color(23, 23, 23, 200))
            stroke(if (isActive) color(200, 220, 255) else color(150, 150, 150))
            strokeWeight(2f)
            rect(button.x, button.y, button.w, button.h, 0f)

            fill(if (isActive) 255 else 200)
            textAlign(PConstants.CENTER, PConstants.CENTER)
            textSize(18f)
            text(button.label, button.x + button.w / 2, button.y + button.h / 2)
            textSize(24f)
        }

        for (i in colorButtons.indices) {
            fill(colorPalette[i])
            stroke(if (colorPalette[i] == currentStrokeColor) color(255, 255, 0) else color(255))
            strokeWeight(if (colorPalette[i] == currentStrokeColor) 3f else 1f)
            rect(colorButtons[i].x, colorButtons[i].y, colorButtons[i].w, colorButtons[i].h, 0f)
        }

        for (button in propertyButtons) {
            fill(color(23, 23, 43, 200))
            stroke(200)
            strokeWeight(2f)
            rect(button.x, button.y, button.w, button.h, 0f)

            fill(255)
            textAlign(PConstants.CENTER, PConstants.CENTER)
            textSize(16f)
            text(button.label, button.x + button.w / 2, button.y + button.h / 2)
            textSize(24f)
        }
    }

    private fun saveSVG(): File? {
        try {
            val svg = StringBuilder()
            svg.append("""<?xml version="1.0" encoding="UTF-8"?>""")
            svg.append("""<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">""")
            svg.append("""<rect width="100%" height="100%" fill="#282834"/>""")

            for (shape in shapes) {
                when (shape) {
                    is Line -> {
                        val strokeColor = colorToString(shape.strokeColor)
                        svg.append("""<line x1="${shape.start.x}" y1="${shape.start.y}" x2="${shape.end.x}" y2="${shape.end.y}" stroke="$strokeColor" stroke-width="${shape.strokeWeight}"/>""")
                    }
                    is Rectangle -> {
                        val strokeColor = colorToString(shape.strokeColor)
                        val fillColor = colorToString(shape.fillColor)
                        svg.append("""<rect x="${shape.x}" y="${shape.y}" width="${shape.width}" height="${shape.height}" stroke="$strokeColor" fill="$fillColor" stroke-width="${shape.strokeWeight}"/>""")
                    }
                    is Ellipse -> {
                        val strokeColor = colorToString(shape.strokeColor)
                        val fillColor = colorToString(shape.fillColor)
                        val cx = shape.x
                        val cy = shape.y
                        val rx = shape.width / 2
                        val ry = shape.height / 2
                        svg.append("""<ellipse cx="$cx" cy="$cy" rx="$rx" ry="$ry" stroke="$strokeColor" fill="$fillColor" stroke-width="${shape.strokeWeight}"/>""")
                    }
                    is Polygon -> {
                        val strokeColor = colorToString(shape.strokeColor)
                        val fillColor = colorToString(shape.fillColor)
                        svg.append("""<polygon points=""""")
                        for (vertex in shape.vertices) {
                            svg.append("${vertex.x},${vertex.y} ")
                        }
                        svg.append("""" stroke="$strokeColor" fill="$fillColor" stroke-width="${shape.strokeWeight}"/>""")
                    }
                    is Polyline -> {
                        val strokeColor = colorToString(shape.strokeColor)
                        svg.append("""<polyline points=""""")
                        for (vertex in shape.vertices) {
                            svg.append("${vertex.x},${vertex.y} ")
                        }
                        svg.append("""" stroke="$strokeColor" stroke-width="${shape.strokeWeight}" fill="none"/>""")
                    }
                }
            }

            svg.append("</svg>")

            val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val fileName = "drawing_$timestamp.svg"
            val svgContent = svg.toString()

            saveStrings(fileName, arrayOf(svgContent))

            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )
            val externalFile = File(downloadsDir, fileName)
            FileOutputStream(externalFile).use { fos ->
                fos.write(svgContent.toByteArray())
            }

           //showMessage("Zapisano SVG: $fileName", color(0, 255, 0))
            //println("SVG saved to: ${externalFile.absolutePath}")

            return externalFile

        } catch (e: Exception) {
            showMessage("Błąd zapisu SVG: ${e.message}", color(255, 0, 0))
            //println("Błąd podczas zapisu SVG: ${e.message}")
            return null
        }
    }

//    private fun shareSVG() {
//        val file = saveSVG()
//        if (file != null && androidActivity != null) {
//            val uri = Uri.fromFile(file)
//            val shareIntent = Intent().apply {
//                action = Intent.ACTION_SEND
//                putExtra(Intent.EXTRA_STREAM, uri)
//                type = "image/svg+xml"
//                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
//            }
//
//            androidActivity!!.startActivity(
//                Intent.createChooser(shareIntent, "Udostępnij plik SVG")
//            )
//        }
//    }

    private fun openFilePicker() {
        androidActivity?.let { activity ->
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/svg+xml"
                addCategory(Intent.CATEGORY_OPENABLE)
            }

            try {
                activity.startActivityForResult(
                    Intent.createChooser(intent, "Wybierz plik SVG"),
                    1001
                )
            } catch (e: Exception) {
                showMessage("Brak aplikacji do wyboru plików", color(255, 0, 0))
            }
        } ?: run {
            showMessage("Brak dostępu do Activity", color(255, 0, 0))
        }
    }

    fun onFileSelected(uri: Uri) {
        try {
            val inputStream = androidActivity?.contentResolver?.openInputStream(uri)
            val file = File.createTempFile("temp_svg", ".svg")
            inputStream?.use { input ->
                file.outputStream().use { output ->
                    input.copyTo(output)
                }
            }

            svgShape = loadShape(file.absolutePath)
            loadedSVGPath = file.absolutePath
            //showMessage("Wczytano plik SVG", color(0, 255, 255))

        } catch (e: Exception) {
            showMessage("Błąd wczytywania SVG: ${e.message}", color(255, 0, 0))
        }
    }

    private fun colorToString(color: Int): String {
        val r = red(color)
        val g = green(color)
        val b = blue(color)
        val a = alpha(color)

        return if (a < 255) {
            "rgba($r,$g,$b,${a/255f})"
        } else {
            "rgb($r,$g,$b)"
        }
    }

    private fun showMessage(text: String, color: Int = color(0, 255, 0)) {
        messageText = text
        messageColor = color
        showMessage = true
        messageTime = millis()
    }

    override fun mousePressed() {
        for (button in modeButtons) {
            if (mouseX.toFloat() in button.x..(button.x + button.w) &&
                mouseY.toFloat() in button.y..(button.y + button.h)) {
                button.action()
                return
            }
        }

        for (button in colorButtons) {
            if (mouseX.toFloat() in button.x..(button.x + button.w) &&
                mouseY.toFloat() in button.y..(button.y + button.h)) {
                button.action()
                return
            }
        }

        for (button in propertyButtons) {
            if (mouseX.toFloat() in button.x..(button.x + button.w) &&
                mouseY.toFloat() in button.y..(button.y + button.h)) {
                button.action()
                return
            }
        }

        when (currentMode) {
            DrawingMode.SELECT -> {
                clearSelection()
                for (shape in shapes.reversed()) {
                    if (shape.contains(mouseX.toFloat(), mouseY.toFloat())) {
                        shape.isSelected = true
                        selectedShape = shape
                        break
                    }
                }
            }
            DrawingMode.DELETE -> {
                val iterator = shapes.iterator()
                while (iterator.hasNext()) {
                    val shape = iterator.next()
                    if (shape.contains(mouseX.toFloat(), mouseY.toFloat())) {
                        iterator.remove()
                        if (selectedShape == shape) selectedShape = null
                        //showMessage("Usunięto kształt", color(255, 100, 100))
                        break
                    }
                }
            }
            DrawingMode.CURVE -> {
                if (!curveFinished) {
                    points.add(PVector(mouseX.toFloat(), mouseY.toFloat()))
                }
            }
            DrawingMode.POLYGON -> {
                if (!polygonFinished) {
                    polygonPoints.add(PVector(mouseX.toFloat(), mouseY.toFloat()))
                    //showMessage("Dodano punkt. Kliknij przycisk 'Zakończ wielokąt' aby zakończyć", color(200, 200, 0))
                }
            }
            DrawingMode.SVG_LOAD -> {
            }
            else -> {
                isDrawing = true
                startPoint = PVector(mouseX.toFloat(), mouseY.toFloat())
                endPoint = startPoint.copy()
            }
        }
    }

    override fun mouseDragged() {
        if (isDrawing) {
            endPoint = PVector(mouseX.toFloat(), mouseY.toFloat())
        } else if (currentMode == DrawingMode.SELECT && selectedShape != null) {
            selectedShape!!.move(mouseX - pmouseX.toFloat(), mouseY - pmouseY.toFloat())
        } else if (currentMode == DrawingMode.CURVE && !curveFinished) {
            points.add(PVector(mouseX.toFloat(), mouseY.toFloat()))
        }
    }

    override fun mouseReleased() {
        if (isDrawing && startPoint.dist(endPoint) > 5) {
            val newShape = when (currentMode) {
                DrawingMode.LINE -> {
                    Line(startPoint.copy(), endPoint.copy()).apply {
                        strokeColor = currentStrokeColor
                        strokeWeight = currentStrokeWeight
                    }
                }
                DrawingMode.RECTANGLE -> {
                    val x = min(startPoint.x, endPoint.x)
                    val y = min(startPoint.y, endPoint.y)
                    val w = abs(endPoint.x - startPoint.x)
                    val h = abs(endPoint.y - startPoint.y)
                    Rectangle(x, y, w, h).apply {
                        strokeColor = currentStrokeColor
                        fillColor = currentFillColor
                        strokeWeight = currentStrokeWeight
                    }
                }
                DrawingMode.ELLIPSE -> {
                    val centerX = (startPoint.x + endPoint.x) / 2
                    val centerY = (startPoint.y + endPoint.y) / 2
                    val w = abs(endPoint.x - startPoint.x)
                    val h = abs(endPoint.y - startPoint.y)
                    Ellipse(centerX, centerY, w, h).apply {
                        strokeColor = currentStrokeColor
                        fillColor = currentFillColor
                        strokeWeight = currentStrokeWeight
                    }
                }
                else -> null
            }

            newShape?.let {
                shapes.add(it)
                clearSelection()
                it.isSelected = true
                selectedShape = it
            }
        }
        isDrawing = false
    }

    private fun clearSelection() {
        shapes.forEach { it.isSelected = false }
        selectedShape = null
    }

    private fun getModeFromLabel(label: String): DrawingMode? {
        return when (label) {
            "Linia" -> DrawingMode.LINE
            "Prostokąt" -> DrawingMode.RECTANGLE
            "Elipsa" -> DrawingMode.ELLIPSE
            "Wielokąt" -> DrawingMode.POLYGON
            "Wybierz" -> DrawingMode.SELECT
            "Usuń" -> DrawingMode.DELETE
            "Krzywa" -> DrawingMode.CURVE
            "Wczytaj SVG" -> DrawingMode.SVG_LOAD
            else -> null
        }
    }
}