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
 * Handler for requesting MediaProjection permission and capturing screen
 * Note: This is a MethodChannel handler, NOT a Service. Do not register in AndroidManifest.
 */
class ScreenCaptureHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private val REQUEST_MEDIA_PROJECTION = 1001
        
        // CRITICAL: These must be static/companion to persist across service calls
        private var captureResultCode: Int = -1
        private var captureResultData: Intent? = null
        
        fun getCaptureResult(): Pair<Int, Intent?>? {
            Log.d("ScreenCaptureHandler", "━━━━━━━━━━ GET PERMISSION DEBUG ━━━━━━━━━━")
            Log.d("ScreenCaptureHandler", "🔍 Current stored values:")
            Log.d("ScreenCaptureHandler", "   captureResultCode: $captureResultCode")
            Log.d("ScreenCaptureHandler", "   captureResultData: $captureResultData")
            Log.d("ScreenCaptureHandler", "   Activity.RESULT_OK value: ${Activity.RESULT_OK}")
            
            // Check if MediaProjection is already initialized
            if (MediaProjectionHolder.isInitialized()) {
                Log.d("ScreenCaptureHandler", "✅ MediaProjection already active - can capture without new token")
                return Pair(Activity.RESULT_OK, null) // Signal that projection is ready
            }
            
            // Check if we have valid permission token
            val isValid = captureResultCode == Activity.RESULT_OK && captureResultData != null
            Log.d("ScreenCaptureHandler", "   isValid: $isValid")
            
            val result = if (isValid) {
                Log.d("ScreenCaptureHandler", "✅ Returning valid permission token")
                Pair(captureResultCode, captureResultData)
            } else {
                Log.e("ScreenCaptureHandler", "❌ No valid capture permission!")
                Log.e("ScreenCaptureHandler", "   Need: resultCode=${Activity.RESULT_OK}, hasData=true")
                Log.e("ScreenCaptureHandler", "   Got: resultCode=$captureResultCode, hasData=${captureResultData != null}")
                null
            }
            
            // IMPORTANT: Only clear token after initializing MediaProjection
            // Don't clear here - let ScreenCaptureService clear after init
            
            return result
        }
        
        fun setCaptureResult(resultCode: Int, data: Intent?) {
            Log.d("ScreenCaptureHandler", "━━━━━━━━━━ SET PERMISSION DEBUG ━━━━━━━━━━")
            Log.d("ScreenCaptureHandler", "📝 setCaptureResult called with:")
            Log.d("ScreenCaptureHandler", "   resultCode: $resultCode")
            Log.d("ScreenCaptureHandler", "   Activity.RESULT_OK: ${Activity.RESULT_OK}")
            Log.d("ScreenCaptureHandler", "   resultCode == RESULT_OK: ${resultCode == Activity.RESULT_OK}")
            Log.d("ScreenCaptureHandler", "   data: $data")
            
            captureResultCode = resultCode
            captureResultData = data
            
            Log.i("ScreenCaptureHandler", "✅ Stored: resultCode=$captureResultCode, hasData=${captureResultData != null}")
            Log.w("ScreenCaptureHandler", "⚠️ Note: Token is single-use - will be cleared after first capture")
            Log.d("ScreenCaptureHandler", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
        
        fun hasPermission(): Boolean {
            return captureResultCode != -1 && captureResultData != null
        }
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("ScreenCaptureHandler", "🔵 onMethodCall: ${call.method}")
        when (call.method) {
            "requestProjection" -> {
                pendingResult = result
                requestScreenCapture()
            }
            "captureScreenshot" -> {
                Log.d("ScreenCaptureHandler", "📸 captureScreenshot called, hasPermission=${hasPermission()}")
                if (hasPermission()) {
                    startCaptureService()
                    result.success(true)
                } else {
                    Log.e("ScreenCaptureHandler", "❌ No capture permission granted yet")
                    result.error("NO_PERMISSION", "Screen capture permission not granted", null)
                }
            }
            "hasPermission" -> {
                val hasPerm = hasPermission()
                Log.d("ScreenCaptureHandler", "🔍 Checking permission: $hasPerm")
                result.success(hasPerm)
            }
            else -> result.notImplemented()
        }
    }
    
    private fun startCaptureService() {
        val captureResult = getCaptureResult()
        if (captureResult == null) {
            Log.e("ScreenCaptureHandler", "❌ Cannot start capture service - no permission")
            return
        }
        
        val (resultCode, resultData) = captureResult
        
        val intent = Intent(context, ScreenCaptureService::class.java).apply {
            action = ScreenCaptureService.ACTION_START_CAPTURE
            putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, resultCode)
            putExtra(ScreenCaptureService.EXTRA_RESULT_DATA, resultData)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
        
        Log.i("ScreenCaptureHandler", "🚀 Started capture service with resultCode=$resultCode")
    }

    private fun requestScreenCapture() {
        try {
            val mgr = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            val intent = mgr.createScreenCaptureIntent()

            // Cast context to Activity to start activity for result
            val activity = context as? Activity
            if (activity == null) {
                Log.e("ScreenCaptureHandler", "❌ Context is not an Activity")
                pendingResult?.success(false)
                return
            }
            activity.startActivityForResult(intent, REQUEST_MEDIA_PROJECTION)
        } catch (e: Exception) {
            Log.e("ScreenCaptureHandler", "❌ Error requesting screen capture: ${e.message}")
            pendingResult?.success(false)
        }
    }

    /**
     * Called from MainActivity.onActivityResult() to handle MediaProjection permission result
     */
    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        Log.d("ScreenCaptureHandler", "━━━━━━━━━━ ACTIVITY RESULT HANDLER ━━━━━━━━━━")
        Log.d("ScreenCaptureHandler", "🔵 handleActivityResult called")
        Log.d("ScreenCaptureHandler", "   requestCode: $requestCode")
        Log.d("ScreenCaptureHandler", "   REQUEST_MEDIA_PROJECTION: $REQUEST_MEDIA_PROJECTION")
        Log.d("ScreenCaptureHandler", "   Match: ${requestCode == REQUEST_MEDIA_PROJECTION}")
        Log.d("ScreenCaptureHandler", "   resultCode: $resultCode")
        Log.d("ScreenCaptureHandler", "   Activity.RESULT_OK: ${Activity.RESULT_OK}")
        Log.d("ScreenCaptureHandler", "   Match: ${resultCode == Activity.RESULT_OK}")
        Log.d("ScreenCaptureHandler", "   data: $data")
        
        if (requestCode == REQUEST_MEDIA_PROJECTION) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                Log.i("ScreenCaptureHandler", "✅ Screen capture permission GRANTED!")
                
                // CRITICAL: Store in companion object (static) so it persists
                setCaptureResult(resultCode, data)
                
                Log.i("ScreenCaptureHandler", "✅ Permission stored successfully")
                
                pendingResult?.success(true)
            } else {
                Log.e("ScreenCaptureHandler", "❌ Screen capture permission DENIED!")
                Log.e("ScreenCaptureHandler", "   Reason: resultCode=$resultCode (expected ${Activity.RESULT_OK}), hasData=${data != null}")
                setCaptureResult(-1, null)
                pendingResult?.success(false)
            }
            pendingResult = null
        } else {
            Log.w("ScreenCaptureHandler", "⚠️ requestCode mismatch - ignoring")
        }
        Log.d("ScreenCaptureHandler", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}
