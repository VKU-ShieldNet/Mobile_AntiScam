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

    // Optimization: Track last known state to avoid unnecessary checks
    private var lastKnownPackage: String? = null
    private var lastKnownProtectedApps: Set<String> = setOf()
    private var lastCheckTime: Long = 0
    private var lastAccessibilityEventTime: Long = 0

    // Debounce: Prevent rapid hide/show during multiple window events
    private var pendingCheckRunnable: Runnable? = null
    private val debounceDelay = 300L // 300ms debounce

    // Fallback check: Only if AccessibilityService not responding
    private var fallbackCheckRunnable: Runnable? = null
    private val FALLBACK_CHECK_INTERVAL = 30000L  // 30 seconds (reduced from 5s)
    private val ACCESSIBILITY_EVENT_TIMEOUT = 10000L  // If no event in 10s, enable fallback

    // Scan state: Prevent spam clicking
    private var isScanning = false

    // Managers for cleaner code organization
    private lateinit var notificationManager: ScanNotificationManager
    private lateinit var scanResultPopup: ScanResultPopup

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

    // Receiver for scan results
    private val scanResultReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == "com.example.antiscam_mobile.SHOW_SCAN_RESULT") {
                android.util.Log.d("FloatingBubble", "📥 Received scan result broadcast!")

                val isSafe = intent.getBooleanExtra("isSafe", false)
                val label = intent.getStringExtra("label") ?: ""
                val evidence = intent.getStringArrayListExtra("evidence") ?: arrayListOf()
                val recommendation = intent.getStringArrayListExtra("recommendation") ?: arrayListOf()

                android.util.Log.d("FloatingBubble", "📊 Result: isSafe=$isSafe, label=$label")

                // Unlock bubble for next scan
                isScanning = false
                android.util.Log.d("FloatingBubble", "🔓 Scan completed, bubble unlocked")

                // Dismiss scanning notification
                notificationManager.dismissScanningNotification()

                // Show popup with result
                scanResultPopup.show(isSafe, label, evidence, recommendation)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()

        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        // Initialize managers
        notificationManager = ScanNotificationManager(this)
        scanResultPopup = ScanResultPopup(this, windowManager)

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
            setOnTouchListener(FloatingDragTouchListener(
                context = this@FloatingBubbleService,
                windowManager = windowManager,
                view = this,
                params = bubbleParams!!,
                onDismiss = {
                    // Hide bubble when dismissed
                    hideBubble()
                }
            ))
            setOnClickListener {
                android.util.Log.d("FloatingBubble", "🟢 Bubble clicked!")

                // Prevent spam clicking
                if (isScanning) {
                    android.util.Log.d("FloatingBubble", "⚠️ Already scanning, ignoring click")
                    return@setOnClickListener
                }

                isScanning = true
                android.util.Log.d("FloatingBubble", "🔒 Scan started, bubble locked")

                // Animation click
                animateBubbleClick()

                // Show native notification
                notificationManager.showScanningNotification()

                // Request to scan text from current screen
                Handler(Looper.getMainLooper()).postDelayed({
                    requestTextScan()
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
            registerReceiver(
                scanResultReceiver,
                IntentFilter("com.example.antiscam_mobile.SHOW_SCAN_RESULT"),
                Context.RECEIVER_EXPORTED
            )
        } else {
            registerReceiver(
                protectedAppsReceiver,
                IntentFilter("com.example.antiscam_mobile.PROTECTED_APPS_UPDATED")
            )
            registerReceiver(
                scanResultReceiver,
                IntentFilter("com.example.antiscam_mobile.SHOW_SCAN_RESULT")
            )
        }

        // Start monitoring foreground app
        startMonitoringForegroundApp()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopMonitoringForegroundApp()
        scanResultPopup.dismiss()
        dismissPopup()
        hideBubble()
        bubbleView = null

        try {
            unregisterReceiver(protectedAppsReceiver)
            unregisterReceiver(scanResultReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
    }

    /**
     * Start monitoring foreground app
     * Primary: Uses AccessibilityService events for real-time detection
     * Fallback: Only check every 30s if AccessibilityService not responding
     */
    private fun startMonitoringForegroundApp() {
        // Setup listener from AccessibilityService - PRIMARY METHOD
        AppSwitchAccessibilityService.setOnPackageChangeListener {
            android.util.Log.d("FloatingBubble", "🔄 App changed (from AccessibilityService) → checking visibility")
            lastAccessibilityEventTime = System.currentTimeMillis()
            checkAndUpdateBubbleVisibilityDebounced()
        }

        // Fallback: Check every 30 seconds ONLY if AccessibilityService not responding
        // This reduces battery drain significantly
        fallbackCheckRunnable = object : Runnable {
            override fun run() {
                val timeSinceLastEvent = System.currentTimeMillis() - lastAccessibilityEventTime

                // If no AccessibilityEvent in 10 seconds, enable fallback checking
                if (timeSinceLastEvent > ACCESSIBILITY_EVENT_TIMEOUT) {
                    android.util.Log.d("FloatingBubble", "⚠️ No AccessibilityEvent for ${timeSinceLastEvent}ms, running fallback check")
                    checkAndUpdateBubbleVisibility()
                }

                // Re-schedule fallback check every 30 seconds
                handler.postDelayed(this, FALLBACK_CHECK_INTERVAL)
            }
        }
        fallbackCheckRunnable?.let { handler.postDelayed(it, FALLBACK_CHECK_INTERVAL) }

        android.util.Log.d("FloatingBubble", "✅ Monitoring started: Primary=AccessibilityEvent, Fallback=30s")
    }

    /**
     * Stop monitoring
     */
    private fun stopMonitoringForegroundApp() {
        handler.removeCallbacksAndMessages(null)
        fallbackCheckRunnable?.let { handler.removeCallbacks(it) }
        AppSwitchAccessibilityService.clearOnPackageChangeListener()
        android.util.Log.d("FloatingBubble", "🛑 Monitoring stopped")
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
     * Request AccessibilityService to scan text from current screen
     */
    private fun requestTextScan() {
        try {
            android.util.Log.d("FloatingBubble", "🔍 Requesting text scan from AccessibilityService...")

            if (AppSwitchAccessibilityService.getInstance() == null) {
                android.util.Log.w("FloatingBubble", "⚠️ AccessibilityService not available. Please enable it in settings.")
                return
            }

            // Request scan
            AppSwitchAccessibilityService.requestTextScan()
        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error requesting text scan: ${e.message}", e)
        }
    }

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
     * Show scan popup mockup
     */
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
