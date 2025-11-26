import 'package:flutter/services.dart';

class BubbleService {
  static const _channel = MethodChannel('anti_scam_bubble');
  static const _appMonitorChannel = MethodChannel('com.example.antiscam_mobile/app_monitor');

  /// Sync protected apps to Android native SharedPreferences
  /// This is necessary because Flutter SharedPreferences and Android native SharedPreferences are different
  static Future<void> setProtectedApps(List<String> apps) async {
    try {
      await _appMonitorChannel.invokeMethod('setProtectedApps', {'apps': apps});
    } catch (e) {
      // Silently fail if channel not available
      rethrow;
    }
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasOverlayPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasAccessibilityPermission');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> startBubble() async {
    try {
      await _channel.invokeMethod('startBubble');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> stopBubble() async {
    try {
      await _channel.invokeMethod('stopBubble');
    } catch (e) {
      rethrow;
    }
  }
}
