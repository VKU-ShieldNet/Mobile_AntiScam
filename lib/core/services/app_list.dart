import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class AppListService {
  static const _channel = MethodChannel('installed_apps');

  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    final result = await _channel.invokeMethod('getInstalledApps');
    final List apps = result as List;
    return apps.map((e) {
      final map = Map<String, dynamic>.from(e);
      return {
        'name': map['appName'],
        'packageName': map['packageName'],
        'icon': map['icon'],
      };
    }).toList();
  }

  /// Decode icon base64 to display with Image.memory safely
  static Uint8List? decodeIcon(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    try {
      final cleanBase64 = base64String
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '');

      // Padding fix nếu thiếu "=" ở cuối
      final mod4 = cleanBase64.length % 4;
      final fixedBase64 =
          mod4 > 0 ? cleanBase64 + '=' * (4 - mod4) : cleanBase64;

      return base64Decode(fixedBase64);
    } catch (e) {
      print('⚠️ [decodeIcon] Invalid base64: $e');
      return null;
    }
  }
}
