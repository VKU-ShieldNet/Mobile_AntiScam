import 'package:flutter/material.dart';
import '../../../data/models/url_scan_result.dart';
import '../../../../../app/theme/color_schemes.dart';


class UrlScanResultModal extends StatelessWidget {
  final UrlScanResult result;

  const UrlScanResultModal({
    Key? key,
    required this.result,
  }) : super(key: key);

  Color _getRiskColor() {
    switch (result.riskLevel.toLowerCase()) {
      case 'dangerous':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'safe':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  IconData _getRiskIcon() {
    switch (result.riskLevel.toLowerCase()) {
      case 'dangerous':
        return Icons.dangerous_outlined;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'safe':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _getRiskLabel() {
    switch (result.riskLevel.toLowerCase()) {
      case 'dangerous':
        return 'NGUY HIỂM';
      case 'warning':
        return 'CẢNH BÁO';
      case 'safe':
        return 'AN TOÀN';
      default:
        return 'THÔNG TIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Risk level badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: riskColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRiskIcon(),
                            color: riskColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getRiskLabel(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: riskColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Score
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Điểm an toàn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${result.score}/100',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: riskColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Conclusion
                  _buildSection(
                    title: 'Kết luận',
                    content: result.conclusion,
                    icon: Icons.assignment_outlined,
                  ),

                  const SizedBox(height: 16),

                  // Explanation
                  _buildSection(
                    title: 'Giải thích',
                    content: result.explanation,
                    icon: Icons.lightbulb_outline,
                  ),

                  const SizedBox(height: 16),

                  // Advice
                  _buildSection(
                    title: 'Khuyến nghị',
                    content: result.advice,
                    icon: Icons.tips_and_updates_outlined,
                    backgroundColor: riskColor.withOpacity(0.05),
                  ),

                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    Color? backgroundColor,
  }) {
    // Parse content into bullet points
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF37352F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Build bullet points or regular text
          if (lines.length > 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines
                  .map((line) => _buildBulletPoint(line.replaceAll(RegExp(r'^[-•\s]+'), '').trim()))
                  .toList(),
            )
          else
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
