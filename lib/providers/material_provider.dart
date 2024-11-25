import 'package:flutter/foundation.dart';
import 'package:learning_management_system/models/material_model.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/material_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Add this line to generate the code
part 'material_provider.g.dart';

final materialListProvider = FutureProvider.family<MaterialListResponse, String>(
  (ref, classId) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    
    if (user == null || user.token == null || user.token!.isEmpty) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await ref.read(materialServiceProvider.notifier).getMaterialList(
        token: user.token!,
        classId: classId,
      );
      
      if (response.data.isEmpty) {
        debugPrint('No materials found for class: $classId');
      }
      
      return response;
    } catch (e) {
      debugPrint('Error fetching materials: $e');
      if (e.toString().contains('null') || 
          e.toString().contains('No materials found')) {
        return const MaterialListResponse(
          code: '1000',
          message: 'Success',
          data: [],
        );
      }
      rethrow;
    }
  },
);

final uploadMaterialProvider = FutureProvider.family<void, UploadMaterialParams>(
  (ref, params) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    
    if (user == null || user.token == null || user.token!.isEmpty) {
      throw Exception('User not authenticated');
    }

    return ref.read(materialServiceProvider.notifier).uploadMaterial(
      token: user.token!,
      classId: params.classId,
      title: params.title,
      description: params.description,
      materialType: params.materialType,
      filePath: params.filePath,
    );
  },
);

class UploadMaterialParams {
  final String classId;
  final String title;
  final String description;
  final String materialType;
  final String filePath;

  const UploadMaterialParams({
    required this.classId,
    required this.title,
    required this.description,
    required this.materialType,
    required this.filePath,
  });
}

@riverpod
class MaterialListNotifier extends _$MaterialListNotifier {
  @override
  FutureOr<MaterialListResponse> build(String classId) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    
    if (user == null || user.token == null || user.token!.isEmpty) {
      throw Exception('User not authenticated');
    }

    return ref.read(materialServiceProvider.notifier).getMaterialList(
      token: user.token!,
      classId: classId,
    );
  }

  Future<void> deleteMaterial(String materialId) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    
    if (user == null || user.token == null || user.token!.isEmpty) {
      throw Exception('User not authenticated');
    }

    await ref.read(materialServiceProvider.notifier).deleteMaterial(
      token: user.token!,
      materialId: materialId,
    );
    ref.invalidateSelf();
  }

  Future<void> editMaterial({
    required String materialId,
    required String classId,
    required String title,
    required String description,
    required String materialType,
    String? filePath,
  }) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    
    if (user == null || user.token == null || user.token!.isEmpty) {
      throw Exception('User not authenticated');
    }

    await ref.read(materialServiceProvider.notifier).editMaterial(
      token: user.token!,
      materialId: materialId,
      classId: classId,
      title: title,
      description: description,
      materialType: materialType,
      filePath: filePath,
    );
    ref.invalidateSelf();
  }
}
