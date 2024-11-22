import 'package:dio/dio.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<User> getUserInfo(String token, String userId) async {
    try {
      print('Debug - UserService - Getting user info with token: $token and userId: $userId');
      
      final response = await _apiService.dio.post(
        '/it4788/get_user_info',
        data: {
          'token': token,
          'userId': userId
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['code'] == "1000") {
          final userData = responseData['data'] as Map<String, dynamic>;
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
          throw Exception('Failed to get user info: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to get user info');
      }
    } on DioException catch (e) {
      print('Debug - UserService - DioException: ${e.message}');
      
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Token is invalid');
      }
      rethrow;
    } catch (e) {
      print('Debug - UserService - Error: $e');
      rethrow;
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
  
  @override
  String toString() => 'UnauthorizedException: $message';
} 