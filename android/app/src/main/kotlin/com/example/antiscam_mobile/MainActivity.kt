package com.example.antiscam_mobile

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var screenCaptureHandler: ScreenCaptureHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Handler xin quyền MediaProjection
        screenCaptureHandler = ScreenCaptureHandler(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "screen_capture")
            .setMethodCallHandler(screenCaptureHandler!!)

        // Handler lấy danh sách app cài đặt
        // MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "installed_apps")
        //     .setMethodCallHandler(InstalledAppsHandler(this))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Gửi kết quả về cho handler
        screenCaptureHandler?.handleActivityResult(requestCode, resultCode, data)
    }
}
