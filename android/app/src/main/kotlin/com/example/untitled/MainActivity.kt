package com.example.untitled

import android.graphics.Color
import android.os.Bundle
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        window.decorView.apply {
            javaClass.declaredFields
                .firstOrNull { it.name == "mSemiTransparentBarColor" }
                ?.apply { isAccessible = true }
                ?.setInt(this, Color.TRANSPARENT)
        }
    }
}
