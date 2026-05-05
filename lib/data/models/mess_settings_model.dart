class MessSettingsModel {
  final String messId;
  final String mealCutoffTime;

  MessSettingsModel({
    required this.messId,
    required this.mealCutoffTime,
  });

  factory MessSettingsModel.fromJson(Map<String, dynamic> json) {
    return MessSettingsModel(
      messId: json['mess_id'] as String,
      mealCutoffTime: json['meal_cutoff_time'] as String? ?? '22:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mess_id': messId,
      'meal_cutoff_time': mealCutoffTime,
    };
  }
}
