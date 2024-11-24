import 'package:flutter/foundation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';

class AttendanceService {
  final ApiService _apiService;

  AttendanceService(this._apiService);

  Future<void> takeAttendance({
    required String classId,
    required DateTime date,
    required List<String> absentStudentIds,
    required String token,
  }) async {
    try {
      debugPrint('AttendanceService - Starting takeAttendance');
      debugPrint('AttendanceService - Request data:');
      debugPrint('  Class ID: $classId');
      debugPrint('  Date: ${date.toIso8601String().split('T')[0]}');
      debugPrint('  Absent IDs: $absentStudentIds');
      debugPrint('  Token: $token');

      final response = await _apiService.dio.post(
        '/it5023e/take_attendance',
        data: {
          'token': token,
          'class_id': classId,
          'date': date.toIso8601String().split('T')[0],
          'attendance_list': absentStudentIds,
        },
      );

      debugPrint('AttendanceService - Response status: ${response.statusCode}');
      debugPrint('AttendanceService - Response data: ${response.data}');

      if (response.statusCode != 200) {
        debugPrint('AttendanceService - Error: Non-200 status code');
        throw Exception(response.data['message'] ?? 'Failed to submit attendance');
      }

      debugPrint('AttendanceService - Attendance submitted successfully');
    } catch (e) {
      debugPrint('AttendanceService - Error occurred: $e');
      throw Exception('Failed to submit attendance: ${e.toString()}');
    }
  }

  Future<AttendanceListResponse?> getAttendanceList({
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

      final responseData = response.data;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9994') {
        return null;
      }

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to get attendance list');
      }

      final returnedData = responseData['data'] as Map<String, dynamic>;
      return AttendanceListResponse.fromJson(returnedData);
    } catch (e) {
      throw Exception('Failed to get attendance list: ${e.toString()}');
    }
  }
}
