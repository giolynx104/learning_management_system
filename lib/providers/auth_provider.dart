import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/mock_api_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final _apiService = MockApiService();

  @override
  FutureOr<void> build() {}

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _apiService.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );
      if (result['success']) {
        state = AsyncValue.data(result['user']);
      } else {
        state = AsyncValue.error(result['message'], StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
