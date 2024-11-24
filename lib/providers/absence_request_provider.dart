import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/absence_request_service.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/absence_request_model.dart';
import 'package:learning_management_system/models/absence_request_list_model.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

part 'absence_request_provider.g.dart';

@riverpod
AbsenceRequestService absenceRequestService(Ref ref) {
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

@riverpod
class GetAbsenceRequests extends _$GetAbsenceRequests {
  @override
  Future<AbsenceRequestList> build(
    String classId, {
    AbsenceRequestStatus? status,
    DateTime? date,
  }) async {
    try {
      final authState = ref.read(authProvider);
      final user = authState.value;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('AbsenceRequestProvider - User role: ${user.role}');
      final isTeacher = user.role.toLowerCase() == 'lecturer';
      debugPrint('AbsenceRequestProvider - isTeacher: $isTeacher');

      return await ref.read(absenceRequestServiceProvider).getAbsenceRequests(
        token: user.token ?? '',
        classId: classId,
        isTeacher: isTeacher,
        status: status,
        date: date,
      );
    } catch (e) {
      debugPrint('AbsenceRequestProvider - Error: $e');
      throw Exception('Failed to get absence requests: $e');
    }
  }
}
