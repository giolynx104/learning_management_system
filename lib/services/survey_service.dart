import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/utils/api_client.dart';
import 'package:learning_management_system/exceptions/unauthorized_exception.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

part 'survey_service.g.dart'; // This will hold the generated code.

@riverpod
class SurveyService extends _$SurveyService {
  @override
  FutureOr<void> build() {
    // Any initialization logic, if needed
  }

  // Existing API to fetch surveys
  Future<List<dynamic>> getAllSurveys({
    required String token,
    required String classId,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/get_all_surveys',
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == 9998) { // Invalid token
        ref.read(authProvider.notifier).logout();
        throw const UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != 1000) { // Other errors
        throw Exception(meta['message'] ?? 'Failed to fetch surveys');
      }

      return responseData['data'] as List<dynamic>;
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == 9998) { // Invalid token
        ref.read(authProvider.notifier).logout();
        throw const UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(meta?['message'] ?? 'Failed to fetch surveys');
    }
  }

  // New method to check if survey is submitted
  Future<bool> checkSubmissionStatus({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/get_submission',
        data: {
          'token': token,
          'assignment_id': assignmentId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      // Check the response data
      if (meta['code'] == 9994) { // No submission found
        return false;  // Not submitted
      } else if (meta['code'] == 1000) {
        return true;  // Submitted
      } else {
        throw Exception(meta['message'] ?? 'Error checking submission status');
      }
    } on DioException catch (e) {
      throw Exception('Error checking submission status: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> getSubmission({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/get_submission',
        data: {
          'token': token,
          'assignment_id': assignmentId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == 9994) { // No submission found
        return null;
      } else if (meta['code'] == 1000) {
        // Return submission data
        return responseData['data'];
      } else {
        throw Exception(meta['message'] ?? 'Error checking submission status');
      }
    } on DioException catch (e) {
      throw Exception('Error checking submission status: ${e.message}');
    }
  }


  Future<void> submitSurvey({
    required String token,
    required String assignmentId,
    required PlatformFile file, // File selected using FilePicker
    required String textResponse,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
        'token': token,
        'assignmentId': assignmentId,
        'textResponse': textResponse,
      });

      final response = await ref.read(apiClientProvider).post(
        '/it5023e/submit_survey?file',
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to submit survey');
      }
    } on DioException catch (e) {
      throw Exception('Error submitting survey: ${e.message}');
    }
  }

  Future<void> createSurvey({
    required String token,
    required String classId,
    required String title,
    required String deadline,
    required String description,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
        'token': token,
        'classId': classId,
        'title': title,
        'deadline': deadline,
        'description': description,
      });

      final response = await ref.read(apiClientProvider).post(
        '/it5023e/create_survey?file',
        data: formData,
      );
      print('Response: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to create survey');
      }
    } on DioException catch (e) {
      throw Exception('Error creating survey: ${e.message}');
    }
  }

  Future<void> editSurvey({
    required String token,
    required String assignmentId,
    required String deadline,
    required String description,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
        'token': token,
        'assignmentId': assignmentId,
        'deadline': deadline,
        'description': description,
      });

      final response = await ref.read(apiClientProvider).post(
        '/it5023e/edit_survey?file',
        data: formData,
      );
      print('Response: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to edit survey');
      }
    } on DioException catch (e) {
      throw Exception('Error editing survey: ${e.message}');
    }
  }

  Future<void> deleteSurvey({
    required String token,
    required String survey_id,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/delete_survey',
        data: {
          'token': token,
          'survey_id': survey_id,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to delete survey');
      }
    } on DioException catch (e) {
      throw Exception('Error editing survey: ${e.message}');
    }
  }
}



