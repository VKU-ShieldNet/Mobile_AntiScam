package com.example.antiscam_mobile

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppSwitchAccessibilityService : AccessibilityService() {

    companion object {
        private var instance: AppSwitchAccessibilityService? = null
        private var onPackageChangeListener: ((String) -> Unit)? = null

        fun getInstance(): AppSwitchAccessibilityService? = instance

        fun getCurrentPackage(): String? {
            return instance?.currentPackage
        }

        /**
         * Register listener for app change notifications
         */
        fun setOnPackageChangeListener(listener: (String) -> Unit) {
            onPackageChangeListener = listener
        }

        fun clearOnPackageChangeListener() {
            onPackageChangeListener = null
        }

        /**
         * Request to scan text from current screen
         */
        fun requestTextScan() {
            android.util.Log.d("AppSwitch", "📝 Text scan requested")
            instance?.scanScreenText()
        }
    }

    private var currentPackage: String? = null
    private lateinit var textScanner: ScreenTextScanner

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        textScanner = ScreenTextScanner(this)
        
        // Configure accessibility service
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or 
                        AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                   AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                   AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            notificationTimeout = 100
        }
        setServiceInfo(info)
        
        android.util.Log.d("AppSwitch", "✅ AccessibilityService CONNECTED - ready for app detection & text scanning!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            
            if (packageName.isNullOrEmpty()) return
            
            // Filter out system packages and temporary overlays
            if (isSystemOrTemporaryPackage(packageName)) {
                android.util.Log.v("AppSwitch", "🔇 Ignoring system/temporary package: $packageName")
                return
            }
            
            // Only update for different app (not temporary events)
            if (packageName != currentPackage) {
                android.util.Log.d("AppSwitch", "🔄 App switched to: $packageName")
                currentPackage = packageName
                
                // Notify listener immediately (real-time)
                onPackageChangeListener?.invoke(packageName)
                
                // Fallback: broadcast for backwards compatibility
                notifyAppSwitch(packageName)
            }
        }
    }

    /**
     * Check if package is a system package or temporary overlay
     * These should not trigger bubble hide
     */
    private fun isSystemOrTemporaryPackage(packageName: String): Boolean {
        // System UI packages
        if (packageName.startsWith("com.android.systemui")) return true
        if (packageName.startsWith("com.android.launcher")) return true
        if (packageName.startsWith("com.android.keyguard")) return true  // Lock screen
        
        // Input methods (keyboard)
        if (packageName.startsWith("com.android.inputmethod")) return true
        if (packageName.contains("keyboard")) return true
        if (packageName == "com.google.android.inputmethod.latin") return true
        if (packageName == "com.sec.android.inputmethod") return true  // Samsung keyboard
        
        // Notifications and system overlays
        if (packageName.contains("notification")) return true
        if (packageName.startsWith("android")) return true
        if (packageName == "com.android.systemui") return true
        if (packageName == "com.android.settings") return true
        
        // Recent apps, screenshot overlay, etc.
        if (packageName.contains("recents")) return true
        if (packageName.contains("screenshot")) return true
        if (packageName.contains("quicksettings")) return true
        
        return false
    }

    override fun onInterrupt() {
        android.util.Log.d("AppSwitch", "⚠️ AccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        android.util.Log.d("AppSwitch", "❌ AccessibilityService destroyed")
    }

    /**
     * Notify FloatingBubbleService about app switch
     */
    private fun notifyAppSwitch(packageName: String) {
        try {
            val intent = Intent("com.example.antiscam_mobile.APP_SWITCHED")
            intent.setPackage(packageName(this))
            intent.putExtra("package", packageName)
            sendBroadcast(intent)
        } catch (e: Exception) {
            android.util.Log.e("AppSwitch", "❌ Error notifying app switch: ${e.message}")
        }
    }

    private fun packageName(context: android.content.Context): String {
        return context.packageName
    }

    /**
     * Request AccessibilityService to scan text from current screen
     */
    private fun scanScreenText() {
        try {
            android.util.Log.d("AppSwitch", "🔍 Requesting text scan...")
            textScanner.scanScreenText()
        } catch (e: Exception) {
            android.util.Log.e("AppSwitch", "❌ Error scanning text: ${e.message}", e)
        }
    }
}
