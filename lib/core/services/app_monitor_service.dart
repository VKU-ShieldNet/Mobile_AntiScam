import 'package:flutter/services.dart';

class AppMonitorService {
  static const MethodChannel _channel =
      MethodChannel('com.example.antiscam_mobile/app_monitor');

  /// Set list of protected apps (package names)
  /// These apps will trigger bubble display
  Future<void> setProtectedApps(List<String> packageNames) async {
    try {
      await _channel.invokeMethod('setProtectedApps', {
        'apps': packageNames,
      });
      print('✅ Protected apps set: $packageNames');
    } catch (e) {
      print('❌ Error setting protected apps: $e');
      rethrow;
    }
  }

  /// Get list of common scam-prone apps (example)
  static List<String> getDefaultProtectedApps() {
    return [
      'com.android.chrome',           // Chrome browser
      'com.google.android.youtube',   // YouTube
      'com.android.settings',         // Settings
      'com.facebook.katana',          // Facebook
      'com.facebook.orca',            // Messenger
      'com.whatsapp',                 // WhatsApp
      'com.viber.voip',               // Viber
      'com.twitter.android',          // Twitter/X
      'com.instagram.android',        // Instagram
      'com.snapchat.android',         // Snapchat
      'com.tencent.mm',               // WeChat
      'org.telegram.messenger',       // Telegram
    ];
  }
}
