package com.example.antiscam_mobile

import android.app.Service
import android.app.usage.UsageStatsManager
import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.*
import android.view.animation.AnimationUtils
import android.widget.Button
import android.widget.ImageView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class FloatingBubbleService : Service() {

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var popupView: View? = null
    private var isPopupShowing = false
    private var isBubbleVisible = false
    private var bubbleParams: WindowManager.LayoutParams? = null
    private val handler = Handler(Looper.getMainLooper())
    private val checkInterval = 2000L // Check every 2 seconds
    
    // Optimization: Track last known state to avoid unnecessary checks
    private var lastKnownPackage: String? = null
    private var lastKnownProtectedApps: Set<String> = setOf()
    private var lastCheckTime: Long = 0
    
    // Debounce: Prevent rapid hide/show during multiple window events
    private var pendingCheckRunnable: Runnable? = null
    private val debounceDelay = 300L // 300ms debounce
    
    // Receiver for protected apps updates
    private val protectedAppsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == "com.example.antiscam_mobile.PROTECTED_APPS_UPDATED") {
                android.util.Log.d("FloatingBubble", "🔔 Protected apps updated via broadcast!")
                // Force immediate re-check
                lastKnownProtectedApps = setOf() // Reset cache to force update
                checkAndUpdateBubbleVisibilityDebounced()
            }
        }
    }

    override fun onCreate() {
        super.onCreate()

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        val inflater = LayoutInflater.from(this)
        bubbleView = inflater.inflate(R.layout.view_bubble, null)

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        bubbleParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        bubbleParams?.apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 200
        }

        bubbleView?.apply {
            setOnTouchListener(FloatingDragTouchListener(windowManager, this, bubbleParams!!))
            setOnClickListener {
                android.util.Log.d("FloatingBubble", "🟢 Bubble clicked!")
                
                // Animation click
                animateBubbleClick()
                
                // Trigger screen capture after animation
                Handler(Looper.getMainLooper()).postDelayed({
                    triggerScreenCapture()
                }, 200)
            }
        }

        // Register receiver for protected apps updates
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            registerReceiver(
                protectedAppsReceiver,
                IntentFilter("com.example.antiscam_mobile.PROTECTED_APPS_UPDATED"),
                Context.RECEIVER_EXPORTED
            )
        } else {
            registerReceiver(
                protectedAppsReceiver,
                IntentFilter("com.example.antiscam_mobile.PROTECTED_APPS_UPDATED")
            )
        }

        // Start monitoring foreground app
        startMonitoringForegroundApp()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopMonitoringForegroundApp()
        dismissPopup()
        hideBubble()
        bubbleView = null
        
        try {
            unregisterReceiver(protectedAppsReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
    }

    /**
     * Start monitoring foreground app
     * Uses AccessibilityService events for real-time detection instead of polling every 2 seconds
     * Falls back to periodic checks if AccessibilityService unavailable
     */
    private fun startMonitoringForegroundApp() {
        // Setup listener from AccessibilityService if available
        AppSwitchAccessibilityService.setOnPackageChangeListener {
            android.util.Log.d("FloatingBubble", "🔄 App changed (from AccessibilityService) → checking visibility")
            checkAndUpdateBubbleVisibilityDebounced()
        }
        
        // Fallback: Check every 5 seconds if AccessibilityService inactive
        handler.post(object : Runnable {
            override fun run() {
                val currentTime = System.currentTimeMillis()
                // Only check if more than 5 seconds since last check
                if (currentTime - lastCheckTime >= 5000) {
                    android.util.Log.d("FloatingBubble", "⏱️ Fallback check after 5 seconds")
                    checkAndUpdateBubbleVisibility()
                }
                handler.postDelayed(this, 5000)
            }
        })
    }

    /**
     * Stop monitoring
     */
    private fun stopMonitoringForegroundApp() {
        handler.removeCallbacksAndMessages(null)
        AppSwitchAccessibilityService.clearOnPackageChangeListener()
    }

    /**
     * Debounced version to avoid excessive checks during rapid window events
     */
    private fun checkAndUpdateBubbleVisibilityDebounced() {
        // Cancel pending check if exists
        pendingCheckRunnable?.let { handler.removeCallbacks(it) }
        
        // Schedule new check after debounce delay
        pendingCheckRunnable = Runnable {
            checkAndUpdateBubbleVisibility()
        }
        handler.postDelayed(pendingCheckRunnable!!, debounceDelay)
    }

    /**
     * Check and update bubble visibility
     * Skip if app and protected list unchanged
     */
    private fun checkAndUpdateBubbleVisibility() {
        Thread {
            try {
                lastCheckTime = System.currentTimeMillis()
                
                // Prioritize AccessibilityService for real-time accuracy
                val currentPackage = AppSwitchAccessibilityService.getCurrentPackage()
                    ?: getCurrentForegroundApp() // Fallback if AccessibilityService not active

                val protectedApps = getProtectedAppsFromStorage()

                // Skip if nothing changed
                if (currentPackage == lastKnownPackage && protectedApps == lastKnownProtectedApps) {
                    android.util.Log.d("FloatingBubble", "⏭️ No change detected, skipping update")
                    return@Thread
                }

                // Update cache
                lastKnownPackage = currentPackage
                lastKnownProtectedApps = protectedApps

                android.util.Log.d("FloatingBubble", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                android.util.Log.d("FloatingBubble", "🔍 Current app: $currentPackage")
                android.util.Log.d("FloatingBubble", "📋 Protected apps (${protectedApps.size}):")
                protectedApps.forEachIndexed { index, app ->
                    android.util.Log.d("FloatingBubble", "   ${index + 1}. $app")
                }

                if (currentPackage == null) {
                    android.util.Log.d("FloatingBubble", "⚠️ Current app is null → keeping current state")
                    return@Thread
                }

                // Only hide bubble when user actually opens Anti-Scam app
                // Don't hide for temporary overlays (bubble, dialog, notification)
                if (currentPackage == packageName) {
                    // Keep bubble visible if already showing (user might be interacting with bubble)
                    if (isBubbleVisible) {
                        android.util.Log.d("FloatingBubble", "🏠 Anti-Scam overlay detected but keeping bubble visible")
                        return@Thread
                    }
                    // Don't show bubble if not already visible
                    android.util.Log.d("FloatingBubble", "🏠 In Anti-Scam app → not showing bubble")
                    return@Thread
                }

                val shouldShow = protectedApps.isNotEmpty() && protectedApps.contains(currentPackage)

                if (protectedApps.isEmpty()) {
                    android.util.Log.d("FloatingBubble", "⚠️ Protected list is EMPTY → hiding bubble")
                } else if (shouldShow) {
                    android.util.Log.d("FloatingBubble", "✅ App in protected list → showing bubble")
                } else {
                    android.util.Log.d("FloatingBubble", "❌ App NOT in protected list → hiding bubble")
                }
                android.util.Log.d("FloatingBubble", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                Handler(Looper.getMainLooper()).post {
                    if (shouldShow) {
                        showBubble()
                    } else {
                        hideBubble()
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e("FloatingBubble", "❌ Error checking visibility: ${e.message}", e)
            }
        }.start()
    }

    /**
     * Show bubble
     */
    private fun showBubble() {
        if (isBubbleVisible) return
        
        try {
            bubbleView?.let {
                windowManager.addView(it, bubbleParams)
                isBubbleVisible = true
                android.util.Log.d("FloatingBubble", "✅ Bubble shown")
            }
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error showing bubble: ${e.message}", e)
        }
    }

    /**
     * Hide bubble
     */
    private fun hideBubble() {
        if (!isBubbleVisible) return
        
        try {
            bubbleView?.let {
                windowManager.removeView(it)
                isBubbleVisible = false
                android.util.Log.d("FloatingBubble", "🔒 Bubble hidden")
            }
            // Also dismiss popup if showing
            dismissPopup()
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error hiding bubble: ${e.message}", e)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    /**
     * Animation when bubble is clicked
     */
    private fun animateBubbleClick() {
        bubbleView?.findViewById<ImageView>(R.id.bubble_icon)?.apply {
            // Scale animation
            animate()
                .scaleX(0.85f)
                .scaleY(0.85f)
                .setDuration(100)
                .withEndAction {
                    animate()
                        .scaleX(1.1f)
                        .scaleY(1.1f)
                        .setDuration(100)
                        .withEndAction {
                            animate()
                                .scaleX(1f)
                                .scaleY(1f)
                                .setDuration(100)
                                .start()
                        }
                        .start()
                }
                .start()

            // Rotation animation
            animate()
                .rotation(rotation + 360f)
                .setDuration(300)
                .start()
        }
    }

    /**
     * Trigger screen capture directly
     */
    private fun triggerScreenCapture() {
        android.util.Log.d("FloatingBubble", "━━━━━━━━━━ CAPTURE TRIGGER DEBUG ━━━━━━━━━━")
        android.util.Log.d("FloatingBubble", "📸 Triggering screen capture...")

        // Check if MediaProjection is already active (can capture immediately)
        if (MediaProjectionHolder.isInitialized()) {
            android.util.Log.d("FloatingBubble", "✅ MediaProjection already active - capturing now!")
            startQuickCapture()
            return
        }

        // Need to get permission token
        val captureResult = ScreenCaptureHandler.getCaptureResult()

        if (captureResult == null) {
            android.util.Log.e("FloatingBubble", "❌ No screen capture permission")
            android.util.Log.e("FloatingBubble", "💡 Opening MainActivity to request permission...")
            android.util.Log.d("FloatingBubble", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

            // Open MainActivity with special intent to request permission
            val intent = Intent(this, MainActivity::class.java).apply {
                action = "REQUEST_SCREEN_CAPTURE"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            startActivity(intent)
            
            // Show toast
            android.os.Handler(android.os.Looper.getMainLooper()).post {
                android.widget.Toast.makeText(
                    this,
                    "Requesting screen capture permission...",
                    android.widget.Toast.LENGTH_SHORT
                ).show()
            }
            return
        }

        val (resultCode, resultData) = captureResult

        android.util.Log.d("FloatingBubble", "✅ Permission token found!")
        android.util.Log.d("FloatingBubble", "   resultCode: $resultCode")
        android.util.Log.d("FloatingBubble", "   resultData: ${resultData != null}")
        android.util.Log.d("FloatingBubble", "🚀 Starting capture service...")

        // Start foreground service (required for MediaProjection on Android 14+)
        // Service will auto-stop after capture (<300ms) to hide notification
        val intent = Intent(this, ScreenCaptureService::class.java).apply {
            action = ScreenCaptureService.ACTION_START_CAPTURE
            putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, resultCode)
            putExtra(ScreenCaptureService.EXTRA_RESULT_DATA, resultData)
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            android.util.Log.d("FloatingBubble", "✅ Screen capture service started successfully")
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Failed to start capture service: ${e.message}", e)
        }
        
        android.util.Log.d("FloatingBubble", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }

    /**
     * Quick capture using existing MediaProjection (no permission dialog)
     */
    private fun startQuickCapture() {
        android.util.Log.d("FloatingBubble", "⚡ Starting quick capture...")
        
        // Check if service is already running with initialized capture system
        if (!ScreenCaptureService.isRunning()) {
            android.util.Log.e("FloatingBubble", "❌ ScreenCaptureService not running - cannot quick capture")
            return
        }
        
        val intent = Intent(this, ScreenCaptureService::class.java).apply {
            action = ScreenCaptureService.ACTION_CAPTURE_NOW
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            android.util.Log.d("FloatingBubble", "✅ Quick capture requested")
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Quick capture failed: ${e.message}", e)
        }
    }
    
    private fun showScanPopup() {
        android.util.Log.d("FloatingBubble", "🔵 showScanPopup called, isPopupShowing: $isPopupShowing")
        
        if (isPopupShowing) {
            android.util.Log.d("FloatingBubble", "⚠️ Popup already showing, skipping")
            return
        }

        try {
            val inflater = LayoutInflater.from(this)
            popupView = inflater.inflate(R.layout.popup_scan_mockup, null)
            android.util.Log.d("FloatingBubble", "✅ Popup view inflated")

            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val params = WindowManager.LayoutParams(
                (resources.displayMetrics.widthPixels * 0.9).toInt(), // 90% screen width
                WindowManager.LayoutParams.WRAP_CONTENT,
                type,
                WindowManager.LayoutParams.FLAG_DIM_BEHIND,
                PixelFormat.TRANSLUCENT
            )

            params.gravity = Gravity.CENTER
            params.dimAmount = 0.6f // Dim background
            params.windowAnimations = android.R.style.Animation_Dialog

            // Setup button listeners
            popupView?.apply {
                // Make popup clickable and focusable
                isFocusable = true
                isClickable = true
                
                findViewById<ImageView>(R.id.btn_close)?.setOnClickListener {
                    dismissPopup()
                }

                findViewById<Button>(R.id.btn_cancel)?.setOnClickListener {
                    dismissPopup()
                }

                findViewById<Button>(R.id.btn_view_details)?.setOnClickListener {
                    dismissPopup()
                    // TODO: Open details in Flutter
                }

                // Set initial state before animation
                alpha = 0f
                translationY = 100f
            }

            windowManager.addView(popupView, params)
            isPopupShowing = true
            android.util.Log.d("FloatingBubble", "✅ Popup added to window manager")

            // Run animation
            popupView?.animate()
                ?.alpha(1f)
                ?.translationY(0f)
                ?.setDuration(300)
                ?.start()

            // Auto dismiss after 5 seconds (mockup behavior)
            Handler(Looper.getMainLooper()).postDelayed({
                android.util.Log.d("FloatingBubble", "⏰ Auto dismissing popup")
                dismissPopup()
            }, 5000)
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error showing popup: ${e.message}", e)
        }
    }

    /**
     * Close popup
     */
    private fun dismissPopup() {
        if (!isPopupShowing) return

        Handler(Looper.getMainLooper()).post {
            popupView?.animate()
                ?.alpha(0f)
                ?.translationY(100f)
                ?.setDuration(200)
                ?.withEndAction {
                    try {
                        popupView?.let { windowManager.removeView(it) }
                        popupView = null
                        isPopupShowing = false
                    } catch (e: Exception) {
                        // View already removed
                    }
                }
                ?.start()
        }
    }

    /**
     * Get protected apps from SharedPreferences
     * Android SharedPreferences only supports getStringSet, not getStringList
     */
    private fun getProtectedAppsFromStorage(): Set<String> {
        try {
            val prefs = getSharedPreferences("com.example.antiscam_mobile", Context.MODE_PRIVATE)
            
            // Android only supports StringSet (Flutter saves List, becomes Set via MethodChannel)
            val apps = prefs.getStringSet("protectedApps", null) ?: setOf()
            
            if (!apps.isNullOrEmpty()) {
                android.util.Log.d("FloatingBubble", "✅ Found protected apps (${apps.size}): $apps")
                return apps
            }
            
            android.util.Log.d("FloatingBubble", "⚠️ No protected apps in SharedPreferences")
            return setOf()
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error reading SharedPreferences: ${e.message}", e)
            return setOf()
        }
    }

    /**
     * Parse JSON array string like ["com.app1", "com.app2"]
     */
    private fun parseJsonArray(jsonStr: String): Set<String> {
        return try {
            jsonStr
                .removeSurrounding("[", "]")
                .split(",")
                .map { it.trim().removeSurrounding("\"") }
                .filter { it.isNotEmpty() }
                .toSet()
        } catch (e: Exception) {
            setOf()
        }
    }

    /**
     * Get package name of currently running app (top activity)
     * This is the app user sees on screen
     */
    private fun getCurrentForegroundApp(): String? {
        return try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
                ?: return null

            @Suppress("DEPRECATION")
            val runningTasks = activityManager.getRunningTasks(1)

            if (runningTasks.isNotEmpty()) {
                val topApp = runningTasks[0].topActivity?.packageName
                android.util.Log.d("FloatingBubble", "📱 Top Activity (app on screen): $topApp")
                return topApp
            }

            android.util.Log.d("FloatingBubble", "⚠️ Could not get top activity")
            null
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error getting top activity: ${e.message}")
            null
        }
    }

    private fun getAppFromUsageStats(): String? {
        return try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                return null
            }

            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return null

            val now = System.currentTimeMillis()
            val timeInterval = 1000 * 30 // 30 seconds

            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_BEST,
                now - timeInterval,
                now
            )

            // Find most recently used app (excluding Anti-Scam)
            val currentApp = stats
                .filter { it.packageName != packageName }
                .maxByOrNull { it.lastTimeUsed }
                ?.packageName

            android.util.Log.d("FloatingBubble", "📱 UsageStats app: $currentApp")
            return currentApp
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ UsageStatsManager error: ${e.message}")
            null
        }
    }
}
