  import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract text from image file
  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Combine all text blocks
      final extractedText = recognizedText.blocks
          .map((block) => block.text)
          .join('\n');
      
      return extractedText;
    } catch (e) {
      print('❌ OCR Error: $e');
      rethrow;
    }
  }

  /// Process screenshot: OCR + delete file
  Future<String> processAndDeleteScreenshot(String imagePath) async {
    try {
      // Extract text
      final text = await extractTextFromImage(imagePath);
      
      // Delete image file for security
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Screenshot deleted: $imagePath');
      }
      
      return text;
    } catch (e) {
      // Still delete file even if OCR fails
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      
      rethrow;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
