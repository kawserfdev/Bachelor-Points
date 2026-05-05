class ExpenseModel {
  final String id;
  final String messId;
  final String addedBy;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  // Joined from profiles
  final String? addedByName;

  ExpenseModel({
    required this.id,
    required this.messId,
    required this.addedBy,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
    this.addedByName,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      addedBy: json['added_by'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      addedByName: json['profiles']?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mess_id': messId,
      'added_by': addedBy,
      'amount': amount,
      'category': category,
      'description': description,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    };
  }
}
