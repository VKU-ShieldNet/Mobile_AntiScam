import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/network_config.dart';
import '../models/text_scan_result.dart';

class TextScanService {
  final Dio _dio;
  final String baseUrl;

  TextScanService({
    required Dio dio,
    this.baseUrl = 'http://10.0.2.2:8000',
  }) : _dio = dio {
    NetworkConfig.configureBackendDio(_dio);
    _dio.options.baseUrl = baseUrl;
  }

  factory TextScanService.create({bool isEmulator = true}) {
    final baseUrl = NetworkConfig.getBackendUrl(isEmulator: isEmulator);
    return TextScanService(
      dio: Dio(),
      baseUrl: baseUrl,
    );
  }

  Future<TextScanResult> scanText(String text) async {
    try {
      debugPrint('📤 Sending POST request to $baseUrl/text/analyze');
      debugPrint('📋 Request body: {"text": "$text"}');
      
      final response = await _dio.post(
        '$baseUrl/text/analyze',
        data: {'text': text},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📦 Response data: ${response.data}');
      debugPrint('📦 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        try {
          debugPrint('🔄 Parsing response to TextScanResult...');
          final result = TextScanResult.fromJson(response.data as Map<String, dynamic>);
          debugPrint('✅ Successfully parsed: isSafe=${result.isSafe}, label=${result.label}');
          return result;
        } catch (parseError) {
          debugPrint('❌ JSON parsing error: $parseError');
          debugPrint('   Raw response: $response.data');
          debugPrint('   Response keys: ${(response.data as Map).keys}');
          throw Exception('Failed to parse response: $parseError\nResponse: ${response.data}');
        }
      } else {
        throw Exception('Failed to scan text: ${response.statusCode}');
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
