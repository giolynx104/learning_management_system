import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/notification_model.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/constants/api_constants.dart';

part 'notification_service.g.dart';

@riverpod
class NotificationService extends _$NotificationService {
  @override
  FutureOr<void> build() {}

  ApiService get _apiService => ref.read(apiServiceProvider);

  /// Fetch the list of notifications
  Future<List<NotificationModel>> getNotifications(
    String token, {
    int index = 0,
    int count = 10,
  }) async {
    try {
      debugPrint('NotificationService - Fetching notifications.');

      final Map<String, dynamic> requestData = {
        'token': token,
        'index': index,
        'count': count,
      };

      final response = await _apiService.dio.post(
        ApiConstants.getNotifications,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != ApiConstants.successCode) {
        throw Exception(meta['message'] ?? 'Failed to get notifications');
      }

      final data = responseData['data'];
      if (data is! List) {
        throw Exception('Unexpected data format');
      }

      return data
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('NotificationService - Error fetching notifications: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (e is UnauthorizedException) rethrow;
      throw Exception('An error occurred while fetching notifications.');
    }
  }

  Future<void> sendNotification(
    String token,
    String message,
    String toUser,
    String type,
    String? image,
  ) async {
    try {
      debugPrint('NotificationService - Sending notification with params:');
      debugPrint('  token: $token');
      debugPrint('  message: $message');
      debugPrint('  toUser: $toUser');
      debugPrint('  type: $type');
      debugPrint('  image: $image');

      // Create form data
      final formData = FormData.fromMap({
        'token': token,
        'message': message,
        'toUser': toUser,
        'type': type,
      });

      if (image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(image),
        ));
      }

      debugPrint('NotificationService - Sending request with formData: ${formData.fields}');

      final response = await _apiService.dio.post(
        ApiConstants.sendNotification,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => true,
        ),
      );

      debugPrint('NotificationService - Response status: ${response.statusCode}');
      debugPrint('NotificationService - Response data: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != ApiConstants.successCode) {
        throw Exception(meta['message'] ?? 'Failed to send notification');
      }

      debugPrint('NotificationService - Notification sent successfully.');
    } catch (e, stackTrace) {
      debugPrint('NotificationService - Error sending notification: $e');
      debugPrint('NotificationService - Error stacktrace: $stackTrace');
      if (e is DioException) {
        debugPrint('NotificationService - Response data: ${e.response?.data}');
        debugPrint('NotificationService - Response headers: ${e.response?.headers}');
      }
      if (e is UnauthorizedException) rethrow;
      throw Exception('An error occurred while sending the notification.');
    }
  }
  Future<int> getUnreadNotificationCount(String token) async {
    try {
      debugPrint('NotificationService - Fetching unread notifications count.');

      final Map<String, dynamic> requestData = {
        'token': token,
      };

      final response = await _apiService.dio.post(
        ApiConstants.getUnreadCount,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != ApiConstants.successCode) {
        throw Exception(meta['message'] ?? 'Failed to get unread notifications count');
      }

      final data = responseData['data'];

      if (data is! int) {
        throw Exception('Unexpected data format');
      }

      return data;
    } catch (e, stackTrace) {
      debugPrint('NotificationService - Error fetching unread notifications count: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (e is UnauthorizedException) rethrow;
      throw Exception('An error occurred while fetching the unread notifications count.');
    }
  }
  Future<void> markNotificationAsRead(String token, String notificationId) async {
    try {
      debugPrint('NotificationService - Marking notification as read.');

      final Map<String, dynamic> requestData = {
        'token': token,
        'notification_id': notificationId,
      };

      final response = await _apiService.dio.post(
        ApiConstants.markAsRead,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == ApiConstants.sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != ApiConstants.successCode) {
        throw Exception(meta['message'] ?? 'Failed to mark notification as read');
      }

      debugPrint('NotificationService - Notification marked as read successfully.');
    } catch (e, stackTrace) {
      debugPrint('NotificationService - Error marking notification as read: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (e is UnauthorizedException) rethrow;
      throw Exception('An error occurred while marking the notification as read.');
    }
  }
}
