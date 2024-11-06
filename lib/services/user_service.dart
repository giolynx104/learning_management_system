import 'package:dio/dio.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<User> getUserInfo(String token) async {
    try {
      final response = await _apiService.dio.post(
        '/it4788/get_user_info',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception('Failed to get user info');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Token is invalid');
      }
      rethrow;
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
} 