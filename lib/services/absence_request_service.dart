import 'package:flutter/foundation.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/models/absence_request_model.dart';

class AbsenceRequestService {
  final ApiService _apiService;

  AbsenceRequestService(this._apiService);

  Future<AbsenceRequestResponse> submitRequest({
    required AbsenceRequest request,
    required String token,
  }) async {
    try {
      debugPrint('AbsenceRequestService - Starting submission');
      
      final Map<String, dynamic> requestData = {
        'token': token,
        'class_id': request.classId,
        'title': request.title,
        'reason': request.reason,
        'date': request.date,
        if (request.proofFile != null) 'proof_file': request.proofFile,
      };

      final response = await _apiService.dio.post(
        '/it5023e/request_absence',
        data: requestData,
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to submit absence request');
      }

      debugPrint('AbsenceRequestService - Request submitted successfully');
      return AbsenceRequestResponse.fromJson(response.data['data']);
    } catch (e) {
      debugPrint('AbsenceRequestService - Error occurred: $e');
      throw Exception('Failed to submit absence request: ${e.toString()}');
    }
  }
} 