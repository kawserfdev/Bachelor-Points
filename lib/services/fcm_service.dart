import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;

  Future<FcmService> init() async {
    // Request permission for iOS
    await _fcm.requestPermission();

    // Get token
    String? token = await _fcm.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }

    if (token != null) {
      _syncToken(token);
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_syncToken);

    // Listen for auth state changes to resync token if a user logs in
    _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
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
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', user.id);
      } catch (e) {
        if (kDebugMode) {
          print("Error syncing FCM token: $e");
        }
      }
    }
  }
}
