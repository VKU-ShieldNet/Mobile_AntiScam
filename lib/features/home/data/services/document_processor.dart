import 'package:flutter/foundation.dart';
import 'ocr_service.dart';

class DocumentProcessor {
  static const List<String> supportedFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'gif',
    'pdf'
  ];

  static Future<String> processFile(String filePath, String fileName) async {
    final extension = fileName.toLowerCase().split('.').last;

    if (supportedFormats.contains(extension)) {
      return await _processImage(filePath);
    } else {
      throw UnsupportedError('Định dạng file không được hỗ trợ: $extension');
    }
  }

  static Future<String> _processImage(String imagePath) async {
    debugPrint('🖼️ Processing file: $imagePath');
    return await OcrService.extractText(imagePath, useFallback: true);
  }

  static bool isSupportedFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return supportedFormats.contains(extension);
  }

  static String getSupportedFormatsString() {
    return supportedFormats.map((e) => e.toUpperCase()).join(', ');
  }
}
