import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/models/assignment.dart';

part 'assignment_service.g.dart';

@riverpod
class AssignmentService extends _$AssignmentService {
  @override
  FutureOr<void> build() {}

  ApiService get _apiService => ref.read(apiServiceProvider);

  Future<List<Assignment>> getStudentAssignments({
    required String token,
  }) async {
    try {
      developer.log(
        'Fetching student assignments',
        name: 'AssignmentService',
      );

      final response = await _apiService.dio.post(
        '/it5023e/get_student_assignments',
        data: {
          'token': token,
        },
      );

      developer.log(
        'Raw response data: ${response.data}',
        name: 'AssignmentService',
      );

      if (response.data['meta']['code'] == '1000') {
        final List<dynamic> assignmentsData = response.data['data'];
        return assignmentsData
            .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.data['meta']['message'] ?? 'Failed to fetch assignments',
        );
      }
    } on DioException catch (e) {
      developer.log(
        'Error fetching assignments: ${e.message}',
        name: 'AssignmentService',
        error: e,
      );
      throw ApiException.fromDioError(e);
    }
  }
} 