package com.example.veegify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.posternova/ExoPlayerView",
            ExoPlayerViewFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}