class MealModel {
  final String id;
  final String messId;
  final String userId;
  final DateTime date;
  final double breakfast;
  final double lunch;
  final double dinner;
  final double guestMeals;
  final String status;
  final String? userName;

  MealModel({
    required this.id,
    required this.messId,
    required this.userId,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.guestMeals = 0.0,
    required this.status,
    this.userName,
      });

  double get totalMeals => breakfast + lunch + dinner + guestMeals;

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      userId: json['user_id'] as String,
      date: _parseDateTime(json['date']),
      breakfast: (json['breakfast'] as num).toDouble(),
      lunch: (json['lunch'] as num).toDouble(),
      dinner: (json['dinner'] as num).toDouble(),
      guestMeals: (json['guest_meals'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      userName: json['profiles']?['full_name'] as String?,
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
      'id': id,
      'mess_id': messId,
      'user_id': userId,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'guest_meals': guestMeals,
      'status': status,
    };
  }
}
