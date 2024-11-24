import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/services/user_service.dart';
import 'package:learning_management_system/providers/user_service_provider.dart';
import 'package:learning_management_system/providers/storage_provider.dart';

part 'auth_provider.g.dart';

/// Manages authentication state using AsyncNotifier.
///
/// Handles:
/// - User authentication state
/// - Token management
/// - Sign in/out operations
@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() async {
    debugPrint('Auth provider building...');
    
    // Check for stored token
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    
    if (token == null) {
      debugPrint('No token found in storage');
      return null;
    }

    try {
      // Try to get user info with stored token
      final userService = ref.read(userServiceProvider);
      final user = await userService.getUserInfo(token);
      debugPrint('Successfully retrieved user info: ${user.toJson()}');
      return user;
    } catch (e) {
      debugPrint('Error getting user info: $e');
      // Clear invalid token
      await storage.clearToken();
      return null;
    }
  }

  Future<void> signIn(User user, String token) async {
    debugPrint('AuthProvider signIn called with token: $token');
    final storage = ref.read(secureStorageProvider);
    await storage.setToken(token);
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearToken();
    state = const AsyncData(null);
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
