import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/attendance_model.dart';
import 'package:learning_management_system/utils/api_client.dart';
import 'package:learning_management_system/exceptions/unauthorized_exception.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

part 'attendance_service.g.dart';

@riverpod
class AttendanceService extends _$AttendanceService {
  @override
  FutureOr<void> build() {}

  Future<void> submitAttendance({
    required String token,
    required String classId,
    required String date,
    required List<int> attendanceList,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/take_attendance',
        data: {
          'token': token,
          'class_id': classId,
          'date': date,
          'attendance_list': attendanceList,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == 9998) {
        // Token invalid code
        ref.read(authProvider.notifier).signOut();
        throw const UnauthorizedException(
            'Session expired. Please sign in again.');
      }

      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to submit attendance');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw Exception('Failed to submit attendance: $e');
    }
  }
}
