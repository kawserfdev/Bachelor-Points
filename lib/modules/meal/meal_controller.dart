import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../../../shared/helpers/navigation_helper.dart';
import '../../core/notifications/notification_service.dart';
import '../notifications/data/notification_repository.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/meal_model.dart';
import 'dart:async';

class MealController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();
  final RealtimeService _realtime = Get.find<RealtimeService>();

  StreamSubscription? _mealSub;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxDouble breakfast = 0.0.obs;
  final RxDouble lunch = 0.0.obs;
  final RxDouble dinner = 0.0.obs;
  final RxDouble guestMeals = 0.0.obs;
  final RxBool isLoading = false.obs;

  double get totalDailyMeals =>
      breakfast.value + lunch.value + dinner.value + guestMeals.value;

  bool get canEdit {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final selectedDayStr =
        "${selectedDate.value.year}-${selectedDate.value.month}-${selectedDate.value.day}";
    final todayStr = "${now.year}-${now.month}-${now.day}";

    debugPrint('[canEdit] selected: $selectedDayStr | today: $todayStr | hour: ${now.hour}');

    if (selectedDate.value.isBefore(today) && selectedDayStr != todayStr) {
      debugPrint('[canEdit] Past date → NOT editable');
      return false;
    }

    if (selectedDayStr == todayStr) {
      if (now.hour >= 10) {
        debugPrint('[canEdit] Today cutoff passed → NOT editable');
        return false;
      }
    }

    debugPrint('[canEdit] Editable');
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('[MealController] Initialized');

    ever(selectedDate, (_) {
      debugPrint('[MealController] Date changed: ${selectedDate.value}');
      _listenToMeals();
    });

    ever(_messController.activeMess, (_) {
      debugPrint('[MealController] Active mess changed');
      _listenToMeals();
    });

    _listenToMeals();
  }

  void changeDate(DateTime date) {
    debugPrint('[changeDate] ${selectedDate.value} → $date');
    selectedDate.value = date;
  }

  void updatePortion(String type, double value) {
    debugPrint('[updatePortion] type: $type, value: $value');

    if (!canEdit) {
      debugPrint('[updatePortion] Edit blocked by canEdit');

      AppNavigation.showSnackBar(
        'Cutoff Time Passed',
        'You can no longer edit meals for this date.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    if (type == 'breakfast') breakfast.value = value;
    if (type == 'lunch') lunch.value = value;
    if (type == 'dinner') dinner.value = value;
    if (type == 'guest') guestMeals.value = value;

    debugPrint('[updatePortion] Updated → B:$breakfast L:$lunch D:$dinner G:$guestMeals');
  }

  void _listenToMeals() {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    debugPrint('[listenToMeals] userId: $userId, messId: $messId');

    if (userId == null || messId == null) {
      debugPrint('[listenToMeals] Missing userId or messId');
      return;
    }

    isLoading.value = true;
    _mealSub?.cancel();

    _mealSub = _realtime.streamMeals(messId).listen((data) {
      debugPrint('[meals stream] total rows: ${data.length}');

      final dateStr =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      debugPrint('[meals filter] date: $dateStr');

      bool found = false;

      for (var row in data) {
        debugPrint('[meals row] ${row['user_id']} | ${row['date']}');

        if (row['user_id'] == userId && row['date'] == dateStr) {
          final meal = MealModel.fromJson(row);

          breakfast.value = meal.breakfast;
          lunch.value = meal.lunch;
          dinner.value = meal.dinner;
          guestMeals.value = meal.guestMeals;

          debugPrint('[meals found] B:${meal.breakfast} L:${meal.lunch} D:${meal.dinner} G:${meal.guestMeals}');

          found = true;
          break;
        }
      }

      if (!found) {
        debugPrint('[meals] No data found → reset to 0');

        breakfast.value = 0.0;
        lunch.value = 0.0;
        dinner.value = 0.0;
        guestMeals.value = 0.0;
      }

      isLoading.value = false;
      debugPrint('[listenToMeals] Update completed');
    }, onError: (e) {
      debugPrint('[meals stream] Error: $e');
      isLoading.value = false;
    });
  }

  Future<void> saveMeal() async {
    debugPrint('[saveMeal] Triggered');

    if (!canEdit) {
      debugPrint('[saveMeal] Blocked by canEdit');

      AppNavigation.showSnackBar(
        'Cutoff Time Passed',
        'You can no longer edit meals for this date.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    debugPrint('[saveMeal] userId: $userId, messId: $messId');

    if (userId == null || messId == null) {
      debugPrint('[saveMeal] Missing user/mess');

      AppNavigation.showSnackBar('Error', 'Missing user or mess data.');
      return;
    }

    try {
      isLoading.value = true;

      final dateStr =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      debugPrint('[saveMeal] date: $dateStr');
      debugPrint('[saveMeal] B:${breakfast.value} L:${lunch.value} D:${dinner.value} G:${guestMeals.value}');

      final docId = '${messId}_${userId}_$dateStr';

      await _firestore.collection('meals').doc(docId).set({
        'mess_id': messId,
        'user_id': userId,
        'date': dateStr,
        'breakfast': breakfast.value,
        'status': 'Approved',
        'lunch': lunch.value,
        'dinner': dinner.value,
        'guest_meals': guestMeals.value,
        'updated_at': FirestoreTime.serverTimestamp,
      }, SetOptions(merge: true));

      debugPrint('[saveMeal] Upsert success');

      AppNavigation.showSnackBar(
        'Success',
        'Meals updated successfully!',
        backgroundColor: Colors.green,
      );

      // Trigger offline/online notifications asynchronously
      unawaited(() async {
        try {
          debugPrint('[MealController] Checking connectivity for notification dispatch...');
          final connectivity = await Connectivity().checkConnectivity();
          final isOffline = connectivity.contains(ConnectivityResult.none);
          debugPrint('[MealController] Connectivity result: $connectivity (isOffline: $isOffline)');
          if (isOffline) {
            debugPrint('[MealController] Offline detected. Showing local offline notification...');
            await NotificationService.instance?.showOfflineNotification(
              title: 'Saved Offline',
              body: 'Your meal entry was saved locally and will sync when online.',
            );
          } else {
            final otherMembers = _messController.members.where((m) => m.userId != userId).toList();
            debugPrint('[MealController] Online detected. Dispatching notifications to ${otherMembers.length} other members...');
            if (otherMembers.isNotEmpty) {
              String userName = 'A member';
              for (var m in _messController.members) {
                if (m.userId == userId) {
                  userName = m.fullName ?? m.email ?? 'A member';
                  break;
                }
              }
              final notificationRepo = NotificationRepositoryImpl();
              for (var member in otherMembers) {
                try {
                  debugPrint('[MealController] Dispatching meal notification to user ${member.userId}...');
                  await notificationRepo.sendNotification(
                    targetUserId: member.userId,
                    messId: messId,
                    title: 'Meal Updated',
                    body: '$userName updated their meals for $dateStr: B:${breakfast.value}, L:${lunch.value}, D:${dinner.value}, G:${guestMeals.value}',
                    type: 'meal',
                    route: '/meal-entry',
                  );
                } catch (ne) {
                  debugPrint('Failed to send meal notification to ${member.userId}: $ne');
                }
              }
            }
          }
        } catch (ne) {
          debugPrint('Failed handling meal notification: $ne');
        }
      }());
    } catch (e) {
      debugPrint('[saveMeal] Error: $e');

      AppNavigation.showSnackBar(
        'Error',
        'Failed to save meals: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
      debugPrint('[saveMeal] Loading finished');
    }
  }

  @override
  void onClose() {
    debugPrint('[MealController] onClose called');
    _mealSub?.cancel();
    super.onClose();
  }
}