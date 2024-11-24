import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/absence_request_service.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/absence_request_model.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

part 'absence_request_provider.g.dart';

@riverpod
AbsenceRequestService absenceRequestService(AbsenceRequestServiceRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AbsenceRequestService(apiService);
}

@riverpod
class SubmitAbsenceRequest extends _$SubmitAbsenceRequest {
  @override
  FutureOr<AbsenceRequestResponse?> build() {
    return null;
  }

  Future<void> submit(AbsenceRequest request) async {
    final token = ref.read(authProvider).value?.token;
    if (token == null) {
      throw Exception('No authentication token found');
    }

    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      return ref.read(absenceRequestServiceProvider).submitRequest(
        request: request,
        token: token,
      );
    });
  }
} 