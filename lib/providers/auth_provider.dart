import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/services/user_service.dart';
import 'package:learning_management_system/providers/user_service_provider.dart';

part 'auth_provider.g.dart';

/// Manages authentication state using AsyncNotifier.
///
/// Handles:
/// - User authentication state
/// - Token management
/// - Sign in/out operations
@riverpod
class Auth extends _$Auth {
  late final StorageService _storage = StorageService();
  late final UserService _userService = ref.read(userServiceProvider);

  @override
  FutureOr<User?> build() async {
    return _getCurrentUser();
  }

  /// Fetches the current user using the stored token.
  ///
  /// Returns null if:
  /// - No token is found
  /// - Token is invalid
  /// - User fetch fails
  Future<User?> _getCurrentUser() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        debugPrint('No token found');
        return null;
      }

      return await _userService.getUserInfo(token);
    } catch (e) {
      debugPrint('Auth error: $e');
      await _storage.clearToken();
      return null;
    }
  }

  /// Signs in a user with the provided credentials.
  ///
  /// Updates the state and stores the token on successful sign in.
  Future<void> signIn(User user, String token) async {
    state = const AsyncValue.loading();

    try {
      await _storage.saveToken(token);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      await _storage.clearToken();
    }
  }

  /// Signs out the current user.
  ///
  /// Clears the stored token and resets the state.
  Future<void> signOut() async {
    await _storage.clearToken();
    state = const AsyncValue.data(null);
  }

  /// Updates the current user's information.
  ///
  /// Useful when user data changes but authentication remains valid.
  void updateUserInfo(User updatedUser) {
    if (!state.isLoading) {
      state = AsyncValue.data(updatedUser);
    }
  }
}

/// Extension methods for easier state checking
extension AuthStateX on AsyncValue<User?> {
  /// Whether there is an authenticated user
  bool get isAuthenticated => whenOrNull(
        data: (user) => user != null,
      ) ?? false;

  /// The current user's role, or null if not authenticated
  String? get userRole => whenOrNull(
        data: (user) => user?.role,
      );

  /// The current authentication token, or null if not authenticated
  String? get token => whenOrNull(
        data: (user) => user?.token,
      );
}
