import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/services/api_service.dart';

class VerificationService {
  final Dio _dio;
  final String _baseUrl;

  VerificationService() 
      : _baseUrl = ApiService().baseUrl,
        _dio = Dio();

  Future<String> getVerificationCode({
    required String email, 
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/get_verify_code',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is String && responseData.contains('Verification code sent:')) {
          final code = responseData.split('Verification code sent:').last.trim();
          print('Extracted code: $code');
          return code;
        }
        throw const VerificationException('Invalid response format');
      } else if (response.statusCode == 409) {
        throw const VerificationException('Email already verified');
      } else {
        throw const VerificationException('Failed to get verification code');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const VerificationException('Email already verified');
      }
      throw VerificationException(e.message ?? 'Network error occurred');
    } catch (e) {
      if (e is VerificationException) rethrow;
      throw VerificationException(e.toString());
    }
  }

  Future<int> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/verify_code',
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('userId')) {
          return responseData['userId'] as int;
        }
        throw const VerificationException('Invalid response format');
      } else if (response.statusCode == 409) {
        throw const VerificationException('Email already verified');
      } else {
        throw const VerificationException('Invalid verification code');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const VerificationException('Email already verified');
      }
      throw VerificationException(e.message ?? 'Network error occurred');
    } catch (e) {
      if (e is VerificationException) rethrow;
      throw VerificationException(e.toString());
    }
  }
}

class VerificationException implements Exception {
  final String message;
  const VerificationException(this.message);

  @override
  String toString() => message;
}

final verificationServiceProvider = Provider((ref) => VerificationService());
