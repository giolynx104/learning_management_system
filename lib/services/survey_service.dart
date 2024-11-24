import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/survey.dart';

part 'survey_service.g.dart'; // This will hold the generated code.

@riverpod
class SurveyService extends _$SurveyService {
  @override
  FutureOr<void> build() {}
  ApiService get _apiService => ref.read(apiServiceProvider);
  // Existing API to fetch surveys
  Future<List<dynamic>> getAllSurveys({
    required String token,
    required String classId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it5023e/get_all_surveys',
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != '1000') { // Other errors
        throw Exception(meta['message'] ?? 'Failed to fetch surveys');
      }

      return responseData['data'] as List<dynamic>;
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;


      throw Exception(meta?['message'] ?? 'Failed to fetch surveys');
    }
  }

  // New method to check if survey is submitted
  Future<bool> checkSubmissionStatus({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it5023e/get_submission',
        data: {
          'token': token,
          'assignment_id': assignmentId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      // Check the response data
      if (meta['code'] == '9994') { // No submission found
        return false;  // Not submitted
      } else if (meta['code'] == '1000') {
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
      final response = await _apiService.dio.post(
        '/it5023e/get_submission',
        data: {
          'token': token,
          'assignment_id': assignmentId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9994') { // No submission found
        return null;
      } else if (meta['code'] == '1000') {
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

      final response = await _apiService.dio.post(
        '/it5023e/submit_survey?file',
        data: formData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != '1000') {
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

      final response = await _apiService.dio.post(
        '/it5023e/create_survey?file',
        data: formData,
      );
      print('Response: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != '1000') {
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

      final response = await _apiService.dio.post(
        '/it5023e/edit_survey?file',
        data: formData,
      );
      print('Response: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != '1000') {
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
      final response = await _apiService.dio.post(
        '/it5023e/delete_survey',
        data: {
          'token': token,
          'survey_id': survey_id,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != '1000') {
        throw Exception(meta['message'] ?? 'Failed to delete survey');
      }
    } on DioException catch (e) {
      throw Exception('Error editing survey: ${e.message}');
    }
  }

  Future<List<Map<String, dynamic>>> responseSurvey({
    required String token,
    required String surveyId,
    String? score, // Optional parameter for grading
    String? submissionId,
  }) async {
    try {
      // Construct the data payload
      final data = <String, dynamic>{
        'token': token,
        'survey_id': surveyId,
      };

      // Add the grade object if provided
      if (score != null && submissionId != null) {
        // Create the grade object
        final grade = {
          'score': score,
          'submission_id': submissionId,
        };
        data['grade'] = grade; // Add the grade object to the data
      }

      print('Post data by get_response_survey API call: ${data}');
      final response = await _apiService.dio.post(
        '/it5023e/get_survey_response',
        data: data,
      );
      print('Data fetched: $response');

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9994') {
        // No submission found
        return [];
      } else if (meta['code'] == '1000') {
        // Return the list of responses
        final List<dynamic> dataList = responseData['data'];
        return dataList.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(meta['message'] ?? 'Error fetching survey responses');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching survey responses: ${e.message}');
    }
  }


}



