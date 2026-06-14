enum ExpenseCategory {
  bazar('bazar'),
  utility('utility'),
  rent('rent'),
  other('other');

  const ExpenseCategory(this.value);
  final String value;

  factory ExpenseCategory.fromString(String category) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.value == category,
      orElse: () => ExpenseCategory.other,
    );
  }
}