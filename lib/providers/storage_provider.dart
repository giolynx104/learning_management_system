import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/storage_service.dart';

part 'storage_provider.g.dart';

@riverpod
StorageService secureStorage(SecureStorageRef ref) {
  return StorageService();
} 