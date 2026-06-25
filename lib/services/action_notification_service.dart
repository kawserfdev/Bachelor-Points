import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import '../modules/notifications/data/notification_repository.dart';

/// A public service to handle action-based push notifications.
class ActionNotificationService {
  static final NotificationRepositoryImpl _notificationRepo =
      NotificationRepositoryImpl();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _localInitialized = false;

  // ---------------------------------------------------------------------------
  // LOCAL NOTIFICATION INIT
  // ---------------------------------------------------------------------------

  static Future<void> _ensureLocalInitialized() async {
    if (_localInitialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);
    _localInitialized = true;
    debugPrint(
      '[ActionNotificationService] FlutterLocalNotifications initialized.',
    );
  }

  // ---------------------------------------------------------------------------
  // EXPENSE
  // ---------------------------------------------------------------------------

  /// Send notification to managers or admins when an expense is added.
  static Future<void> notifyExpenseAdded({
    required String messId,
    required String senderName,
    required double amount,
    required String label,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyExpenseAdded called by $senderName (ID: $currentUserId) for messId: $messId. Amount: $amount, Label: $label',
    );

    try {
      final managersAndAdmins = members
          .where(
            (m) =>
                m.userId != currentUserId &&
                (m.role == 'manager' || m.role == 'owner'),
          )
          .toList();

      debugPrint(
        '[ActionNotificationService] Dispatching expense notification to ${managersAndAdmins.length} managers/admins...',
      );

      for (var member in managersAndAdmins) {
        try {
          debugPrint(
            '[ActionNotificationService] Attempting to send notification to User ID: ${member.userId} (${member.role})',
          );
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'New Expense Request',
            body: '$senderName requested an expense of $amount for $label.',
            type: 'expense',
            route: '/approvals',
          );
          debugPrint(
            '[ActionNotificationService] Notification successfully sent to User ID: ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to send expense notification to ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error filtering members or iterating in notifyExpenseAdded: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // REQUEST APPROVED (generic)
  // ---------------------------------------------------------------------------

  /// Send notification to the applicant when their request is accepted.
  static Future<void> notifyRequestAccepted({
    required String targetUserId,
    required String messId,
    required String typeLabel,
    required String detail,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyRequestAccepted called for targetUserId: $targetUserId, messId: $messId, type: $typeLabel',
    );

    try {
      await _notificationRepo.sendNotification(
        targetUserId: targetUserId,
        messId: messId,
        title: 'Request Approved',
        body: 'Your request for $typeLabel$detail has been approved.',
        type: 'request_status',
        route: '/approvals',
      );
      debugPrint(
        '[ActionNotificationService] Approval notification successfully sent to targetUserId: $targetUserId',
      );
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error notifying request accepted for $targetUserId: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MEAL
  // ---------------------------------------------------------------------------

  /// Notify all other mess members when someone updates their meal entry.
  static Future<void> notifyMealUpdated({
    required String messId,
    required String senderName,
    required String dateStr,
    required double breakfast,
    required double lunch,
    required double dinner,
    required double guestMeals,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyMealUpdated called by $senderName for $dateStr',
    );

    try {
      final otherMembers = members
          .where((m) => m.userId != currentUserId)
          .toList();
      debugPrint(
        '[ActionNotificationService] Dispatching meal update to ${otherMembers.length} members...',
      );

      for (var member in otherMembers) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'Meal Updated',
            // body: '$senderName updated meals for $dateStr: '
            //     'B:$breakfast, L:$lunch, D:$dinner, G:$guestMeals',
            body:
                '$senderName updated meal counts for $dateStr.\n'
                '🍳 Breakfast: $breakfast | 🍛 Lunch: $lunch | 🍽️ Dinner: $dinner | 👥 Guest Meals: $guestMeals',
            type: 'meal',
            route: '/meal-entry',
          );
          debugPrint(
            '[ActionNotificationService] Meal notification sent to ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint('[ActionNotificationService] Error in notifyMealUpdated: $e');
    }
  }

  /// Notify all other mess members when someone updates their meal plan for a duration.
  static Future<void> notifyMealPlanUpdated({
    required String messId,
    required String senderName,
    required String startDateStr,
    required String endDateStr,
    required double breakfast,
    required double lunch,
    required double dinner,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyMealPlanUpdated called by $senderName for $startDateStr to $endDateStr',
    );

    try {
      final otherMembers = members
          .where((m) => m.userId != currentUserId)
          .toList();
      debugPrint(
        '[ActionNotificationService] Dispatching meal plan update to ${otherMembers.length} members...',
      );

      for (var member in otherMembers) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'Meal Plan Set 📅',
            body:
                '$senderName set a meal plan from $startDateStr to $endDateStr.\n'
                '🍳 Breakfast: $breakfast | 🍛 Lunch: $lunch | 🍽️ Dinner: $dinner',
            type: 'meal',
            route: '/meal-entry',
          );
          debugPrint(
            '[ActionNotificationService] Meal plan notification sent to ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint('[ActionNotificationService] Error in notifyMealPlanUpdated: $e');
    }
  }

  /// Notify all other mess members when someone closes specific meals for a range of dates.
  static Future<void> notifyMealsClosed({
    required String messId,
    required String senderName,
    required String startDateStr,
    required String endDateStr,
    required String closedMealsLabel,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyMealsClosed called by $senderName for $startDateStr to $endDateStr',
    );

    try {
      final otherMembers = members
          .where((m) => m.userId != currentUserId)
          .toList();
      debugPrint(
        '[ActionNotificationService] Dispatching meal closed notification to ${otherMembers.length} members...',
      );

      for (var member in otherMembers) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'Meals Closed 🚫',
            body: '$senderName closed $closedMealsLabel from $startDateStr to $endDateStr.',
            type: 'meal',
            route: '/meal-entry',
          );
          debugPrint(
            '[ActionNotificationService] Meal closed notification sent to ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint('[ActionNotificationService] Error in notifyMealsClosed: $e');
    }
  }


  // ---------------------------------------------------------------------------
  // DEPOSIT
  // ---------------------------------------------------------------------------

  /// Notify managers/admins when a member submits a deposit request.
  static Future<void> notifyDepositRequested({
    required String messId,
    required String senderName,
    required double amount,
    required String paymentMethod,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyDepositRequested called by $senderName. Amount: $amount',
    );

    try {
      final managersAndAdmins = members
          .where(
            (m) =>
                m.userId != currentUserId &&
                (m.role == 'manager' || m.role == 'owner'),
          )
          .toList();

      debugPrint(
        '[ActionNotificationService] Dispatching deposit notification to ${managersAndAdmins.length} managers/admins...',
      );

      for (var member in managersAndAdmins) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'New Deposit Request',
            body:
                '$senderName requested a deposit of $amount via $paymentMethod.',
            type: 'deposit',
            route: '/approvals',
          );
          debugPrint(
            '[ActionNotificationService] Deposit notification sent to ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyDepositRequested: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // ROLE CHANGE
  // ---------------------------------------------------------------------------

  /// Notify a member when their role has been changed by an admin.
  static Future<void> notifyRoleChanged({
    required String targetUserId,
    required String messId,
    required String newRole,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyRoleChanged for $targetUserId → $newRole',
    );

    try {
      await _notificationRepo.sendNotification(
        targetUserId: targetUserId,
        messId: messId,
        title: 'Role Updated',
        body: 'Your role in the mess has been updated to $newRole.',
        type: 'manager',
        route: '/settings',
      );
      debugPrint(
        '[ActionNotificationService] Role change notification sent to $targetUserId',
      );
    } catch (e) {
      debugPrint('[ActionNotificationService] Error in notifyRoleChanged: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // MEAL CUTOFF TIME
  // ---------------------------------------------------------------------------

  /// Notify all members when the meal cutoff time has been updated.
  static Future<void> notifyCutoffTimeChanged({
    required String messId,
    required String newTime,
    required List<dynamic> members,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyCutoffTimeChanged → $newTime for $messId',
    );

    try {
      debugPrint(
        '[ActionNotificationService] Dispatching cutoff time notification to ${members.length} members...',
      );

      for (var member in members) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'Meal Cutoff Time Updated',
            body: 'The meal entry cutoff time has been changed to $newTime.',
            type: 'settings',
            route: '/meal-entry',
          );
          debugPrint(
            '[ActionNotificationService] Cutoff notification sent to ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyCutoffTimeChanged: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BAZAR DUTY ASSIGNED
  // ---------------------------------------------------------------------------

  /// Notify a member when they have been assigned bazar duty.
  static Future<void> notifyBazarAssigned({
    required String targetUserId,
    required String messId,
    required String formattedDate,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyBazarAssigned → targetUserId: $targetUserId, date: $formattedDate',
    );

    try {
      await _notificationRepo.sendNotification(
        targetUserId: targetUserId,
        messId: messId,
        title: 'Bazar Duty Assigned 🛒',
        body: 'You have been assigned bazar duty on $formattedDate.',
        type: 'bazar',
        route: '/settings',
      );
      debugPrint(
        '[ActionNotificationService] Bazar assignment notification sent to $targetUserId',
      );
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyBazarAssigned: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BAZAR DUTY REMINDER (Local Scheduled Notification)
  // ---------------------------------------------------------------------------

  /// Schedule a local device reminder at 8:00 AM on the bazar duty date.
  static Future<void> scheduleBazarReminder({
    required DateTime dutyDate,
  }) async {
    debugPrint(
      '[ActionNotificationService] scheduleBazarReminder for $dutyDate',
    );

    try {
      await _ensureLocalInitialized();

      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneInfo.identifier);

      // Schedule for 8:00 AM on the duty date
      final scheduledTime = tz.TZDateTime(
        location,
        dutyDate.year,
        dutyDate.month,
        dutyDate.day,
        8, // 8 AM
        0,
      );

      // Only schedule if the time is in the future
      if (scheduledTime.isBefore(tz.TZDateTime.now(location))) {
        debugPrint(
          '[ActionNotificationService] Bazar reminder skipped — date is in the past.',
        );
        return;
      }

      final notificationId = dutyDate.millisecondsSinceEpoch ~/ 1000 % 100000;

      const androidDetails = AndroidNotificationDetails(
        'bazar_reminder_channel',
        'Bazar Reminders',
        channelDescription: 'Reminders for scheduled bazar duties',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        notificationId,
        '🛒 Bazar Duty Reminder',
        "Today is your bazar duty day! Don't forget to go shopping.",
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );

      debugPrint(
        '[ActionNotificationService] Bazar reminder scheduled at $scheduledTime (ID: $notificationId)',
      );
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error scheduling bazar reminder: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SHOPPING ITEM REQUEST
  // ---------------------------------------------------------------------------

  /// Notify all managers/owners when a member submits a new shopping item request.
  static Future<void> notifyShoppingItemRequested({
    required String messId,
    required String requesterName,
    required String itemName,
    required String quantity,
    required String priority,
    required List<dynamic> members,
    required String currentUserId,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyShoppingItemRequested: $requesterName → "$itemName" ($priority)',
    );

    try {
      final managersAndOwners = members
          .where(
            (m) =>
                m.userId != currentUserId &&
                (m.role == 'manager' || m.role == 'owner'),
          )
          .toList();

      debugPrint(
        '[ActionNotificationService] Dispatching shopping request notification to ${managersAndOwners.length} managers/owners...',
      );

      final qtyLabel = quantity.trim().isNotEmpty ? ' ($quantity)' : '';
      final priorityLabel = priority == 'urgent' ? ' 🔴 URGENT' : '';

      for (var member in managersAndOwners) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: member.userId,
            messId: messId,
            title: 'New Shopping Request 🛒',
            body: '$requesterName requested "$itemName"$qtyLabel.$priorityLabel',
            type: 'shopping_request',
            route: '/shopping-list',
          );
          debugPrint(
            '[ActionNotificationService] Shopping request notification sent to ${member.userId}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${member.userId}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyShoppingItemRequested: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SHOPPING ITEM APPROVED
  // ---------------------------------------------------------------------------

  /// Notify the requester when their shopping item request is approved.
  static Future<void> notifyShoppingItemApproved({
    required String targetUserId,
    required String messId,
    required String itemName,
    required String quantity,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyShoppingItemApproved → targetUserId: $targetUserId, item: $itemName',
    );

    try {
      final qtyLabel = quantity.trim().isNotEmpty ? ' ($quantity)' : '';
      await _notificationRepo.sendNotification(
        targetUserId: targetUserId,
        messId: messId,
        title: 'Shopping Request Approved ✅',
        body: 'Your request for "$itemName"$qtyLabel has been approved and added to the shopping list.',
        type: 'shopping_approved',
        route: '/shopping-list',
      );
      debugPrint(
        '[ActionNotificationService] Shopping approved notification sent to $targetUserId',
      );
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyShoppingItemApproved: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SHOPPING ITEM REJECTED
  // ---------------------------------------------------------------------------

  /// Notify the requester when their shopping item request is rejected.
  static Future<void> notifyShoppingItemRejected({
    required String targetUserId,
    required String messId,
    required String itemName,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyShoppingItemRejected → targetUserId: $targetUserId, item: $itemName',
    );

    try {
      await _notificationRepo.sendNotification(
        targetUserId: targetUserId,
        messId: messId,
        title: 'Shopping Request Rejected ❌',
        body: 'Your request for "$itemName" was not approved. You may re-submit with adjustments.',
        type: 'shopping_rejected',
        route: '/shopping-list',
      );
      debugPrint(
        '[ActionNotificationService] Shopping rejected notification sent to $targetUserId',
      );
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyShoppingItemRejected: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // EXIT REQUEST
  // ---------------------------------------------------------------------------

  /// Notify all managers/owners when a member submits an exit (leave mess) request.
  static Future<void> notifyExitRequested({
    required String messId,
    required String memberName,
    required String reason,
    required List<dynamic> managers,
  }) async {
    debugPrint(
      '[ActionNotificationService] notifyExitRequested: $memberName submitted exit request.',
    );

    try {
      debugPrint(
        '[ActionNotificationService] Dispatching exit request notification to ${managers.length} managers/owners...',
      );

      final reasonLabel = reason.trim().isNotEmpty ? ' Reason: "${reason.trim()}"' : '';

      for (var manager in managers) {
        try {
          await _notificationRepo.sendNotification(
            targetUserId: manager['userId'] as String,
            messId: messId,
            title: 'Exit Request Submitted 🚪',
            body: '$memberName has requested to leave the mess.$reasonLabel',
            type: 'exit_request',
            route: '/approvals',
          );
          debugPrint(
            '[ActionNotificationService] Exit request notification sent to ${manager["userId"]}',
          );
        } catch (e) {
          debugPrint(
            '[ActionNotificationService] Failed to notify ${manager["userId"]}: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[ActionNotificationService] Error in notifyExitRequested: $e',
      );
    }
  }
}
