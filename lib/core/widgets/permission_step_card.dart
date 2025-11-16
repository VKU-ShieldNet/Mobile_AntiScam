import 'package:flutter/material.dart';
import '../../../../app/theme/color_schemes.dart';

/// Reusable permission step card component
/// Shows step number, title, description, and action button
class PermissionStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;
  final bool enabled;
  final String buttonText;
  final bool isLoading;

  const PermissionStepCard({
    Key? key,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
    required this.buttonText,
    this.enabled = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isGranted 
                  ? AppColors.primary70.withValues(alpha: 0.1)
                  : (enabled ? Colors.grey[100] : Colors.grey[50]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isGranted
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.primary70,
                      size: 24,
                    )
                  : Text(
                      '$stepNumber',
                      style: TextStyle(
                        color: enabled ? Colors.grey[700] : Colors.grey[400],
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.black87 : Colors.grey[400],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled ? Colors.grey[600] : Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                if (!isGranted && enabled) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading ? null : onRequest,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary70,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
