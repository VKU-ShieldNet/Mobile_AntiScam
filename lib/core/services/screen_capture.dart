import 'package:flutter/services.dart';

class ScreenCapture {
  static const _channel = MethodChannel('screen_capture');

  /// Xin quyền chụp màn hình (hiện popup hệ thống)
  static Future<bool> requestPermission() async {
    final granted = await _channel.invokeMethod('requestProjection');
    return granted == true;
  }

  /// Chụp ảnh màn hình và trả về đường dẫn file PNG
  static Future<String?> capture() async {
    return await _channel.invokeMethod('captureScreenshot');
  }
}
