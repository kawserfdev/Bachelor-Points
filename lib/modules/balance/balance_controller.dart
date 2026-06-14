import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../../../shared/helpers/navigation_helper.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/deposit_model.dart';
import '../../../data/models/member_balance_model.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/expense_model.dart';

class BalanceController extends GetxController {
  final _messController = Get.find<MessController>();
  final _realtime = Get.find<RealtimeService>();

  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  RxString depositByUserId = ''.obs;

  final RxDouble mealRate = 0.0.obs;
  final RxDouble globalTotalBazar = 0.0.obs;
  final RxDouble globalTotalFixed = 0.0.obs;
  final RxDouble globalTotalMeals = 0.0.obs;

  final RxList<MemberBalanceModel> memberBalances = <MemberBalanceModel>[].obs;

  StreamSubscription? _mealsSub;
  StreamSubscription? _expensesSub;
  StreamSubscription? _depositsSub;

  List<MealModel> _allMeals = [];
  List<ExpenseModel> _allExpenses = [];
  List<DepositModel> _allDeposits = [];

  @override
  void onInit() {
    super.onInit();
    debugPrint('[BalanceController] Initialized');

    ever(selectedMonth, (_) {
      debugPrint('[BalanceController] Month changed: ${selectedMonth.value}');
      _recalculate();
    });

    // Listen for activeMess changes (e.g. after joining a mess)
    ever(_messController.activeMess, (mess) {
      if (mess != null) {
        debugPrint('[BalanceController] Active mess changed: ${mess.id}');
        _listenToData();
      }
    });

    _listenToData();
  }

  @override
  void onClose() {
    _mealsSub?.cancel();
    _expensesSub?.cancel();
    _depositsSub?.cancel();
    super.onClose();
  }

  void _listenToData() {
    final messId = _messController.activeMess.value?.id;
    if (messId == null) {
      debugPrint('[BalanceController] No messId, skipping stream subscriptions');
      return;
    }

    debugPrint('[BalanceController] Subscribing to real-time streams for $messId');

    _mealsSub?.cancel();
    _mealsSub = _realtime.streamMeals(messId).listen((data) {
      _allMeals = data.map((e) => MealModel.fromJson(e)).toList();
      debugPrint('[BalanceController] Meals stream updated: ${_allMeals.length} items');
      _recalculate();
    }, onError: (e) => debugPrint('[BalanceController] Meals stream error: $e'));

    _expensesSub?.cancel();
    _expensesSub = _realtime.streamExpenses(messId).listen((data) {
      _allExpenses = data.map((e) => ExpenseModel.fromJson(e)).toList();
      debugPrint('[BalanceController] Expenses stream updated: ${_allExpenses.length} items');
      _recalculate();
    }, onError: (e) => debugPrint('[BalanceController] Expenses stream error: $e'));

    _depositsSub?.cancel();
    _depositsSub = _realtime.streamDeposits(messId).listen((data) {
      _allDeposits = data.map((e) => DepositModel.fromJson(e)).toList();
      debugPrint('[BalanceController] Deposits stream updated: ${_allDeposits.length} items');
      _recalculate();
    }, onError: (e) => debugPrint('[BalanceController] Deposits stream error: $e'));
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

      await FirebaseFirestore.instance.collection('deposits').add({
        'mess_id': messId,
        'user_id': userId,
        'amount': amount,
        'status': 'Pending',
        'received_by': depositByUserId.value,
        'date': dateStr,
        'created_at': FirestoreTime.serverTimestamp,
      });

      debugPrint('[addDeposit] Deposit inserted successfully');

      AppNavigation.back();
      AppNavigation.showSnackBar('Success', 'Deposit added successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('[addDeposit] Error: $e');

      AppNavigation.showSnackBar('Error', 'Failed to add deposit: $e',
          backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
      debugPrint('[addDeposit] Loading finished');
    }
  }

  /// Recalculates balances from in-memory data (derived from real-time streams).
  /// Filters by the selected month and approved status.
  void _recalculate() {
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

      debugPrint('[recalculate] Date range: $startDateStr → $endDateStr');

      // Filter approved items within the selected month
      final meals = _allMeals.where((m) =>
          m.status == 'Approve' &&
          _isDateInRange(m.date, startDate, endDate)).toList();

      final expenses = _allExpenses.where((e) =>
          e.status == 'Approve' &&
          _isDateInRange(e.date, startDate, endDate)).toList();

      final deposits = _allDeposits.where((d) =>
          d.status == 'Approve' &&
          _isDateInRange(d.date, startDate, endDate)).toList();

      debugPrint('[recalculate] meals: ${meals.length} | expenses: ${expenses.length} | deposits: ${deposits.length}');

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

      debugPrint('[recalculate] totalBazar: $totalBazar');
      debugPrint('[recalculate] totalFixed: $totalFixed');
      debugPrint('[recalculate] totalMeals: $totalMeals');

      globalTotalBazar.value = totalBazar;
      globalTotalFixed.value = totalFixed;
      globalTotalMeals.value = totalMeals;

      mealRate.value = totalMeals > 0 ? (totalBazar / totalMeals) : 0.0;

      debugPrint('[recalculate] mealRate: ${mealRate.value}');

      final members = _messController.members;
      debugPrint('[recalculate] members count: ${members.length}');

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

      debugPrint('[recalculate] Calculation completed with ${newBalances.length} members');
    } catch (e) {
      debugPrint('[recalculate] Error: $e');
    } finally {
      isLoading.value = false;
      debugPrint('[recalculate] Loading finished');
    }
  }

  /// Checks whether [date] falls within [start] and [end] (inclusive).
  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}