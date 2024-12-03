import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
class FireBaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message:');
  _printRemoteMessage(message);
}
void _printRemoteMessage(RemoteMessage message) {
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
    // Platform-specific fields can be added here if needed
  };
  // Convert the map to a pretty-printed JSON string
  String prettyMessage = const JsonEncoder.withIndent('  ').convert(messageDetails);
  print(prettyMessage);
}
  Future<void> initNotification() async{
    await _firebaseMessaging.requestPermission();
    try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
  } catch (e) {
    print("Error fetching token: $e");
    Future.delayed(Duration(seconds: 10), initNotification);
  }
  }
  
}