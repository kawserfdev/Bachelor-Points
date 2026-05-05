import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';
import '../../../services/realtime_service.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/expense_model.dart';
import 'dart:async';

class ExpenseController extends GetxController {
  final _supabase = Supabase.instance.client;
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
    ever(selectedMonth, (_) => _listenToExpenses());
    ever(_messController.activeMess, (_) => _listenToExpenses());
    _listenToExpenses();
  }

  void changeMonth(int offsetMonths) {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + offsetMonths,
      1,
    );
  }

  void _listenToExpenses() {
    final messId = _messController.activeMess.value?.id;
    if (messId == null) return;

    isLoading.value = true;
    _expenseSub?.cancel();
    
    _expenseSub = _realtime.streamExpenses(messId).listen((data) {
      final startDate = DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
      final endDate = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

      final startDateStr = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-01";
      final endDateStr = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final List<ExpenseModel> fetchedExpenses = [];
      for (var row in data) {
         final dateStr = row['date'] as String;
         if (dateStr.compareTo(startDateStr) >= 0 && dateStr.compareTo(endDateStr) <= 0) {
            final userId = row['added_by'] as String;
            row['profiles'] = _messController.getProfileCached(userId);
            fetchedExpenses.add(ExpenseModel.fromJson(row));
         }
      }
      
      fetchedExpenses.sort((a, b) => b.date.compareTo(a.date));
      expenses.value = fetchedExpenses;
      calculateSummary();
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('Error listening to expenses: $e');
      isLoading.value = false;
    });
  }

  void calculateSummary() {
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    totalMonthlyExpense.value = total;

    // Equal cost splitting logic based on total active members
    final totalMembers = _messController.members.length;
    if (totalMembers > 0) {
      costPerPerson.value = total / totalMembers;
    } else {
      costPerPerson.value = 0.0;
    }
  }

  Future<void> addExpense({
    required double amount,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    final userId = _authService.currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) return;

    try {
      isLoading.value = true;

      await _supabase.from('expenses').insert({
        'mess_id': messId,
        'added_by': userId,
        'amount': amount,
        'category': category,
        'description': description?.trim(),
        'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      });

      // No need to manually fetch, the stream will automatically update the UI

      
      Get.back();
      Get.snackbar('Success', 'Expense added successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
  @override
  void onClose() {
    _expenseSub?.cancel();
    super.onClose();
  }
}
