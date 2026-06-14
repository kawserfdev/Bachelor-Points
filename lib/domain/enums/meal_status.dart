enum MealStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const MealStatus(this.value);
  final String value;

  factory MealStatus.fromString(String status) {
    return MealStatus.values.firstWhere(
      (s) => s.value == status,
      orElse: () => MealStatus.pending,
    );
  }
}