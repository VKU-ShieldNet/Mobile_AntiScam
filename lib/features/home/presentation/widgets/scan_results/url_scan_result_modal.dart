import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/url_scan_result.dart';
import '../../../data/services/url_scan_service.dart';
import '../../../../../app/theme/color_schemes.dart';

class UrlScanResultModal extends StatefulWidget {
  final UrlScanResult result;

  const UrlScanResultModal({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  State<UrlScanResultModal> createState() => _UrlScanResultModalState();
}

class _UrlScanResultModalState extends State<UrlScanResultModal> {
  late Future<WebsitePreviewResult> _previewFuture;
  late Future<ReputationResult> _reputationFuture;
  late UrlScanService _service;

  @override
  void initState() {
    super.initState();
    _service = UrlScanService.create();
    // Fetch preview image (screenshot)
    _previewFuture = _service.getWebsitePreview(widget.result.url);
    // Fetch third-party reputation data
    _reputationFuture = _service.getReputationCheck(widget.result.url);
  }

  Color _getRiskColor() {
    if (widget.result.isSafe) return AppColors.success;
    if (widget.result.riskScore > 70) return AppColors.danger;
    return AppColors.warning;
  }

  IconData _getRiskIcon() {
    if (widget.result.isSafe) return Icons.check_circle;
    if (widget.result.riskScore > 70) return Icons.dangerous;
    return Icons.warning_amber_rounded;
  }

  String _getRiskLabel() {
    if (widget.result.isSafe) return 'SAFE';
    if (widget.result.riskScore > 70) return 'DANGEROUS';
    return 'WARNING';
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: true, // Enable top safe area to avoid status bar overlap
        bottom: true, // Enable bottom safe area for home indicator
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(_getRiskIcon(), color: riskColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRiskLabel(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.result.url,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            overflow: TextOverflow.ellipsis,
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Safety Score
                    _buildScoreSection(riskColor),
                    const SizedBox(height: 24),

                    // AI Analysis
                    _buildSection(
                      title: 'AI Analysis',
                      icon: Icons.psychology,
                      child: MarkdownBody(
                        data: widget.result.geminiAnalysis,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF374151)),
                          strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          listBullet: TextStyle(color: AppColors.primary, fontSize: 16),
                        ),
                      ),
                      backgroundColor: Colors.blue.withOpacity(0.05),
                      iconColor: Colors.blue,
                    ),

                    const SizedBox(height: 16),

                    // Security Checks
                    _buildChecksSection(),

                    const SizedBox(height: 16),

                    // Third-Party Security Report
                    _buildReputationSection(),

                    const SizedBox(height: 16),

                    // Screenshot Preview
                    _buildPreviewSection(),

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
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Close', style: TextStyle(color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _launchUrl(widget.result.url),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Visit Site'),
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

  Widget _buildScoreSection(Color color) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: widget.result.riskScore / 100,
                      backgroundColor: Colors.grey[100],
                      color: color,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.result.riskScore}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        'Risk Score',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecksSection() {
    return Column(
      children: [
        _buildCheckItem(
          icon: widget.result.checks.ssl.valid ? Icons.lock : Icons.lock_open,
          label: 'SSL Certificate',
          value: widget.result.checks.ssl.valid ? 'Valid' : 'Invalid',
          isSafe: widget.result.checks.ssl.valid,
        ),
        const SizedBox(height: 8),
        _buildCheckItem(
          icon: Icons.public,
          label: 'Domain Age',
          value: widget.result.checks.domainAge.isNew ? 'New (< 30 days)' : 'Established',
          isSafe: !widget.result.checks.domainAge.isNew,
        ),
        const SizedBox(height: 8),
        _buildCheckItem(
          icon: Icons.sim_card_alert,
          label: 'Suspicious Keywords',
          value: '${widget.result.checks.suspiciousKeywords.count} found',
          isSafe: widget.result.checks.suspiciousKeywords.riskLevel == 'safe',
        ),
      ],
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isSafe,
  }) {
    final color = isSafe ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(
            isSafe ? Icons.check_circle : Icons.error,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return FutureBuilder<WebsitePreviewResult>(
      future: _previewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading preview...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (snapshot.hasError || snapshot.data?.screenshotBase64.isEmpty == true) {
          return const SizedBox.shrink(); // Hide if failed
        }

        final imageBytes = base64Decode(snapshot.data!.screenshotBase64);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Live Preview',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
          ],
        );
      },
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

