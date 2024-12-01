import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:learning_management_system/constants/api_constants.dart';

part 'assignment_service.g.dart';

@riverpod
class AssignmentService extends _$AssignmentService {
  @override
  FutureOr<void> build() {}

  ApiService get _apiService => ref.read(apiServiceProvider);

  Future<List<Assignment>> getAllAssignments({
    required String token,
    required String classId,
  }) async {
    try {
      developer.log(
        'Fetching assignments for class: $classId',
        name: 'AssignmentService',
      );

      final response = await _apiService.dio.post(
        ApiConstants.getAllSurveys,
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      developer.log(
        'Raw response data: ${response.data}',
        name: 'AssignmentService',
      );

      return await _handleResponse<List<Assignment>>(
        response,
        (data) => (data as List)
            .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      developer.log(
        'Error fetching assignments: ${e.message}',
        name: 'AssignmentService',
        error: e,
      );
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createAssignment({
    required String token,
    required String classId,
    required String title,
    required String deadline,
    required String description,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'token': token,
        'classId': classId,
        'title': title,
        'deadline': deadline,
        'description': description,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await _apiService.dio.post(
        ApiConstants.createSurvey,
        data: formData,
      );

      _handleResponse<void>(response, (_) {});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> editAssignment({
    required String token,
    required String assignmentId,
    required String title,
    required String deadline,
    required String description,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'token': token,
        'assignmentId': assignmentId,
        'title': title,
        'deadline': deadline,
        'description': description,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await _apiService.dio.post(
        ApiConstants.editSurvey,
        data: formData,
      );

      _handleResponse<void>(response, (_) {});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteAssignment({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.deleteSurvey,
        data: {
          'token': token,
          'survey_id': assignmentId,
        },
      );

      _handleResponse<void>(response, (_) {});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> submitAssignment({
    required String token,
    required String assignmentId,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'token': token,
        'assignmentId': assignmentId,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await _apiService.dio.post(
        ApiConstants.submitSurvey,
        data: formData,
      );

      _handleResponse<void>(response, (_) {});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAssignmentResponses({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.getSurveyResponse,
        data: {
          'token': token,
          'survey_id': assignmentId,
        },
      );

      return await _handleResponse<List<Map<String, dynamic>>>(
        response,
        (data) => List<Map<String, dynamic>>.from(data as List),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> gradeAssignment({
    required String token,
    required String assignmentId,
    required String score,
    required String submissionId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.getSurveyResponse,
        data: {
          'token': token,
          'survey_id': assignmentId,
          'grade': {
            'score': score,
            'submission_id': submissionId,
          },
        },
      );

      await _handleResponse<void>(response, (_) {});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic) onSuccess,
  ) async {
    if (response.data['meta']['code'] == '1000') {
      return onSuccess(response.data['data']);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.data['meta']['message'] ?? 'Failed to fetch assignments',
      );
    }
  }
} 