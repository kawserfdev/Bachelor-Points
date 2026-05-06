import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/meal_model.dart';
import 'dart:async';
class MealController extends GetxController {
  final _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();
  final RealtimeService _realtime = Get.find<RealtimeService>();

  StreamSubscription? _mealSub;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxDouble breakfast = 0.0.obs;
  final RxDouble lunch = 0.0.obs;
  final RxDouble dinner = 0.0.obs;
  final RxBool isLoading = false.obs;

  double get totalDailyMeals =>
      breakfast.value + lunch.value + dinner.value;

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
        debugPrint('[canEdit] Today কিন্তু cutoff passed → NOT editable');
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

      Get.snackbar(
        'Cutoff Time Passed',
        'You can no longer edit meals for this date.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (type == 'breakfast') breakfast.value = value;
    if (type == 'lunch') lunch.value = value;
    if (type == 'dinner') dinner.value = value;

    debugPrint('[updatePortion] Updated → B:$breakfast L:$lunch D:$dinner');
  }

  void _listenToMeals() {
    final userId = _authService.currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    debugPrint('[listenToMeals] userId: $userId, messId: $messId');

    if (userId == null || messId == null) {
      debugPrint('[listenToMeals] Missing userId বা messId');
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

          debugPrint('[meals found] B:${meal.breakfast} L:${meal.lunch} D:${meal.dinner}');

          found = true;
          break;
        }
      }

      if (!found) {
        debugPrint('[meals] No data found → reset to 0');

        breakfast.value = 0.0;
        lunch.value = 0.0;
        dinner.value = 0.0;
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

      Get.snackbar(
        'Cutoff Time Passed',
        'You can no longer edit meals for this date.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final userId = _authService.currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    debugPrint('[saveMeal] userId: $userId, messId: $messId');

    if (userId == null || messId == null) {
      debugPrint('[saveMeal] Missing user/mess');

      Get.snackbar('Error', 'Missing user or mess data.');
      return;
    }

    try {
      isLoading.value = true;

      final dateStr =
          "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      debugPrint('[saveMeal] date: $dateStr');
      debugPrint('[saveMeal] B:${breakfast.value} L:${lunch.value} D:${dinner.value}');

      await _supabase.from('meals').upsert({
        'mess_id': messId,
        'user_id': userId,
        'date': dateStr,
        'breakfast': breakfast.value,
        'lunch': lunch.value,
        'dinner': dinner.value,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'mess_id, user_id, date');

      debugPrint('[saveMeal] Upsert success');

      Get.snackbar(
        'Success',
        'Meals updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[saveMeal] Error: $e');

      Get.snackbar(
        'Error',
        'Failed to save meals: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
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