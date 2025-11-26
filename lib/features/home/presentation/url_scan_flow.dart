import 'package:flutter/material.dart';
import '../data/services/url_scan_service.dart';
import '../data/models/url_scan_result.dart';
import 'widgets/scan_results/url_scan_result_modal.dart';
import 'widgets/scan_results/url_scan_loading_dialog.dart';


/// Scan URL in background and auto-close loading dialog when done
Future<void> _scanInBackground(
  BuildContext dialogCtx,
  UrlScanService service,
  String url,
) async {
  try {
    debugPrint('🔄 Starting scan for: $url');
    final result = await service.scanUrl(url);
    debugPrint('✅ Scan completed: ${result.isSafe ? "Safe" : "Unsafe"}');
    debugPrint('📊 Result details: riskLevel=${result.riskLevel}, score=${result.score}');

    // Close loading dialog and pass result back
    if (dialogCtx.mounted) {
      debugPrint('🔙 Popping dialog with result');
      Navigator.pop(dialogCtx, result);
    } else {
      debugPrint('⚠️ Dialog context not mounted!');
    }
  } catch (e) {
    debugPrint('❌ Scan error: $e');
    if (dialogCtx.mounted) {
      Navigator.pop(dialogCtx, null);
    }
  }
}

/// Show URL scan flow: loading -> result modal
Future<void> showUrlScanFlow({
  required BuildContext context,
  required String url,
  String? baseUrl,
}) async {
  if (!context.mounted) return;

  try {
    // Create service with auto-configuration for emulator
    final service = UrlScanService.create(isEmulator: true);

    debugPrint('🔍 Starting URL scan flow...');
    debugPrint('📍 URL to scan: $url');
    debugPrint('🌐 API endpoint: ${service.baseUrl}/model/analyze');

    // Show loading dialog and scan in background
    final result = await showDialog<UrlScanResult?>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogCtx) {
        debugPrint('🎨 Showing loading dialog');
        // Start scanning in background
        _scanInBackground(dialogCtx, service, url);

        return WillPopScope(
          onWillPop: () async => false,
          child: const UrlScanLoadingDialog(),
        );
      },
    );

    debugPrint('🔍 Dialog closed, result received: ${result != null}');

    // Show result modal if we got result
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
          debugPrint('🎨 Building UrlScanResultModal');
          return UrlScanResultModal(result: result);
        },
      );
      debugPrint('✅ Modal bottom sheet closed');
    } else if (result == null) {
      debugPrint('⚠️ No result received from scan');
    } else {
      debugPrint('⚠️ Context not mounted, cannot show modal');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error in showUrlScanFlow: $e');
    debugPrint('📍 Stack trace: $stackTrace');

    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể kết nối server. Vui lòng kiểm tra:\n1. Server đang chạy tại localhost:8000\n2. API endpoint /model/analyze\n\nError: $e'),
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
