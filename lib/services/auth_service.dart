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
}