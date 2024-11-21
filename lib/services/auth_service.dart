import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/unauthorized_exception.dart';
import 'package:learning_management_system/exceptions/api_exception.dart';

part 'auth_service.g.dart';

/// Service responsible for making authentication-related API calls.
///
/// Handles all direct communication with the authentication server including:
/// - Sign in
/// - Sign up
/// - Verification code requests
/// - Token validation
class AuthService {
  /// Dio instance for making HTTP requests
  final Dio _dio;

  /// Creates an AuthService instance using the provided Dio client
  AuthService(this._dio);

  /// Attempts to sign in a user with email and password.
  ///
  /// Makes a POST request to the login endpoint and processes the response.
  /// If the account needs verification, it will return the verification code.
  ///
  /// @param email The user's email address
  /// @param password The user's password
  /// @return A Map containing:
  ///   - success: boolean indicating if the sign-in was successful
  ///   - user: user data if sign-in was successful
  ///   - token: authentication token if sign-in was successful
  ///   - needs_verification: boolean indicating if verification is needed
  ///   - verify_code: verification code if verification is needed
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/it4788/login',
        data: {
          'email': email,
          'password': password,
          'deviceId': 1,
        },
      );

      // Handle verification required case
      if (response.statusCode == 403 && response.data['code'] == 9991) {
        final verifyCodeResponse = await _dio.post(
          '/it4788/get_verify_code',
          data: {
            'email': email,
            'password': password,
          },
        );

        if (verifyCodeResponse.statusCode == 200 &&
            verifyCodeResponse.data['code'] == 1000) {
          return {
            'success': false,
            'needs_verification': true,
            'verify_code': verifyCodeResponse.data['verify_code'],
            'email': email,
          };
        }
        throw Exception('Failed to get verification code');
      }

      // Handle successful login
      if (response.statusCode == 200 &&
          (response.data['message'] == 'OK' || response.data['code'] == 1000)) {
        final userData = response.data['data'];

        // Convert string ID to int if necessary
        if (userData['id'] is String) {
          userData['id'] = int.parse(userData['id']);
        }

        return {
          'success': true,
          'user': userData,
          'token': userData['token'],
          'needs_verification': false,
        };
      }

      throw Exception(response.data['message'] ?? 'Unknown error');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.data['code'] == 9998) {
        throw UnauthorizedException('Invalid credentials or session expired');
      } else if (e.response?.statusCode == 422) {
        throw ValidationException(
          message: 'Invalid input data',
          validationErrors: _parseValidationErrors(e.response?.data),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: e.message ?? 'Unknown error occurred',
        data: e.response?.data,
      );
    }
  }

  Map<String, List<String>> _parseValidationErrors(Map<String, dynamic>? data) {
    final errors = <String, List<String>>{};
    // Parse validation errors from response
    // Implementation depends on your API error format
    return errors;
  }

  /// Registers a new user with the provided information.
  ///
  /// @param firstName User's first name
  /// @param lastName User's last name
  /// @param email User's email address
  /// @param password User's password
  /// @param role User's role (e.g., 'STUDENT', 'LECTURER')
  /// @return A Map containing:
  ///   - success: boolean indicating if the sign-up was successful
  ///   - verify_code: verification code for the new account
  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/it4788/signup',
        data: {
          'ho': firstName,
          'ten': lastName,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return {
          'success': true,
          'verify_code': response.data['verify_code'],
        };
      }

      throw Exception(response.data['message'] ?? 'Failed to sign up');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('User already exists: ${e.response?.data['message']}');
      }
      throw Exception('Error during sign up: ${e.message}');
    }
  }

  /// Verifies a user's account using the provided verification code.
  ///
  /// @param email User's email address
  /// @param verifyCode Verification code sent to the user
  /// @return bool indicating if verification was successful
  Future<bool> checkVerifyCode({
    required String email,
    required String verifyCode,
  }) async {
    try {
      final response = await _dio.post(
        '/it4788/check_verify_code',
        data: {
          'email': email,
          'verify_code': verifyCode,
        },
      );

      return response.statusCode == 200 &&
          (response.data['message'] == 'OK' || response.data['code'] == 1000);
    } on DioException {
      return false;
    }
  }
}

/// Provider for the AuthService instance
@riverpod
AuthService authService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService.dio);
}
