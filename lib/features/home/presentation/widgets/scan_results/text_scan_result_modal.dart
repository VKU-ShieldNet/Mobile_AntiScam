import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../data/models/text_scan_result.dart';
import '../../../../../app/theme/color_schemes.dart';

class TextScanResultModal extends StatelessWidget {
  final TextScanResult result;

  const TextScanResultModal({
    Key? key,
    required this.result,
  }) : super(key: key);

  Color _getLabelColor() {
    return result.isSafe ? AppColors.success : AppColors.danger;
  }

  IconData _getLabelIcon() {
    return result.isSafe ? Icons.check_circle : Icons.dangerous;
  }

  String _getLabelText() {
    if (result.isSafe) return 'SAFE CONTENT';
    // Translate common labels if needed
    if (result.label.toUpperCase() == 'SCAM') return 'SCAM DETECTED';
    if (result.label.toUpperCase() == 'SPAM') return 'SPAM DETECTED';
    return result.label.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _getLabelColor();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(_getLabelIcon(), color: labelColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLabelText(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.isSafe ? 'No threats found' : 'Potential threat detected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[700],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.evidence.isNotEmpty)
                      _buildSection(
                        title: 'Evidence',
                        icon: Icons.search,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result.evidence
                              .map((item) => _buildBulletPoint(item))
                              .toList(),
                        ),
                        iconColor: AppColors.primary,
                      ),

                    if (result.evidence.isNotEmpty) const SizedBox(height: 16),

                    if (result.recommendation.isNotEmpty)
                      _buildSection(
                        title: 'Recommendations',
                        icon: Icons.tips_and_updates,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result.recommendation
                              .map((item) => _buildBulletPoint(item))
                              .toList(),
                        ),
                        backgroundColor: labelColor.withValues(alpha: 0.05),
                        iconColor: labelColor,
                      ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Sticky Footer Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: result.recommendation.join('\n')));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied results to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy Results'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: iconColor != null ? Color.lerp(iconColor, Colors.black, 0.4) : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
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
            padding: const EdgeInsets.only(right: 10, top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
                strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
