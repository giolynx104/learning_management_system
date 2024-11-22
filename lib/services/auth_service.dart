import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:learning_management_system/models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://157.66.24.126:8080/it4788';

  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
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
          'ho': firstName,
          'ten': lastName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['code'] == "1000") {
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
          'device_id': 1,
          'fcm_token': null,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Debug - Raw response data: $responseData');
        final code = responseData['code']?.toString();
        if (responseData['code'] == "1000") {
          final userData = responseData['data'];
          final user = User.fromJson(userData);
          
          return {
            'success': true,
            'user': userData,
            'token': userData['token'],
            'needs_verification': false,
          };
        } else {
          throw Exception('Login failed: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to sign in: ${response.body}');
      }
    } catch (e) {
      print('Debug - Sign in error: $e');
      throw Exception('Error during sign in: $e');
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
      debugPrint('Sending verification request with email: $email, code: $verifyCode');
      
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

      debugPrint('Verification response status: ${response.statusCode}');
      debugPrint('Verification response body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Simply check if code is 1000
        return responseBody['code'] == "1000";
      }
      
      return false;
    } catch (e) {
      debugPrint('Verification error: $e');
      throw Exception('Error verifying code: $e');
    }
  }
}
