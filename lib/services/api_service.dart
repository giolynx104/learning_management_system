import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_service.g.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = 'http://157.66.24.126:8080';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.options.validateStatus = (status) => status != null && status < 500;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for better error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🌐 Request: ${options.method} ${options.uri}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('📥 Response: ${response.statusCode}');
        debugPrint('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('❌ Error: ${e.type}');
        debugPrint('Message: ${e.message}');
        debugPrint('Response: ${e.response?.data}');
        
        if (e.type == DioExceptionType.unknown) {
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: NetworkException(
                message: 'Connection failed. Please check your internet connection.',
              ),
            ),
          );
        }
        
        if (e.response?.statusCode == 401 ||
            (e.response?.data is Map && e.response?.data['code'] == '9998')) {
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: UnauthorizedException('Token is invalid or expired'),
            ),
          );
        } else {
          handler.next(e);
        }
      },
    ));
  }

  Dio get dio => _dio;
}

@riverpod
ApiService apiService(Ref ref) {
  return ApiService();
}
