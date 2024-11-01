import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/services/storage_service.dart';
import 'package:learning_management_system/models/user.dart';

final authServiceProvider = Provider((ref) => AuthService());
final storageServiceProvider = Provider((ref) => StorageService());

final signUpProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, signUpData) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signUp(
    email: signUpData['email'] as String,
    password: signUpData['password'] as String,
    uuid: signUpData['uuid'] as int,
    role: signUpData['role'] as String,
  );
});

final loginProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, loginData) async {
  final authService = ref.watch(authServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  
  final response = await authService.login(
    email: loginData['email'] as String,
    password: loginData['password'] as String,
    deviceId: loginData['deviceId'] as int,
  );

  if (response['success'] == true && !response['needs_verification']) {
    final user = response['user'] as User;
    // Save user session data after successful login
    await storageService.saveUserSession(
      token: user.token,
      role: user.role,
      userId: user.id,
    );
  }

  return response;
});

final userProvider = StateProvider<User?>((ref) => null);

// Add a provider to check user session
final userSessionProvider = FutureProvider<User?>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  
  final token = await storageService.getToken();
  final role = await storageService.getUserRole();
  final userId = await storageService.getUserId();

  if (token != null && role != null && userId != null) {
    return User(
      id: userId,
      token: token,
      role: role,
      active: 'Active', // Default value for existing sessions
      classList: [], // Default empty list for existing sessions
    );
  }
  return null;
});
