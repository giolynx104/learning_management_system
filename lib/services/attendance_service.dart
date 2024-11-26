import 'package:flutter/foundation.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/attendance_list_model.dart';
import 'package:dio/dio.dart';

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

    } on DioException catch (e) {
      debugPrint('AttendanceService - DioException: ${e.message}');
      debugPrint('AttendanceService - Response data: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        if (responseData != null) {
          final errorMessage = responseData['data'] as String? ?? 
                             responseData['meta']?['message'] ?? 
                             'Invalid request';
          
          throw ApiException(
            statusCode: 400,
            message: errorMessage,
            data: responseData,
          );
        }
      }

      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('AttendanceService - Error: $e');
      rethrow;
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

      debugPrint('AttendanceService - Fetching attendance list');
      debugPrint('AttendanceService - Request data: $data');

      final response = await _apiService.dio.post(
        '/it5023e/get_attendance_list',
        data: data,
      );

      final responseData = response.data;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9994') {
        return null;
      }

      final returnedData = responseData['data'] as Map<String, dynamic>;
      return AttendanceListResponse.fromJson(returnedData);
    } on DioException catch (e) {
      debugPrint('AttendanceService - DioException: ${e.message}');
      debugPrint('AttendanceService - Response data: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        if (responseData != null) {
          final errorMessage = responseData['data'] as String? ?? 
                             responseData['meta']?['message'] ?? 
                             'Invalid request';
          
          throw ApiException(
            statusCode: 400,
            message: errorMessage,
            data: responseData,
          );
        }
      }

      throw ApiException.fromDioError(e);
    } catch (e) {
      debugPrint('AttendanceService - Error: $e');
      rethrow;
    }
  }
}
