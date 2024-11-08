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
    
    if (token == null) return null;
    
    try {
      final user = await ref.read(userServiceProvider).getUserInfo(token);
      print('Debug - Auth build - Got user: $user');
      return user.copyWith(token: token);
    } catch (e) {
      print('Debug - Auth build - Error: $e');
      await StorageService().clearToken();
      return null;
    }
  }

  Future<void> login(User user, String token) async {
    print('Debug - Auth login - Token: $token');
    await StorageService().saveToken(token);
    state = AsyncValue.data(user.copyWith(token: token));
  }

  Future<void> logout() async {
    await StorageService().clearToken();
    state = const AsyncValue.data(null);
  }
}

@riverpod
ApiService apiService(ApiServiceRef ref) => ApiService();

@riverpod
UserService userService(UserServiceRef ref) => 
    UserService(ref.watch(apiServiceProvider));
