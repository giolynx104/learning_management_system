import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/services/api_service.dart';

/// Service responsible for making authentication-related API calls.
///
/// Handles all direct communication with the authentication server including:
/// - Sign in
/// - Sign up
/// - Verification code requests
/// - Token validation
class AuthService {
  /// ApiService instance for making HTTP requests
  final ApiService _apiService;

  /// Creates an AuthService instance using the provided ApiService
  AuthService(this._apiService);

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
      debugPrint('Attempting sign in for email: $email');
      final response = await _apiService.dio.post(
        '/it4788/login',
        data: {
          'email': email,
          'password': password,
          'device_id': "1",
        },
      );
      debugPrint('Login response: ${response.data}');

      // Handle verification required case
      if (response.statusCode == 403 &&
          response.data['code'].toString() == '9991') {
        final verifyCodeResponse = await _apiService.dio.post(
          '/it4788/get_verify_code',
          data: {
            'email': email,
            'password': password,
          },
        );

        if (verifyCodeResponse.statusCode == 200 &&
            verifyCodeResponse.data['code'].toString() == '1000') {
          return {
            'success': false,
            'needs_verification': true,
            'verify_code': verifyCodeResponse.data['verify_code'],
            'email': email,
          };
        }
        throw ApiException(
          statusCode: verifyCodeResponse.statusCode,
          message: 'Failed to get verification code',
        );
      }

      // Handle successful login
      if (response.statusCode == 200 &&
          (response.data['message'] == 'OK' ||
              response.data['code'].toString() == '1000')) {
        final userData = response.data['data'];
        debugPrint('User data from login: $userData');

        // Convert string ID to int if necessary
        final id = userData['id'] is String
            ? int.parse(userData['id'])
            : userData['id'] as int;

        // Map the response data to match User model fields
        final mappedUserData = {
          'id': id,
          'firstName': userData['ho'] ?? '',
          'lastName': userData['ten'] ?? '',
          'email': userData['email'] ?? '',
          'role': userData['role'] ?? '',
          'avatar': userData['avatar'],
          'token': userData['token'],
        };
        debugPrint('Mapped user data: $mappedUserData');

        return {
          'success': true,
          'user': mappedUserData,
          'token': userData['token'],
          'needs_verification': false,
        };
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: response.data['message'] ?? 'Unknown error',
      );
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
  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it4788/signup',
        data: {
          'ho': firstName,
          'ten': lastName,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      if (response.statusCode == 200 &&
          response.data['code'].toString() == '1000') {
        return {
          'success': true,
          'verify_code': response.data['verify_code'],
        };
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: response.data['message'] ?? 'Failed to sign up',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ApiException(
          statusCode: 409,
          message: 'User already exists: ${e.response?.data['message']}',
        );
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Error during sign up: ${e.message}',
      );
    }
  }

  /// Verifies a user's account using the provided verification code.
  Future<bool> checkVerifyCode({
    required String email,
    required String verifyCode,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it4788/check_verify_code',
        data: {
          'email': email,
          'verify_code': verifyCode,
        },
      );

      return response.statusCode == 200 &&
          (response.data['message'] == 'OK' ||
              response.data['code'].toString() == '1000');
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Error verifying code: ${e.message}',
      );
    }
  }

  /// Signs out the user by invalidating their token on the server
  ///
  /// @param token The authentication token to invalidate
  /// @return bool indicating if logout was successful
  Future<bool> signOut(String token) async {
    try {
      final response = await _apiService.dio.post(
        '/it4788/logout',
        data: {
          'token': token,
        },
      );

      return response.statusCode == 200 && response.data['code'] == '1000';
    } on DioException catch (e) {
      debugPrint('Error during logout: ${e.message}');
      // We'll still clear local auth state even if server logout fails
      return false;
    }
  }

  /// Updates user information after signup including avatar
  Future<Map<String, dynamic>> changeInfoAfterSignup({
    required String token,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'token': token,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _apiService.dio.post(
        '/it4788/change_info_after_signup',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && 
          response.data['code'].toString() == '1000') {
        return response.data['data'];
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: response.data['message'] ?? 'Failed to update profile',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid token or session expired');
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Error updating profile: ${e.message}',
      );
    }
  }

  /// Changes the user's password
  Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it4788/change_password',
        data: {
          'token': token,
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == '1000') {
        return;
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: response.data['message'] ?? 'Failed to change password',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials or session expired');
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: e.response?.data['message'] ?? 'Failed to change password',
      );
    }
  }
}
