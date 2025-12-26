import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/network_config.dart';
import '../models/url_scan_result.dart';

class UrlScanService {
  final Dio _dio;
  final String baseUrl;

  UrlScanService({
    required Dio dio,
    this.baseUrl = 'http://10.0.2.2:8000', // Default: emulator
  }) : _dio = dio {
    // Configure Dio with proper settings
    NetworkConfig.configureBackendDio(_dio);
    _dio.options.baseUrl = baseUrl;
  }

  /// Factory constructor for easier creation
  factory UrlScanService.create({bool isEmulator = true}) {
    final baseUrl = NetworkConfig.getBackendUrl(isEmulator: isEmulator);
    return UrlScanService(
      dio: Dio(),
      baseUrl: baseUrl,
    );
  }

  /// Scan a URL for potential scams
  /// Returns [UrlScanResult] with analysis details
  Future<UrlScanResult> scanUrl(String url) async {
    try {
      debugPrint('📤 Sending POST request to $baseUrl/scan/website');
      debugPrint('📋 Request body: {"url": "$url"}');

      final response = await _dio.post(
        '$baseUrl/scan/website',
        data: {'url': url},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 45), // Increased timeout for analysis
        ),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response data available: ${response.data != null}');

      if (response.statusCode == 200) {
        try {
          debugPrint('🔄 Parsing response to UrlScanResult...');
          final result = UrlScanResult.fromJson(response.data as Map<String, dynamic>);
          debugPrint('✅ Successfully parsed: isSafe=${result.isSafe}, score=${result.riskScore}');
          return result;
        } catch (parseError) {
          debugPrint('❌ JSON parsing error: $parseError');
          throw Exception('Failed to parse response: $parseError\nResponse: ${response.data}');
        }
      } else {
        throw Exception('Failed to scan URL: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🌐 DioException occurred');
      debugPrint('   Type: ${e.type}');
      debugPrint('   Message: ${e.message}');
      if (e.response != null) {
        debugPrint('   Response status: ${e.response?.statusCode}');
        debugPrint('   Response data: ${e.response?.data}');
        throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('⚠️ Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get website preview (screenshot)
  Future<WebsitePreviewResult> getWebsitePreview(String url) async {
    try {
      debugPrint('📤 Sending POST request to $baseUrl/preview/website');

      final response = await _dio.post(
        '$baseUrl/preview/website',
        data: {'url': url},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return WebsitePreviewResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get preview: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Error getting preview: $e');
      throw Exception('Failed to load website preview');
    }
  }

  /// Check URL reputation using third-party APIs (Google Safe Browsing, VirusTotal)
  Future<ReputationResult> getReputationCheck(String url) async {
    try {
      debugPrint('📤 Sending POST request to $baseUrl/scan/website/reputation');

      final response = await _dio.post(
        '$baseUrl/scan/website/reputation',
        data: {'url': url},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Reputation check completed');
        return ReputationResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to check reputation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🌐 DioException in reputation check: ${e.message}');
      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('⚠️ Error checking reputation: $e');
      throw Exception('Failed to check URL reputation');
    }
  }
}
