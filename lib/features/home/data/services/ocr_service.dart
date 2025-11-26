import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> extractText(
    String imagePath, {
    bool useFallback = true,
  }) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      debugPrint('🔍 Using Google ML Kit OCR for: $imagePath');
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final result = recognizedText.text;

      if (result.isEmpty) {
        debugPrint('⚠️ OCR returned empty result for: $imagePath');
        return '';
      }
      debugPrint('✅ OCR extraction successful, text length: ${result.length}');
      return result;
    } catch (e) {
      debugPrint('❌ OCR extraction failed: $e');
      rethrow;
    } finally {
      await textRecognizer.close();
    }
  }
}
