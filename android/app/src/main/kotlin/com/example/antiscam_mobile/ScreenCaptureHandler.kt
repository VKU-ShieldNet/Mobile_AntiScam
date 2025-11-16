package com.example.antiscam_mobile

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Handler xử lý xin quyền MediaProjection & chuyển sang service chụp
 */
class ScreenCaptureHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    private val REQUEST_MEDIA_PROJECTION = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestProjection" -> {
                pendingResult = result
                requestScreenCapture()
            }
            else -> result.notImplemented()
        }
    }

    private fun requestScreenCapture() {
        val mgr = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val intent = mgr.createScreenCaptureIntent()

        // Vì không thể startActivityForResult ngoài Activity context,
        // nên ta ép context về FlutterActivity
        val activity = context as? Activity ?: return
        activity.startActivityForResult(intent, REQUEST_MEDIA_PROJECTION)
    }

    /**
     * Gọi từ MainActivity.onActivityResult() để gửi kết quả về Flutter
     */
    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_MEDIA_PROJECTION) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                Log.i("ScreenCaptureHandler", "✅ Projection permission granted")

                val serviceIntent = Intent(context, ScreenCaptureHandler::class.java).apply {
                    putExtra("resultCode", resultCode)
                    putExtra("data", data)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    context.startForegroundService(serviceIntent)
                else
                    context.startService(serviceIntent)

                pendingResult?.success(true)
            } else {
                Log.e("ScreenCaptureHandler", "❌ Permission denied or null data")
                pendingResult?.success(false)
            }
        }
    }
}
