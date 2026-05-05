import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/deposit_model.dart';
import '../../../data/models/member_balance_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/expense_model.dart';

class BalanceController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _messController = Get.find<MessController>();

  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxBool isLoading = false.obs;

  // Global metrics
  final RxDouble mealRate = 0.0.obs;
  final RxDouble globalTotalBazar = 0.0.obs;
  final RxDouble globalTotalFixed = 0.0.obs;
  final RxDouble globalTotalMeals = 0.0.obs;

  // Balances
  final RxList<MemberBalanceModel> memberBalances = <MemberBalanceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedMonth, (_) => calculateBalances());
    calculateBalances();
  }

  void changeMonth(int offsetMonths) {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + offsetMonths,
      1,
    );
  }

  Future<void> addDeposit({
    required double amount,
    required DateTime date,
  }) async {
    final userId = Get.find<AuthService>().currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) return;

    try {
      isLoading.value = true;
      await _supabase.from('deposits').insert({
        'mess_id': messId,
        'user_id': userId,
        'amount': amount,
        'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      });

      if (date.year == selectedMonth.value.year && date.month == selectedMonth.value.month) {
        await calculateBalances();
      }

      Get.back();
      Get.snackbar('Success', 'Deposit added successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add deposit: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> calculateBalances() async {
    final messId = _messController.activeMess.value?.id;
    if (messId == null) return;

    try {
      isLoading.value = true;

      final startDate = DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
      final endDate = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

      final startDateStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-01";
      final endDateStr = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      // Fetch Meals
      final mealsResponse = await _supabase
          .from('meals')
          .select()
          .eq('mess_id', messId)
          .gte('date', startDateStr)
          .lte('date', endDateStr);
      final meals = (mealsResponse as List).map((e) => MealModel.fromJson(e)).toList();

      // Fetch Expenses
      final expensesResponse = await _supabase
          .from('expenses')
          .select()
          .eq('mess_id', messId)
          .gte('date', startDateStr)
          .lte('date', endDateStr);
      final expenses = (expensesResponse as List).map((e) => ExpenseModel.fromJson(e)).toList();

      // Fetch Deposits
      final depositsResponse = await _supabase
          .from('deposits')
          .select()
          .eq('mess_id', messId)
          .gte('date', startDateStr)
          .lte('date', endDateStr);
      final deposits = (depositsResponse as List).map((e) => DepositModel.fromJson(e)).toList();

      // Calculate Globals
      double totalBazar = 0.0;
      double totalFixed = 0.0;
      double totalMeals = 0.0;

      for (var ex in expenses) {
        if (ex.category == 'bazar') {
          totalBazar += ex.amount;
        } else {
          totalFixed += ex.amount;
        }
      }

      for (var meal in meals) {
        totalMeals += meal.totalMeals;
      }

      globalTotalBazar.value = totalBazar;
      globalTotalFixed.value = totalFixed;
      globalTotalMeals.value = totalMeals;
      
      mealRate.value = totalMeals > 0 ? (totalBazar / totalMeals) : 0.0;

      // Calculate Per Member
      final members = _messController.members;
      final fixedCostPerPerson = members.isNotEmpty ? (totalFixed / members.length) : 0.0;

      List<MemberBalanceModel> newBalances = [];

      for (var member in members) {
        // Member Meals
        double memberMeals = meals
            .where((m) => m.userId == member.userId)
            .fold(0.0, (sum, m) => sum + m.totalMeals);

        // Member Deposits
        double memberDeposits = deposits
            .where((d) => d.userId == member.userId)
            .fold(0.0, (sum, d) => sum + d.amount);

        double memberMealCost = memberMeals * mealRate.value;
        double memberTotalCost = memberMealCost + fixedCostPerPerson;
        double memberBalance = memberDeposits - memberTotalCost;

        newBalances.add(MemberBalanceModel(
          userId: member.userId,
          userName: member.fullName ?? 'Unknown',
          totalMeals: memberMeals,
          totalDeposits: memberDeposits,
          mealCost: memberMealCost,
          fixedCost: fixedCostPerPerson,
          totalCost: memberTotalCost,
          balance: memberBalance,
        ));
      }

      memberBalances.value = newBalances;

    } catch (e) {
      debugPrint("Error calculating balances: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
