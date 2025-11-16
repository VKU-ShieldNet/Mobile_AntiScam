import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/theme/color_schemes.dart';

/// Status badge for bubble control card
class BubbleStatusBadge extends StatelessWidget {
  final bool hasOverlayPermission;
  final bool hasAccessibilityPermission;
  final bool isLoading;

  const BubbleStatusBadge({
    Key? key,
    required this.hasOverlayPermission,
    required this.hasAccessibilityPermission,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.success,
        ),
      );
    }

    final isReady = hasOverlayPermission && hasAccessibilityPermission;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: isReady
            ? AppColors.success.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isReady
            ? 'home.advanced.status.ready'.tr()
            : 'home.advanced.status.setup'.tr(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isReady ? AppColors.success : Colors.orange[700],
        ),
      ),
    );
  }
}
