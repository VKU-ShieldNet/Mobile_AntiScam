import 'package:flutter/services.dart';

class BubbleService {
  static const _channel = MethodChannel('anti_scam_bubble');

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
