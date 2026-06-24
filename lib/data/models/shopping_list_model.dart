class ShoppingListModel {
  final String id;
  final String messId;
  final String title;
  final String status; // 'active' | 'completed' | 'inactive'
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? startDate;
  final DateTime? endDate;

  ShoppingListModel({
    required this.id,
    required this.messId,
    required this.title,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.completedAt,
    this.startDate,
    this.endDate,
  });

  bool get isActive => status == 'active';

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      title: json['title'] as String,
      status: json['status'] as String? ?? 'active',
      createdBy: json['created_by'] as String,
      createdAt: _parseDateTime(json['created_at']),
      completedAt: json['completed_at'] != null
          ? _parseDateTime(json['completed_at'])
          : null,
      startDate: json['start_date'] != null
          ? _parseDateTime(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? _parseDateTime(json['end_date'])
          : null,
    );
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }
}
