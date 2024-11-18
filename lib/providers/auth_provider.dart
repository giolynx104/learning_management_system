import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'dart:developer' as dev;

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    final token = await StorageService().getToken();
    dev.log('Auth build - Token from storage: $token');

    if (token == null) {
      dev.log('Auth build - No token found in storage');
      return null;
    }

    try {
      final user = await ref.read(userServiceProvider).getUserInfo(token);
      dev.log('Auth build - Got user: $user');
      final userWithToken = user.copyWith(token: token);
      dev.log('Auth build - User with token: $userWithToken');
      return userWithToken;
    } catch (e) {
      dev.log('Auth build - Error: $e');
      await StorageService().clearToken();
      return null;
    }
  }

  Future<void> login(User user, String token) async {
    dev.log('Auth login - Starting login');
    dev.log('Auth login - Token: $token');
    dev.log('Auth login - User: $user');

    await StorageService().saveToken(token);
    final savedToken = await StorageService().getToken();
    dev.log('Auth login - Saved token verification: $savedToken');

    state = AsyncValue.data(user.copyWith(token: token));
    dev.log('Auth login - State updated');
  }

  Future<void> logout() async {
    dev.log('Auth logout - Starting logout');
    await StorageService().clearToken();
    state = const AsyncValue.data(null);
    dev.log('Auth logout - Completed logout');
  }
}

@riverpod
ApiService apiService(Ref ref) => ApiService();

@riverpod
UserService userService(Ref ref) =>
    UserService(ref.watch(apiServiceProvider));
