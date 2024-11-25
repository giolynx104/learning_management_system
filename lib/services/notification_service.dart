import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/models/notification_model.dart';
import 'package:learning_management_system/services/api_service.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

part 'notification_service.g.dart';

@riverpod
class NotificationService extends _$NotificationService {
  @override
  FutureOr<void> build() {}

  ApiService get _apiService => ref.read(apiServiceProvider);

  static const String _getNotificationsEndpoint = '/it5023e/get_notifications';
  static const String _sendNotificationEndpoint = '/it5023e/send_notification';
  static const String _getUnreadCountEndpoint = '/it5023e/get_unread_notification_count';
  static const String _markAsReadEndpoint = '/it5023e/mark_notification_as_read';
  static const String _sessionExpiredCode = '9998';
  static const String _successCode = '1000';

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
        _getNotificationsEndpoint,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == _sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != _successCode) {
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

  /// Send a notification
  Future<void> sendNotification({
    required String token,
    required String message,
    required String toUser,
    required String type,
    XFile? imageFile,
  }) async {
    try {
      debugPrint('NotificationService - Sending notification.');

      // Prepare the form data
      final formData = FormData();

      formData.fields.add(MapEntry('token', token));
      formData.fields.add(MapEntry('message', message));
      formData.fields.add(MapEntry('toUser', toUser));
      formData.fields.add(MapEntry('type', type));

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
        ));
      }

      // Send the POST request with form-data
      final response = await _apiService.dio.post(
        _sendNotificationEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == _sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != _successCode) {
        throw Exception(meta['message'] ?? 'Failed to send notification');
      }

      debugPrint('NotificationService - Notification sent successfully.');
    } catch (e, stackTrace) {
      debugPrint('NotificationService - Error sending notification: $e');
      debugPrintStack(stackTrace: stackTrace);
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
        _getUnreadCountEndpoint,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == _sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != _successCode) {
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
  /// Mark a notification as read
  Future<void> markNotificationAsRead(String token, String notificationId) async {
    try {
      debugPrint('NotificationService - Marking notification as read.');

      final Map<String, dynamic> requestData = {
        'token': token,
        'notification_id': notificationId,
      };

      final response = await _apiService.dio.post(
        _markAsReadEndpoint,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;
      final meta = responseData['meta'] as Map<String, dynamic>;

      if (meta['code'] == _sessionExpiredCode) {
        ref.read(authProvider.notifier).signOut();
        throw UnauthorizedException('Session expired. Please sign in again.');
      }

      if (meta['code'] != _successCode) {
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
