import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Demo result dialog widget
class DemoResultDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const DemoResultDialog({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(32),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.green,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'onboarding.dialog.demoResult.title'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'onboarding.dialog.demoResult.message'.tr(),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultItem(
                  'onboarding.dialog.demoResult.details.noLinks'.tr(),
                ),
                const SizedBox(height: 8),
                _buildResultItem(
                  'onboarding.dialog.demoResult.details.normalLanguage'.tr(),
                ),
                const SizedBox(height: 8),
                _buildResultItem(
                  'onboarding.dialog.demoResult.details.noMoneyRequest'.tr(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onContinue();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text('onboarding.dialog.demoResult.continue'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
