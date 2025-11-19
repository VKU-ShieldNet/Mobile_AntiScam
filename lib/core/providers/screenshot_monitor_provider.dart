import 'package:flutter/material.dart';
import '../services/screenshot_processor_service.dart';

/// Global service to handle screenshot processing
/// Start this once in main.dart or app initialization
class ScreenshotMonitorProvider extends ChangeNotifier {
  static final ScreenshotMonitorProvider _instance = ScreenshotMonitorProvider._internal();
  factory ScreenshotMonitorProvider() => _instance;
  ScreenshotMonitorProvider._internal();

  final ScreenshotProcessorService _processorService = ScreenshotProcessorService();
  final List<String> _detectedTexts = [];
  bool _isMonitoring = false;

  List<String> get detectedTexts => List.unmodifiable(_detectedTexts);
  bool get isMonitoring => _isMonitoring;

  /// Start monitoring - call this in app initialization
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    notifyListeners();
    
    debugPrint('🎯 Starting screenshot monitoring...');
    
    _processorService.startListening(
      onTextExtracted: (extractedText, originalPath) {
        debugPrint('━━━━━━━━━━ TEXT EXTRACTED ━━━━━━━━━━');
        debugPrint('📝 Length: ${extractedText.length} chars');
        debugPrint('📄 Preview: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        _detectedTexts.insert(0, extractedText);
        notifyListeners();
        
        // TODO: Send to backend
        _sendToBackend(extractedText);
      },
      onError: (error) {
        debugPrint('❌ Screenshot processing error: $error');
      },
    );
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _processorService.stopListening();
    notifyListeners();
    
    debugPrint('🛑 Screenshot monitoring stopped');
  }

  Future<void> _sendToBackend(String text) async {
    // TODO: Implement API call
    debugPrint('📤 [TODO] Send to backend: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
  }

  @override
  void dispose() {
    _processorService.dispose();
    super.dispose();
  }
}
