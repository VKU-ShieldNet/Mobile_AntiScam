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
      debugPrint('📤 Sending POST request to $baseUrl/model/analyze');
      debugPrint('📋 Request body: {"url": "$url"}');
      
      final response = await _dio.post(
        '$baseUrl/model/analyze',
        data: {'url': url},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response data: ${response.data}');
      debugPrint('📦 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        try {
          debugPrint('🔄 Parsing response to UrlScanResult...');
          final result = UrlScanResult.fromJson(response.data as Map<String, dynamic>);
          debugPrint('✅ Successfully parsed: isSafe=${result.isSafe}, riskLevel=${result.riskLevel}');
          return result;
        } catch (parseError) {
          debugPrint('❌ JSON parsing error: $parseError');
          debugPrint('   Raw response: $response.data');
          debugPrint('   Response keys: ${(response.data as Map).keys}');
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
      debugPrint('   Error type: ${e.runtimeType}');
      throw Exception('Unexpected error: $e');
    }
  }
}
