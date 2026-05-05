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
  final RxList<MemberSummaryModel> memberSummaries = <MemberSummaryModel>[].obs;

  String? _messId;
  String _messName = "My Mess";

  @override
  void onInit() {
    super.onInit();
    _fetchMessInfoAndData();
  }

  Future<void> _fetchMessInfoAndData() async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final memberResponse = await _supabase
          .from('members')
          .select('mess_id, messes(name)')
          .eq('user_id', userId)
          .single();
          
      _messId = memberResponse['mess_id'] as String;
      _messName = memberResponse['messes']?['name'] as String? ?? "My Mess";
      
      await generateReport();
    } catch (e) {
      debugPrint("Error fetching mess info: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateReport() async {
    if (_messId == null) return;
    
    try {
      isLoading.value = true;
      
      // Calculate start and end dates for the selected month
      final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
      final endDate = DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

      // Fetch Meals
      final mealsResponse = await _supabase
          .from('meals')
          .select('*')
          .eq('mess_id', _messId!)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
          
      final meals = (mealsResponse as List).map((e) => MealModel.fromJson(e)).toList();

      // Fetch Expenses
      final expensesResponse = await _supabase
          .from('expenses')
          .select('*, profiles(full_name)')
          .eq('mess_id', _messId!)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
          
      final expenses = (expensesResponse as List).map((e) => ExpenseModel.fromJson(e)).toList();

      // Fetch Deposits
      final depositsResponse = await _supabase
          .from('deposits')
          .select('*, profiles(full_name)')
          .eq('mess_id', _messId!)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
          
      final deposits = (depositsResponse as List).map((e) => DepositModel.fromJson(e)).toList();

      // Fetch All Members of the mess to ensure everyone is listed even if 0 meals
      final membersResponse = await _supabase
          .from('members')
          .select('user_id, profiles(full_name)')
          .eq('mess_id', _messId!);

      // Aggregation Logic
      double totalMessMeals = meals.fold(0.0, (sum, m) => sum + m.totalMeals);
      double totalMessExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
      double currentMealRate = totalMessMeals > 0 ? totalMessExpenses / totalMessMeals : 0.0;

      summary.value = ReportSummaryModel(
        month: selectedMonth.value,
        year: selectedYear.value,
        totalMeals: totalMessMeals,
        totalExpenses: totalMessExpenses,
        mealRate: currentMealRate,
      );

      // Aggregate per user
      final Map<String, MemberSummaryModel> userSummaries = {};

      for (var m in membersResponse) {
        final uid = m['user_id'] as String;
        final name = m['profiles']?['full_name'] as String? ?? 'Unknown';
        
        final userMeals = meals.where((meal) => meal.userId == uid).fold(0.0, (sum, meal) => sum + meal.totalMeals);
        final userDeposits = deposits.where((dep) => dep.userId == uid).fold(0.0, (sum, dep) => sum + dep.amount);
        
        final userCost = userMeals * currentMealRate;
        final finalBalance = userDeposits - userCost;

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

    } catch (e) {
      debugPrint("Error generating report: $e");
      Get.snackbar('Error', 'Failed to generate report');
    } finally {
      isLoading.value = false;
    }
  }
  
  void changeMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    generateReport();
  }

  void exportToPdf() {
    if (summary.value == null || memberSummaries.isEmpty) {
      Get.snackbar('Warning', 'No data to export');
      return;
    }
    
    PdfService.generateAndPrintReport(
      messName: _messName,
      summary: summary.value!,
      members: memberSummaries,
    );
  }
}
