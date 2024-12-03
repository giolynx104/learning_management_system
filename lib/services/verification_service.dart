import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/constants/api_constants.dart';

part 'verification_service.g.dart';

class VerificationService {
  final ApiService _apiService;

  VerificationService(this._apiService);

  Future<String> getVerificationCode({
    required String email, 
    required String password,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.getVerifyCode,
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
      final response = await _apiService.dio.post(
        ApiConstants.checkVerifyCode,
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

@riverpod
VerificationService verificationService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return VerificationService(apiService);
}
