import 'package:get/get.dart';
import 'dart:async';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/realtime_service.dart';
import '../mess/mess_controller.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/deposit_model.dart';

class HomeController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final StorageService storageService = Get.find<StorageService>();
  final RealtimeService _realtime = Get.find<RealtimeService>();
  final MessController _messController = Get.find<MessController>();

  // Dashboard summary observables
  final RxInt memberCount = 0.obs;
  final RxDouble myBalance = 0.0.obs;
  final RxDouble myTotalMeals = 0.0.obs;
  final RxDouble myDeposits = 0.0.obs;
  final RxDouble totalBazarExpense = 0.0.obs;
  final RxDouble mealRate = 0.0.obs;
  final RxDouble totalFixedExpense = 0.0.obs;

  StreamSubscription? _mealsSub;
  StreamSubscription? _expensesSub;
  StreamSubscription? _depositsSub;

  List<MealModel> _allMeals = [];
  List<ExpenseModel> _allExpenses = [];
  List<DepositModel> _allDeposits = [];

  @override
  void onInit() {
    super.onInit();
    _listenToMembers();
    _listenToData();
  }

  void _listenToMembers() {
    ever(_messController.members, (members) {
      memberCount.value = members.length;
    });
    memberCount.value = _messController.members.length;
  }

  void _listenToData() {
    ever(_messController.activeMess, (mess) {
      if (mess != null) {
        _subscribeToStreams(mess.id);
      }
    });

    final messId = _messController.activeMess.value?.id;
    if (messId != null) {
      _subscribeToStreams(messId);
    }
  }

  void _subscribeToStreams(String messId) {
    _mealsSub?.cancel();
    _mealsSub = _realtime.streamMeals(messId).listen((data) {
      _allMeals = data.map((e) => MealModel.fromJson(e)).toList();
      _recalculateDashboard();
    });

    _expensesSub?.cancel();
    _expensesSub = _realtime.streamExpenses(messId).listen((data) {
      _allExpenses = data.map((e) => ExpenseModel.fromJson(e)).toList();
      _recalculateDashboard();
    });

    _depositsSub?.cancel();
    _depositsSub = _realtime.streamDeposits(messId).listen((data) {
      _allDeposits = data.map((e) => DepositModel.fromJson(e)).toList();
      _recalculateDashboard();
    });
  }

  void _recalculateDashboard() {
    final userId = authService.currentUser.value?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Filter current month data — only approved items affect dashboard
    final monthMeals = _allMeals
        .where((m) => !m.date.isBefore(startOfMonth) && m.status == 'Approved')
        .toList();
    final monthExpenses = _allExpenses
        .where((e) => !e.date.isBefore(startOfMonth) && e.status == 'Approved')
        .toList();
    final monthDeposits = _allDeposits
        .where((d) => !d.date.isBefore(startOfMonth) && d.status == 'Approved')
        .toList();

    // My meals this month
    double myMeals = monthMeals
        .where((m) => m.userId == userId)
        .fold(0.0, (sum, m) => sum + m.totalMeals);
    myTotalMeals.value = myMeals;

    // My deposits this month
    double myDep = monthDeposits
        .where((d) => d.userId == userId)
        .fold(0.0, (sum, d) => sum + d.amount);
    myDeposits.value = myDep;

    // Total bazar expense this month
    double bazarTotal = monthExpenses
        .where((e) => e.category == 'bazar')
        .fold(0.0, (sum, e) => sum + e.amount);
    totalBazarExpense.value = bazarTotal;

    // Total fixed expense this month
    double fixedTotal = monthExpenses
        .where((e) => e.category != 'bazar')
        .fold(0.0, (sum, e) => sum + e.amount);
    totalFixedExpense.value = fixedTotal;

    // Meal rate: total bazar / total meals
    double totalMeals = monthMeals.fold(0.0, (sum, m) => sum + m.totalMeals);
    mealRate.value = totalMeals > 0 ? (bazarTotal / totalMeals) : 0.0;

    // My balance: deposits - (my meals * meal rate + fixed per person)
    final membersCount = _messController.members.length;
    final fixedPerPerson = membersCount > 0 ? (fixedTotal / membersCount) : 0.0;
    final myMealCost = myMeals * mealRate.value;
    final myTotalCost = myMealCost + fixedPerPerson;
    myBalance.value = myDep - myTotalCost;
  }

  Future<void> logout() async {
    await storageService.clearAll();
    await authService.signOut();
  }

  @override
  void onClose() {
    _mealsSub?.cancel();
    _expensesSub?.cancel();
    _depositsSub?.cancel();
    super.onClose();
  }
}
