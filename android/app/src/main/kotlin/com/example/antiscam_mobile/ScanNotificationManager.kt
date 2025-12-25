package com.example.antiscam_mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

/**
 * Manager for scan-related notifications
 */
class ScanNotificationManager(private val context: Context) {

    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    companion object {
        private const val SCAN_NOTIFICATION_ID = 12345
        private const val CHANNEL_ID = "scan_channel"
        private const val CHANNEL_NAME = "Scan Notifications"
    }

    init {
        createNotificationChannel()
    }

    /**
     * Create notification channel for Android 8+
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for text scanning"
            }
            notificationManager.createNotificationChannel(channel)
            android.util.Log.d("ScanNotification", "✅ Notification channel created")
        }
    }

    /**
     * Create a basic notification for the foreground service
     */
    fun createInitialNotification(): android.app.Notification {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            android.app.Notification.Builder(context, CHANNEL_ID)
        } else {
            android.app.Notification.Builder(context)
        }.apply {
            setSmallIcon(R.mipmap.ic_launcher)
            setContentTitle("AntiScam đang chạy")
            setContentText("Bong bóng bảo vệ đang hoạt động.")
            setPriority(android.app.Notification.PRIORITY_MIN) // Low priority for persistent notification
        }.build()
    }

    /**
     * Show "Scanning..." notification
     */
    fun showScanningNotification() {
        try {
            val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                android.app.Notification.Builder(context, CHANNEL_ID)
            } else {
                android.app.Notification.Builder(context)
            }.apply {
                setSmallIcon(R.mipmap.ic_launcher) // Use app icon instead of generic icon
                setContentTitle("Anti-Scam đang quét")
                setContentText("Đang phân tích nội dung để phát hiện nguy hiểm...")
                setOngoing(true) // Cannot be dismissed
                setAutoCancel(false)
                setProgress(0, 0, true) // Indeterminate progress
                setPriority(android.app.Notification.PRIORITY_HIGH) // Show at top
            }.build()

            notificationManager.notify(SCAN_NOTIFICATION_ID, notification)
            android.util.Log.d("ScanNotification", "✅ Scanning notification shown")
        } catch (e: Exception) {
            android.util.Log.e("ScanNotification", "❌ Error showing notification: ${e.message}", e)
        }
    }

    /**
     * Dismiss scanning notification
     */
    fun dismissScanningNotification() {
        try {
            notificationManager.cancel(SCAN_NOTIFICATION_ID)
            android.util.Log.d("ScanNotification", "✅ Scanning notification dismissed")
        } catch (e: Exception) {
            android.util.Log.e("ScanNotification", "❌ Error dismissing notification: ${e.message}", e)
        }
    }
}
