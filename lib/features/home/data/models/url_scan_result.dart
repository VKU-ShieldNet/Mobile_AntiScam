class UrlScanResult {
  final String conclusion;
  final String riskLevel;
  final bool isSafe;
  final int score;
  final String explanation;
  final String advice;
  final List<String> toolsUsed;
  final bool cacheHit;

  UrlScanResult({
    required this.conclusion,
    required this.riskLevel,
    required this.isSafe,
    required this.score,
    required this.explanation,
    required this.advice,
    required this.toolsUsed,
    required this.cacheHit,
  });

  factory UrlScanResult.fromJson(Map<String, dynamic> json) {
    try {
      return UrlScanResult(
        conclusion: json['conclusion'] as String? ?? 'Unknown',
        riskLevel: json['risk_level'] as String? ?? 'unknown',
        isSafe: json['is_safe'] as bool? ?? false,
        score: (json['score'] as num?)?.toInt() ?? 0,
        explanation: json['explanation'] as String? ?? 'No explanation',
        advice: json['advice'] as String? ?? 'No advice',
        toolsUsed: (json['tools_used'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        cacheHit: json['cache_hit'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing UrlScanResult: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'conclusion': conclusion,
      'risk_level': riskLevel,
      'is_safe': isSafe,
      'score': score,
      'explanation': explanation,
      'advice': advice,
      'tools_used': toolsUsed,
      'cache_hit': cacheHit,
    };
  }
}
