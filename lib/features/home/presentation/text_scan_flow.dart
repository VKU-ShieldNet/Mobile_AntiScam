import 'package:flutter/material.dart';
import '../data/services/text_scan_service.dart';
import '../data/models/text_scan_result.dart';
import 'widgets/scan_results/text_scan_result_modal.dart';
import 'widgets/scan_results/url_scan_loading_dialog.dart';


Future<void> _scanTextInBackground(
  BuildContext dialogCtx,
  TextScanService service,
  String text,
) async {
  try {
    final preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    debugPrint('🔄 Starting text scan for: $preview');
    final result = await service.scanText(text);
    debugPrint('✅ Text scan completed: isSafe=${result.isSafe}');
    debugPrint('📊 Result details: label=${result.label}');

    if (dialogCtx.mounted) {
      debugPrint('🔙 Popping dialog with result');
      Navigator.pop(dialogCtx, result);
    } else {
      debugPrint('⚠️ Dialog context not mounted!');
    }
  } catch (e) {
    debugPrint('❌ Text scan error: $e');
    if (dialogCtx.mounted) {
      Navigator.pop(dialogCtx, null);
    }
  }
}

Future<void> showTextScanFlow({
  required BuildContext context,
  required String text,
}) async {
  if (!context.mounted) return;

  try {
    final service = TextScanService.create(isEmulator: true);

    final preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    debugPrint('🔍 Starting text scan flow...');
    debugPrint('📍 Text to scan: $preview');
    debugPrint('🌐 API endpoint: ${service.baseUrl}/text/analyze');

    final result = await showDialog<TextScanResult?>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogCtx) {
        debugPrint('🎨 Showing loading dialog');
        _scanTextInBackground(dialogCtx, service, text);
        return WillPopScope(
          onWillPop: () async => false,
          child: const UrlScanLoadingDialog(),
        );
      },
    );

    debugPrint('🔍 Dialog closed, result received: ${result != null}');

    if (result != null && context.mounted) {
      debugPrint('📊 Showing result modal...');

      // Small delay to ensure dialog is fully dismissed
      await Future.delayed(const Duration(milliseconds: 100));

      if (!context.mounted) {
        debugPrint('⚠️ Context not mounted after delay');
        return;
      }

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (modalContext) {
          debugPrint('🎨 Building TextScanResultModal');
          return TextScanResultModal(result: result);
        },
      );
      debugPrint('✅ Modal bottom sheet closed');
    } else if (result == null) {
      debugPrint('⚠️ No result received from scan');
    } else {
      debugPrint('⚠️ Context not mounted, cannot show modal');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error in showTextScanFlow: $e');
    debugPrint('📍 Stack trace: $stackTrace');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối server: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
