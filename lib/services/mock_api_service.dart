class MockApiService {
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'existing@example.com') {
      return {'success': false, 'message': 'Email already registered'};
    }

    // Simulating successful registration
    return {
      'success': true,
      'message': 'Registration successful',
      'user': {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
      },
    };
  }
}
