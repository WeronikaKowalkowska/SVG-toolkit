package com.example.processingandroidapp

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import com.example.android_app.MySketch
import processing.android.CompatUtils
import processing.android.PFragment
import processing.core.PApplet
import processing.core.PApplet.max
import processing.core.PApplet.min
import processing.core.PConstants
import processing.core.PVector

abstract class Shape {
    var strokeColor: Int = 0xFFFFFFFF.toInt()
    var fillColor: Int = 0xFFFF0000.toInt()
    var strokeWeight: Float = 3f
    var isSelected: Boolean = false
    abstract fun draw(p: PApplet)
    abstract fun contains(x: Float, y: Float): Boolean
    abstract fun move(dx: Float, dy: Float)
}

class Line(var start: PVector, var end: PVector) : Shape() {
    override fun draw(p: PApplet) {
        p.stroke(strokeColor)
        p.strokeWeight(strokeWeight)
        if (isSelected) {
            p.stroke(p.color(0, 255, 0))
            p.strokeWeight(strokeWeight + 2)
        }
        p.line(start.x, start.y, end.x, end.y)
    }

    override fun contains(x: Float, y: Float): Boolean {
        val d = distToSegment(PVector(x, y), start, end)
        return d < 20
    }

    override fun move(dx: Float, dy: Float) {
        start.add(dx, dy)
        end.add(dx, dy)
    }

    private fun distToSegment(p: PVector, v: PVector, w: PVector): Float {
        val l2 = v.dist(w) * v.dist(w)
        if (l2 == 0.0f) return p.dist(v)
        val t = max(0f, min(1f, PVector.sub(p, v).dot(PVector.sub(w, v)) / l2))
        val projection = PVector.add(v, PVector.sub(w, v).mult(t))
        return p.dist(projection)
    }
}

class Rectangle(var x: Float, var y: Float, var width: Float, var height: Float) : Shape() {
    override fun draw(p: PApplet) {
        p.stroke(strokeColor)
        p.strokeWeight(strokeWeight)
        p.fill(fillColor)
        if (isSelected) {
            p.stroke(p.color(0, 255, 0))
            p.strokeWeight(strokeWeight + 2)
        }
        p.rect(x, y, width, height)
    }

    override fun contains(px: Float, py: Float): Boolean {
        return px > x && px < x + width && py > y && py < y + height
    }

    override fun move(dx: Float, dy: Float) {
        x += dx
        y += dy
    }
}

class Ellipse(var x: Float, var y: Float, var width: Float, var height: Float) : Shape() {
    override fun draw(p: PApplet) {
        p.stroke(strokeColor)
        p.strokeWeight(strokeWeight)
        p.fill(fillColor)
        if (isSelected) {
            p.stroke(p.color(0, 255, 0))
            p.strokeWeight(strokeWeight + 2)
        }
        p.ellipse(x, y, width, height)
    }

    override fun contains(px: Float, py: Float): Boolean {
        val centerX = x
        val centerY = y
        val radiusX = width / 2
        val radiusY = height / 2
        val dx = px - centerX
        val dy = py - centerY
        return (dx * dx) / (radiusX * radiusX) + (dy * dy) / (radiusY * radiusY) <= 1
    }

    override fun move(dx: Float, dy: Float) {
        x += dx
        y += dy
    }
}

class Polygon(var vertices: MutableList<PVector>) : Shape() {
    override fun draw(p: PApplet) {
        p.stroke(strokeColor)
        p.strokeWeight(strokeWeight)
        p.fill(fillColor)
        if (isSelected) {
            p.stroke(p.color(0, 255, 0))
            p.strokeWeight(strokeWeight + 2)
        }
        p.beginShape()
        for (vertex in vertices) {
            p.vertex(vertex.x, vertex.y)
        }
        p.endShape(PConstants.CLOSE)
    }

    override fun contains(px: Float, py: Float): Boolean {
        var inside = false
        for (i in vertices.indices) {
            val j = if (i == 0) vertices.size - 1 else i - 1
            if (((vertices[i].y > py) != (vertices[j].y > py)) &&
                (px < (vertices[j].x - vertices[i].x) * (py - vertices[i].y) /
                        (vertices[j].y - vertices[i].y) + vertices[i].x)) {
                inside = !inside
            }
        }
        return inside
    }

    override fun move(dx: Float, dy: Float) {
        for (vertex in vertices) {
            vertex.add(dx, dy)
        }
    }
}

class Polyline(var vertices: MutableList<PVector>) : Shape() {
    override fun draw(p: PApplet) {
        p.stroke(strokeColor)
        p.strokeWeight(strokeWeight)
        p.noFill()
        if (isSelected) {
            p.stroke(p.color(0, 255, 0))
            p.strokeWeight(strokeWeight + 2)
        }
        p.beginShape()
        for (vertex in vertices) {
            p.vertex(vertex.x, vertex.y)
        }
        p.endShape()
    }

    override fun contains(px: Float, py: Float): Boolean {
        for (i in 0 until vertices.size - 1) {
            val start = vertices[i]
            val end = vertices[i + 1]
            val d = distToSegment(PVector(px, py), start, end)
            if (d < 20) return true
        }
        return false
    }

    override fun move(dx: Float, dy: Float) {
        for (vertex in vertices) {
            vertex.add(dx, dy)
        }
    }

    private fun distToSegment(p: PVector, v: PVector, w: PVector): Float {
        val l2 = v.dist(w) * v.dist(w)
        if (l2 == 0.0f) return p.dist(v)
        val t = max(0f, min(1f, PVector.sub(p, v).dot(PVector.sub(w, v)) / l2))
        val projection = PVector.add(v, PVector.sub(w, v).mult(t))
        return p.dist(projection)
    }
}