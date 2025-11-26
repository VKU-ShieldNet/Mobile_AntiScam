package com.example.antiscam_mobile

import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

/**
 * Popup overlay for displaying scan results
 * Matches Flutter UI design
 */
class ScanResultPopup(
    private val context: Context,
    private val windowManager: WindowManager
) {

    private var popupView: View? = null
    private var isShowing = false

    // Colors matching Flutter AppColors
    private val primaryColor = Color.parseColor("#724CDA")
    private val successColor = Color.parseColor("#40C58B")
    private val dangerColor = Color.parseColor("#E14747")
    private val greyTextColor = Color.parseColor("#6D6D6A")
    private val darkTextColor = Color.parseColor("#37352F")
    private val greyBgColor = Color.parseColor("#F5F5F1")

    /**
     * Show scan result popup
     */
    fun show(
        isSafe: Boolean,
        label: String,
        evidence: ArrayList<String>,
        recommendation: ArrayList<String>,
        onDismiss: () -> Unit = {}
    ) {
        Handler(Looper.getMainLooper()).post {
            try {
                android.util.Log.d("ScanResultPopup", "🎨 Showing scan result popup...")

                // Dismiss any existing popup
                dismiss()

                val labelColor = if (isSafe) successColor else dangerColor
                val labelBgColor = if (isSafe)
                    Color.argb(25, 64, 197, 139) // success.withOpacity(0.1)
                else
                    Color.argb(25, 225, 71, 71) // danger.withOpacity(0.1)

                // Create ScrollView for content
                val scrollView = ScrollView(context).apply {
                    layoutParams = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT
                    )
                }

                // Main container
                val popupLayout = createMainLayout()

                // Add components
                popupLayout.addView(createHandleBar())
                popupLayout.addView(createLabelBadge(label, labelColor, labelBgColor))
                popupLayout.addView(createSpacer(60)) // 24dp

                // Evidence section
                if (evidence.isNotEmpty()) {
                    popupLayout.addView(createSection(
                        "Bằng chứng",
                        evidence,
                        "🔍",
                        greyBgColor
                    ))
                    popupLayout.addView(createSpacer(40)) // 16dp
                }

                // Recommendation section
                if (recommendation.isNotEmpty()) {
                    val recBgColor = Color.argb(
                        13,
                        Color.red(labelColor),
                        Color.green(labelColor),
                        Color.blue(labelColor)
                    )
                    popupLayout.addView(createSection(
                        "Khuyến nghị",
                        recommendation,
                        "💡",
                        recBgColor
                    ))
                    popupLayout.addView(createSpacer(60)) // 24dp
                }

                // Close button
                popupLayout.addView(createCloseButton {
                    dismiss()
                    onDismiss()
                })

                scrollView.addView(popupLayout)

                // Show popup with window params
                val params = createWindowParams()

                // Rounded corners
                val mainShape = GradientDrawable()
                mainShape.cornerRadii = floatArrayOf(50f, 50f, 50f, 50f, 0f, 0f, 0f, 0f)
                mainShape.setColor(Color.WHITE)
                scrollView.background = mainShape

                popupView = scrollView
                windowManager.addView(popupView, params)
                isShowing = true

                android.util.Log.d("ScanResultPopup", "✅ Scan result popup shown")

            } catch (e: Exception) {
                android.util.Log.e("ScanResultPopup", "❌ Error showing popup: ${e.message}", e)
            }
        }
    }

    /**
     * Dismiss popup
     */
    fun dismiss() {
        try {
            if (isShowing && popupView != null) {
                windowManager.removeView(popupView)
                popupView = null
                isShowing = false
                android.util.Log.d("ScanResultPopup", "✅ Popup dismissed")
            }
        } catch (e: Exception) {
            android.util.Log.e("ScanResultPopup", "❌ Error dismissing popup: ${e.message}", e)
        }
    }

    // ===== UI Component Builders =====

    private fun createMainLayout() = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(60, 60, 60, 60) // 24dp
        setBackgroundColor(Color.WHITE)
    }

    private fun createHandleBar() = View(context).apply {
        layoutParams = LinearLayout.LayoutParams(100, 10).apply {
            gravity = Gravity.CENTER_HORIZONTAL
            setMargins(0, 30, 0, 60)
        }
        val shape = GradientDrawable()
        shape.cornerRadius = 5f
        shape.setColor(Color.parseColor("#C3C2BD"))
        background = shape
    }

    private fun createLabelBadge(label: String, labelColor: Int, bgColor: Int) =
        LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(50, 30, 50, 30)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }

            val shape = GradientDrawable()
            shape.cornerRadius = 30f
            shape.setColor(bgColor)
            shape.setStroke(4, Color.argb(76, Color.red(labelColor), Color.green(labelColor), Color.blue(labelColor)))
            background = shape

            // Icon
            addView(TextView(context).apply {
                text = if (label.contains("AN TOÀN") || label.contains("SAFE")) "✓" else "⚠"
                textSize = 24f
                setTextColor(labelColor)
                setPadding(0, 0, 20, 0)
            })

            // Label text
            addView(TextView(context).apply {
                text = label
                textSize = 16f
                setTextColor(labelColor)
                setTypeface(null, android.graphics.Typeface.BOLD)
            })
        }

    private fun createSpacer(height: Int) = View(context).apply {
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            height
        )
    }

    private fun createSection(
        title: String,
        items: ArrayList<String>,
        emoji: String,
        backgroundColor: Int
    ) = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(40, 40, 40, 40)
        layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )

        val shape = GradientDrawable()
        shape.cornerRadius = 30f
        shape.setColor(backgroundColor)
        background = shape

        // Title row
        addView(createTitleRow(title, emoji))
        addView(createSpacer(30)) // 12dp

        // Bullet points
        items.forEach { item ->
            addView(createBulletPoint(item))
        }
    }

    private fun createTitleRow(title: String, emoji: String) =
        LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL

            addView(TextView(context).apply {
                text = emoji
                textSize = 20f
                setPadding(0, 0, 20, 0)
            })

            addView(TextView(context).apply {
                text = title
                textSize = 14f
                setTextColor(darkTextColor)
                setTypeface(null, android.graphics.Typeface.BOLD)
            })
        }

    private fun createBulletPoint(text: String) =
        LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(0, 0, 0, 20)

            // Bullet
            addView(View(context).apply {
                layoutParams = LinearLayout.LayoutParams(15, 15).apply {
                    setMargins(0, 10, 30, 0)
                }
                val bulletShape = GradientDrawable()
                bulletShape.shape = GradientDrawable.OVAL
                bulletShape.setColor(primaryColor)
                background = bulletShape
            })

            // Text
            addView(TextView(context).apply {
                this.text = text
                textSize = 14f
                setTextColor(greyTextColor)
                setLineSpacing(7f, 1f)
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    1f
                )
            })
        }

    private fun createCloseButton(onClick: () -> Unit) =
        Button(context).apply {
            text = "Đóng"
            textSize = 16f
            setTextColor(Color.WHITE)
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, 40, 0, 40)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )

            val shape = GradientDrawable()
            shape.cornerRadius = 30f
            shape.setColor(primaryColor)
            background = shape
            elevation = 0f
            stateListAnimator = null

            setOnClickListener { onClick() }
        }

    private fun createWindowParams() = WindowManager.LayoutParams(
        (context.resources.displayMetrics.widthPixels * 0.9).toInt(),
        WindowManager.LayoutParams.WRAP_CONTENT,
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        },
        WindowManager.LayoutParams.FLAG_DIM_BEHIND or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
        PixelFormat.TRANSLUCENT
    ).apply {
        gravity = Gravity.CENTER
        dimAmount = 0.6f
    }
}
