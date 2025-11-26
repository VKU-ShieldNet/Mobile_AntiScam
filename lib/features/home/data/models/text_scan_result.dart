class TextScanResult {
  final String label;
  final bool isSafe;
  final List<String> evidence;
  final List<String> recommendation;

  TextScanResult({
    required this.label,
    required this.isSafe,
    required this.evidence,
    required this.recommendation,
  });

  factory TextScanResult.fromJson(Map<String, dynamic> json) {
    try {
      return TextScanResult(
        label: json['label'] as String? ?? 'KHÔNG RÕ',
        isSafe: json['is_safe'] as bool? ?? true,
        evidence: List<String>.from(json['evidence'] as List? ?? []),
        recommendation: List<String>.from(json['recommendation'] as List? ?? []),
      );
    } catch (e) {
      print('Error parsing TextScanResult: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'is_safe': isSafe,
      'evidence': evidence,
      'recommendation': recommendation,
    };
  }
}
