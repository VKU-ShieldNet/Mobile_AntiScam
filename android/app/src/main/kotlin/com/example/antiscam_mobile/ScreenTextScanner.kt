package com.example.antiscam_mobile

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONObject

/**
 * Scanner for extracting text content from current screen
 * Focuses on main content area, filters junk, and maintains proper ordering
 */
class ScreenTextScanner(private val context: AccessibilityService) {

    /**
     * Data class to hold text with position information
     */
    private data class TextItem(
        val text: String,
        val rect: Rect,
        val className: String
    )

    private var junkKeywordsSet: Set<String> = emptySet()

    init {
        loadJunkKeywords()
    }

    /**
     * Scan all text from current screen viewport
     * Returns list of text items sorted by position (top-to-bottom, left-to-right)
     */
    fun scanScreenText(): List<String> {
        try {
            val rootNode = context.rootInActiveWindow
            if (rootNode == null) {
                android.util.Log.w("TextScanner", "⚠️ No root node available for scanning")
                return emptyList()
            }

            // Get viewport boundaries
            val viewport = getViewportBounds()

            val textItems = mutableListOf<TextItem>()
            var urlFromWebView: String? = null
            extractTextFromNode(rootNode, textItems, viewport)

            // Try to extract URL from WebView or URL bar
            urlFromWebView = extractUrlFromScreen(rootNode)

            // Sort by position: top to bottom, left to right
            textItems.sortWith(compareBy({ it.rect.top }, { it.rect.left }))

            logResults(textItems, urlFromWebView)
            rootNode.recycle()

            // Build final text output
            val scannedText = if (!urlFromWebView.isNullOrBlank()) {
                "main link: $urlFromWebView | " + textItems.joinToString(" ") { it.text }
            } else {
                textItems.joinToString(" ") { it.text }
            }

            // Call Flutter to handle the scanned text
            if (scannedText.isNotBlank()) {
                callFlutterWithScannedText(scannedText)
            }

            return textItems.map { it.text }
        } catch (e: Exception) {
            android.util.Log.e("TextScanner", "❌ Error scanning screen text: ${e.message}", e)
            return emptyList()
        }
    }

    /**
     * Call Flutter via MethodChannel with scanned text
     */
    private fun callFlutterWithScannedText(text: String) {
        try {
            android.util.Log.d("TextScanner", "📱 Calling Flutter with scanned text...")

            // Get MainActivity instance to access MethodChannel
            val activity = context.applicationContext as? android.app.Application
            if (activity == null) {
                android.util.Log.w("TextScanner", "⚠️ Cannot get application context")
                return
            }

            // Send broadcast to MainActivity
            val intent = android.content.Intent("com.example.antiscam_mobile.TEXT_SCANNED")
            intent.setPackage(context.packageName)
            intent.putExtra("text", text)
            context.sendBroadcast(intent)

            android.util.Log.d("TextScanner", "✅ Broadcast sent to MainActivity")
        } catch (e: Exception) {
            android.util.Log.e("TextScanner", "❌ Error calling Flutter: ${e.message}", e)
        }
    }


    /**
     * Get viewport boundaries (center content area)
     * Excludes: top 200px (status/app bar), bottom 150px (nav bar), left/right 20px margins
     */
    private fun getViewportBounds(): Rect {
        val displayMetrics = context.resources.displayMetrics
        val screenHeight = displayMetrics.heightPixels
        val screenWidth = displayMetrics.widthPixels

        return Rect(
            20,                         // left
            200,                        // top
            screenWidth - 20,           // right
            screenHeight - 150          // bottom
        )
    }

