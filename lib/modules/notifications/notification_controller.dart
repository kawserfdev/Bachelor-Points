import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../services/auth_service.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxList<NotificationModel> notifications =
      <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[NotificationController] Initialized');
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final userId = _authService.currentUser.value?.uid;

    debugPrint('[fetchNotifications] userId: $userId');

    if (userId == null) {
      debugPrint('[fetchNotifications] No user found');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[fetchNotifications] Fetching notifications...');

      final response = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      debugPrint(
          '[fetchNotifications] Raw count: ${response.docs.length}');

      final list = response.docs
          .map((doc) => NotificationModel.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .toList();

      notifications.assignAll(list);

      debugPrint(
          '[fetchNotifications] Parsed count: ${notifications.length}');
    } catch (e) {
      debugPrint('[fetchNotifications] Error: $e');
    } finally {
      isLoading.value = false;
      debugPrint('[fetchNotifications] Loading finished');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    debugPrint('[markAsRead] notificationId: $notificationId');

    try {
      debugPrint('[markAsRead] Sending update to Firestore');

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});

      debugPrint('[markAsRead] Update success');

      final index =
          notifications.indexWhere((n) => n.id == notificationId);

      debugPrint('[markAsRead] Found index: $index');

      if (index != -1) {
        final old = notifications[index];

        notifications[index] = NotificationModel(
          id: old.id,
          userId: old.userId,
          title: old.title,
          body: old.body,
          isRead: true,
          createdAt: old.createdAt,
        );

        debugPrint('[markAsRead] Local state updated');
      } else {
        debugPrint('[markAsRead] Notification not found in local list');
      }
    } catch (e) {
      debugPrint('[markAsRead] Error: $e');
    }
  }
}