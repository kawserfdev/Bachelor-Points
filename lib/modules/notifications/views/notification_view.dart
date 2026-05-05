import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchNotifications(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.notifications.isEmpty) {
          return const Center(child: Text('No new notifications.'));
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final isRead = notification.isRead;
            
            return Card(
              color: isRead ? Colors.white : Colors.blue.shade50,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(
                  notification.title,
                  style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body),
                    const SizedBox(height: 4),
                    Text(
                      notification.createdAt.toLocal().toString().split('.')[0],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  if (!isRead) {
                    controller.markAsRead(notification.id);
                  }
                },
                leading: Icon(
                  isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: isRead ? Colors.grey : Colors.blue,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
