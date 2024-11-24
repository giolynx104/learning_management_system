import 'package:flutter/foundation.dart';
import 'package:learning_management_system/models/absence_request_list_model.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/absence_request_model.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class AbsenceRequestService {
  final ApiService _apiService;

  AbsenceRequestService(this._apiService);

  Future<AbsenceRequestResponse> submitRequest({
    required AbsenceRequest request,
    required String token,
  }) async {
    try {
      debugPrint('AbsenceRequestService - Starting submission');
      debugPrint('AbsenceRequestService - Request details:');
      debugPrint('  Class ID: ${request.classId}');
      debugPrint('  Title: ${request.title}');
      debugPrint('  Reason: ${request.reason}');
      debugPrint('  Date: ${request.date}');
      debugPrint('  Proof File: ${request.proofFile}');
      debugPrint('  Token: $token');
      
      // Create FormData
      final formData = FormData.fromMap({
        'token': token,
        'classId': request.classId,
        'title': request.title,
        'reason': request.reason,
        'date': request.date,
        if (request.proofFile != null)
          'proof_file': await MultipartFile.fromFile(
            request.proofFile!,
            filename: request.proofFile!.split('/').last,
          ),
      });

      debugPrint('AbsenceRequestService - FormData created');

      final response = await _apiService.dio.post(
        '/it5023e/request_absence',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': '*/*',
          },
        ),
      );

      debugPrint('AbsenceRequestService - Response status: ${response.statusCode}');
      debugPrint('AbsenceRequestService - Raw response: ${response.data}');

      if (response.statusCode != 200) {
        final errorMessage = response.data['message'] ?? 
                            response.data['meta']?['message'] ?? 
                            'Failed to submit absence request';
        debugPrint('AbsenceRequestService - Error message from server: $errorMessage');
        throw Exception(errorMessage);
      }

      final responseData = AbsenceRequestResponse.fromJson(response.data['data']);
      debugPrint('AbsenceRequestService - Parsed response: ${responseData.toString()}');
      debugPrint('AbsenceRequestService - Request ID: ${responseData.requestId}');
      debugPrint('AbsenceRequestService - Status: ${responseData.status}');
      
      debugPrint('AbsenceRequestService - Request submitted successfully');
      return responseData;
    } catch (e) {
      debugPrint('AbsenceRequestService - Error occurred: $e');
      if (e is DioException && e.response?.data != null) {
        final errorData = e.response?.data;
        debugPrint('AbsenceRequestService - Error response data: $errorData');
        
        if (errorData['data'] is Map) {
          final fieldErrors = errorData['data'] as Map;
          final errorMessages = fieldErrors.values.join(', ');
          throw Exception('Validation failed: $errorMessages');
        }
        
        final errorMessage = errorData['message'] ?? 
                            errorData['meta']?['message'] ?? 
                            e.message;
        throw Exception(errorMessage);
      }
      throw Exception('Failed to submit absence request: ${e.toString()}');
    }
  }

  Future<AbsenceRequestList> getAbsenceRequests({
    required String token,
    required String classId,
    required bool isTeacher,
    AbsenceRequestStatus? status,
    DateTime? date,
  }) async {
    try {
      debugPrint('AbsenceRequestService - Starting getAbsenceRequests');
      debugPrint('AbsenceRequestService - Is teacher: $isTeacher');

      final endpoint = isTeacher
          ? '/it5023e/get_absence_requests'
          : '/it5023e/get_student_absence_requests';
      debugPrint('AbsenceRequestService - Request endpoint: $endpoint');

      final requestData = {
        'token': token,
        'class_id': classId,
        if (status != null) 'status': status.name.toUpperCase(),
        if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
      };
      debugPrint('AbsenceRequestService - Request data: $requestData');

      final response = await _apiService.dio.post(
        endpoint,
        data: requestData,
      );

      debugPrint('AbsenceRequestService - Response status: ${response.statusCode}');
      debugPrint('AbsenceRequestService - Raw response: ${response.data}');

      if (response.statusCode == 200) {
        try {
          final responseData = AbsenceRequestListResponse.fromJson(response.data);
          return responseData.data;
        } catch (e, stackTrace) {
          debugPrint('AbsenceRequestService - Error parsing response: $e');
          debugPrint('AbsenceRequestService - Stack trace: $stackTrace');
          throw Exception('Failed to parse absence requests: $e');
        }
      }

      throw Exception('Failed to get absence requests: ${response.statusCode}');
    } catch (e, stackTrace) {
      debugPrint('AbsenceRequestService - Error getting requests: $e');
      debugPrint('AbsenceRequestService - Stack trace: $stackTrace');
      throw Exception('Failed to get absence requests: $e');
    }
  }

  Future<void> reviewAbsenceRequest({
    required String token,
    required int requestId,
    required String status,
  }) async {
    try {
      debugPrint('AbsenceRequestService - Starting review request');
      debugPrint('AbsenceRequestService - Request data:');
      debugPrint('  Request ID: $requestId');
      debugPrint('  Status: $status');
      debugPrint('  Token: $token');

      final response = await _apiService.dio.post(
        '/it5023e/review_absence_request',
        data: {
          'token': token,
          'request_id': requestId.toString(),
          'status': status,
        },
      );

      debugPrint('AbsenceRequestService - Response status: ${response.statusCode}');
      debugPrint('AbsenceRequestService - Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to review absence request');
      }

      debugPrint('AbsenceRequestService - Request reviewed successfully');
    } catch (e) {
      debugPrint('AbsenceRequestService - Error reviewing request: $e');
      throw Exception('Failed to review absence request: $e');
    }
  }
} 