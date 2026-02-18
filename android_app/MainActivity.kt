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

class MainActivity : AppCompatActivity() {

    private lateinit var sketch: MySketch

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val frame = FrameLayout(this).apply {
            id = CompatUtils.getUniqueViewId()
        }
        setContentView(frame, ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ))

        sketch = MySketch()

        sketch.setAndroidActivity(this)

        val fragment = PFragment(sketch)
        fragment.setView(frame, this)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK && data != null) {
            when (requestCode) {
                1001 -> { // SVG file selection
                    data.data?.let { uri ->
                        sketch.onFileSelected(uri)
                    }
                }
            }
        }
    }
}