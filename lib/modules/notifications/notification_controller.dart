import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../services/auth_service.dart';
class NotificationController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
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
    final userId = _authService.currentUser.value?.id;

    debugPrint('[fetchNotifications] userId: $userId');

    if (userId == null) {
      debugPrint('[fetchNotifications] No user found');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[fetchNotifications] Fetching notifications...');

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint(
          '[fetchNotifications] Raw count: ${(response as List).length}');

      final list = response
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      notifications.assignAll(list);

      debugPrint(
          '[fetchNotifications] Parsed count: ${notifications.length}');
    } catch (e) {
      debugPrint('[fetchNotifications] Error: $e');

      // Optional:
      // Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
      debugPrint('[fetchNotifications] Loading finished');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    debugPrint('[markAsRead] notificationId: $notificationId');

    try {
      debugPrint('[markAsRead] Sending update to Supabase');

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

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