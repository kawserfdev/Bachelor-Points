import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/deposit_model.dart';
import '../../services/auth_service.dart';
import '../mess/mess_controller.dart';
import '../mess/member_controller.dart';

class RequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final userId = _authService.currentUser.value?.uid;
    final messId = _messController.activeMess.value?.id;

    if (userId == null || messId == null) return;

    if (!_memberController.isAdmin) {
      debugPrint('[fetchPendingItems] Access denied (not admin)');
      return;
    }

    try {
      isLoading.value = true;

      // Fetch Pending Meals
      final mealsResponse = await _firestore
          .collection('meals')
          .where('mess_id', isEqualTo: messId)
          .where('status', isEqualTo: 'Pending')
          .orderBy('date', descending: true)
          .get();

      final pendingMealsList = <MealModel>[];
      for (var doc in mealsResponse.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['user_id']).get();
          data['profiles'] = profileDoc.data();
          pendingMealsList.add(MealModel.fromJson({'id': doc.id, ...data}));
      }

      // Fetch Pending Expenses
      final expensesResponse = await _firestore
          .collection('expenses')
          .where('mess_id', isEqualTo: messId)
          .where('status', isEqualTo: 'Pending')
          .orderBy('date', descending: true)
          .get();

      final pendingExpensesList = <ExpenseModel>[];
      for (var doc in expensesResponse.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['created_by']).get();
          data['profiles'] = profileDoc.data();
          pendingExpensesList.add(ExpenseModel.fromJson({'id': doc.id, ...data}));
      }

      // Fetch Pending Deposits
      final depositsResponse = await _firestore
          .collection('deposits')
          .where('mess_id', isEqualTo: messId)
          .where('status', isEqualTo: 'Pending')
          .orderBy('date', descending: true)
          .get();

      final pendingDepositsList = <DepositModel>[];
      for (var doc in depositsResponse.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['user_id']).get();
          data['profiles'] = profileDoc.data();
          pendingDepositsList.add(DepositModel.fromJson({'id': doc.id, ...data}));
      }

      pendingMeals.assignAll(pendingMealsList);
      pendingExpenses.assignAll(pendingExpensesList);
      pendingDeposits.assignAll(pendingDepositsList);

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

      await _firestore
          .collection(tableName)
          .doc(id)
          .update({'status': newStatus, 'updated_at': FieldValue.serverTimestamp()});

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