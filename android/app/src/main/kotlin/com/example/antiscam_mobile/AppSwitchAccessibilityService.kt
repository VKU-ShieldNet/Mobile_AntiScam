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
         * Real-time detection instead of polling every 2 seconds
         */
        fun setOnPackageChangeListener(listener: (String) -> Unit) {
            onPackageChangeListener = listener
        }

        fun clearOnPackageChangeListener() {
            onPackageChangeListener = null
        }
    }

    private var currentPackage: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        
        // Configure accessibility service
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
        }
        setServiceInfo(info)
        
        android.util.Log.d("AppSwitch", "✅ AccessibilityService CONNECTED - real-time app detection enabled!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            
            if (packageName.isNullOrEmpty()) return
            
            if (packageName.startsWith("com.android.systemui") ||
                packageName.startsWith("com.android.launcher") ||
                packageName.contains("notification")) {
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
}