  Widget _buildReputationSection() {
    return FutureBuilder<ReputationResult>(
      future: _reputationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSection(
            title: 'Third-Party Security Check',
            icon: Icons.shield,
            backgroundColor: Colors.purple.withOpacity(0.05),
            iconColor: Colors.purple,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Checking external databases...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildSection(
            title: 'Third-Party Security Check',
            icon: Icons.shield,
            backgroundColor: Colors.grey.withOpacity(0.05),
            iconColor: Colors.grey,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unable to fetch external reports',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }

        final reputation = snapshot.data!;
        return _buildSection(
          title: 'Third-Party Security Check',
          icon: Icons.shield,
          backgroundColor: Colors.purple.withOpacity(0.05),
          iconColor: Colors.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reputation Score
              _buildReputationScoreIndicator(reputation.reputationScore),
              const SizedBox(height: 16),

              // Google Safe Browsing
              _buildSafeBrowsingCard(reputation.safeBrowsing),
              const SizedBox(height: 10),

              // VirusTotal
              _buildVirusTotalCard(reputation.virusTotal),
              const SizedBox(height: 12),

              // Recommendation
              _buildRecommendationBanner(reputation.recommendation, reputation.reputationScore),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReputationScoreIndicator(int score) {
    Color scoreColor;
    if (score >= 70) {
      scoreColor = AppColors.success;
    } else if (score >= 50) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.danger;
    }

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scoreColor.withOpacity(0.15),
            border: Border.all(color: scoreColor, width: 3),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reputation Score',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                score >= 70 ? 'Good standing' : score >= 50 ? 'Use with caution' : 'Poor reputation',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafeBrowsingCard(SafeBrowsingResult sb) {
    IconData icon;
    Color color;
    String statusText;

    if (sb.isSafe) {
      icon = Icons.verified_user;
      color = AppColors.success;
      statusText = 'No threats detected';
    } else if (sb.isUnsafe) {
      icon = Icons.gpp_bad;
      color = AppColors.danger;
      statusText = sb.threatType ?? 'Threat detected';
    } else if (sb.isDisabled) {
      icon = Icons.shield_outlined;
      color = Colors.grey;
      statusText = 'Not configured';
    } else {
      icon = Icons.error_outline;
      color = Colors.orange;
      statusText = 'Check failed';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Google Safe Browsing',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  statusText,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            sb.isSafe ? Icons.check_circle : sb.isUnsafe ? Icons.cancel : Icons.remove_circle_outline,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildVirusTotalCard(VirusTotalResult vt) {
    IconData icon;
    Color color;
    String statusText;

    if (vt.isAnalyzed) {
      if (vt.malicious > 0) {
        icon = Icons.bug_report;
        color = AppColors.danger;
        statusText = '${vt.malicious} engine(s) flagged as malicious';
      } else if (vt.suspicious > 0) {
        icon = Icons.warning_amber;
        color = AppColors.warning;
        statusText = '${vt.suspicious} engine(s) flagged as suspicious';
      } else {
        icon = Icons.verified;
        color = AppColors.success;
        statusText = '${vt.harmless} engine(s) marked as safe';
      }
    } else if (vt.isNotFound) {
      icon = Icons.search_off;
      color = Colors.grey;
      statusText = 'Not yet analyzed';
    } else if (vt.isDisabled) {
      icon = Icons.shield_outlined;
      color = Colors.grey;
      statusText = 'Not configured';
    } else {
      icon = Icons.error_outline;
      color = Colors.orange;
      statusText = 'Check failed';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VirusTotal',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  statusText,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
          if (vt.isAnalyzed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${vt.totalEngines} engines',
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBanner(String recommendation, int score) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (score >= 70) {
      bgColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
      icon = Icons.check_circle_outline;
    } else if (score >= 50) {
      bgColor = AppColors.warning.withOpacity(0.1);
      textColor = AppColors.warning;
      icon = Icons.info_outline;
    } else {
      bgColor = AppColors.danger.withOpacity(0.1);
      textColor = AppColors.danger;
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
