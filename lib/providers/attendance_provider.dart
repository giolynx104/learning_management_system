import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/attendance_service.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';

part 'attendance_provider.g.dart';

@riverpod
AttendanceService attendanceService(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AttendanceService(apiService);
}

@riverpod
class TakeAttendance extends _$TakeAttendance {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> submit({
    required String classId,
    required DateTime date,
    required List<String> absentStudentIds,
  }) async {
    debugPrint('TakeAttendance Provider - Starting submission');
    
    final token = ref.read(authProvider).value?.token;
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      await ref.read(attendanceServiceProvider).takeAttendance(
            classId: classId,
            date: date,
            absentStudentIds: absentStudentIds,
            token: token,
          );
    });
  }
}

@riverpod
class GetAttendanceList extends _$GetAttendanceList {
  @override
  FutureOr<AttendanceListResponse?> build() {
    return null;
  }

  Future<void> fetch({
    required String classId,
    required DateTime date,
    required String token,
  }) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() => ref
        .read(attendanceServiceProvider)
        .getAttendanceList(
          classId: classId,
          date: date,
          token: token,
        ));
  }
} 