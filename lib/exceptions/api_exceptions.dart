import 'package:dio/dio.dart';

/// Base exception class for API-related errors.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, dynamic>? data;

  const ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      final responseData = error.response?.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>?;
      
      return ApiException(
        message: meta?['message'] ?? responseData['message'] ?? 'Unknown error occurred',
        statusCode: error.response?.statusCode,
        data: responseData,
      );
    }

    // Handle different DioException types
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection');
      default:
        return ApiException(
          message: error.message ?? 'Unknown error occurred',
          statusCode: error.response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}

/// Exception for authentication and authorization errors.
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message)
      : super(
          statusCode: 401,
          message: message,
        );
}

/// Exception for network-related failures.
class NetworkException extends ApiException {
  const NetworkException({required String message}) : super(message: message);
}

/// Exception for validation errors from the API.
class ValidationException extends ApiException {
  final Map<String, List<String>> validationErrors;

  const ValidationException({
    required super.message,
    required this.validationErrors,
    int? statusCode,
  }) : super(
          statusCode: statusCode ?? 422,
        );

  @override
  String toString() {
    return 'ValidationException: $message\nValidation Errors: $validationErrors';
  }
}

class UserNotFoundException implements Exception {
  final String message;
  
  const UserNotFoundException(this.message);
  
  @override
  String toString() => 'UserNotFoundException: $message';
} 