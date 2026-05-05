class DepositModel {
  final String id;
  final String messId;
  final String userId;
  final double amount;
  final DateTime date;
  
  final String? userName;

  DepositModel({
    required this.id,
    required this.messId,
    required this.userId,
    required this.amount,
    required this.date,
    this.userName,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      userName: json['profiles']?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mess_id': messId,
      'user_id': userId,
      'amount': amount,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    };
  }
}
