import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../services/action_notification_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../../../shared/helpers/navigation_helper.dart';
import '../../core/notifications/notification_service.dart';
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
          if (isOffline) {
            await NotificationService.instance?.showOfflineNotification(
              title: 'Saved Offline',
              body: 'Your meal entry was saved locally and will sync when online.',
            );
          } else {
            String userName = 'A member';
            for (var m in _messController.members) {
              if (m.userId == userId) {
                userName = m.fullName ?? m.email ?? 'A member';
                break;
              }
            }
            await ActionNotificationService.notifyMealUpdated(
              messId: messId,
              senderName: userName,
              dateStr: dateStr,
              breakfast: breakfast.value,
              lunch: lunch.value,
              dinner: dinner.value,
              guestMeals: guestMeals.value,
              members: _messController.members,
              currentUserId: userId,
            );
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

  bool checkCanEditDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final targetDate = DateTime(date.year, date.month, date.day);
    final targetStr = "${targetDate.year}-${targetDate.month}-${targetDate.day}";
    final todayStr = "${now.year}-${now.month}-${now.day}";

    if (targetDate.isBefore(today) && targetStr != todayStr) {
      return false;
    }

    if (targetStr == todayStr) {
      if (now.hour >= 10) {
        return false;
      }
    }

    return true;
  }

  Future<void> saveMealPlan({
    required double breakfastPortion,
    required double lunchPortion,
    required double dinnerPortion,
    required int durationDays,
    required DateTime startDate,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) {
      AppNavigation.showSnackBar('Error', 'Missing user or mess data.');
      return;
    }

    try {
      isLoading.value = true;

      // 1. Save default meal plan
      final defaultPlanDoc = '${messId}_$userId';
      await _firestore.collection('default_meal_plans').doc(defaultPlanDoc).set({
        'mess_id': messId,
        'user_id': userId,
        'breakfast': breakfastPortion,
        'lunch': lunchPortion,
        'dinner': dinnerPortion,
        'updated_at': FirestoreTime.serverTimestamp,
      }, SetOptions(merge: true));

      // 2. Loop through duration to write/update documents
      final batch = _firestore.batch();
      int writeCount = 0;
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = start.add(Duration(days: durationDays - 1));

      for (int i = 0; i < durationDays; i++) {
        final currentDate = start.add(Duration(days: i));
        if (!checkCanEditDate(currentDate)) {
          continue;
        }

        final dateStr =
            "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
        final docId = '${messId}_${userId}_$dateStr';
        final docRef = _firestore.collection('meals').doc(docId);

        batch.set(docRef, {
          'mess_id': messId,
          'user_id': userId,
          'date': dateStr,
          'breakfast': breakfastPortion,
          'lunch': lunchPortion,
          'dinner': dinnerPortion,
          'status': 'Approved',
          'updated_at': FirestoreTime.serverTimestamp,
        }, SetOptions(merge: true));
        writeCount++;
      }

      if (writeCount > 0) {
        await batch.commit();
      }

      AppNavigation.showSnackBar(
        'Success',
        'Meal plan set successfully for $durationDays days!',
        backgroundColor: Colors.green,
      );

      // Trigger offline/online notifications
      unawaited(() async {
        try {
          final connectivity = await Connectivity().checkConnectivity();
          final isOffline = connectivity.contains(ConnectivityResult.none);
          if (isOffline) {
            await NotificationService.instance?.showOfflineNotification(
              title: 'Saved Offline',
              body: 'Meal plan saved locally and will sync when online.',
            );
          } else {
            String userName = 'A member';
            for (var m in _messController.members) {
              if (m.userId == userId) {
                userName = m.fullName ?? m.email ?? 'A member';
                break;
              }
            }
            final startStr = "${start.day}/${start.month}/${start.year}";
            final endStr = "${end.day}/${end.month}/${end.year}";
            await ActionNotificationService.notifyMealPlanUpdated(
              messId: messId,
              senderName: userName,
              startDateStr: startStr,
              endDateStr: endStr,
              breakfast: breakfastPortion,
              lunch: lunchPortion,
              dinner: dinnerPortion,
              members: _messController.members,
              currentUserId: userId,
            );
          }
        } catch (e) {
          debugPrint('Failed to send meal plan notification: $e');
        }
      }());
    } catch (e) {
      debugPrint('[saveMealPlan] Error: $e');
      AppNavigation.showSnackBar(
        'Error',
        'Failed to save meal plan: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> closeMeals({
    required DateTime startDate,
    required DateTime endDate,
    required bool closeBreakfast,
    required bool closeLunch,
    required bool closeDinner,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) {
      AppNavigation.showSnackBar('Error', 'Missing user or mess data.');
      return;
    }

    try {
      isLoading.value = true;

      // 1. Fetch user's default meal plan from default_meal_plans
      final defaultPlanDoc = '${messId}_$userId';
      final defaultSnap = await _firestore.collection('default_meal_plans').doc(defaultPlanDoc).get();
      final defaultData = defaultSnap.data();

      final defaultBreakfast = (defaultData?['breakfast'] as num?)?.toDouble() ?? 1.0;
      final defaultLunch = (defaultData?['lunch'] as num?)?.toDouble() ?? 1.0;
      final defaultDinner = (defaultData?['dinner'] as num?)?.toDouble() ?? 1.0;

      // 2. Determine how many days we are modifying
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      final durationDays = end.difference(start).inDays + 1;

      if (durationDays <= 0) {
        AppNavigation.showSnackBar('Error', 'Invalid date range.');
        return;
      }

      // Fetch existing meals in the date range for this user
      final startStr =
          "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
      final endStr =
          "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

      final mealsQuery = await _firestore
          .collection('meals')
          .where('mess_id', isEqualTo: messId)
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .get();

      final existingMeals = {
        for (var doc in mealsQuery.docs) doc.data()['date'] as String: doc.data()
      };

      final batch = _firestore.batch();
      int writeCount = 0;

      for (int i = 0; i < durationDays; i++) {
        final currentDate = start.add(Duration(days: i));
        if (!checkCanEditDate(currentDate)) {
          continue;
        }

        final dateStr =
            "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
        final docId = '${messId}_${userId}_$dateStr';
        final docRef = _firestore.collection('meals').doc(docId);

        final existing = existingMeals[dateStr];
        double bVal = 0.0;
        double lVal = 0.0;
        double dVal = 0.0;
        double gVal = 0.0;

        if (existing != null) {
          bVal = closeBreakfast ? 0.0 : (existing['breakfast'] as num).toDouble();
          lVal = closeLunch ? 0.0 : (existing['lunch'] as num).toDouble();
          dVal = closeDinner ? 0.0 : (existing['dinner'] as num).toDouble();
          gVal = (existing['guest_meals'] as num?)?.toDouble() ?? 0.0;
        } else {
          bVal = closeBreakfast ? 0.0 : defaultBreakfast;
          lVal = closeLunch ? 0.0 : defaultLunch;
          dVal = closeDinner ? 0.0 : defaultDinner;
          gVal = 0.0;
        }

        batch.set(docRef, {
          'mess_id': messId,
          'user_id': userId,
          'date': dateStr,
          'breakfast': bVal,
          'lunch': lVal,
          'dinner': dVal,
          'guest_meals': gVal,
          'status': 'Approved',
          'updated_at': FirestoreTime.serverTimestamp,
        }, SetOptions(merge: true));
        writeCount++;
      }

      if (writeCount > 0) {
        await batch.commit();
      }

      AppNavigation.showSnackBar(
        'Success',
        'Meals closed successfully for selected dates!',
        backgroundColor: Colors.green,
      );

      // Trigger notification
      unawaited(() async {
        try {
          final connectivity = await Connectivity().checkConnectivity();
          final isOffline = connectivity.contains(ConnectivityResult.none);
          if (isOffline) {
            await NotificationService.instance?.showOfflineNotification(
              title: 'Saved Offline',
              body: 'Meal changes saved locally and will sync when online.',
            );
          } else {
            String userName = 'A member';
            for (var m in _messController.members) {
              if (m.userId == userId) {
                userName = m.fullName ?? m.email ?? 'A member';
                break;
              }
            }
            final closedList = <String>[];
            if (closeBreakfast) closedList.add('Breakfast');
            if (closeLunch) closedList.add('Lunch');
            if (closeDinner) closedList.add('Dinner');

            final closedMealsLabel = closedList.isEmpty
                ? 'no meals'
                : closedList.join(', ');

            final displayStartStr = "${start.day}/${start.month}/${start.year}";
            final displayEndStr = "${end.day}/${end.month}/${end.year}";

            await ActionNotificationService.notifyMealsClosed(
              messId: messId,
              senderName: userName,
              startDateStr: displayStartStr,
              endDateStr: displayEndStr,
              closedMealsLabel: closedMealsLabel,
              members: _messController.members,
              currentUserId: userId,
            );
          }
        } catch (e) {
          debugPrint('Failed to send meal closed notification: $e');
        }
      }());
    } catch (e) {
      debugPrint('[closeMeals] Error: $e');
      AppNavigation.showSnackBar(
        'Error',
        'Failed to close meals: $e',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    debugPrint('[MealController] onClose called');
    _mealSub?.cancel();
    super.onClose();
  }
}