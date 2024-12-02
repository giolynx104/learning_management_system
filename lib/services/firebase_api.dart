import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:learning_management_system/constants/api_constants.dart';
import 'package:learning_management_system/services/storage_service.dart';

class FireBaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;
  final StorageService _storageService = StorageService() ;
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling a background message:');
    _printRemoteMessage(message);
  }
  static void _printRemoteMessage(RemoteMessage message) {
    final Map<String, dynamic> messageDetails = {
      'senderId': message.senderId,
      'category': message.category,
      'collapseKey': message.collapseKey,
      'contentAvailable': message.contentAvailable,
      'data': message.data,
      'from': message.from,
      'messageId': message.messageId,
      'messageType': message.messageType,
      'mutableContent': message.mutableContent,
      'notification': message.notification != null
          ? {
              'title': message.notification!.title,
              'body': message.notification!.body,
              'android': message.notification!.android?.toMap(),
              'apple': message.notification!.apple?.toMap(),
            }
          : null,
      'sentTime': message.sentTime?.toIso8601String(),
      'threadId': message.threadId,
      'ttl': message.ttl,
    };

    String prettyMessage = const JsonEncoder.withIndent('  ').convert(messageDetails);
    debugPrint(prettyMessage);
  }
  Future<void> initNotification() async {
  print('initNotification: Start');
  try {
    print('Requesting permission');
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    print('Permission status: ${settings.authorizationStatus}');
    
    print('Fetching FCM token');
    String? token = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 10));
   
    if (token != null) {
      debugPrint("FCM Token: $token");
      await _storageService.setFCMToken(token);
    } else {
      debugPrint("Failed to retrieve FCM Token");
    }
  } on TimeoutException catch (e) {
    debugPrint("Timeout fetching token: $e");
  } catch (e, stackTrace) {
    debugPrint("Error fetching token: $e");
    debugPrint("Stack trace: $stackTrace");
  }
  print('initNotification: End');
}
}
  