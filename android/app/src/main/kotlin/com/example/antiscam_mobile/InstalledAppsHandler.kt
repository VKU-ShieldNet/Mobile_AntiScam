package com.example.antiscam_mobile

import android.content.Context
import android.content.pm.PackageManager
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/**
 * Handler lấy danh sách app cài đặt (tên, package, icon Base64)
 */
class InstalledAppsHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInstalledApps" -> result.success(getInstalledApps())
            else -> result.notImplemented()
        }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = context.packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        return apps.mapNotNull { appInfo ->
            try {
                val appName = pm.getApplicationLabel(appInfo).toString()
                val packageName = appInfo.packageName
                val icon = pm.getApplicationIcon(appInfo)
                val iconBitmap = (icon as? BitmapDrawable)?.bitmap
                val iconBase64 = if (iconBitmap != null) {
                    val stream = ByteArrayOutputStream()
                    iconBitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                    Base64.encodeToString(stream.toByteArray(), Base64.DEFAULT)
                } else ""
                mapOf(
                    "appName" to appName,
                    "packageName" to packageName,
                    "icon" to iconBase64
                )
            } catch (e: Exception) {
                null
            }
        }
    }
}
