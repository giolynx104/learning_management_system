import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://160.30.168.228:8080',
    validateStatus: (status) => true,
  ));
} 