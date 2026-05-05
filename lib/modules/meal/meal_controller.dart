import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/meal_model.dart';

class MealController extends GetxController {
  final _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxDouble breakfast = 0.0.obs;
  final RxDouble lunch = 0.0.obs;
  final RxDouble dinner = 0.0.obs;
  final RxBool isLoading = false.obs;

  double get totalDailyMeals => breakfast.value + lunch.value + dinner.value;

  bool get canEdit {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Exact day matching by ignoring time
    final selectedDayStr = "${selectedDate.value.year}-${selectedDate.value.month}-${selectedDate.value.day}";
    final todayStr = "${now.year}-${now.month}-${now.day}";

    // Past dates cannot be edited
    if (selectedDate.value.isBefore(today) && selectedDayStr != todayStr) {
      return false;
    }

    // Today's meals can only be edited before 10:00 AM
    if (selectedDayStr == todayStr) {
      if (now.hour >= 10) return false;
    }

    return true; // Future dates are always editable
  }

  @override
  void onInit() {
    super.onInit();
    // Re-fetch meal when date changes
    ever(selectedDate, (_) => fetchMealForDate());
    fetchMealForDate();
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
  }

  void updatePortion(String type, double value) {
    if (!canEdit) {
      Get.snackbar('Cutoff Time Passed', 'You can no longer edit meals for this date.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    if (type == 'breakfast') breakfast.value = value;
    if (type == 'lunch') lunch.value = value;
    if (type == 'dinner') dinner.value = value;
  }

  Future<void> fetchMealForDate() async {
    final userId = _authService.currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) return;

    try {
      isLoading.value = true;
      final dateStr = "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      final response = await _supabase
          .from('meals')
          .select()
          .eq('mess_id', messId)
          .eq('user_id', userId)
          .eq('date', dateStr)
          .maybeSingle();

      if (response != null) {
        final meal = MealModel.fromJson(response);
        breakfast.value = meal.breakfast;
        lunch.value = meal.lunch;
        dinner.value = meal.dinner;
      } else {
        breakfast.value = 0.0;
        lunch.value = 0.0;
        dinner.value = 0.0;
      }
    } catch (e) {
      debugPrint('Error fetching meal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMeal() async {
    if (!canEdit) {
      Get.snackbar('Cutoff Time Passed', 'You can no longer edit meals for this date.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    final userId = _authService.currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) {
      Get.snackbar('Error', 'Missing user or mess data.');
      return;
    }

    try {
      isLoading.value = true;
      final dateStr = "${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}";

      // Upsert: Insert or Update based on UNIQUE(mess_id, user_id, date) constraint
      await _supabase.from('meals').upsert({
        'mess_id': messId,
        'user_id': userId,
        'date': dateStr,
        'breakfast': breakfast.value,
        'lunch': lunch.value,
        'dinner': dinner.value,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'mess_id, user_id, date');

      Get.snackbar('Success', 'Meals updated successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save meals: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
