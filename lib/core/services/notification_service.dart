import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  /// Show scanning notification
  Future<void> showScanningNotification() async {
    try {
      debugPrint('🔔 showScanningNotification called');

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'scan_channel',
        'Scan Notifications',
        channelDescription: 'Notifications for text scanning',
        importance: Importance.high,
        priority: Priority.high,
        showProgress: true,
        maxProgress: 100,
        progress: 50,
        indeterminate: true,
        ongoing: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _notificationsPlugin.show(
        1, // notification id
        '🔍 Quét Văn Bản',
        'Đang quét và phân tích văn bản...',
        notificationDetails,
      );

      debugPrint('✅ Scanning notification shown');
    } catch (e) {
      debugPrint('❌ Error showing scanning notification: $e');
    }
  }


  /// Show scan completed notification
  Future<void> showScanCompletedNotification({
    required bool isSafe,
    required String label,
  }) async {
    try {
      debugPrint('🔔 showScanCompletedNotification called: isSafe=$isSafe, label=$label');

      final title = isSafe ? '✅ An Toàn' : '⚠️ Cảnh Báo';
      final body = 'Kết quả: $label';

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'scan_channel',
          'Scan Notifications',
          channelDescription: 'Notifications for text scanning',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        1,
        title,
        body,
        notificationDetails,
      );

      debugPrint('✅ Scan completed notification shown');
    } catch (e) {
      debugPrint('❌ Error showing scan completed notification: $e');
    }
  }


  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
