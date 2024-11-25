import 'package:firebase_messaging/firebase_messaging.dart';

class FireBaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;
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