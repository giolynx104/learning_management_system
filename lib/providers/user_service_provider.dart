import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/user_service.dart';
import 'package:learning_management_system/services/api_service.dart';

part 'user_service_provider.g.dart';

@riverpod
UserService userService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserService(apiService);
} 