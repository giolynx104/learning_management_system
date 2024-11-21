import 'package:dio/dio.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';

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
      final response = await _apiService.dio.post(
        '/it4788/get_user_info',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        if (responseData['code'] == 1000) {
          final userData = responseData['data'] as Map<String, dynamic>;
          if (userData == null) {
            throw const UserNotFoundException('User not found');
          }

          final mappedData = {
            'id': userData['id'],
            'ho': userData['ho'] ?? '',
            'ten': userData['ten'] ?? '',
            'username': userData['email'] ?? userData['name'] ?? '',
            'token': token,
            'active': userData['status'] ?? 'Active',
            'role': userData['role'] ?? '',
            'class_list': userData['class_list'] ?? [],
            'avatar': userData['avatar'],
          };
          
          return User.fromJson(mappedData);
        } else {
          throw ApiException(
            statusCode: response.statusCode,
            message: responseData['message'] ?? 'Failed to get user info',
          );
        }
      }
      
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to get user info',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Token is invalid');
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: 'Error fetching user info: ${e.message}',
      );
    }
  }
}