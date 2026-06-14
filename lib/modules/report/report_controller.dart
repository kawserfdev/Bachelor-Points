import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/report_summary_model.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/deposit_model.dart';
import '../../services/auth_service.dart';
import '../../services/pdf_service.dart';
import '../../shared/helpers/navigation_helper.dart';

class ReportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  final RxBool isLoading = false.obs;

  final Rx<ReportSummaryModel?> summary = Rx<ReportSummaryModel?>(null);
  final RxList<MemberSummaryModel> memberSummaries =
      <MemberSummaryModel>[].obs;

  String? _messId;
  String _messName = "My Mess";

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ReportController] Initialized');

    _fetchMessInfoAndData();
  }

  Future<void> _fetchMessInfoAndData() async {
    final userId = _authService.currentUser.value?.uid;

    debugPrint('[fetchMessInfo] userId: $userId');

    if (userId == null) {
      debugPrint('[fetchMessInfo] userId null');
      return;
    }

    try {
      isLoading.value = true;

      final memberResponse = await _firestore
          .collection('mess_members')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (memberResponse.docs.isNotEmpty) {
        _messId = memberResponse.docs.first.data()['mess_id'] as String;

        final messDoc = await _firestore.collection('messes').doc(_messId).get();
        _messName = messDoc.data()?['name'] as String? ?? "My Mess";

        debugPrint('[fetchMessInfo] messId: $_messId');
        debugPrint('[fetchMessInfo] messName: $_messName');

        await generateReport();
      }
    } catch (e) {
      debugPrint('[fetchMessInfo] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateReport() async {
    debugPrint('[generateReport] Triggered');

    if (_messId == null) {
      debugPrint('[generateReport] messId is null');
      return;
    }

    try {
      isLoading.value = true;

      final startDate =
          DateTime(selectedYear.value, selectedMonth.value, 1);
      final endDate = DateTime(
          selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

      final startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-01";
      final endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      debugPrint(
          '[generateReport] Date range: $startDateStr → $endDateStr');

      // Meals
      final mealsResponse = await _firestore
          .collection('meals')
          .where('mess_id', isEqualTo: _messId)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      debugPrint(
          '[generateReport] meals count: ${mealsResponse.docs.length}');

      final meals = mealsResponse.docs
          .map((doc) => MealModel.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .toList();

      // Expenses
      final expensesResponse = await _firestore
          .collection('expenses')
          .where('mess_id', isEqualTo: _messId)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      debugPrint(
          '[generateReport] expenses count: ${expensesResponse.docs.length}');

      final expensesList = <ExpenseModel>[];
      for (var doc in expensesResponse.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['created_by']).get();
          data['profiles'] = profileDoc.data();
          expensesList.add(ExpenseModel.fromJson({'id': doc.id, ...data}));
      }

      final expenses = expensesList;

      // Deposits
      final depositsResponse = await _firestore
          .collection('deposits')
          .where('mess_id', isEqualTo: _messId)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      debugPrint(
          '[generateReport] deposits count: ${depositsResponse.docs.length}');

      final depositsList = <DepositModel>[];
      for (var doc in depositsResponse.docs) {
          final data = doc.data();
          final profileDoc = await _firestore.collection('profiles').doc(data['user_id']).get();
          data['profiles'] = profileDoc.data();
          depositsList.add(DepositModel.fromJson({'id': doc.id, ...data}));
      }
      final deposits = depositsList;

      // Members
      final membersResponse = await _firestore
          .collection('mess_members')
          .where('mess_id', isEqualTo: _messId)
          .get();

      debugPrint(
          '[generateReport] members count: ${membersResponse.docs.length}');

      // Aggregation
      double totalMessMeals =
          meals.fold(0.0, (sum, m) => sum + m.totalMeals);

      double totalMessExpenses =
          expenses.fold(0.0, (sum, e) => sum + e.amount);

      double currentMealRate =
          totalMessMeals > 0 ? totalMessExpenses / totalMessMeals : 0.0;

      debugPrint('[generateReport] totalMeals: $totalMessMeals');
      debugPrint(
          '[generateReport] totalExpenses: $totalMessExpenses');
      debugPrint('[generateReport] mealRate: $currentMealRate');

      summary.value = ReportSummaryModel(
        month: selectedMonth.value,
        year: selectedYear.value,
        totalMeals: totalMessMeals,
        totalExpenses: totalMessExpenses,
        mealRate: currentMealRate,
      );

      final Map<String, MemberSummaryModel> userSummaries = {};

      for (var doc in membersResponse.docs) {
        final uid = doc.data()['user_id'] as String;
        final profileDoc = await _firestore.collection('profiles').doc(uid).get();
        final name =
            profileDoc.data()?['full_name'] as String? ?? 'Unknown';

        final userMeals = meals
            .where((meal) => meal.userId == uid)
            .fold(0.0, (sum, meal) => sum + meal.totalMeals);

        final userDeposits = deposits
            .where((dep) => dep.userId == uid)
            .fold(0.0, (sum, dep) => sum + dep.amount);

        final userCost = userMeals * currentMealRate;
        final finalBalance = userDeposits - userCost;

        debugPrint('[MemberSummary] $name | Meals: $userMeals | '
            'Deposits: $userDeposits | Balance: $finalBalance');

        userSummaries[uid] = MemberSummaryModel(
          userId: uid,
          userName: name,
          totalMeals: userMeals,
          totalDeposits: userDeposits,
          totalCost: userCost,
          finalBalance: finalBalance,
        );
      }

      memberSummaries.assignAll(userSummaries.values.toList());

      debugPrint('[generateReport] completed successfully');
    } catch (e) {
      debugPrint('[generateReport] Error: $e');

      AppNavigation.showSnackBar('Error', 'Failed to generate report');
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(int month, int year) {
    debugPrint('[changeMonth] $month/$year');

    selectedMonth.value = month;
    selectedYear.value = year;

    generateReport();
  }

  void exportToPdf() {
    debugPrint('[exportToPdf] Triggered');

    if (summary.value == null || memberSummaries.isEmpty) {
      debugPrint('[exportToPdf] No data to export');

      AppNavigation.showSnackBar('Warning', 'No data to export');
      return;
    }

    PdfService.generateAndPrintReport(
      messName: _messName,
      summary: summary.value!,
      members: memberSummaries,
    );

    debugPrint('[exportToPdf] PDF generated');
  }
}