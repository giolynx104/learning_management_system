import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:learning_management_system/constants/api_constants.dart';

class FireBaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
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
  Future<void> initNotification() async{
    await _firebaseMessaging.requestPermission();
    try {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM Token: $token");
  } catch (e) {
    debugPrint("Error fetching token: $e");
    Future.delayed(const Duration(seconds: 10), initNotification);
  }
  }
  

}