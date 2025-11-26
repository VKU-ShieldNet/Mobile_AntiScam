import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../app/theme/color_schemes.dart';
import '../bubble_status_badge.dart';


/// Modern bubble control card with status indicator
class BubbleControlCard extends StatelessWidget {
  final bool hasOverlayPermission;
  final bool hasAccessibilityPermission;
  final bool isLoading;
  final VoidCallback onTap;

  const BubbleControlCard({
    Key? key,
    required this.hasOverlayPermission,
    required this.hasAccessibilityPermission,
    required this.isLoading,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bubble_chart_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'bubble.quickAccess.title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'bubble.quickAccess.description'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Status and arrow
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BubbleStatusBadge(
                  hasOverlayPermission: hasOverlayPermission,
                  hasAccessibilityPermission: hasAccessibilityPermission,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
