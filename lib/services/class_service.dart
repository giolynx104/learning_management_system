import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/class_model.dart';
import '../utils/api_client.dart';

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
    required int lecturerId,
  }) async {
    try {
      final response = await ref.read(apiClientProvider).post(
        '/it5023e/create_class',
        data: {
          'token': token,
          'class_id': classId,
          'class_name': className,
          'class_type': classType,
          'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
          'end_date': endDate.toIso8601String().split('T')[0],
          'max_student_amount': maxStudentAmount,
          'lecturer_id': lecturerId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create class: HTTP ${response.statusCode}');
      }

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;
      
      if (meta['code'] != 1000) {
        throw Exception(meta['message'] ?? 'Unknown error occurred');
      }

      return ClassModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create class: $e');
    }
  }

  Future<List<ClassModel>> getClassList({
    required String role,
    required String accountId,
  }) async {
    final response = await ref.read(apiClientProvider).get(
      '/it5023e/get_class_list',
      queryParameters: {
        'role': role,
        'account_id': accountId,
      },
    );

    // TODO: Handle response format
    // Need to verify the exact response structure from backend
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => ClassModel.fromJson(json)).toList();
  }
} 