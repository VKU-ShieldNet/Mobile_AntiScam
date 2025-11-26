import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/home/data/services/text_scan_service.dart';
import '../../features/home/data/models/text_scan_result.dart';

/// Service to handle bubble scan events from native Android
class BubbleScanService {
  static const _channel = MethodChannel('anti_scam_bubble');
  static GlobalKey<NavigatorState>? _navigatorKey;

  // Prevent spam/concurrent scans
  static bool _isScanning = false;

  // Handler setup flag
  static bool _handlerSetup = false;

  /// Initialize the service with navigator key
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    debugPrint('🔧 BubbleScanService.initialize called with navigatorKey');
    _navigatorKey = navigatorKey;
    debugPrint('✅ Navigator key set');

    // Setup handler if not already done
    if (!_handlerSetup) {
      _setupMethodCallHandler();
    }
  }

  /// Setup method call handler to receive events from native (can be called early)
  static void setupHandler() {
    if (_handlerSetup) {
      debugPrint('⚠️ Handler already setup');
      return;
    }
    debugPrint('🔧 Setting up MethodChannel handler (early init)...');
    _setupMethodCallHandler();
  }

  /// Setup method call handler to receive events from native
  static void _setupMethodCallHandler() {
    debugPrint('🔧 Setting up MethodChannel handler...');

    _channel.setMethodCallHandler((call) async {
      debugPrint('📱 Received method call from native: ${call.method}');
      debugPrint('📱 Method arguments: ${call.arguments}');

      switch (call.method) {
        case 'onTextScanned':
          final text = call.arguments as String?;
          debugPrint('📝 Text scanned event received: $text');

          if (text != null && text.isNotEmpty) {
            debugPrint('✅ Calling _handleTextScanned with text');
            await _handleTextScanned(text);
          } else {
            debugPrint('⚠️ Received empty text from scan');
          }
          break;
        default:
          debugPrint('⚠️ Unknown method: ${call.method}');
      }
    });

    _handlerSetup = true;
    debugPrint('✅ BubbleScanService MethodChannel handler setup complete');
  }

  /// Get current context from navigator key
  static BuildContext? get _context {
    final context = _navigatorKey?.currentContext;
    debugPrint('🔍 Getting context from navigatorKey: ${context != null ? "✅ Available" : "❌ NULL"}');
    return context;
  }

  /// Handle scanned text - call API and send result to Kotlin
  static Future<void> _handleTextScanned(String text) async {
    // Prevent spam - if already scanning, skip
    if (_isScanning) {
      debugPrint('⚠️ Scan already in progress, ignoring new request');
      return;
    }

    debugPrint('📝 Handling scanned text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');

    final context = _context;
    if (context == null) {
      debugPrint('❌ Navigator context is NULL - cannot proceed');
      return;
    }

    if (!context.mounted) {
      debugPrint('❌ Context not mounted');
      return;
    }

    debugPrint('✅ Context is available and mounted');

    try {
      _isScanning = true;
      debugPrint('🔔 Setting _isScanning = true');

      // Native notification is shown from Kotlin side
      // Call API to scan text
      debugPrint('🔄 Creating TextScanService...');
      final service = TextScanService.create(isEmulator: true);
      debugPrint('🔄 Calling API to scan text...');

      final result = await service.scanText(text);
      debugPrint('✅ API scan completed: isSafe=${result.isSafe}, label=${result.label}');

      // Send result back to Kotlin to show overlay popup
      // Kotlin will also dismiss the scanning notification
      debugPrint('📤 Sending result back to Kotlin...');
      await _sendResultToKotlin(result);

    } catch (e) {
      debugPrint('❌ Error in bubble scan: $e');
      final currentContext = _context;
      if (currentContext != null && currentContext.mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      _isScanning = false;
    }
  }

  /// Send scan result back to Kotlin to show overlay popup
  static Future<void> _sendResultToKotlin(TextScanResult result) async {
    try {
      // Prepare data to send
      final data = {
        'isSafe': result.isSafe,
        'label': result.label,
        'evidence': result.evidence,
        'recommendation': result.recommendation,
      };

      await _channel.invokeMethod('showScanResult', data);
      debugPrint('✅ Result sent to Kotlin');
    } catch (e) {
      debugPrint('❌ Error sending result to Kotlin: $e');
    }
  }

  /// Show error message
  static void _showErrorSnackBar(String message) {
    final context = _context;
    if (context == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Dispose the service
  static void dispose() {
    _navigatorKey = null;
    _isScanning = false;
  }
}
