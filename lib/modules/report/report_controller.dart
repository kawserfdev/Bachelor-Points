import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../data/models/report_summary_model.dart';
import '../../data/models/meal_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/deposit_model.dart';
import '../../services/auth_service.dart';
import '../../services/pdf_service.dart';
class ReportController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
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
    final userId = _authService.currentUser.value?.id;

    debugPrint('[fetchMessInfo] userId: $userId');

    if (userId == null) {
      debugPrint('[fetchMessInfo] userId null');
      return;
    }

    try {
      isLoading.value = true;

      final memberResponse = await _supabase
          .from('members')
          .select('mess_id, messes(name)')
          .eq('user_id', userId)
          .single();

      debugPrint('[fetchMessInfo] response: $memberResponse');

      _messId = memberResponse['mess_id'] as String;
      _messName =
          memberResponse['messes']?['name'] as String? ?? "My Mess";

      debugPrint('[fetchMessInfo] messId: $_messId');
      debugPrint('[fetchMessInfo] messName: $_messName');

      await generateReport();
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

      debugPrint(
          '[generateReport] Date range: $startDate → $endDate');

      // Meals
      final mealsResponse = await _supabase
          .from('meals')
          .select('*')
          .eq('mess_id', _messId!)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      debugPrint(
          '[generateReport] meals count: ${(mealsResponse as List).length}');

      final meals = mealsResponse
          .map((e) => MealModel.fromJson(e))
          .toList();

      // Expenses
      final expensesResponse = await _supabase
          .from('expenses')
          .select('*, profiles(full_name)')
          .eq('mess_id', _messId!)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      debugPrint(
          '[generateReport] expenses count: ${(expensesResponse as List).length}');

      final expenses = expensesResponse
          .map((e) => ExpenseModel.fromJson(e))
          .toList();

      // Deposits
      final depositsResponse = await _supabase
          .from('deposits')
          .select('*, profiles(full_name)')
          .eq('mess_id', _messId!)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      debugPrint(
          '[generateReport] deposits count: ${(depositsResponse as List).length}');

      final deposits = depositsResponse
          .map((e) => DepositModel.fromJson(e))
          .toList();

      // Members
      final membersResponse = await _supabase
          .from('members')
          .select('user_id, profiles(full_name)')
          .eq('mess_id', _messId!);

      debugPrint(
          '[generateReport] members count: ${(membersResponse as List).length}');

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

      for (var m in membersResponse) {
        final uid = m['user_id'] as String;
        final name =
            m['profiles']?['full_name'] as String? ?? 'Unknown';

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

      Get.snackbar('Error', 'Failed to generate report');
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

      Get.snackbar('Warning', 'No data to export');
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