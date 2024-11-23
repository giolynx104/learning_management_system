import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() => ref
        .read(attendanceServiceProvider)
        .takeAttendance(
          classId: classId,
          date: date,
          absentStudentIds: absentStudentIds,
        ));
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