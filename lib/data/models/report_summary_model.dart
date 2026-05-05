class ReportSummaryModel {
  final int month;
  final int year;
  final double totalMeals;
  final double totalExpenses;
  final double mealRate;

  ReportSummaryModel({
    required this.month,
    required this.year,
    required this.totalMeals,
    required this.totalExpenses,
    required this.mealRate,
  });
}

class MemberSummaryModel {
  final String userId;
  final String userName;
  final double totalMeals;
  final double totalDeposits;
  final double totalCost;
  final double finalBalance;

  MemberSummaryModel({
    required this.userId,
    required this.userName,
    required this.totalMeals,
    required this.totalDeposits,
    required this.totalCost,
    required this.finalBalance,
  });
}
