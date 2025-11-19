package com.example.antiscam_mobile

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer

class ScreenCaptureService : Service() {
    companion object {
        const val ACTION_START_CAPTURE = "com.example.antiscam_mobile.START_CAPTURE"
        const val ACTION_CAPTURE_NOW = "CAPTURE_NOW"
        const val ACTION_STOP_SERVICE = "com.example.antiscam_mobile.STOP_CAPTURE_SERVICE"
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"
        const val NOTIFICATION_CHANNEL_ID = "screen_capture_channel"
        const val NOTIFICATION_ID = 1002
        
        private var instance: ScreenCaptureService? = null
        
        fun isRunning(): Boolean = instance != null
    }

    // SINGLETON resources - created once, reused many times
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var isInitialized = false

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
        Log.d("ScreenCaptureService", "📸 Service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("ScreenCaptureService", "━━━━━━━━━━ SERVICE START DEBUG ━━━━━━━━━━")
        Log.d("ScreenCaptureService", "🔵 onStartCommand called")
        Log.d("ScreenCaptureService", "   intent: $intent")
        Log.d("ScreenCaptureService", "   action: ${intent?.action}")
        Log.d("ScreenCaptureService", "🟩 Foreground required for MediaProjection - will stop after capture (<300ms)")

        // Start foreground immediately (required by Android 14+ for MediaProjection)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    createNotification(),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                )
            } else {
                startForeground(NOTIFICATION_ID, createNotification())
            }
            Log.d("ScreenCaptureService", "✅ Started foreground (icon will disappear after capture)")
        } catch (e: Exception) {
            Log.e("ScreenCaptureService", "❌ Failed to start foreground: ${e.message}", e)
            stopSelf()
            return START_NOT_STICKY
        }

        when (intent?.action) {
            ACTION_CAPTURE_NOW -> {
                Log.d("ScreenCaptureService", "⚡ ACTION_CAPTURE_NOW - capture from existing setup")
                if (!isInitialized) {
                    Log.e("ScreenCaptureService", "❌ Service not initialized yet")
                    stopSelf()
                    return START_NOT_STICKY
                }
                captureImageNow()
            }
            ACTION_START_CAPTURE -> {
                Log.d("ScreenCaptureService", "📸 ACTION_START_CAPTURE - initialize capture system")
                
                val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, 0)
                val data = intent.getParcelableExtra<Intent>(EXTRA_RESULT_DATA)
                
                Log.d("ScreenCaptureService", "   resultCode: $resultCode")
                Log.d("ScreenCaptureService", "   Activity.RESULT_OK: ${Activity.RESULT_OK}")
                Log.d("ScreenCaptureService", "   Match: ${resultCode == Activity.RESULT_OK}")
                Log.d("ScreenCaptureService", "   data: $data")
                
                if (resultCode == Activity.RESULT_OK && data != null) {
                    Log.d("ScreenCaptureService", "✅ Valid permission data - initializing capture system")

                    // Initialize ONCE - create MediaProjection, ImageReader, VirtualDisplay
                    initializeCaptureSystem(resultCode, data)
                    
                    // Immediately capture first frame
                    captureImageNow()
                } else {
                    Log.e("ScreenCaptureService", "❌ Invalid result code or data")
                    Log.e("ScreenCaptureService", "   Expected resultCode: ${Activity.RESULT_OK}")
                    Log.e("ScreenCaptureService", "   Got resultCode: $resultCode")
                    Log.e("ScreenCaptureService", "   data: $data")
                    stopSelf()
                }
            }
            ACTION_STOP_SERVICE -> {
                Log.d("ScreenCaptureService", "🛑 ACTION_STOP_SERVICE received")
                cleanup()
                stopSelf()
            }
            else -> {
                Log.e("ScreenCaptureService", "❌ Unknown action: ${intent?.action}")
            }
        }
        Log.d("ScreenCaptureService", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        return START_NOT_STICKY // Don't restart - we start fresh each time for <300ms capture
    }

    /**
     * STEP 1: Initialize capture system ONCE
     * Create MediaProjection, ImageReader, VirtualDisplay - only called once
     */
    private fun initializeCaptureSystem(resultCode: Int, data: Intent) {
        if (isInitialized) {
            Log.w("ScreenCaptureService", "⚠️ Already initialized, skipping")
            return
        }
        
        Log.d("ScreenCaptureService", "━━━━━━━━━━ INITIALIZING CAPTURE SYSTEM ━━━━━━━━━━")
        
        try {
            // 1. Create MediaProjection (ONCE)
            val projectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            mediaProjection = projectionManager.getMediaProjection(resultCode, data)
            Log.d("ScreenCaptureService", "✅ MediaProjection created")
            
            // 1.5. Register callback (required for Android 14+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                mediaProjection?.registerCallback(object : MediaProjection.Callback() {
                    override fun onStop() {
                        Log.d("ScreenCaptureService", "MediaProjection stopped")
                        cleanup()
                    }
                }, Handler(Looper.getMainLooper()))
                Log.d("ScreenCaptureService", "✅ MediaProjection callback registered")
            }
            
            // 2. Create ImageReader (ONCE)
            val metrics = resources.displayMetrics
            val width = metrics.widthPixels
            val height = metrics.heightPixels
            val density = metrics.densityDpi
            
            Log.d("ScreenCaptureService", "📐 Screen: ${width}x${height} @ ${density}dpi")
            
            imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
            Log.d("ScreenCaptureService", "✅ ImageReader created")
            
            // 3. Create VirtualDisplay (ONCE)
            virtualDisplay = mediaProjection?.createVirtualDisplay(
                "ScreenCapture",
                width, height, density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageReader?.surface, null, null
            )
            Log.d("ScreenCaptureService", "✅ VirtualDisplay created")
            
            isInitialized = true
            Log.d("ScreenCaptureService", "✅✅✅ CAPTURE SYSTEM READY - can capture many times now")
            Log.d("ScreenCaptureService", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
        } catch (e: Exception) {
            Log.e("ScreenCaptureService", "❌ Failed to initialize: ${e.message}", e)
            cleanup()
            stopSelf()
        }
    }

    /**
     * STEP 2: Capture image from ImageReader
     * Can be called multiple times - just reads current frame
     */
    private fun captureImageNow() {
        if (!isInitialized) {
            Log.e("ScreenCaptureService", "❌ Cannot capture - system not initialized")
            return
        }
        
        Log.d("ScreenCaptureService", "━━━━━━━━━━ CAPTURING FRAME ━━━━━━━━━━")
        val captureStartTime = System.currentTimeMillis()
        
        try {
            // Wait a bit for VirtualDisplay to have a frame ready
            Handler(Looper.getMainLooper()).postDelayed({
                val image = imageReader?.acquireLatestImage()
                if (image == null) {
                    Log.e("ScreenCaptureService", "❌ No image available from ImageReader")
                    // Stop service immediately since capture failed
                    cleanup()
                    stopSelf()
                    return@postDelayed
                }
                
                Log.d("ScreenCaptureService", "✅ Image acquired from ImageReader")
                
                // Convert to Bitmap
                val planes = image.planes
                val buffer: ByteBuffer = planes[0].buffer
                val pixelStride = planes[0].pixelStride
                val rowStride = planes[0].rowStride
                val rowPadding = rowStride - pixelStride * image.width
                
                val bitmap = Bitmap.createBitmap(
                    image.width + rowPadding / pixelStride,
                    image.height,
                    Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)
                image.close()
                
                Log.d("ScreenCaptureService", "✅ Bitmap: ${bitmap.width}x${bitmap.height}")
                
                // Save to file
                val picturesDir = getExternalFilesDir(null) ?: filesDir
                val screenshotFile = File(picturesDir, "screenshot_${System.currentTimeMillis()}.png")
                
                FileOutputStream(screenshotFile).use { out ->
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                }
                bitmap.recycle()
                
                val totalTime = System.currentTimeMillis() - captureStartTime
                Log.i("ScreenCaptureService", "✅ Screenshot saved: ${screenshotFile.absolutePath}")
                Log.i("ScreenCaptureService", "⚡ Total capture time: ${totalTime}ms")
                
                // Broadcast result
                val broadcastIntent = Intent("com.example.antiscam_mobile.SCREENSHOT_CAPTURED").apply {
                    putExtra("file_path", screenshotFile.absolutePath)
                    setPackage(packageName)
                }
                sendBroadcast(broadcastIntent)
                
                Log.d("ScreenCaptureService", "✅ Broadcast sent")
                Log.d("ScreenCaptureService", "🛑 Stopping service immediately to hide notification icon")
                Log.d("ScreenCaptureService", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                // 🟩 STOP SERVICE IMMEDIATELY after capture (<300ms total)
                // This prevents Android from showing the notification icon
                cleanup()
                stopSelf()
                
            }, 100) // Small delay for frame to be ready
            
        } catch (e: Exception) {
            Log.e("ScreenCaptureService", "❌ Capture failed: ${e.message}", e)
            cleanup()
            stopSelf()
        }
    }

    /**
     * STEP 3: Cleanup everything when stopping service
     */
    private fun cleanup() {
        Log.d("ScreenCaptureService", "🛑 Cleaning up capture system")
        
        virtualDisplay?.release()
        imageReader?.close()
        mediaProjection?.stop()
        
        virtualDisplay = null
        imageReader = null
        mediaProjection = null
        isInitialized = false
        
        Log.d("ScreenCaptureService", "✅ Cleanup complete")
    }

    override fun onDestroy() {
        cleanup()
        instance = null
        super.onDestroy()
        Log.d("ScreenCaptureService", "📸 Service destroyed")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Screen Capture",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Capturing screen for scam detection"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("AntiScam")
            .setContentText("Capturing screen for analysis...")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }
}
