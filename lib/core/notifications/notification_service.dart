import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../modules/notifications/data/notification_repository.dart';
import '../providers/auth_providers.dart';
import '../../shared/helpers/navigation_helper.dart';

/// Coordinator service managing push messaging (FCM) and local notifications.
class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'bachelorpoints_channel';
  static const String _androidChannelName = 'BachelorPoints Notifications';
  static const String _androidChannelDescription =
      'Channel for high-importance bachelorpoints notifications';

  static NotificationService? _instance;
  static NotificationService? get instance => _instance;

  NotificationService(this._ref) {
    _instance = this;
  }

  /// Initializes timezone configurations, notification channels, listeners, and startup messages.
  Future<void> init() async {
    debugPrint('Initializing NotificationService...');

    // 1. Timezone database initialization (for scheduled reminders)
    tz.initializeTimeZones();

    // 2. Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // 3. Android High Importance Channel creation
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // 4. Request FCM permissions
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 5. Setup Token Refresh Listener
    _fcm.onTokenRefresh.listen((token) {
      _syncToken(token);
    });

    // 6. Foreground message handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessageReceived);

    // 7. Background message opened app listener (app in background -> user clicks notif)
    FirebaseMessaging.onMessageOpenedApp.listen(_onPushNotificationTapped);

    // 8. Terminated state (cold start -> user clicks notif)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleDeepLink(initialMessage);
    }

    // 9. Sync token immediately if user is already authenticated
    final authState = _ref.read(authStateProvider);
    if (authState == AuthState.authenticated) {
      final token = await _fcm.getToken();
      if (token != null) {
        await _syncToken(token);
      }
    }
  }

  /// Triggered when FCM token refresh occurs or user signs in.
  Future<void> _syncToken(String token) async {
    final userAsync = _ref.read(authUserStreamProvider);
    final user = userAsync.asData?.value;
    if (user == null) return;

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown Device';
      String platform = 'Unknown';

      if (kIsWeb) {
        platform = 'web';
        deviceName = 'Web Browser';
      } else if (Platform.isAndroid) {
        platform = 'android';
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        platform = 'ios';
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      }

      final repo = _ref.read(notificationRepositoryProvider);
      await repo.syncFcmToken(user.uid, token, platform, deviceName);
      debugPrint("FCM token synced successfully for device: $deviceName");
    } catch (e) {
      debugPrint("Error syncing FCM token: $e");
    }
  }

  /// Removes current FCM token during logout sequence.
  Future<void> removeToken() async {
    try {
      final userAsync = _ref.read(authUserStreamProvider);
      final user = userAsync.asData?.value;
      if (user != null) {
        final token = await _fcm.getToken();
        if (token != null) {
          final repo = _ref.read(notificationRepositoryProvider);
          await repo.removeFcmToken(user.uid, token);
          debugPrint("FCM token removed successfully from database.");
        }
      }
    } catch (e) {
      debugPrint("Error removing FCM token: $e");
    }
  }

  /// Handles foreground push notifications.
  void _onForegroundMessageReceived(RemoteMessage message) {
    debugPrint("Foreground message received: ${message.notification?.title}");

    final notification = message.notification;
    if (notification == null) return;

    // Retrieve preferences to respect sound/vibration/push toggles
    final userAsync = _ref.read(authUserStreamProvider);
    final user = userAsync.asData?.value;
    if (user != null) {
      _ref.read(notificationRepositoryProvider).getPreferences(user.uid).then((
        prefs,
      ) {
        if (!prefs.pushNotifications) return;

        _showLocalNotification(
          title: notification.title ?? '',
          body: notification.body ?? '',
          payload: message.data['route'] as String?,
          playSound: prefs.sound,
          enableVibration: prefs.vibration,
        );
      });
    } else {
      _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data['route'] as String?,
      );
    }
  }

  /// Shows local notifications on screen (either for offline triggers or foreground FCM).
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: enableVibration,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Triggered when a local notification is tapped.
  void _onLocalNotificationTapped(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) {
      AppNavigation.to(route);
    }
  }

  /// Triggered when a background push notification is tapped.
  void _onPushNotificationTapped(RemoteMessage message) {
    _handleDeepLink(message);
  }

  /// Handles routing deep-links from push messages.
  void _handleDeepLink(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      AppNavigation.to(route);
    }
  }

  /// Public API to dispatch instant offline notification.
  Future<void> showOfflineNotification({
    required String title,
    required String body,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: '/notifications',
    );
  }
}

/// Riverpod provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});
