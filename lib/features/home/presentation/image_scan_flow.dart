import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../data/services/document_processor.dart';
import 'text_scan_flow.dart';

Future<void> showImageScanFlow({
  required BuildContext context,
  required ImageSource source,
}) async {
  try {
    final picker = ImagePicker();
    
    // Add a small delay to ensure proper channel initialization
    await Future.delayed(const Duration(milliseconds: 100));
    
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image == null) return;

    if (context.mounted) {
      await _processAndScan(
        context: context,
        filePath: image.path,
        fileName: image.name,
      );
    }
  } on PlatformException catch (e) {
    debugPrint('❌ PlatformException in showImageScanFlow: ${e.code} - ${e.message}');
    if (e.code == 'channel-error') {
      _showError(context, 'Lỗi khởi tạo camera. Vui lòng thử lại.');
    } else if (e.code == 'camera_access_denied') {
      _showError(context, 'Cần cấp quyền camera để sử dụng tính năng này');
    } else if (e.code == 'photo_access_denied') {
      _showError(context, 'Cần cấp quyền truy cập ảnh để sử dụng tính năng này');
    } else {
      _showError(context, 'Lỗi: ${e.message ?? e.code}');
    }
  } catch (e) {
    debugPrint('❌ Error in showImageScanFlow: $e');
    _showError(context, 'Lỗi: ${e.toString()}');
  }
}

Future<void> showFileScanFlow({
  required BuildContext context,
}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty || result.files.first.path == null) {
      return;
    }

    final file = result.files.first;

    if (context.mounted) {
      await _processAndScan(
        context: context,
        filePath: file.path!,
        fileName: file.name,
      );
    }
  } catch (e) {
    debugPrint('❌ Error in showFileScanFlow: $e');
    _showError(context, 'Lỗi chọn file: $e');
  }
}

Future<void> _processAndScan({
  required BuildContext context,
  required String filePath,
  required String fileName,
}) async {
  try {
    debugPrint('📁 Processing: $fileName');

    final extractedText = await DocumentProcessor.processFile(filePath, fileName);

    if (extractedText.trim().isEmpty) {
      _showWarning(context, 'Không tìm thấy văn bản trong file');
      return;
    }

    debugPrint('✅ Extracted ${extractedText.length} characters');

    if (context.mounted) {
      await showTextScanFlow(context: context, text: extractedText);
    }
  } catch (e) {
    debugPrint('❌ Error processing file: $e');
    _showError(context, 'Lỗi xử lý file: $e');
  }
}

void _showError(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    ),
  );
}

void _showWarning(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
    ),
  );
}
