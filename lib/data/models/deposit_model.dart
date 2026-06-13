class DepositModel {
  final String id;
  final String messId;
  final String userId;
  final double amount;
  final DateTime date;
  final String? receivedById;
  final String? status;

  
  final String? userName;

  DepositModel({
    required this.id,
    required this.messId,
    required this.userId,
    required this.amount,
    required this.date,
    this.userName,
    this.receivedById,
    this.status,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: _parseDateTime(json['date']),
      userName: json['profiles']?['full_name'] as String?,
      receivedById: json['received_by'] as String?,
      status: json['status'] as String?,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return (value as dynamic).toDate() as DateTime;
  }

  Map<String, dynamic> toJson() {
    return {
      'mess_id': messId,
      'user_id': userId,
      'amount': amount,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'received_by': receivedById,
      'status': status,
    };
  }
}
