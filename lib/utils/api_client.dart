import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(ApiClientRef ref) {
  return Dio(BaseOptions(
    baseUrl: 'YOUR_BASE_URL', // TODO: Add your base URL
    validateStatus: (status) => true, // We'll handle status codes ourselves
  ));
} 