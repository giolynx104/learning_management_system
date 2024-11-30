import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/constants/api_constants.dart';

part 'survey_service.g.dart'; // This will hold the generated code.

@riverpod
class SurveyService extends _$SurveyService {
  @override
  FutureOr<void> build() {}
  ApiService get _apiService => ref.read(apiServiceProvider);
  // Existing API to fetch surveys
  Future<List<Survey>> getAllSurveys({
    required String token,
    required String classId,
  }) async {
    try {
      developer.log(
        'Fetching surveys for class: $classId',
        name: 'SurveyService',
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
        name: 'SurveyService',
      );

      return _handleResponse<List<Survey>>(
        response,
        (data) {
          developer.log(
            'Processing survey list data: $data',
            name: 'SurveyService',
          );
          return (data as List)
              .map((json) => Survey.fromJson(json as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      developer.log(
        'Error fetching surveys: ${e.message}',
        name: 'SurveyService',
        error: e,
      );
      throw ApiException.fromDioError(e);
    }
  }

  T _handleResponse<T>(Response response, T Function(dynamic data) mapper) {
    final responseData = response.data as Map<String, dynamic>;
    final meta = responseData['meta'] as Map<String, dynamic>;

    if (meta['code'] != ApiConstants.successCode) {
      throw ApiException(
        message: meta['message'] ?? 'Unknown error',
        statusCode: int.tryParse(meta['code']?.toString() ?? ''),
        data: responseData,
      );
    }

    return mapper(responseData['data']);
  }

  // New method to check if survey is submitted
  Future<bool> checkSubmissionStatus({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'token': token,
        'assignment_id': assignmentId,
      };
      
      developer.log(
        'Sending to /it5023e/get_submission: $data',
        name: 'SurveyService.checkSubmissionStatus',
      );
      
      final response = await _apiService.dio.post(
        ApiConstants.getSubmission,
        data: data,
        options: Options(
          validateStatus: (status) => 
            status != null && (status < 500 || status == 400),
        ),
      );
      
      developer.log(
        'Response from /it5023e/get_submission: ${response.data}',
        name: 'SurveyService.checkSubmissionStatus',
      );

      // Check if response contains meta information
      final meta = response.data['meta'] as Map<String, dynamic>;
      
      // If code is 9994, it means no submission found
      if (meta['code'] == ApiConstants.noDataCode) {
        return false;
      }
      
      // If code is 1000 and we have data, submission exists
      if (meta['code'] == ApiConstants.successCode && response.data['data'] != null) {
        return true;
      }

      return false;
    } catch (e, stack) {
      developer.log(
        'Error checking submission status: $e',
        name: 'SurveyService.checkSubmissionStatus',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }



  Future<Map<String, dynamic>?> getSubmission({
    required String token,
    required String assignmentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'token': token,
        'assignment_id': assignmentId,
      };
      final response = await _apiService.dio.post(
        ApiConstants.getSubmission,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == ApiConstants.noDataCode) { // No submission found
        return null;
      } else if (meta['code'] == ApiConstants.successCode) {
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
    required PlatformFile file,
    required String textResponse,
  }) async {
    try {
      final formData = FormData.fromMap({
        'token': token,
        'assignmentId': assignmentId,
        'textResponse': textResponse,
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

  Future<void> editSurvey({
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

  Future<void> deleteSurvey({
    required String token,
    required String surveyId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.deleteSurvey,
        data: {
          'token': token,
          'survey_id': surveyId,
        },
      );

      _handleResponse<void>(response, (_) {});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
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

      developer.log(
        'Post data by get_response_survey API call: ${data}',
        name: 'SurveyService',
      );
      final response = await _apiService.dio.post(
        ApiConstants.getSurveyResponse,
        data: data,
      );
      developer.log(
        'Data fetched: $response',
        name: 'SurveyService',
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == ApiConstants.noDataCode) {
        // No submission found
        return [];
      } else if (meta['code'] == ApiConstants.successCode) {
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



