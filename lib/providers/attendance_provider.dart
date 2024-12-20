import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
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
    debugPrint('TakeAttendance Provider - Build started');
    return null;
  }

  Future<void> submit({
    required String classId,
    required DateTime date,
    required List<String> absentStudentIds,
  }) async {
    try {
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
    } catch (e, stackTrace) {
      debugPrint('TakeAttendance Provider - Error: $e');
      debugPrint('TakeAttendance Provider - Stack trace: $stackTrace');
      rethrow;
    }
  }
}

@riverpod
Future<AttendanceListResponse?> getAttendanceList(
  Ref ref,
  String classId,
  DateTime date,
) async {
  try {
    final token = ref.read(authProvider).value?.token;
    if (token == null) {
      throw Exception('No authentication token found');
    }

    return await ref.read(attendanceServiceProvider).getAttendanceList(
      classId: classId,
      date: date,
      token: token,
    );
  } on ApiException catch (e) {
    debugPrint('AttendanceProvider - ApiException: ${e.message}');
    rethrow;
  } catch (e) {
    debugPrint('AttendanceProvider - Error: $e');
    rethrow;
  }
} 