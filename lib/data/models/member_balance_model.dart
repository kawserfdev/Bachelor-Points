class MemberBalanceModel {
  final String userId;
  final String userName;
  
  final double totalMeals;
  final double totalDeposits;
  
  final double mealCost;
  final double fixedCost;
  
  final double totalCost;
  final double balance; // Positive = gets money back, Negative = owes money

  MemberBalanceModel({
    required this.userId,
    required this.userName,
    required this.totalMeals,
    required this.totalDeposits,
    required this.mealCost,
    required this.fixedCost,
    required this.totalCost,
    required this.balance,
  });
}
