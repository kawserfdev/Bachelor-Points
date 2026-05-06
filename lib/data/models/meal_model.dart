class MealModel {
  final String id;
  final String messId;
  final String userId;
  final DateTime date;
  final double breakfast;
  final double lunch;
  final double dinner;
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
    required this.status,
    this.userName,
      });

  double get totalMeals => breakfast + lunch + dinner;

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      breakfast: (json['breakfast'] as num).toDouble(),
      lunch: (json['lunch'] as num).toDouble(),
      dinner: (json['dinner'] as num).toDouble(),
      status: json['status'] as String,
      userName: json['profiles']?['full_name'] as String?,
    );
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
      'status': status,
    };
  }
}
