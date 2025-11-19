import 'package:flutter/services.dart';

class BubbleService {
  static const _channel = MethodChannel('anti_scam_bubble');
  static const _screenCaptureChannel = MethodChannel('screen_capture');

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

  static Future<bool> hasScreenCapturePermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasScreenCapturePermission');
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

  /// Xin quyền chụp màn hình (hiện popup hệ thống)
  static Future<bool> requestScreenCapturePermission() async {
    try {
      final granted = await _screenCaptureChannel.invokeMethod<bool>('requestProjection');
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Chụp ảnh màn hình và trả về đường dẫn file PNG
  static Future<String?> captureScreenshot() async {
    try {
      final path = await _screenCaptureChannel.invokeMethod<String>('captureScreenshot');
      return path;
    } catch (e) {
      return null;
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
