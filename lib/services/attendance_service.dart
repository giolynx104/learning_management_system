import 'package:learning_management_system/services/api_service.dart';

class AttendanceService {
  final ApiService _apiService;

  AttendanceService(this._apiService);

  Future<void> takeAttendance({
    required String classId,
    required DateTime date,
    required List<String> absentStudentIds,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it5023e/take_attendance',
        data: {
          'class_id': classId,
          'date': date.toIso8601String().split('T')[0],
          'attendance_list': absentStudentIds,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to submit attendance');
      }
    } catch (e) {
      throw Exception('Failed to submit attendance: ${e.toString()}');
    }
  }
}
