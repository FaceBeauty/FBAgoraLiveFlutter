package com.toivan.mtcamera

import com.toivan.mtcamera.mt_plugin.view.MtCameraPlatformView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {


    //在此注册原生View
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val registrant = flutterEngine.platformViewsController.registry
        registrant.registerViewFactory("CameraView", MtCameraPlatformView(StandardMessageCodec.INSTANCE))
    }
}
