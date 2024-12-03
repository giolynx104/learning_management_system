import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/user_service.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';

part 'user_provider.g.dart';

/// Manages the current user's state and information.
/// 
/// This provider:
/// 1. Fetches user information when initialized
/// 2. Handles token validation
/// 3. Provides methods to refresh user data
/// 4. Manages loading and error states
@riverpod
class UserState extends _$UserState {
  late final StorageService _storage;
  late final UserService _userService;
  
  @override
  Future<User?> build() async {
    _storage = StorageService();
    _userService = ref.read(userServiceProvider);
    return _fetchUserInfo();
  }

  /// Fetches the current user's information using their auth token.
  /// 
  /// Returns null if:
  /// - No token is found
  /// - Token is invalid
  /// - User doesn't exist
  /// 
  /// Throws [ApiException] for network or server errors.
  Future<User?> _fetchUserInfo() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        debugPrint('No token found');
        return null;
      }

      final user = await _userService.getUserInfo(token);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Handles authentication errors by clearing the token and notifying listeners.
  Future<void> _handleAuthError() async {
    await _storage.clearToken();
    ref.invalidateSelf(); // Invalidate this provider
  }

  /// Refreshes the user's information.
  /// 
  /// Updates the state to loading while fetching new data.
  /// Handles errors gracefully and updates state accordingly.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUserInfo());
  }

  /// Updates specific user information locally.
  /// 
  /// Use this method when you need to update user data without
  /// fetching everything again from the server.
  /// 
  /// Returns false if there's no current user.
  bool updateUserInfo(User updatedUser) {
    if (state case AsyncData(value: User?)) {
      state = AsyncValue.data(updatedUser);
      return true;
    }
    return false;
  }

  /// Signs out the current user.
  /// 
  /// Clears the token and user data.
  Future<void> signOut() async {
    await _storage.clearToken();
    state = const AsyncValue.data(null);
  }
}

/// Provider for UserService instance.
/// 
/// Uses [ApiService] for making HTTP requests.
@riverpod
UserService userService(UserServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
} 