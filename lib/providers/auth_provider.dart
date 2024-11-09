import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    final token = await StorageService().getToken();
    print('Debug - Auth build - Token from storage: $token');

    if (token == null) {
      print('Debug - Auth build - No token found in storage');
      return null;
    }

    try {
      final user = await ref.read(userServiceProvider).getUserInfo(token);
      print('Debug - Auth build - Got user: $user');
      final userWithToken = user.copyWith(token: token);
      print('Debug - Auth build - User with token: $userWithToken');
      return userWithToken;
    } catch (e) {
      print('Debug - Auth build - Error: $e');
      await StorageService().clearToken();
      return null;
    }
  }

  Future<void> login(User user, String token) async {
    print('Debug - Auth login - Starting login');
    print('Debug - Auth login - Token: $token');
    print('Debug - Auth login - User: $user');

    await StorageService().saveToken(token);
    final savedToken = await StorageService().getToken();
    print('Debug - Auth login - Saved token verification: $savedToken');

    state = AsyncValue.data(user.copyWith(token: token));
    print('Debug - Auth login - State updated');
  }

  Future<void> logout() async {
    print('Debug - Auth logout - Starting logout');
    await StorageService().clearToken();
    state = const AsyncValue.data(null);
    print('Debug - Auth logout - Completed logout');
  }
}

@riverpod
ApiService apiService(ApiServiceRef ref) => ApiService();

@riverpod
UserService userService(UserServiceRef ref) =>
    UserService(ref.watch(apiServiceProvider));
