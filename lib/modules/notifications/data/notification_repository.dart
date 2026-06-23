import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/notification_model.dart';
import '../domain/notification_preferences.dart';

/// Repository interface handling notification reads/writes, preferences, tokens, and logs.
abstract class NotificationRepository {
  /// Returns a stream of notifications for the specified [userId].
  Stream<List<NotificationModel>> getNotificationsStream(String userId);

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read for a given [userId].
  Future<void> markAllAsRead(String userId);

  /// Deletes a specific notification.
  Future<void> deleteNotification(String notificationId);

  /// Syncs an FCM token to the user's secure fcm_tokens subcollection.
  Future<void> syncFcmToken(
    String userId,
    String token,
    String platform,
    String deviceName,
  );

  /// Removes an FCM token (usually called on logout).
  Future<void> removeFcmToken(String userId, String token);

  /// Gets the notification preferences for a given [userId].
  Future<NotificationPreferences> getPreferences(String userId);

  /// Updates the notification preferences for a given [userId].
  Future<void> updatePreferences(
    String userId,
    NotificationPreferences preferences,
  );

  /// Logs a notification event for audit and debug tracing.
  Future<void> logNotificationEvent({
    required String userId,
    required String notificationId,
    required String status,
    String? errorMessage,
  });

  /// Creates/sends a notification to a specific user by writing to the notifications collection.
  Future<void> sendNotification({
    required String targetUserId,
    required String messId,
    required String title,
    required String body,
    required String type,
    String? route,
  });
}

/// Firestore implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            return NotificationModel.fromJson({'id': doc.id, ...doc.data()});
          }).toList();

          // Sort in-memory descending by createdAt to bypass Firestore index requirements
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'is_read': true,
      'read_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final unreadQuery = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .get();

    if (unreadQuery.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in unreadQuery.docs) {
      batch.update(doc.reference, {
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  @override
  Future<void> syncFcmToken(
    String userId,
    String token,
    String platform,
    String deviceName,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fcm_tokens')
        .doc(token)
        .set({
          'token': token,
          'platform': platform,
          'device_name': deviceName,
          'updated_at': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> removeFcmToken(String userId, String token) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fcm_tokens')
        .doc(token)
        .delete();
  }

  @override
  Future<NotificationPreferences> getPreferences(String userId) async {
    final doc = await _firestore
        .collection('notification_preferences')
        .doc(userId)
        .get();
    if (doc.exists && doc.data() != null) {
      return NotificationPreferences.fromJson(doc.data()!);
    }
    return const NotificationPreferences();
  }

  @override
  Future<void> updatePreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await _firestore
        .collection('notification_preferences')
        .doc(userId)
        .set(preferences.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> logNotificationEvent({
    required String userId,
    required String notificationId,
    required String status,
    String? errorMessage,
  }) async {
    try {
      await _firestore.collection('notification_logs').add({
        'user_id': userId,
        'notification_id': notificationId,
        'status': status,
        'error_message': errorMessage,
        'logged_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error writing notification log: $e");
    }
  }

  @override
  Future<void> sendNotification({
    required String targetUserId,
    required String messId,
    required String title,
    required String body,
    required String type,
    String? route,
  }) async {
    debugPrint('[sendNotification] TargetUserId: $targetUserId | Title: $title | Body: $body | Type: $type');
    
    // 1. Write to local Firestore notifications collection
    String? notificationId;
    try {
      final docRef = await _firestore.collection('notifications').add({
        'user_id': targetUserId,
        'mess_id': messId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
        'route': route,
        'created_at': FieldValue.serverTimestamp(),
      });
      notificationId = docRef.id;
      debugPrint('[sendNotification] Notification document written successfully: $notificationId');
    } catch (e) {
      debugPrint('[sendNotification] Error writing notification to Firestore: $e');
    }

    // 2. Dispatch FCM notification via Vercel Backend if configured
    final apiUrl = dotenv.env['VERCEL_API_URL'];
    final apiSecret = dotenv.env['VERCEL_API_SECRET'];

    if (apiUrl == null || apiUrl.isEmpty) {
      debugPrint('[sendNotification] VERCEL_API_URL is not set. Skipping FCM push.');
      if (notificationId != null) {
        await logNotificationEvent(
          userId: targetUserId,
          notificationId: notificationId,
          status: 'skipped_fcm_not_configured',
        );
      }
      return;
    }

    try {
      debugPrint('[sendNotification] Sending request to Vercel FCM backend: $apiUrl');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (apiSecret != null && apiSecret.isNotEmpty) {
        headers['x-api-key'] = apiSecret;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode({
          'targetUserId': targetUserId,
          'title': title,
          'body': body,
          'type': type,
          'route': route ?? '/',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('[sendNotification] Vercel backend dispatched FCM successfully: ${response.body}');
        if (notificationId != null) {
          await logNotificationEvent(
            userId: targetUserId,
            notificationId: notificationId,
            status: 'sent',
          );
        }
      } else {
        final errorMsg = 'Failed with status code: ${response.statusCode}, body: ${response.body}';
        debugPrint('[sendNotification] Vercel backend error: $errorMsg');
        if (notificationId != null) {
          await logNotificationEvent(
            userId: targetUserId,
            notificationId: notificationId,
            status: 'failed',
            errorMessage: errorMsg,
          );
        }
      }
    } catch (e) {
      final errorMsg = e.toString();
      debugPrint('[sendNotification] Exception sending to Vercel API: $errorMsg');
      if (notificationId != null) {
        await logNotificationEvent(
          userId: targetUserId,
          notificationId: notificationId,
          status: 'failed',
          errorMessage: errorMsg,
        );
      }
    }
  }
}

/// Riverpod provider for [NotificationRepository].
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});
