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

      // Get all assignments
      final assignments = await _handleResponse<List<Assignment>>(
        response,
        (data) => (data as List)
            .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
            .toList(),
      );

      // For each assignment, try to get its submission
      final assignmentsWithSubmissions = await Future.wait(
        assignments.map((assignment) async {
          try {
            final submission = await getStudentSubmission(
              token: token,
              assignmentId: assignment.id,
            );

            if (submission != null) {
              // Create a new assignment with the submission data
              return Assignment.fromJson({
                'id': assignment.id,
                'title': assignment.title,
                'description': assignment.description,
                'file_url': assignment.fileUrl,
                'lecturer_id': assignment.lecturerId,
                'deadline': assignment.deadline.toIso8601String(),
                'class_id': assignment.classId,
                'submission': submission,
              });
            }
          } catch (e) {
            developer.log(
              'Error fetching submission for assignment ${assignment.id}: $e',
              name: 'AssignmentService',
            );
          }
          return assignment;
        }),
      );

      return assignmentsWithSubmissions;
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
    String? description,
    PlatformFile? file,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'token': token,
        'classId': classId,
        'title': title,
        'deadline': deadline,
      };

      if (description != null && description.isNotEmpty) {
        formDataMap['description'] = description;
      }

      if (file != null) {
        formDataMap['file'] = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      final formData = FormData.fromMap(formDataMap);

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
    PlatformFile? file,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'token': token,
        'assignmentId': assignmentId,
        'title': title,
        'deadline': deadline,
        'description': description,
      };

      if (file != null) {
        formDataMap['file'] = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      final formData = FormData.fromMap(formDataMap);

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

  Future<Map<String, dynamic>?> getStudentSubmission({
    required String token,
    required String assignmentId,
  }) async {
    try {
      developer.log(
        'Getting student submission for assignment: $assignmentId',
        name: 'AssignmentService',
      );

      final response = await _apiService.dio.post(
        ApiConstants.getSubmission,
        data: {
          'token': token,
          'assignment_id': assignmentId,
        },
        options: Options(
          validateStatus: (status) => 
            status != null && (status < 500 || status == 400),
        ),
      );

      developer.log(
        'Raw response data: ${response.data}',
        name: 'AssignmentService',
      );

      if (response.statusCode == 400 || 
          response.data['meta']['code'] == ApiConstants.noDataCode) {
        return null;
      }

      final responseData = response.data['data'];
      if (responseData == null) return null;

      return {
        'id': responseData['id'],
        'assignment_id': responseData['assignment_id'],
        'submission_time': responseData['submission_time'],
        'grade': responseData['grade'],
        'file_url': responseData['file_url'],
        'text_response': responseData['text_response'],
        'student_account': responseData['student_account'],
      };
    } on DioException catch (e) {
      developer.log(
        'Error getting student submission: ${e.message}',
        name: 'AssignmentService',
        error: e,
      );
      if (e.response?.statusCode == 400) {
        return null;
      }
      throw ApiException.fromDioError(e);
    }
  }
} 