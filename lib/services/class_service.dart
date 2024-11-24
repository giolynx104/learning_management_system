import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/class_model.dart';
import 'package:learning_management_system/models/class_list_model.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/class_detail_model.dart';

part 'class_service.g.dart';

@riverpod
class ClassService extends _$ClassService {
  @override
  FutureOr<void> build() {}

  ApiService get _apiService => ref.read(apiServiceProvider);

  Future<void> createClass({
    required String token,
    required String classId,
    required String className,
    required String classType,
    required String startDate,
    required String endDate,
    required int maxStudentAmount,
    String? attachedCode,
  }) async {
    try {
      debugPrint('ClassService - Creating class with data:');
      debugPrint('Token: $token');
      debugPrint('ClassId: $classId');
      debugPrint('ClassName: $className');
      debugPrint('ClassType: $classType');
      debugPrint('StartDate: $startDate');
      debugPrint('EndDate: $endDate');
      debugPrint('MaxStudentAmount: $maxStudentAmount');
      debugPrint('AttachedCode: $attachedCode');

      final response = await _apiService.dio.post(
        '/it5023e/create_class',
        data: {
          'token': token,
          'class_id': classId,
          'class_name': className,
          'class_type': _mapClassType(classType),
          'start_date': startDate,
          'end_date': endDate,
          'max_student_amount': maxStudentAmount,
          if (attachedCode != null) 'attached_code': attachedCode,
        },
      );

      debugPrint('ClassService - Response received: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      debugPrint('ClassService - Response meta: $meta');

      if (meta['code'] == '9998') {
        debugPrint('ClassService - Token expired');
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        debugPrint('ClassService - Error: ${meta['message']}');

        // Map specific error codes to more meaningful messages
        switch (meta['code']) {
          case '1004':
            if (responseData['data']
                .toString()
                .contains('class id already exists')) {
              throw Exception('Class ID already exists');
            }
            throw Exception('Invalid parameters: ${responseData['data']}');
          case '9998':
            ref.read(authProvider.notifier).signOut();
            throw UnauthorizedException(
                'Session expired. Please sign in again.');
          default:
            throw Exception('Failed to create class: ${responseData['data']}');
        }
      }

      debugPrint('ClassService - Class created successfully');
    } on DioException catch (e) {
      debugPrint('ClassService - DioException: ${e.message}');
      debugPrint('ClassService - Response: ${e.response?.data}');
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(meta?['message'] ?? 'Failed to create class');
    }
  }

  Future<List<ClassListItem>> getClassList(
    String token, {
    String? role,
    int? page,
    int? pageSize,
  }) async {
    try {
      debugPrint('ClassService - Fetching class list with token: $token');

      final Map<String, dynamic> requestData = {
        'token': token,
        if (role != null) 'role': role,
        if (page != null || pageSize != null)
          'pageable_request': {
            'page': (page ?? 0).toString(),
            'page_size': (pageSize ?? 10).toString(),
          },
      };

      final response = await _apiService.dio.post(
        '/it5023e/get_class_list',
        data: requestData,
      );
      debugPrint('ClassService - Raw response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        throw Exception(meta['message'] ?? 'Failed to get class list');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final pageContent = data['page_content'] as List<dynamic>;

      // Convert the list items and handle potential type mismatches
      return pageContent
          .map((json) {
            try {
              return ClassListItem.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('ClassService - Error parsing class item: $e');
              debugPrint('ClassService - Problematic JSON: $json');
              // Skip invalid items instead of failing the whole list
              return null;
            }
          })
          .whereType<ClassListItem>()
          .toList(); // Filter out null values
    } catch (e) {
      debugPrint('ClassService - Error fetching class list: $e');
      if (e is UnauthorizedException) rethrow;
      return []; // Return empty list on error
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

      final response = await _apiService.dio.post(
        '/it5023e/edit_class',
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9998') {
        // Token invalid code
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        throw Exception(meta['message'] ?? 'Failed to edit class');
      }

      return ClassModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        // Token invalid code
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(meta?['message'] ?? 'Failed to edit class');
    }
  }

  Future<ClassModel?> getBasicClassInfo({
    required String token,
    required String classId,
  }) async {
    try {
      debugPrint('ClassService - Fetching basic class info for ID: $classId');
      final response = await _apiService.dio.post(
        '/it5023e/get_basic_class_info',
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('ClassService - Raw response: $responseData');

      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        return null; // Return null if class not found
      }

      final data = responseData['data'] as Map<String, dynamic>;
      debugPrint('ClassService - Data to parse: $data');

      return ClassModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('ClassService - DioException: ${e.response?.data}');
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      return null; // Return null for any other error
    } catch (e) {
      debugPrint('ClassService - Unexpected error: $e');
      return null;
    }
  }

  String _mapClassType(String uiClassType) {
    switch (uiClassType) {
      case 'Theory':
        return 'LT';
      case 'Exercise':
        return 'BT';
      case 'Both':
        return 'LT_BT';
      default:
        throw Exception('Invalid class type');
    }
  }

  Future<void> deleteClass({
    required String token,
    required String classId,
  }) async {
    try {
      final data = {
        'token': token,
        'role': 'LECTURER', // Hardcoded as per endpoint example
        'class_id': classId,
      };

      final response = await _apiService.dio.post(
        '/it5023e/delete_class',
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9998') {
        // Token invalid code
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        throw Exception(meta['message'] ?? 'Failed to delete class');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        // Token invalid code
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(meta?['message'] ?? 'Failed to delete class');
    }
  }

  Future<ClassModel?> searchClass({
    required String token,
    required String classId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it5023e/get_class_info',
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] != '1000') {
        return null; // Return null if class not found
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return ClassModel.fromJson(data);
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      return null; // Return null for any other error
    }
  }

  Future<List<Map<String, String>>> registerClasses({
    required String token,
    required List<String> classIds,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/it5023e/register_class',
        data: {
          'token': token,
          'class_ids': classIds,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '1009') {
        throw UnauthorizedException(
            'Your role is not allowed to register for classes');
      }

      if (meta['code'] != '1000') {
        throw Exception(meta['message'] ?? 'Failed to register classes');
      }

      final data = responseData['data'] as List<dynamic>;
      return data
          .map((item) => {
                'status': item['status'] as String,
                'class_id': item['class_id'] as String,
              })
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(meta?['message'] ?? 'Failed to register classes');
    }
  }

  Future<ClassModel?> getClassInfo({
    required String token,
    required String classId,
  }) async {
    try {
      debugPrint('ClassService - Fetching class info for ID: $classId');
      final response = await _apiService.dio.post(
        '/it5023e/get_basic_class_info', // Using the basic info endpoint
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('ClassService - Raw response: $responseData');

      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        return null;
      }

      final data = responseData['data'] as Map<String, dynamic>;
      debugPrint('ClassService - Data to parse: $data');

      return ClassModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('ClassService - DioException: ${e.response?.data}');
      final responseData = e.response?.data as Map<String, dynamic>?;
      final meta = responseData?['meta'] as Map<String, dynamic>?;

      if (meta?['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      return null;
    } catch (e) {
      debugPrint('ClassService - Unexpected error: $e');
      return null;
    }
  }

  Future<ClassDetailModel?> getClassDetail({
    required String token,
    required String classId,
  }) async {
    try {
      debugPrint(
          'ClassService - Fetching detailed class info for ID: $classId');
      final response = await _apiService.dio.post(
        '/it5023e/get_class_info',
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == '9998') {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != '1000') {
        return null;
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return ClassDetailModel.fromJson(data);
    } catch (e) {
      debugPrint('ClassService - Error fetching class detail: $e');
      return null;
    }
  }
}
