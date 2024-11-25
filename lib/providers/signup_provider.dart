import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/providers/auth_service_provider.dart';

part 'signup_provider.g.dart';

/// Provider for handling user registration functionality.
///
/// Uses [AuthService] to make the API call and returns the signup response
/// which includes verification details.
@riverpod
Future<Map<String, dynamic>> signUp(
  SignUpRef ref, {
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String role,
}) async {
  // Use read instead of watch since we don't need to watch for changes
  final authService = ref.read(authServiceProvider);

  try {
    // Attempt to sign up the user
    final response = await authService.signUp(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      password: password,
      role: role.toUpperCase(),
    );

    if (response['success'] && response['verify_code'] != null) {
      return {
        'verify_code': response['verify_code'],
        'needs_verification': true,
      };
    }

    throw Exception('Invalid signup response format');
  } catch (e) {
    // Rethrow the error to be handled by the UI
    throw Exception('Failed to sign up: $e');
  }
}
