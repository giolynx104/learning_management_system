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

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
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
  NetworkException({String? message})
      : super(
          message: message ?? 'Network connection failed',
          statusCode: null,
        );
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