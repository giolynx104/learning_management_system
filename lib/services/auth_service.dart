import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learning_management_system/models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://160.30.168.228:8080/it4788';

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required int uuid,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'PostmanRuntime/7.42.0',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'uuid': uuid,
          'role': role,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['status_code'] == 1000) {
          return {
            'success': true,
            'verify_code': responseBody['verify_code'],
          };
        } else {
          throw Exception('Signup failed: ${responseBody['message']}');
        }
      } else if (response.statusCode == 409) {
        throw Exception('User already exists: ${responseBody['message']}');
      } else {
        throw Exception('Failed to sign up: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during sign up: $e');
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'PostmanRuntime/7.42.0',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'deviceId': 1,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = User.fromJson(responseData);
        
        return {
          'success': true,
          'user': responseData,
          'token': user.token,
          'needs_verification': false,
        };
      } else if (response.statusCode == 401) {
        throw Exception('User not found or wrong password');
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getVerifyCode({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/get_verify_code'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'PostmanRuntime/7.42.0',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['verify_code'];
      } else {
        throw Exception(
            'Failed to get verification code: ${responseBody['message']}');
      }
    } catch (e) {
      throw Exception('Error getting verification code: $e');
    }
  }

  Future<bool> checkVerifyCode({
    required String email,
    required String verifyCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/check_verify_code'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'PostmanRuntime/7.42.0',
        },
        body: jsonEncode({
          'email': email,
          'verify_code': verifyCode,
        }),
      );

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Success case: message contains "1000 | OK"
        return responseBody['message']?.contains('1000 | OK') ?? false;
      } else if (response.statusCode == 409) {
        // Email already verified case
        if (responseBody.toString().contains('Email already verified')) {
          return true; // Consider already verified as success
        }
        throw Exception('Email verification failed: ${responseBody.toString()}');
      } else {
        throw Exception('Failed to verify code: ${responseBody.toString()}');
      }
    } catch (e) {
      throw Exception('Error verifying code: $e');
    }
  }
}
