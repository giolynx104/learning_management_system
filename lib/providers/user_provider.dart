import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/user.dart';
import 'package:learning_management_system/services/user_service.dart';
import 'package:learning_management_system/services/storage_service.dart';

part 'user_provider.g.dart';

@riverpod
class UserState extends _$UserState {
  @override
  Future<User?> build() async {
    return _fetchUserInfo();
  }

  Future<User?> _fetchUserInfo() async {
    try {
      final storageService = StorageService();
      final token = await storageService.getToken();
      final userId = await storageService.getUserId();
      if (token == null||userId == null) return null;

      final userService = ref.read(userServiceProvider);
      return await userService.getUserInfo(token,userId);
    } on UnauthorizedException {
      // Clear invalid token
      final storageService = StorageService();
      await storageService.clearUserSession();
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchUserInfo());
  }
}

@riverpod
UserService userService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
} 