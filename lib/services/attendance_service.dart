import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';

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

  Future<AttendanceListResponse> getAttendanceList({
    required String classId,
    required DateTime date,
    required String token,
    int? page,
    int? pageSize,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'token': token,
        'class_id': classId,
        'date': date.toIso8601String().split('T')[0],
        if (page != null && pageSize != null)
          'pageable_request': {
            'page': page.toString(),
            'page_size': pageSize.toString(),
          },
      };

      final response = await _apiService.dio.post(
        '/it5023e/get_attendance_list',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to get attendance list');
      }

      final responseData = response.data['data'] as Map<String, dynamic>;
      return AttendanceListResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Failed to get attendance list: ${e.toString()}');
    }
  }
}
