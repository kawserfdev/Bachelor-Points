import 'package:bachelorpoints/shared/helpers/firestore_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../../../shared/helpers/navigation_helper.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/expense_model.dart';
import 'dart:async';

class ExpenseController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();
  final RealtimeService _realtime = Get.find<RealtimeService>();

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxDouble totalMonthlyExpense = 0.0.obs;
  final RxDouble costPerPerson = 0.0.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription? _expenseSub;

  final Rx<DateTime> selectedMonth = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ExpenseController] Initialized');

    ever(selectedMonth, (_) {
      debugPrint('[ExpenseController] Month changed: ${selectedMonth.value}');
      _listenToExpenses();
    });

    ever(_messController.activeMess, (_) {
      debugPrint('[ExpenseController] Active mess changed');
      _listenToExpenses();
    });

    _listenToExpenses();
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

  void _listenToExpenses() {
    final messId = _messController.activeMess.value?.id;
    debugPrint('[listenToExpenses] messId: $messId');

    if (messId == null) {
      debugPrint('[listenToExpenses] No messId found');
      return;
    }

    isLoading.value = true;
    _expenseSub?.cancel();

    _expenseSub = _realtime.streamExpenses(messId).listen((data) {
      debugPrint('[expenses stream] total rows: ${data.length}');

      final startDate =
          DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
      final endDate =
          DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

      final startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-01";
      final endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      debugPrint('[expenses filter] range: $startDateStr → $endDateStr');

      final List<ExpenseModel> fetchedExpenses = [];

      for (var row in data) {
        final dateStr = row['date'] as String;

        if (dateStr.compareTo(startDateStr) >= 0 &&
            dateStr.compareTo(endDateStr) <= 0) {
          final userId = row['created_by'] as String;

          final profile = _messController.getProfileCached(userId);
          debugPrint('[expense row] userId: $userId, profile: $profile');

          row['profiles'] = profile;

          fetchedExpenses.add(ExpenseModel.fromJson(row));
        }
      }

      debugPrint('[expenses filtered] count: ${fetchedExpenses.length}');

      fetchedExpenses.sort((a, b) => b.date.compareTo(a.date));

      expenses.value = fetchedExpenses;

      calculateSummary();

      isLoading.value = false;
      debugPrint('[listenToExpenses] Update completed');
    }, onError: (e) {
      debugPrint('[expenses stream] Error: $e');
      isLoading.value = false;
    });
  }

  void calculateSummary() {
    debugPrint('[calculateSummary] Started');

    double total = 0.0;

    for (var expense in expenses) {
      total += expense.amount;
    }

    totalMonthlyExpense.value = total;

    debugPrint('[calculateSummary] totalMonthlyExpense: $total');

    final totalMembers = _messController.members.length;
    debugPrint('[calculateSummary] totalMembers: $totalMembers');

    if (totalMembers > 0) {
      costPerPerson.value = total / totalMembers;
    } else {
      costPerPerson.value = 0.0;
    }

    debugPrint('[calculateSummary] costPerPerson: ${costPerPerson.value}');
  }

  Future<void> addExpense({
    required double amount,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    debugPrint('[addExpense] userId: $userId, messId: $messId');
    debugPrint('[addExpense] amount: $amount, category: $category, date: $date');

    if (userId == null || messId == null) {
      debugPrint('[addExpense] Missing userId or messId');
      return;
    }

    try {
      isLoading.value = true;

      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      debugPrint('[addExpense] formatted date: $dateStr');

      await _firestore.collection('expenses').add({
        'mess_id': messId,
        'created_by': userId,
        'status': 'Pending',
        'amount': amount,
        'category': category,
        'note': description?.trim(),
        'date': dateStr,
        'created_at': FirestoreTime.serverTimestamp,
      });

      debugPrint('[addExpense] Expense inserted successfully');

      AppNavigation.back();
      AppNavigation.showSnackBar('Success', 'Expense added successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('[addExpense] Error: $e');

      AppNavigation.showSnackBar('Error', 'Failed to add expense: $e',
          backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
      debugPrint('[addExpense] Loading finished');
    }
  }

  @override
  void onClose() {
    debugPrint('[ExpenseController] onClose called');
    _expenseSub?.cancel();
    super.onClose();
  }
}