import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../app/theme/color_schemes.dart';
import '../../url_scan_flow.dart';

/// Bottom sheet for checking URL/link
class LinkCheckBottomSheet extends StatefulWidget {
  const LinkCheckBottomSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LinkCheckBottomSheet(),
    );
  }

  @override
  State<LinkCheckBottomSheet> createState() => _LinkCheckBottomSheetState();
}

class _LinkCheckBottomSheetState extends State<LinkCheckBottomSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCheck(BuildContext context) {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập URL'),
        ),
      );
      return;
    }

    // Get the root navigator context before popping
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    Navigator.pop(context);

    // Use root context for scan flow
    showUrlScanFlow(
      context: rootContext,
      url: url,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'home.quickCheck.link.bottomSheet.title'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // URL input field
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'home.quickCheck.link.bottomSheet.placeholder'.tr(),
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            autofocus: true,
            onSubmitted: (_) => _handleCheck(context),
          ),
          const SizedBox(height: 16),

          // Check button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleCheck(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'home.quickCheck.checkButton'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
