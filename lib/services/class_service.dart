import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/class_model.dart';
import 'package:learning_management_system/models/class_list_model.dart';
import 'package:learning_management_system/utils/api_client.dart';

part 'class_service.g.dart';

@riverpod
class ClassService extends _$ClassService {
  @override
  FutureOr<void> build() {}

  Future<ClassModel> createClass({
    required String token,
    required String classId,
    required String className,
    required String classType,
    required DateTime startDate,
    required DateTime endDate,
    required int maxStudentAmount,
    String? attachedCode,
  }) async {
    try {
      final data = {
        'token': token,
        'class_id': classId,
        'class_name': className,
        'class_type': _mapClassType(classType),
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'max_student_amount': maxStudentAmount,
      };
      
      if (attachedCode != null && attachedCode.isNotEmpty) {
        data['attached_code'] = attachedCode;
      }

      final response = await ref.read(apiClientProvider).post(
        '/it5023e/create_class',
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;
      
      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to create class');
      }

      return ClassModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;
      throw Exception(meta?['message'] ?? 'Failed to create class');
    }
  }

  Future<List<ClassListItem>> getClassList(String token) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/get_class_list',
        data: {'token': token},
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;
      
      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to get class list');
      }

      final List<dynamic> classListData = responseData['data'];
      return classListData
          .map((json) => ClassListItem.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;
      throw Exception(meta?['message'] ?? 'Failed to get class list');
    }
  }

  Future<ClassModel> editClass({
    required String token,
    required String classId,
    required String className,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final data = {
        'token': token,
        'class_id': classId,
        'class_name': className,
        'status': status,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      };

      final response = await ref.read(apiClientProvider).post(
        '/it5023e/edit_class',
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;
      
      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to edit class');
      }

      return ClassModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;
      throw Exception(meta?['message'] ?? 'Failed to edit class');
    }
  }

  Future<ClassModel> getClassInfo({
    required String token,
    required String classId,
  }) async {
    try {
      debugPrint('ClassService - Fetching class info for ID: $classId');
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/get_class_info',
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('ClassService - Raw response: $responseData');
      
      final meta = responseData['meta'] as Map<String, dynamic>;
      
      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Failed to get class info');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      debugPrint('ClassService - Data to parse: $data');

      // Ensure all required fields are present and of correct type
      data['student_count'] = data['student_count'] ?? 0;
      data['student_accounts'] = data['student_accounts'] ?? [];

      return ClassModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('ClassService - DioException: ${e.response?.data}');
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;
      throw Exception(meta?['message'] ?? 'Failed to get class info');
    } catch (e) {
      debugPrint('ClassService - Unexpected error: $e');
      rethrow;
    }
  }

  String _mapClassType(String type) {
    switch (type.toLowerCase()) {
      case 'theory':
        return 'LT';
      case 'exercise':
        return 'BT';
      case 'both':
        return 'LT_BT';
      default:
        throw Exception('Invalid class type');
    }
  }
}
