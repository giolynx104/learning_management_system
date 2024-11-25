import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/auth_service.dart';
import 'package:learning_management_system/providers/api_service_provider.dart';

part 'auth_service_provider.g.dart';

@riverpod
AuthService authService(Ref ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthService(apiService);
} 