    /**
     * Recursively extract text from accessibility node tree
     */
    private fun extractTextFromNode(
        node: AccessibilityNodeInfo,
        textItems: MutableList<TextItem>,
        viewport: Rect
    ) {
        try {
            // Skip invisible nodes
            if (!node.isVisibleToUser) {
                return
            }

            // Get node bounds
            val rect = Rect()
            node.getBoundsInScreen(rect)

            // Check if node intersects with viewport
            if (isInViewport(rect, viewport)) {
                val className = node.className?.toString() ?: ""
                val text = node.text?.toString()

                if (!text.isNullOrBlank()) {
                    val trimmedText = text.trim()

                    // Apply filters
                    if (shouldIncludeText(trimmedText, className)) {
                        textItems.add(TextItem(trimmedText, rect, getSimpleClassName(className)))
                    }
                }
            }

            // Recursively process children
            for (i in 0 until node.childCount) {
                val child = node.getChild(i)
                if (child != null) {
                    extractTextFromNode(child, textItems, viewport)
                    child.recycle()
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("TextScanner", "❌ Error extracting text: ${e.message}")
        }
    }

    /**
     * Check if rect intersects with viewport
     */
    private fun isInViewport(rect: Rect, viewport: Rect): Boolean {
        return rect.top < viewport.bottom &&
               rect.bottom > viewport.top &&
               rect.left < viewport.right &&
               rect.right > viewport.left
    }

    /**
     * Determine if text should be included based on filters
     */
    private fun shouldIncludeText(text: String, className: String): Boolean {
        // Filter by length
        if (text.length < 3) return false

        // Filter junk text
        if (isJunkText(text)) return false

        // Only include content node types
        if (!isContentNode(className)) return false

        return true
    }

    /**
     * Check if node class contains main content
     */
    private fun isContentNode(className: String): Boolean {
        return className.contains("TextView") ||
               className.contains("EditText") ||
               className.contains("WebView") ||
               className.contains("RecyclerView") ||
               className.contains("ListView") ||
               className.contains("ScrollView")
    }

    /**
     * Filter out common UI labels and junk text
     */
    private fun isJunkText(text: String): Boolean {
        val lowerText = text.lowercase()

        // Check against junk keywords from JSON
        if (junkKeywordsSet.contains(lowerText)) return true

        // Skip if all digits and too short (not a phone number)
        if (text.all { it.isDigit() } && text.length < 8) return true

        // Skip if all special characters
        if (text.all { !it.isLetterOrDigit() }) return true

        return false
    }

    /**
     * Extract simple class name from full class path
     */
    private fun getSimpleClassName(className: String): String {
        return className.substringAfterLast(".")
    }

    /**
     * Log scan results - consolidated view with URL if available
     */
    private fun logResults(textItems: List<TextItem>, urlFromWebView: String?) {
        android.util.Log.d("TextScanner", "━".repeat(60))
        android.util.Log.d("TextScanner", "📝 SCREEN CONTENT (${textItems.size} items)")
        android.util.Log.d("TextScanner", "━".repeat(60))

        if (textItems.isEmpty()) {
            android.util.Log.d("TextScanner", "⚠️ No content found in viewport")
        } else {
            // Build output: include URL if found
            val output = if (!urlFromWebView.isNullOrBlank()) {
                "main link: $urlFromWebView | " + textItems.joinToString(" ") { it.text }
            } else {
                textItems.joinToString(" ") { it.text }
            }

            android.util.Log.d("TextScanner", output)
        }

        android.util.Log.d("TextScanner", "━".repeat(60))
    }

    /**
     * Load junk keywords from JSON resource file
     */
    private fun loadJunkKeywords() {
        try {
            val inputStream = context.resources.openRawResource(R.raw.junk_keywords)
            val jsonText = inputStream.bufferedReader().use { it.readText() }
            val jsonObject = JSONObject(jsonText)
            val keywordArray = jsonObject.getJSONArray("junkKeywords")

            val keywords = mutableSetOf<String>()
            for (i in 0 until keywordArray.length()) {
                keywords.add(keywordArray.getString(i).lowercase())
            }

            junkKeywordsSet = keywords
        } catch (e: Exception) {
            android.util.Log.e("TextScanner", "❌ Error loading junk keywords: ${e.message}")
            junkKeywordsSet = emptySet()
        }
    }

    /**
     * Extract URL from WebView or address bar
     * Looks for text that matches URL pattern
     */
    private fun extractUrlFromScreen(rootNode: AccessibilityNodeInfo): String? {
        try {
            val viewport = getViewportBounds()
            val foundUrls = mutableListOf<String>()

            searchForUrl(rootNode, foundUrls, viewport)

            if (foundUrls.isNotEmpty()) {
                val url = foundUrls.first()
                android.util.Log.v("TextScanner", "🔗 Found URL: $url")
                return url
            }

            return null
        } catch (e: Exception) {
            android.util.Log.e("TextScanner", "❌ Error extracting URL: ${e.message}")
            return null
        }
    }

    /**
     * Recursively search for URL in accessibility tree
     */
    private fun searchForUrl(node: AccessibilityNodeInfo, urls: MutableList<String>, viewport: Rect) {
        try {
            if (!node.isVisibleToUser) return

            val text = node.text?.toString() ?: ""

            // Check if text looks like a URL
            if (isUrlText(text)) {
                urls.add(text)
                return  // Found URL, stop searching
            }

            // Recursively search children
            for (i in 0 until node.childCount) {
                val child = node.getChild(i)
                if (child != null) {
                    searchForUrl(child, urls, viewport)
                    child.recycle()
                    // If URL found, stop searching further
                    if (urls.isNotEmpty()) return
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("TextScanner", "❌ Error searching for URL: ${e.message}")
        }
    }

    /**
     * Check if text looks like a URL
     */
    private fun isUrlText(text: String): Boolean {
        val lowerText = text.lowercase()

        // Common URL patterns
        if (lowerText.startsWith("http://")) return true
        if (lowerText.startsWith("https://")) return true
        if (lowerText.startsWith("www.")) return true

        // Domain pattern: something.something (simple check)
        if (text.contains(".") && !text.contains(" ")) {
            val parts = text.split(".")
            if (parts.size >= 2 && parts[parts.size - 1].length >= 2) {
                // Likely a domain
                return true
            }
        }

        return false
    }
}
