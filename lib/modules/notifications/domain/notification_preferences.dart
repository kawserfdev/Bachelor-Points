/// Domain model representing notification preferences configuration.
class NotificationPreferences {
  final bool mealNotifications;
  final bool expenseNotifications;
  final bool depositNotifications;
  final bool shoppingNotifications;
  final bool pushNotifications;
  final bool sound;
  final bool vibration;

  const NotificationPreferences({
    this.mealNotifications = true,
    this.expenseNotifications = true,
    this.depositNotifications = true,
    this.shoppingNotifications = true,
    this.pushNotifications = true,
    this.sound = true,
    this.vibration = true,
  });

  /// Creates a copy of preferences with modified properties.
  NotificationPreferences copyWith({
    bool? mealNotifications,
    bool? expenseNotifications,
    bool? depositNotifications,
    bool? shoppingNotifications,
    bool? pushNotifications,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationPreferences(
      mealNotifications: mealNotifications ?? this.mealNotifications,
      expenseNotifications: expenseNotifications ?? this.expenseNotifications,
      depositNotifications: depositNotifications ?? this.depositNotifications,
      shoppingNotifications:
          shoppingNotifications ?? this.shoppingNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }

  /// Deserializes JSON map to [NotificationPreferences].
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      mealNotifications: json['meal_notifications'] as bool? ?? true,
      expenseNotifications: json['expense_notifications'] as bool? ?? true,
      depositNotifications: json['deposit_notifications'] as bool? ?? true,
      shoppingNotifications: json['shopping_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
    );
  }

  /// Serializes [NotificationPreferences] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'meal_notifications': mealNotifications,
      'expense_notifications': expenseNotifications,
      'deposit_notifications': depositNotifications,
      'shopping_notifications': shoppingNotifications,
      'push_notifications': pushNotifications,
      'sound': sound,
      'vibration': vibration,
    };
  }
}
