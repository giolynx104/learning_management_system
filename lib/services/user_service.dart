import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/constants/api_constants.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// Fetches user information using the provided token.
  ///
  /// Throws:
  /// - [UnauthorizedException] if token is invalid
  /// - [UserNotFoundException] if user doesn't exist
  /// - [ApiException] for other API errors
  Future<User> getUserInfo(String token) async {
    try {
      debugPrint('GetUserInfo called with token: $token');
      if (token.isEmpty) {
        throw const ApiException(
          statusCode: null,
          message: 'Token cannot be empty',
        );
      }

      final response = await _apiService.dio.post(
        ApiConstants.getUserInfo,
        data: {'token': token},
      );
      debugPrint('GetUserInfo raw response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('Response data code: ${responseData['code']}');

      if (responseData['code'].toString() == ApiConstants.successCode && responseData['data'] != null) {
        final userData = responseData['data'];
        
        // Convert ID to int if it's a string
        final id = userData['id'] is String 
            ? int.parse(userData['id']) 
            : userData['id'] as int;
            
        final mappedData = {
          'id': id,
          'firstName': userData['ho'] ?? '',
          'lastName': userData['ten'] ?? '',
          'email': userData['email'] ?? '',
          'role': userData['role'] ?? '',
          'avatar': userData['avatar'],
          'token': token,
        };
        return User.fromJson(mappedData);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: responseData['message'] ?? 'Failed to get user info',
      );
    } on DioException catch (e) {
      debugPrint('DioException in getUserInfo: $e');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Token is invalid or expired');
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Error fetching user info: ${e.message}',
      );
    }
  }
}
