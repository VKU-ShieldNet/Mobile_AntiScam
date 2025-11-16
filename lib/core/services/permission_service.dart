import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'screen_capture.dart';

/// Service quản lý quyền cho toàn app
class PermissionService {
  /// 1️⃣ Quyền thông báo (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// 2️⃣ Quyền chụp màn hình (MediaProjection)
  static Future<bool> requestScreenCapturePermission() async {
    try {
      debugPrint("[PermissionService] Requesting screen capture permission...");
      final granted = await ScreenCapture.requestPermission();
      debugPrint("[PermissionService] Screen capture: $granted");
      return granted;
    } catch (e) {
      debugPrint("[PermissionService] Error: $e");
      return false;
    }
  }

  /// 3️⃣ Quyền overlay (nút nổi)
  static Future<bool> requestOverlayPermission() async {
    final overlayStatus = await Permission.systemAlertWindow.status;

    if (overlayStatus.isGranted) {
      return true;
    }

    // Nếu bị từ chối, mở Settings cho user bật
    const intent = AndroidIntent(
      action: 'android.settings.MANAGE_OVERLAY_PERMISSION',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();

    return false;
  }

  /// 4️⃣ Xin tất cả quyền cần thiết (tùy chọn overlay)
  static Future<Map<String, bool>> requestAllPermissions({
    bool includeOverlay = false,
  }) async {
    final results = <String, bool>{};

    results['notification'] = await requestNotificationPermission();
    results['screenCapture'] = await requestScreenCapturePermission();

    if (includeOverlay) {
      results['overlay'] = await requestOverlayPermission();
    }

    return results;
  }

  /// 5️⃣ Mở App Settings thủ công
  static Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}
