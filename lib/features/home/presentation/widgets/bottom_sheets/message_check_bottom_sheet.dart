import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../app/theme/color_schemes.dart';
import '../../text_scan_flow.dart';

/// Bottom sheet for checking message/text
class MessageCheckBottomSheet extends StatefulWidget {
  const MessageCheckBottomSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const MessageCheckBottomSheet(),
    );
  }

  @override
  State<MessageCheckBottomSheet> createState() => _MessageCheckBottomSheetState();
}

class _MessageCheckBottomSheetState extends State<MessageCheckBottomSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCheck(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tin nhắn'),
        ),
      );
      return;
    }

    // Get the root navigator context before popping
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    Navigator.pop(context);

    // Use root context for scan flow
    showTextScanFlow(
      context: rootContext,
      text: text,
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
            'home.quickCheck.message.bottomSheet.title'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Message input field
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'home.quickCheck.message.bottomSheet.placeholder'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            autofocus: true,
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
