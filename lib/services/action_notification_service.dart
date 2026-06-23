import 'package:flutter/foundation.dart';
import '../modules/notifications/data/notification_repository.dart';

/// A public service to handle action-based push notifications.
class ActionNotificationService {
  static final NotificationRepositoryImpl _notificationRepo = NotificationRepositoryImpl();

  /// Send notification to managers or admins when an expense is added.
  static Future<void> notifyExpenseAdded({
    required String messId,
    required String senderName,
    required double amount,
    required String label,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    // Added entry log
    debugPrint('[ActionNotificationService] notifyExpenseAdded called by $senderName (ID: $currentUserId) for messId: $messId. Amount: $amount, Label: $label');
    
    try {
      final managersAndAdmins = members.where((m) =>
          m.userId != currentUserId &&
          (m.role == 'manager' || m.role == 'owner')).toList();

      debugPrint('[ActionNotificationService] Dispatching expense notification to ${managersAndAdmins.length} managers/admins...');

      for (var member in managersAndAdmins) {
        try {
          // Added step log for each individual notification payload
          debugPrint('[ActionNotificationService] Attempting to send notification to User ID: ${member.userId} (${member.role})');
          
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'New Expense Request',
            body: '$senderName requested an expense of $amount for $label.',
            type: 'expense',
            route: '/requests',
          );
          
          // Added success confirmation log
          debugPrint('[ActionNotificationService] Notification successfully sent to User ID: ${member.userId}');
        } catch (e) {
          debugPrint('[ActionNotificationService] Failed to send expense notification to ${member.userId}: $e');
        }
      }
    } catch (e) {
      debugPrint('[ActionNotificationService] Error filtering members or iterating in notifyExpenseAdded: $e');
    }
  }

  /// Send notification to the applicant when their request is accepted.
  static Future<void> notifyRequestAccepted({
    required String targetUserId,
    required String messId,
    required String typeLabel,
    required String detail,
  }) async {
    // Added entry log
    debugPrint('[ActionNotificationService] notifyRequestAccepted called for targetUserId: $targetUserId, messId: $messId, type: $typeLabel');
    
    try {
      debugPrint('[ActionNotificationService] Dispatching approval notification to request creator: $targetUserId');
      
      await _notificationRepo.sendNotification(
        targetUserId: targetUserId,
        messId: messId,
        title: 'Request Approved',
        body: 'Your request for $typeLabel$detail has been approved.',
        type: 'request_status',
        route: '/requests',
      );
      
      // Added success confirmation log
      debugPrint('[ActionNotificationService] Approval notification successfully sent to targetUserId: $targetUserId');
    } catch (e) {
      debugPrint('[ActionNotificationService] Error notifying request accepted for $targetUserId: $e');
    }
  }
}