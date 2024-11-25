import 'dart:developer';

import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/providers/auth_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/providers/user_service_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:learning_management_system/services/auth_service.dart';

part 'auth_provider.g.dart';

/// Manages authentication state using AsyncNotifier.
///
/// Handles:
/// - User authentication state
/// - Token management
/// - Sign in/out operations
@riverpod
class Auth extends _$Auth {
  final _storage = const FlutterSecureStorage();

  @override
  Future<User?> build() async {
    log('Auth provider building...');

    // Try to get stored token on initialization
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken != null) {
      try {
        final user = await _getUserInfo(storedToken);
        return user;
      } catch (e) {
        // If token is invalid, clear it
        await _storage.delete(key: 'auth_token');
        return null;
      }
    }
    return null;
  }

  Future<void> signIn(String token) async {
    state = const AsyncLoading();
    try {
      // Store token securely
      await _storage.write(key: 'auth_token', value: token);

      final user = await _getUserInfo(token);
      if (user != null) {
        state = AsyncData(user);
        debugPrint('Successfully signed in user: ${user.email}');
      } else {
        throw Exception('Failed to get user info after sign in');
      }
    } catch (e) {
      debugPrint('Error during sign in: $e');
      state = AsyncError(e, StackTrace.current);
      // Clean up on error
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<void> signOut() async {
    try {
      final currentToken = await _storage.read(key: 'auth_token');
      if (currentToken != null) {
        // Attempt to logout on server
        final authService = ref.read(authServiceProvider);
        await authService.signOut(currentToken);
      }
    } catch (e) {
      debugPrint('Error during server logout: $e');
      // Continue with local logout even if server logout fails
    } finally {
      // Always clear local auth state
      await _storage.delete(key: 'auth_token');
      state = const AsyncData(null);
    }
  }

  Future<User> _getUserInfo(String token) async {
    try {
      final userService = ref.read(userServiceProvider);
      final user = await userService.getUserInfo(token);
      debugPrint('Successfully got user info: $user');
      return user;
    } catch (e) {
      debugPrint('Error getting user info: $e');
      // Only rethrow if it's a real error, not a successful response
      if (e is! ApiException || e.statusCode != 200) {
        throw e;
      }
      // If we get here, we have a successful response that was incorrectly treated as an error
      final userService = ref.read(userServiceProvider);
      return await userService.getUserInfo(token);
    }
  }

  /// Handles the complete sign-in process including verification if needed
  Future<Map<String, dynamic>> handleSignIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signIn(
        email: email,
        password: password,
      );

      debugPrint('Sign in response: $response');

      if (response['success']) {
        final token = response['token'] as String;
        await signIn(token);
        return {'success': true};
      } else if (response['needs_verification']) {
        return {
          'success': false,
          'needs_verification': true,
          'verify_code': response['verify_code'],
        };
      }

      throw Exception('Sign in failed');
    } catch (e) {
      debugPrint('Error in handleSignIn: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Handles sign-in after successful verification
  Future<bool> handleSignInAfterVerification({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signIn(
        email: email,
        password: password,
      );

      if (response['success']) {
        await signIn(response['token'] as String);
        return true;
      }
      return false;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateAvatar(String filePath) async {
    try {
      final currentUser = state.value;
      if (currentUser == null || currentUser.token == null) {
        throw Exception('Not authenticated');
      }

      final authService = ref.read(authServiceProvider);
      final userData = await authService.changeInfoAfterSignup(
        token: currentUser.token!,
        filePath: filePath,
      );

      // Update the user state with new data
      final updatedUser = User(
        id: int.parse(userData['id']),
        firstName: userData['ho'] ?? '',
        lastName: userData['ten'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? '',
        avatar: userData['avatar'],
        token: currentUser.token,
      );

      state = AsyncData(updatedUser);
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      rethrow;
    }
  }
}

/// Extension methods for easier state checking
extension AuthStateX on AsyncValue<User?> {
  /// Whether there is an authenticated user
  bool get isAuthenticated =>
      whenOrNull(
        data: (user) => user != null,
      ) ??
      false;

  /// The current user's role, or null if not authenticated
  String? get userRole => whenOrNull(
        data: (user) => user?.role,
      );

  /// The current authentication token, or null if not authenticated
  String? get token => whenOrNull(
        data: (user) => user?.token,
      );
}
