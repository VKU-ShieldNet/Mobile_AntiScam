import 'dart:async';
import 'package:flutter/services.dart';
import 'ocr_service.dart';

class ScreenshotProcessorService {
  static const EventChannel _eventChannel =
      EventChannel('com.example.antiscam_mobile/screenshot_events');
  
  final OcrService _ocrService = OcrService();
  StreamSubscription? _subscription;

  /// Start listening for screenshots
  void startListening({
    required Function(String extractedText, String originalPath) onTextExtracted,
    required Function(String error) onError,
  }) {
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) async {
        if (event is Map) {
          final filePath = event['file_path'] as String?;
          
          if (filePath != null && filePath.isNotEmpty) {
            print('📸 Screenshot received: $filePath');
            
            try {
              // Process: OCR + delete
              final extractedText = await _ocrService.processAndDeleteScreenshot(filePath);
              
              print('✅ Text extracted (${extractedText.length} chars)');
              print('📝 Preview: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');
              
              onTextExtracted(extractedText, filePath);
            } catch (e) {
              print('❌ Processing error: $e');
              onError(e.toString());
            }
          }
        }
      },
      onError: (error) {
        print('❌ Event channel error: $error');
        onError(error.toString());
      },
    );
  }

  /// Stop listening
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
    _ocrService.dispose();
  }
}
