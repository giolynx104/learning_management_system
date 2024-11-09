import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/class_model.dart';
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
