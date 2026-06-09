import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/deposit_model.dart';
import '../../../data/models/member_balance_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/expense_model.dart';

class BalanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _messController = Get.find<MessController>();

  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  RxString depositByUserId = ''.obs;

  final RxDouble mealRate = 0.0.obs;
  final RxDouble globalTotalBazar = 0.0.obs;
  final RxDouble globalTotalFixed = 0.0.obs;
  final RxDouble globalTotalMeals = 0.0.obs;

  final RxList<MemberBalanceModel> memberBalances = <MemberBalanceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[BalanceController] Initialized');

    ever(selectedMonth, (_) {
      debugPrint('[BalanceController] Month changed: ${selectedMonth.value}');
      calculateBalances();
    });

    calculateBalances();
  }

  void changeMonth(int offsetMonths) {
    final oldMonth = selectedMonth.value;
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + offsetMonths,
      1,
    );

    debugPrint('[changeMonth] $oldMonth → ${selectedMonth.value}');
  }

  Future<void> addDeposit({
    required double amount,
    required DateTime date,
  }) async {
    final userId = Get.find<AuthService>().currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    debugPrint('[addDeposit] userId: $userId, messId: $messId');
    debugPrint('[addDeposit] amount: $amount, date: $date');

    if (userId == null || messId == null) {
      debugPrint('[addDeposit] Missing userId or messId');
      return;
    }

    try {
      isLoading.value = true;

      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      debugPrint('[addDeposit] formatted date: $dateStr');
      debugPrint('[addDeposit] received_by: $userId');
      debugPrint('[addDeposit] status: Pending');
      debugPrint('[addDeposit] amount: $amount');

      await _firestore.collection('deposits').add({
        'mess_id': messId,
        'user_id': userId,
        'amount': amount,
        'status': 'Pending',
        'received_by': depositByUserId.value,
        'date': dateStr,
        'created_at': FieldValue.serverTimestamp(),
      });

      debugPrint('[addDeposit] Deposit inserted successfully');

      Get.back();
      Get.snackbar('Success', 'Deposit added successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('[addDeposit] Error: $e');

      Get.snackbar('Error', 'Failed to add deposit: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      debugPrint('[addDeposit] Loading finished');
    }
  }

  Future<void> calculateBalances() async {
    final messId = _messController.activeMess.value?.id;

    debugPrint('[calculateBalances] messId: $messId');

    if (messId == null) {
      debugPrint('[calculateBalances] No messId found');
      return;
    }

    try {
      isLoading.value = true;

      final startDate =
          DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
      final endDate =
          DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

      final startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-01";
      final endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      debugPrint('[calculateBalances] Date range: $startDateStr → $endDateStr');

      // Meals
      final mealsResponse = await _firestore
          .collection('meals')
          .where('mess_id', isEqualTo: messId)
          .where('status', isEqualTo: 'Approve')
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      debugPrint('[calculateBalances] meals count: ${mealsResponse.docs.length}');
      final meals = mealsResponse.docs.map((e) => MealModel.fromJson({'id': e.id, ...e.data() as Map<String, dynamic>})).toList();

      // Expenses
      final expensesResponse = await _firestore
          .collection('expenses')
          .where('mess_id', isEqualTo: messId)
          .where('status', isEqualTo: 'Approve')
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      debugPrint('[calculateBalances] expenses count: ${expensesResponse.docs.length}');
      final expenses = expensesResponse.docs.map((e) => ExpenseModel.fromJson({'id': e.id, ...e.data() as Map<String, dynamic>})).toList();

      // Deposits
      var depositQuery = _firestore
          .collection('deposits')
          .where('mess_id', isEqualTo: messId)
          .where('status', isEqualTo: 'Approve')
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr);
          
      final depositsResponse = await depositQuery.get();

      debugPrint('[calculateBalances] deposits count: ${depositsResponse.docs.length}');
      final deposits = depositsResponse.docs.map((e) => DepositModel.fromJson({'id': e.id, ...e.data() as Map<String, dynamic>})).toList();

      // Global Calculation
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

      debugPrint('[calculateBalances] totalBazar: $totalBazar');
      debugPrint('[calculateBalances] totalFixed: $totalFixed');
      debugPrint('[calculateBalances] totalMeals: $totalMeals');

      globalTotalBazar.value = totalBazar;
      globalTotalFixed.value = totalFixed;
      globalTotalMeals.value = totalMeals;

      mealRate.value = totalMeals > 0 ? (totalBazar / totalMeals) : 0.0;

      debugPrint('[calculateBalances] mealRate: ${mealRate.value}');

      final members = _messController.members;
      debugPrint('[calculateBalances] members count: ${members.length}');

      final fixedCostPerPerson =
          members.isNotEmpty ? (totalFixed / members.length) : 0.0;

      List<MemberBalanceModel> newBalances = [];

      for (var member in members) {
        double memberMeals = meals
            .where((m) => m.userId == member.userId)
            .fold(0.0, (sum, m) => sum + m.totalMeals);

        double memberDeposits = deposits
            .where((d) => d.userId == member.userId)
            .fold(0.0, (sum, d) => sum + d.amount);

        double memberMealCost = memberMeals * mealRate.value;
        double memberTotalCost = memberMealCost + fixedCostPerPerson;
        double memberBalance = memberDeposits - memberTotalCost;

        debugPrint('[MemberBalance] ${member.fullName} | '
            'Meals: $memberMeals | Deposits: $memberDeposits | '
            'Balance: $memberBalance');

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

      debugPrint('[calculateBalances] Calculation completed');
    } catch (e) {
      debugPrint('[calculateBalances] Error: $e');
    } finally {
      isLoading.value = false;
      debugPrint('[calculateBalances] Loading finished');
    }
  }
}