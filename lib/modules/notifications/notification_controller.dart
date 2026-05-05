import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../services/auth_service.dart';

class NotificationController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      notifications.assignAll((response as List).map((e) => NotificationModel.fromJson(e)).toList());
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      // Uncomment to show a snackbar on error
      // Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
          
      // Update local state without refetching to be faster
      final index = notifications.indexWhere((n) => n.id == notificationId);
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
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
