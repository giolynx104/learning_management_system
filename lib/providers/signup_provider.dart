import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';

part 'signup_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> signUp(
  Ref ref, {
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String role,
}) {
  return ref.watch(authServiceProvider).signUp(
    firstName: firstName,
    lastName: lastName,
    email: email,
    password: password,
    role: role,
  );
}

@riverpod
AuthService authService(Ref ref) => AuthService(); 