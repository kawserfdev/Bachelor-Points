class ShoppingItemModel {
  final String id;
  final String listId;
  final String messId;
  final String itemName;
  final String quantity;
  final String priority; // 'urgent' | 'normal'
  final bool isPurchased;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String requestedBy;
  final String requestedByName;
  final String? approvedBy;
  final String? note;
  final DateTime createdAt;

  ShoppingItemModel({
    required this.id,
    required this.listId,
    required this.messId,
    required this.itemName,
    required this.quantity,
    required this.priority,
    required this.isPurchased,
    required this.status,
    required this.requestedBy,
    required this.requestedByName,
    this.approvedBy,
    this.note,
    required this.createdAt,
  });

  bool get isUrgent => priority == 'urgent';
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      messId: json['mess_id'] as String,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as String? ?? '',
      priority: json['priority'] as String? ?? 'normal',
      isPurchased: json['is_purchased'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      requestedBy: json['requested_by'] as String,
      requestedByName: json['requested_by_name'] as String? ?? 'Unknown',
      approvedBy: json['approved_by'] as String?,
      note: json['note'] as String?,
      createdAt: _parseDateTime(json['created_at']),
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
