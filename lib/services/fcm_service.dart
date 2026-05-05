import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<FcmService> init() async {
    // Request permission for iOS
    await _fcm.requestPermission();

    // Get token
    String? token = await _fcm.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
        );
      }
    });

    return this;
  }
}
