import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Network configuration for different environments
class NetworkConfig {
  /// Get backend URL based on environment
  static String getBackendUrl({bool isEmulator = true}) {
    if (isEmulator) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://192.168.1.11:8000';
    }
  }

  static void configureBackendDio(Dio dio) {
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );

    // Add simple interceptor for debugging API calls
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🌐 [API] ${options.method} ${options.path}');
          debugPrint('📤 Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [API] ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ [API] Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }
}
