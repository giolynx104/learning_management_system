import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/attendance_service.dart';
import 'package:learning_management_system/services/api_service.dart';

part 'attendance_provider.g.dart';

@riverpod
AttendanceService attendanceService(AttendanceServiceRef ref) {
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