import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/deposit_model.dart';
import '../../services/auth_service.dart';
import '../mess/mess_controller.dart';
import '../mess/member_controller.dart';

class RequestController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();
  final MessController _messController = Get.find<MessController>();
  final MemberController _memberController = Get.find<MemberController>();

  final RxList<MealModel> pendingMeals = <MealModel>[].obs;
  final RxList<ExpenseModel> pendingExpenses = <ExpenseModel>[].obs;
  final RxList<DepositModel> pendingDeposits = <DepositModel>[].obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[RequestController] Initialized');
    fetchPendingItems();
  }

  Future<void> fetchPendingItems() async {
    final userId = _authService.currentUser.value?.id;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) return;

    if (!_memberController.isAdmin) {
      debugPrint('[fetchPendingItems] Access denied (not admin)');
      return;
    }

    try {
      isLoading.value = true;

      // Fetch Pending Meals
      final mealsResponse = await _supabase
          .from('meals')
          .select('*, profiles(full_name)')
          .eq('mess_id', messId)
          .eq('status', 'Pending')
          .order('date', ascending: false);

      // Fetch Pending Expenses
      final expensesResponse = await _supabase
          .from('expenses')
          .select('*, profiles(full_name)')
          .eq('mess_id', messId)
          .eq('status', 'Pending')
          .order('date', ascending: false);

      // Fetch Pending Deposits
      final depositsResponse = await _supabase
          .from('deposits')
          .select('*, profiles(full_name)')
          .eq('mess_id', messId)
          .eq('status', 'Pending')
          .order('date', ascending: false);

      pendingMeals.assignAll((mealsResponse as List).map((e) => MealModel.fromJson(e)).toList());
      pendingExpenses.assignAll((expensesResponse as List).map((e) => ExpenseModel.fromJson(e)).toList());
      pendingDeposits.assignAll((depositsResponse as List).map((e) => DepositModel.fromJson(e)).toList());

    } catch (e) {
      debugPrint('[fetchPendingItems] Error: $e');
      Get.snackbar('Error', 'Failed to load pending items');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItemStatus(String type, String id, String newStatus) async {
    try {
      isLoading.value = true;
      
      String tableName = '';
      if (type == 'meal') tableName = 'meals';
      else if (type == 'expense') tableName = 'expenses';
      else if (type == 'deposit') tableName = 'deposits';
      else return;

      await _supabase
          .from(tableName)
          .update({'status': newStatus})
          .eq('id', id);

      Get.snackbar('Success', '${type.capitalizeFirst} $newStatus', 
        backgroundColor: newStatus == 'Approve' ? Colors.green : Colors.red,
        colorText: Colors.white);
      
      // Refresh the lists
      fetchPendingItems();
    } catch (e) {
      debugPrint('[updateItemStatus] Error: $e');
      Get.snackbar('Error', 'Failed to update $type status');
    } finally {
      isLoading.value = false;
    }
  }
}