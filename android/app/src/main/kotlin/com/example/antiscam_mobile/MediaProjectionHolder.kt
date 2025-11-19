package com.example.antiscam_mobile

import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Handler
import android.os.Looper
import android.util.Log

/**
 * Singleton manager to keep MediaProjection alive for multiple captures
 * Token is single-use, but MediaProjection instance can be reused
 */
object MediaProjectionHolder {
    private var mediaProjection: MediaProjection? = null
    private var isActive = false

    fun initialize(context: Context, resultCode: Int, data: Intent) {
        if (isActive && mediaProjection != null) {
            Log.w("MediaProjectionHolder", "⚠️ MediaProjection already active, reusing...")
            return
        }

        Log.d("MediaProjectionHolder", "🎬 Initializing MediaProjection...")
        
        val mgr = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        mediaProjection = mgr.getMediaProjection(resultCode, data)
        
        // Register callback to track lifecycle
        mediaProjection?.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() {
                Log.w("MediaProjectionHolder", "⚠️ MediaProjection stopped by system")
                isActive = false
                mediaProjection = null
            }
            
            override fun onCapturedContentVisibilityChanged(isVisible: Boolean) {
                Log.d("MediaProjectionHolder", "👁️ Visibility: $isVisible")
            }
            
            override fun onCapturedContentResize(width: Int, height: Int) {
                Log.d("MediaProjectionHolder", "📐 Resized: ${width}x${height}")
            }
        }, Handler(Looper.getMainLooper()))
        
        isActive = true
        Log.i("MediaProjectionHolder", "✅ MediaProjection initialized and ready for multiple captures")
    }

    fun getProjection(): MediaProjection? {
        if (!isActive || mediaProjection == null) {
            Log.e("MediaProjectionHolder", "❌ MediaProjection not active!")
            return null
        }
        return mediaProjection
    }

    fun isInitialized(): Boolean = isActive && mediaProjection != null

    fun release() {
        Log.d("MediaProjectionHolder", "🛑 Releasing MediaProjection...")
        mediaProjection?.stop()
        mediaProjection = null
        isActive = false
    }
}
