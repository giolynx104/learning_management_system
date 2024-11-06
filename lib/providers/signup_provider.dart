import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';

part 'signup_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> signUp(
  SignUpRef ref,
  {
    required String email,
    required String password,
    required int uuid,
    required String role,
  }
) async {
  final authService = AuthService();
  final response = await authService.signUp(
    email: email,
    password: password,
    uuid: uuid,
    role: role,
  );
  return response;
}

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService(); 