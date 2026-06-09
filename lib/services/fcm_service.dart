import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FcmService extends GetxService {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<FcmService> init() async {
    debugPrint('FcmService init called');
    // Request permission for iOS
    await _fcm.requestPermission();

    // Get token
    String? token = await _fcm.getToken();
    debugPrint("FCM Token: $token");

    if (token != null) {
      _syncToken(token);
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_syncToken);

    // Listen for auth state changes to resync token if a user logs in
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        String? currentToken = await _fcm.getToken();
        if (currentToken != null) {
          _syncToken(currentToken);
        }
      }
    });

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

  Future<void> _syncToken(String token) async {
    debugPrint('FcmService _syncToken called');
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('profiles')
            .doc(user.uid)
            .set({'fcm_token': token}, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error syncing FCM token: $e");
      }
    }
  }
}
