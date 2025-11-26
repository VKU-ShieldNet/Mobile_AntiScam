package com.example.antiscam_mobile

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import kotlin.math.abs
import kotlin.math.sqrt

class FloatingDragTouchListener(
    private val context: Context,
    private val windowManager: WindowManager,
    private val view: View,
    private val params: WindowManager.LayoutParams,
    private val onDismiss: () -> Unit
) : View.OnTouchListener {

    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var isDragging = false
    private var hasMoved = false

    // Dismiss zone
    private var dismissZone: View? = null
    private val dismissZoneSize = 150 // dp
    private val dismissThreshold = 200f // Distance to trigger dismiss
    private val dragThreshold = 10f // Minimum movement to consider as drag

    override fun onTouch(v: View, event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                initialX = params.x
                initialY = params.y
                initialTouchX = event.rawX
                initialTouchY = event.rawY
                isDragging = false
                hasMoved = false
                return false // Allow click to propagate initially
            }

            MotionEvent.ACTION_MOVE -> {
                val deltaX = event.rawX - initialTouchX
                val deltaY = event.rawY - initialTouchY
                val distance = sqrt(deltaX * deltaX + deltaY * deltaY)

                // Check if moved beyond threshold
                if (distance > dragThreshold) {
                    hasMoved = true
                    isDragging = true

                    // Show dismiss zone
                    if (dismissZone == null) {
                        showDismissZone()
                    }

                    // Update bubble position
                    params.x = initialX + deltaX.toInt()
                    params.y = initialY + deltaY.toInt()

                    // Check if near dismiss zone
                    val screenWidth = context.resources.displayMetrics.widthPixels
                    val screenHeight = context.resources.displayMetrics.heightPixels
                    val dismissZoneX = screenWidth - dismissZoneSize * context.resources.displayMetrics.density / 2
                    val dismissZoneY = screenHeight - dismissZoneSize * context.resources.displayMetrics.density / 2

                    val distanceToDismissZone = sqrt(
                        (event.rawX - dismissZoneX) * (event.rawX - dismissZoneX) +
                        (event.rawY - dismissZoneY) * (event.rawY - dismissZoneY)
                    )

                    if (distanceToDismissZone < dismissThreshold) {
                        // Attract to dismiss zone
                        dismissZone?.animate()
                            ?.scaleX(1.3f)
                            ?.scaleY(1.3f)
                            ?.alpha(1f)
                            ?.setDuration(100)
                            ?.start()

                        view.animate()
                            .scaleX(0.8f)
                            .scaleY(0.8f)
                            .setDuration(100)
                            .start()
                    } else {
                        // Reset dismiss zone
                        dismissZone?.animate()
                            ?.scaleX(1f)
                            ?.scaleY(1f)
                            ?.alpha(0.7f)
                            ?.setDuration(100)
                            ?.start()

                        view.animate()
                            .scaleX(1f)
                            .scaleY(1f)
                            .setDuration(100)
                            .start()
                    }

                    windowManager.updateViewLayout(view, params)
                    return true // Consume event to prevent click
                }
                return false
            }

            MotionEvent.ACTION_UP -> {
                // Hide dismiss zone
                hideDismissZone()

                // Reset bubble scale
                view.animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(200)
                    .start()

                // Check if should dismiss
                if (isDragging) {
                    val screenWidth = context.resources.displayMetrics.widthPixels
                    val screenHeight = context.resources.displayMetrics.heightPixels
                    val dismissZoneX = screenWidth - dismissZoneSize * context.resources.displayMetrics.density / 2
                    val dismissZoneY = screenHeight - dismissZoneSize * context.resources.displayMetrics.density / 2

                    val distanceToDismissZone = sqrt(
                        (event.rawX - dismissZoneX) * (event.rawX - dismissZoneX) +
                        (event.rawY - dismissZoneY) * (event.rawY - dismissZoneY)
                    )

                    if (distanceToDismissZone < dismissThreshold) {
                        // Dismiss bubble
                        android.util.Log.d("FloatingBubble", "🗑️ Bubble dismissed by user")
                        onDismiss()
                        return true
                    }
                }

                // If moved, consume event to prevent click
                if (hasMoved) {
                    isDragging = false
                    hasMoved = false
                    return true
                }

                return false // Allow click if not dragged
            }

            MotionEvent.ACTION_CANCEL -> {
                hideDismissZone()
                view.animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(200)
                    .start()
                isDragging = false
                hasMoved = false
                return false
            }
        }
        return false
    }

    private fun showDismissZone() {
        try {
            val inflater = LayoutInflater.from(context)
            dismissZone = ImageView(context).apply {
                setImageResource(android.R.drawable.ic_menu_delete)
                setColorFilter(android.graphics.Color.RED)
                alpha = 0.7f
            }

            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val size = (dismissZoneSize * context.resources.displayMetrics.density).toInt()
            val dismissParams = WindowManager.LayoutParams(
                size,
                size,
                type,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                PixelFormat.TRANSLUCENT
            )

            dismissParams.gravity = Gravity.BOTTOM or Gravity.END
            dismissParams.x = 20
            dismissParams.y = 20

            windowManager.addView(dismissZone, dismissParams)

            // Fade in animation
            dismissZone?.alpha = 0f
            dismissZone?.animate()
                ?.alpha(0.7f)
                ?.setDuration(200)
                ?.start()

        } catch (e: Exception) {
            android.util.Log.e("FloatingBubble", "❌ Error showing dismiss zone: ${e.message}")
        }
    }

    private fun hideDismissZone() {
        dismissZone?.let {
            it.animate()
                .alpha(0f)
                .setDuration(200)
                .withEndAction {
                    try {
                        windowManager.removeView(it)
                        dismissZone = null
                    } catch (e: Exception) {
                        // Already removed
                    }
                }
                .start()
        }
    }
}
