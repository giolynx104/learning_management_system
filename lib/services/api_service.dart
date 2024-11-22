import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';

part 'api_service.g.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = 'http://157.66.24.126:8080';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for better error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401 || 
            (e.response?.data is Map && e.response?.data['code'] == 9998)) {
          // Only throw UnauthorizedException for actual auth errors
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: UnauthorizedException('Token is invalid or expired'),
            ),
          );
        } else {
          // For other errors, just pass them through
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
