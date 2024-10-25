import 'package:http/http.dart' as http;
import 'dart:convert';

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
        return responseBody;
      } else if (response.statusCode == 409) {
        // Handle the 409 Conflict specifically
        throw Exception('User already exists: ${responseBody['message']}');
      } else {
        // Handle other status codes
        throw Exception('Failed to sign up: ${response.body}');
      }
    } catch (e) {
      // Handle any network or other errors
      throw Exception('Error during sign up: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required int deviceId,
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
          'deviceId': deviceId,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Assuming the response includes a 'role' field
        if (!responseBody.containsKey('role')) {
          throw Exception('Role information is missing from the response');
        }
        return responseBody;
      } else if (response.statusCode == 401) {
        throw Exception('User not found or wrong password');
      } else {
        throw Exception('Failed to login: ${responseBody['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
