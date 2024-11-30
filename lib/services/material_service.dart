import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/material_model.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:learning_management_system/constants/api_constants.dart';

part 'material_service.g.dart';

@riverpod
class MaterialService extends _$MaterialService {
  ApiService get _apiService => ref.read(apiServiceProvider);

  @override
  FutureOr<void> build() {}

  Future<MaterialListResponse> getMaterialList({
    required String token,
    required String classId,
  }) async {
    try {
      debugPrint(
          'MaterialService - Fetching material list for class: $classId');

      final response = await _apiService.dio.post(
        ApiConstants.getMaterialList,
        data: {
          'token': token,
          'class_id': classId,
        },
      );

      debugPrint('MaterialService - Raw response: ${response.data}');

      if (response.data == null) {
        return const MaterialListResponse(
          code: '1000',
          message: 'Success',
          data: [],
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      debugPrint('MaterialService - Response code: ${responseData['code']}');
      debugPrint(
          'MaterialService - Response message: ${responseData['message']}');
      debugPrint('MaterialService - Response data: ${responseData['data']}');

      if (responseData['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (responseData['code'] != ApiConstants.successCode) {
        throw Exception(
            responseData['message'] ?? 'Failed to get material list');
      }

      final materialListResponse = MaterialListResponse.fromJson(responseData);
      debugPrint(
          'MaterialService - Parsed materials count: ${materialListResponse.data.length}');

      return materialListResponse;
    } on DioException catch (e) {
      debugPrint('MaterialService - DioException: ${e.message}');
      debugPrint('MaterialService - Response data: ${e.response?.data}');

      final responseData = e.response?.data as Map<String, dynamic>?;
      if (responseData?['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(
          responseData?['message'] ?? 'Failed to get material list');
    } catch (e, stackTrace) {
      debugPrint('MaterialService - Error getting material list: $e');
      debugPrint('MaterialService - Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> uploadMaterial({
    required String token,
    required String classId,
    required String title,
    required String description,
    required String materialType,
    required String filePath,
  }) async {
    // Validate file type
    final extension = filePath.split('.').last.toLowerCase();
    final mimeType = switch (extension) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => throw Exception('Unsupported file type: $extension'),
    };

    // Ensure materialType matches the actual file type
    final validatedMaterialType = switch (extension) {
      'pdf' => 'PDF',
      'jpg' || 'jpeg' || 'png' => 'IMAGE',
      _ => materialType,
    };

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: MediaType.parse(mimeType),
      ),
      'token': token,
      'classId': classId,
      'title': title,
      'description': description,
      'materialType': validatedMaterialType,
    });

    try {
      final response = await _apiService.dio.post(
        ApiConstants.uploadMaterial,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': '*/*',
          },
          validateStatus: (status) => status! < 500,
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          debugPrint('Upload progress: $progress%');
        },
      );

      debugPrint('MaterialService - Upload response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['code'] != ApiConstants.successCode) {
        throw Exception(responseData['message'] ?? 'Failed to upload material');
      }
    } catch (e) {
      debugPrint('MaterialService - Error during upload: $e');
      throw Exception('Failed to upload material: $e');
    }
  }

  Future<void> deleteMaterial({
    required String token,
    required String materialId,
  }) async {
    try {
      debugPrint('MaterialService - Deleting material: $materialId');

      final response = await _apiService.dio.post(
        ApiConstants.deleteMaterial,
        data: {
          'token': token,
          'material_id': materialId,
        },
      );

      debugPrint('MaterialService - Delete response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (responseData['code'] != ApiConstants.successCode) {
        throw Exception(
          responseData['message'] ?? 'Failed to delete material',
        );
      }

      debugPrint('MaterialService - Material deleted successfully');
    } on DioException catch (e) {
      debugPrint('MaterialService - DioException: ${e.message}');
      final responseData = e.response?.data as Map<String, dynamic>?;

      if (responseData?['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(responseData?['message'] ?? 'Failed to delete material');
    } catch (e) {
      debugPrint('MaterialService - Error deleting material: $e');
      rethrow;
    }
  }

  Future<MaterialResponse> editMaterial({
    required String token,
    required String materialId,
    required String classId,
    required String title,
    required String description,
    required String materialType,
    String? filePath,
  }) async {
    try {
      debugPrint('MaterialService - Editing material: $materialId');

      final Map<String, dynamic> formMap = {
        'token': token,
        'materialId': materialId,
        'class_id': classId,
        'title': title,
        'description': description,
        'materialType': materialType,
      };

      // Only add file if a new one is provided
      if (filePath != null) {
        final file = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        );
        formMap['file'] = file;
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiService.dio.post(
        ApiConstants.editMaterial,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': '*/*',
          },
        ),
      );

      debugPrint('MaterialService - Edit response: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (responseData['code'] != ApiConstants.successCode) {
        throw Exception(responseData['message'] ?? 'Failed to edit material');
      }

      debugPrint('MaterialService - Material edited successfully');
      return MaterialResponse.fromJson(responseData);
    } on DioException catch (e) {
      debugPrint('MaterialService - DioException: ${e.message}');
      final responseData = e.response?.data as Map<String, dynamic>?;

      if (responseData?['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      throw Exception(responseData?['message'] ?? 'Failed to edit material');
    } catch (e) {
      debugPrint('MaterialService - Error editing material: $e');
      rethrow;
    }
  }
}
