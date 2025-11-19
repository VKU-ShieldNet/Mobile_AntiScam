package com.example.antiscam_mobile

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import android.content.Context
import android.content.BroadcastReceiver
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private var screenCaptureHandler: ScreenCaptureHandler? = null
    private val bubbleChannel = "anti_scam_bubble"
    private var screenshotEventSink: EventChannel.EventSink? = null
    private var isReceiverRegistered = false
    
    private val captureReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                "com.example.antiscam_mobile.TRIGGER_CAPTURE" -> {
                    android.util.Log.d("MainActivity", "🔔 Received TRIGGER_CAPTURE")
                    screenCaptureHandler?.onMethodCall(
                        io.flutter.plugin.common.MethodCall("captureScreenshot", null),
                        object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                android.util.Log.d("MainActivity", "✅ Capture triggered: $result")
                            }
                            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                                android.util.Log.e("MainActivity", "❌ Capture error: $errorMessage")
                            }
                            override fun notImplemented() {}
                        }
                    )
                }
                "com.example.antiscam_mobile.SCREENSHOT_CAPTURED" -> {
                    val filePath = intent.getStringExtra("file_path")
                    android.util.Log.d("MainActivity", "━━━━━━━━━━ BROADCAST RECEIVED ━━━━━━━━━━")
                    android.util.Log.d("MainActivity", "📸 Screenshot captured!")
                    android.util.Log.d("MainActivity", "   filePath: $filePath")
                    android.util.Log.d("MainActivity", "   eventSink: $screenshotEventSink")
                    
                    // Send to Flutter via EventChannel
                    if (screenshotEventSink != null && filePath != null) {
                        screenshotEventSink?.success(mapOf("file_path" to filePath))
                        android.util.Log.d("MainActivity", "✅ Sent to Flutter EventChannel")
                    } else {
                        android.util.Log.e("MainActivity", "❌ Cannot send: eventSink=$screenshotEventSink, filePath=$filePath")
                    }
                    android.util.Log.d("MainActivity", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                }
            }
        }
    }
    
    override fun onStart() {
        super.onStart()
        
        // Handle intent action for screen capture request from bubble
        if (intent?.action == "REQUEST_SCREEN_CAPTURE") {
            android.util.Log.d("MainActivity", "🔔 Received REQUEST_SCREEN_CAPTURE intent")
            screenCaptureHandler?.onMethodCall(
                io.flutter.plugin.common.MethodCall("requestProjection", null),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        android.util.Log.d("MainActivity", "✅ Permission request completed")
                    }
                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        android.util.Log.e("MainActivity", "❌ Permission error: $errorMessage")
                    }
                    override fun notImplemented() {}
                }
            )
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Only unregister when activity is destroyed (not when going to background)
        if (isReceiverRegistered) {
            try {
                unregisterReceiver(captureReceiver)
                isReceiverRegistered = false
                android.util.Log.d("MainActivity", "📡 Broadcast receiver unregistered")
            } catch (e: Exception) {
                android.util.Log.e("MainActivity", "Error unregistering receiver: ${e.message}")
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register broadcast receiver ONCE (persists even when app is in background)
        if (!isReceiverRegistered) {
            val filter = IntentFilter().apply {
                addAction("com.example.antiscam_mobile.TRIGGER_CAPTURE")
                addAction("com.example.antiscam_mobile.SCREENSHOT_CAPTURED")
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(captureReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(captureReceiver, filter)
            }
            isReceiverRegistered = true
            android.util.Log.d("MainActivity", "✅ Broadcast receiver registered")
        }

        // Setup EventChannel for screenshot events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.antiscam_mobile/screenshot_events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    screenshotEventSink = events
                    android.util.Log.d("MainActivity", "📡 EventChannel listener registered")
                }

                override fun onCancel(arguments: Any?) {
                    screenshotEventSink = null
                    android.util.Log.d("MainActivity", "📡 EventChannel listener cancelled")
                }
            })

        // Setup screen capture permission handler
        screenCaptureHandler = ScreenCaptureHandler(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "screen_capture")
            .setMethodCallHandler(screenCaptureHandler!!)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.antiscam_mobile/app_monitor")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setProtectedApps" -> {
                        val apps = call.argument<List<String>>("apps") ?: emptyList()
                        android.util.Log.d("MainActivity", "📥 Received protected apps from Flutter: $apps")
                        
                        val pref = getSharedPreferences("com.example.antiscam_mobile", MODE_PRIVATE)
                        pref.edit().putStringSet("protectedApps", apps.toSet()).apply()
                        
                        val intent = Intent("com.example.antiscam_mobile.PROTECTED_APPS_UPDATED")
                        intent.putStringArrayListExtra("apps", ArrayList(apps))
                        sendBroadcast(intent)
                        
                        android.util.Log.d("MainActivity", "✅ Saved protected apps to SharedPreferences: $apps")
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Bubble control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, bubbleChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasOverlayPermission" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "hasAccessibilityPermission" -> {
                        result.success(isAccessibilityServiceEnabled())
                    }
                    "requestOverlayPermission" -> {
                        requestOverlayPermission()
                        result.success(null)
                    }
                    "requestAccessibilityPermission" -> {
                        requestAccessibilityPermission()
                        result.success(null)
                    }
                    "startBubble" -> {
                        startBubbleService()
                        result.success(null)
                    }
                    "stopBubble" -> {
                        stopBubbleService()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestOverlayPermission() {
        if (!Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                startActivity(intent)
        }
    }

    private fun requestAccessibilityPermission() {
        // Open Accessibility Settings for user to enable our service
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityManager = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )

        // Debug logging for accessibility service detection
        android.util.Log.d("MainActivity", "========== ACCESSIBILITY CHECK ==========")
        android.util.Log.d("MainActivity", "Package name: $packageName")
        android.util.Log.d("MainActivity", "Enabled services raw: '$enabledServices'")

        if (enabledServices.isNullOrEmpty()) {
            android.util.Log.d("MainActivity", "❌ No accessibility services enabled")
            return false
        }

        // Check for our service in both possible naming formats
        val serviceName1 = "${packageName}/.AppSwitchAccessibilityService"
        val serviceName2 = "${packageName}/${packageName}.AppSwitchAccessibilityService"

        android.util.Log.d("MainActivity", "Looking for format 1: '$serviceName1'")
        android.util.Log.d("MainActivity", "Looking for format 2: '$serviceName2'")

        // Split and check each service
        val servicesList = enabledServices.split(":")
        servicesList.forEachIndexed { index, service ->
            android.util.Log.d("MainActivity", "Service [$index]: '$service'")
        }

        // Check if our service is in the enabled services list (support both formats)
        val isEnabled = servicesList.any {
            val trimmed = it.trim()
            val matches = trimmed == serviceName1 || trimmed == serviceName2
            if (matches) {
                android.util.Log.d("MainActivity", "✅ MATCH FOUND: '$trimmed'")
            }
            matches
        }

        android.util.Log.d("MainActivity", "Final result: $isEnabled")
        android.util.Log.d("MainActivity", "=========================================")
        return isEnabled
    }

    private fun startBubbleService() {
        if (Settings.canDrawOverlays(this)) {
            val intent = Intent(this, FloatingBubbleService::class.java)
            startService(intent)
        } else {
            requestOverlayPermission()
        }
    }

    private fun stopBubbleService() {
        val intent = Intent(this, FloatingBubbleService::class.java)
        stopService(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        android.util.Log.d("MainActivity", "━━━━━━━━━━ ACTIVITY RESULT DEBUG ━━━━━━━━━━")
        android.util.Log.d("MainActivity", "🔵 onActivityResult called")
        android.util.Log.d("MainActivity", "   requestCode: $requestCode")
        android.util.Log.d("MainActivity", "   resultCode: $resultCode")
        android.util.Log.d("MainActivity", "   data: $data")
        android.util.Log.d("MainActivity", "   screenCaptureHandler: $screenCaptureHandler")
        android.util.Log.d("MainActivity", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        // Forward result to screen capture handler
        screenCaptureHandler?.handleActivityResult(requestCode, resultCode, data)
    }
}
