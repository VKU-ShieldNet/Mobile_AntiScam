class UrlScanResult {
  final String url;
  final bool isSafe;
  final int riskScore;
  final WebsiteChecks checks;
  final String geminiAnalysis;
  final int analysisTimeMs;

  UrlScanResult({
    required this.url,
    required this.isSafe,
    required this.riskScore,
    required this.checks,
    required this.geminiAnalysis,
    required this.analysisTimeMs,
  });

  factory UrlScanResult.fromJson(Map<String, dynamic> json) {
    return UrlScanResult(
      url: json['url'] as String? ?? '',
      isSafe: json['is_safe'] as bool? ?? false,
      riskScore: (json['risk_score'] as num?)?.toInt() ?? 0,
      checks: WebsiteChecks.fromJson(json['checks'] as Map<String, dynamic>? ?? {}),
      geminiAnalysis: json['gemini_analysis'] as String? ?? 'No analysis available',
      analysisTimeMs: (json['analysis_time_ms'] as num?)?.toInt() ?? 0,
    );
  }
}

class WebsiteChecks {
  final SSLCheck ssl;
  final DomainAgeCheck domainAge;
  final SuspiciousKeywordsCheck suspiciousKeywords;

  WebsiteChecks({
    required this.ssl,
    required this.domainAge,
    required this.suspiciousKeywords,
  });

  factory WebsiteChecks.fromJson(Map<String, dynamic> json) {
    return WebsiteChecks(
      ssl: SSLCheck.fromJson(json['ssl'] as Map<String, dynamic>? ?? {}),
      domainAge: DomainAgeCheck.fromJson(json['domain_age'] as Map<String, dynamic>? ?? {}),
      suspiciousKeywords: SuspiciousKeywordsCheck.fromJson(json['suspicious_keywords'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SSLCheck {
  final bool valid;
  final String? issuer;
  final String? expires;
  final int? daysUntilExpiry;
  final String? error;

  SSLCheck({
    required this.valid,
    this.issuer,
    this.expires,
    this.daysUntilExpiry,
    this.error,
  });

  factory SSLCheck.fromJson(Map<String, dynamic> json) {
    return SSLCheck(
      valid: json['valid'] as bool? ?? false,
      issuer: json['issuer'] as String?,
      expires: json['expires'] as String?,
      daysUntilExpiry: (json['days_until_expiry'] as num?)?.toInt(),
      error: json['error'] as String?,
    );
  }
}

class DomainAgeCheck {
  final int? ageDays;
  final bool isNew;
  final bool? isVeryNew;
  final bool? estimated;
  final String? error;

  DomainAgeCheck({
    this.ageDays,
    required this.isNew,
    this.isVeryNew,
    this.estimated,
    this.error,
  });

  factory DomainAgeCheck.fromJson(Map<String, dynamic> json) {
    return DomainAgeCheck(
      ageDays: (json['age_days'] as num?)?.toInt(),
      isNew: json['is_new'] as bool? ?? false,
      isVeryNew: json['is_very_new'] as bool?,
      estimated: json['estimated'] as bool?,
      error: json['error'] as String?,
    );
  }
}

class SuspiciousKeywordsCheck {
  final List<String> found;
  final int count;
  final String riskLevel;

  SuspiciousKeywordsCheck({
    required this.found,
    required this.count,
    required this.riskLevel,
  });

  factory SuspiciousKeywordsCheck.fromJson(Map<String, dynamic> json) {
    return SuspiciousKeywordsCheck(
      found: List<String>.from(json['found'] as List? ?? []),
      count: (json['count'] as num?)?.toInt() ?? 0,
      riskLevel: json['risk_level'] as String? ?? 'safe',
    );
  }
}

class WebsitePreviewResult {
  final String url;
  final String screenshotBase64;
  final Map<String, dynamic> metadata;
  final String? error;

  WebsitePreviewResult({
    required this.url,
    required this.screenshotBase64,
    required this.metadata,
    this.error,
  });

  factory WebsitePreviewResult.fromJson(Map<String, dynamic> json) {
    return WebsitePreviewResult(
      url: json['url'] as String? ?? '',
      screenshotBase64: json['screenshot_base64'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      error: json['error'] as String?,
    );
  }
}

// ========== THIRD-PARTY REPUTATION MODELS ==========

class ReputationResult {
  final String url;
  final int reputationScore;
  final SafeBrowsingResult safeBrowsing;
  final VirusTotalResult virusTotal;
  final String recommendation;

  ReputationResult({
    required this.url,
    required this.reputationScore,
    required this.safeBrowsing,
    required this.virusTotal,
    required this.recommendation,
  });

  factory ReputationResult.fromJson(Map<String, dynamic> json) {
    final sources = json['sources'] as Map<String, dynamic>? ?? {};
    return ReputationResult(
      url: json['url'] as String? ?? '',
      reputationScore: (json['reputation_score'] as num?)?.toInt() ?? 50,
      safeBrowsing: SafeBrowsingResult.fromJson(
        sources['safe_browsing'] as Map<String, dynamic>? ?? {},
      ),
      virusTotal: VirusTotalResult.fromJson(
        sources['virustotal'] as Map<String, dynamic>? ?? {},
      ),
      recommendation: json['recommendation'] as String? ?? 'Unknown',
    );
  }
}

class SafeBrowsingResult {
  final String status; // 'safe', 'unsafe', 'error', 'disabled'
  final String? threatType;
  final String? message;
  final String? error;

  SafeBrowsingResult({
    required this.status,
    this.threatType,
    this.message,
    this.error,
  });

  bool get isSafe => status == 'safe';
  bool get isUnsafe => status == 'unsafe';
  bool get isDisabled => status == 'disabled';
  bool get isError => status == 'error';

  factory SafeBrowsingResult.fromJson(Map<String, dynamic> json) {
    return SafeBrowsingResult(
      status: json['status'] as String? ?? 'error',
      threatType: json['threat_type'] as String?,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

class VirusTotalResult {
  final String status; // 'analyzed', 'not_found', 'error', 'disabled'
  final int malicious;
  final int suspicious;
  final int harmless;
  final int undetected;
  final String? message;
  final String? error;

  VirusTotalResult({
    required this.status,
    this.malicious = 0,
    this.suspicious = 0,
    this.harmless = 0,
    this.undetected = 0,
    this.message,
    this.error,
  });

  bool get isAnalyzed => status == 'analyzed';
  bool get isNotFound => status == 'not_found';
  bool get isDisabled => status == 'disabled';
  bool get isError => status == 'error';

  int get totalEngines => malicious + suspicious + harmless + undetected;

  factory VirusTotalResult.fromJson(Map<String, dynamic> json) {
    return VirusTotalResult(
      status: json['status'] as String? ?? 'error',
      malicious: (json['malicious'] as num?)?.toInt() ?? 0,
      suspicious: (json['suspicious'] as num?)?.toInt() ?? 0,
      harmless: (json['harmless'] as num?)?.toInt() ?? 0,
      undetected: (json['undetected'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}
