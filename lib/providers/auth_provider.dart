import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

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
  return authService.login(
    email: loginData['email'] as String,
    password: loginData['password'] as String,
    deviceId: loginData['deviceId'] as int,
  );
});
