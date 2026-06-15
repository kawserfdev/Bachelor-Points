import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final GetStorage _storage = GetStorage();

  static const String _keyMonth = 'report_selectedMonth';
  static const String _keyYear = 'report_selectedYear';
  static const String _keyScrollOffset = 'report_scrollOffset';

  late final RxInt selectedMonth;
  late final RxInt selectedYear;

  final RxBool isLoading = false.obs;

  /// Scroll controller whose offset is persisted across page navigations.
  late final ScrollController scrollController;

  final Rx<ReportSummaryModel?> summary = Rx<ReportSummaryModel?>(null);
  final RxList<MemberSummaryModel> memberSummaries =
      <MemberSummaryModel>[].obs;

  String? _messId;
  String _messName = "My Mess";

  @override
  void onInit() {
    super.onInit();

    // Restore persisted month/year, defaulting to current month
    final savedMonth = _storage.read<int>(_keyMonth);
    final savedYear = _storage.read<int>(_keyYear);
    selectedMonth = (savedMonth ?? DateTime.now().month).obs;
    selectedYear = (savedYear ?? DateTime.now().year).obs;

    // Restore persisted scroll offset
    final savedScrollOffset = _storage.read<double>(_keyScrollOffset) ?? 0.0;
    scrollController = ScrollController(initialScrollOffset: savedScrollOffset);

    // Persist scroll offset whenever the user scrolls
    scrollController.addListener(_persistScrollOffset);

    debugPrint(
        '[ReportController] Initialized — month=${selectedMonth.value} '
        'year=${selectedYear.value} '
        'scrollOffset=$savedScrollOffset');

    _fetchMessInfoAndData();
  }

  void _persistScrollOffset() {
    if (scrollController.hasClients) {
      _storage.write(_keyScrollOffset, scrollController.offset);
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_persistScrollOffset);
    scrollController.dispose();
    super.onClose();
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

      // ── Fetch all data in parallel (no date range in Firestore query
      //    to avoid needing composite indexes; filter client-side below) ──
      final results = await Future.wait([
        _firestore
            .collection('meals')
            .where('mess_id', isEqualTo: _messId)
            .get(),
        _firestore
            .collection('expenses')
            .where('mess_id', isEqualTo: _messId)
            .get(),
        _firestore
            .collection('deposits')
            .where('mess_id', isEqualTo: _messId)
            .get(),
        _firestore
            .collection('mess_members')
            .where('mess_id', isEqualTo: _messId)
            .get(),
      ]);

      final mealsResponse = results[0] as QuerySnapshot;
      final expensesResponse = results[1] as QuerySnapshot;
      final depositsResponse = results[2] as QuerySnapshot;
      final membersResponse = results[3] as QuerySnapshot;

      debugPrint(
          '[generateReport] Raw — meals: ${mealsResponse.docs.length} | '
          'expenses: ${expensesResponse.docs.length} | '
          'deposits: ${depositsResponse.docs.length} | '
          'members: ${membersResponse.docs.length}');

      // ── Filter by status & date range (client-side, no composite index needed) ──
      bool _dateInRange(DateTime dt) {
        final d = DateTime(dt.year, dt.month, dt.day);
        final s = DateTime(startDate.year, startDate.month, startDate.day);
        final e = DateTime(endDate.year, endDate.month, endDate.day);
        return !d.isBefore(s) && !d.isAfter(e);
      }

      final meals = mealsResponse.docs
          .map((doc) => MealModel.fromJson(
              {'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .where((m) =>
              (m.status == 'Approve' || m.status == 'Pending') &&
              _dateInRange(m.date))
          .toList();

      final expenses = expensesResponse.docs
          .map((doc) => ExpenseModel.fromJson(
              {'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .where((e) =>
              (e.status == 'Approve' || e.status == 'Pending') &&
              _dateInRange(e.date))
          .toList();

      final deposits = depositsResponse.docs
          .map((doc) => DepositModel.fromJson(
              {'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .where((d) =>
              (d.status == 'Approve' || d.status == 'Pending') &&
              _dateInRange(d.date))
          .toList();

      debugPrint(
          '[generateReport] Countable — meals: ${meals.length} | '
          'expenses: ${expenses.length} | deposits: ${deposits.length}');

      // ── Batch-fetch all profile names ──
      final profileIds = <String>{};
      for (final doc in membersResponse.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          profileIds.add(data['user_id'] as String? ?? '');
        }
      }
      for (final m in meals) {
        profileIds.add(m.userId);
      }
      for (final d in deposits) {
        profileIds.add(d.userId);
      }

      final profileNames = <String, String>{};
      if (profileIds.isNotEmpty) {
        // Firestore allows up to 30 docs in an `whereIn` query; chunk if needed.
        final ids = profileIds.toList();
        for (var i = 0; i < ids.length; i += 30) {
          final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
          final profilesSnap = await _firestore
              .collection('profiles')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          for (final p in profilesSnap.docs) {
            profileNames[p.id] =
                p.data()['full_name'] as String? ?? 'Unknown';
          }
        }
      }

      // ── Aggregation ──
      double totalMessMeals = meals.fold(0.0, (sum, m) => sum + m.totalMeals);

      double totalBazar = 0.0;
      double totalFixed = 0.0;
      for (final e in expenses) {
        if (e.category == 'bazar') {
          totalBazar += e.amount;
        } else {
          totalFixed += e.amount;
        }
      }

      double totalMessExpenses = totalBazar + totalFixed;

      // Meal rate = total bazar / total meals (fixed costs are split evenly)
      double currentMealRate =
          totalMessMeals > 0 ? totalBazar / totalMessMeals : 0.0;

      debugPrint('[generateReport] totalMeals: $totalMessMeals');
      debugPrint('[generateReport] totalBazar: $totalBazar, totalFixed: $totalFixed');
      debugPrint('[generateReport] mealRate: $currentMealRate');

      summary.value = ReportSummaryModel(
        month: selectedMonth.value,
        year: selectedYear.value,
        totalMeals: totalMessMeals,
        totalExpenses: totalMessExpenses,
        mealRate: currentMealRate,
      );

      final members = membersResponse.docs;
      final fixedCostPerPerson =
          members.isNotEmpty ? totalFixed / members.length : 0.0;

      final Map<String, MemberSummaryModel> userSummaries = {};

      for (final doc in members) {
        final data = doc.data() as Map<String, dynamic>?;
        final uid = data?['user_id'] as String? ?? '';
        final name = profileNames[uid] ?? 'Unknown';

        final userMeals = meals
            .where((meal) => meal.userId == uid)
            .fold(0.0, (sum, meal) => sum + meal.totalMeals);

        final userDeposits = deposits
            .where((dep) => dep.userId == uid)
            .fold(0.0, (sum, dep) => sum + dep.amount);

        final mealCost = userMeals * currentMealRate;
        final totalCost = mealCost + fixedCostPerPerson;
        final finalBalance = userDeposits - totalCost;

        debugPrint('[MemberSummary] $name | Meals: $userMeals | '
            'Deposits: $userDeposits | Balance: $finalBalance');

        userSummaries[uid] = MemberSummaryModel(
          userId: uid,
          userName: name,
          totalMeals: userMeals,
          totalDeposits: userDeposits,
          totalCost: totalCost,
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

    // Persist selection so it survives page refreshes
    _storage.write(_keyMonth, month);
    _storage.write(_keyYear, year);

    // Reset scroll position to top when month changes
    _storage.write(_keyScrollOffset, 0.0);
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

    generateReport();
  }

  void exportToPdf({bool downloadOnly = false}) {
    debugPrint('[exportToPdf] Triggered (downloadOnly=$downloadOnly)');

    if (summary.value == null || memberSummaries.isEmpty) {
      debugPrint('[exportToPdf] No data to export');

      AppNavigation.showSnackBar('Warning', 'No data to export');
      return;
    }

    PdfService.generateAndPrintReport(
      messName: _messName,
      summary: summary.value!,
      members: memberSummaries,
      downloadOnly: downloadOnly,
    );

    debugPrint('[exportToPdf] PDF generated');
  }
}