import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified request model supporting both financial (expense/deposit) and
/// member (JOIN_MESS, REMOVE_MEMBER, ROLE_CHANGE) request types.
class RequestModel {
  final String id;
  final String messId;
  final String requestType;
  // 'expense', 'deposit', 'JOIN_MESS', 'REMOVE_MEMBER', 'ROLE_CHANGE'

  // ── Financial fields ──
  final String? title;
  final String? category;
  final double amount; // 0 for member requests
  final String? paymentMethod;
  final String? note;

  // ── Member / profile fields ──
  final String? memberId;
  final String? memberName;
  final String? userName;
  final String? userEmail;
  final String? photoUrl;
  final String? oldRole;
  final String? newRole;
  final String? currentRole;
  final String? reason;
  final String? targetUserId;

  // ── Meal Plan Request fields ──
  final double? breakfast;
  final double? lunch;
  final double? dinner;
  final DateTime? startDate;
  final DateTime? endDate;

  // ── Date ──
  final DateTime requestDate;

  // ── Status ──
  final String status; // 'Pending', 'Approved', 'Rejected'

  // ── Audit ──
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectedBy;
  final DateTime? rejectedAt;

  // ── Joined from profiles ──
  final String? createdByName;

  RequestModel({
    required this.id,
    required this.messId,
    required this.requestType,
    this.title,
    this.category,
    this.amount = 0,
    this.paymentMethod,
    this.note,
    this.memberId,
    this.memberName,
    this.userName,
    this.userEmail,
    this.photoUrl,
    this.oldRole,
    this.newRole,
    this.currentRole,
    this.reason,
    this.targetUserId,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.startDate,
    this.endDate,
    required this.requestDate,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.createdByName,
  });

  // ── Helpers ──

  bool get isFinancial => requestType == 'expense' || requestType == 'deposit';
  bool get isMemberRequest =>
      requestType == 'JOIN_MESS' ||
      requestType == 'REMOVE_MEMBER' ||
      requestType == 'ROLE_CHANGE';

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      requestType: json['request_type'] as String,
      title: json['title'] as String?,
      category: json['category'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String?,
      note: json['note'] as String?,
      memberId: json['member_id'] as String? ?? json['user_id'] as String?,
      memberName: json['member_name'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      photoUrl: json['photo_url'] as String?,
      oldRole: json['old_role'] as String?,
      newRole: json['new_role'] as String?,
      currentRole: json['current_role'] as String?,
      reason: json['reason'] as String?,
      targetUserId: json['target_user_id'] as String?,
      breakfast: (json['breakfast'] as num?)?.toDouble(),
      lunch: (json['lunch'] as num?)?.toDouble(),
      dinner: (json['dinner'] as num?)?.toDouble(),
      startDate: json['start_date'] != null ? _parseDateTime(json['start_date']) : null,
      endDate: json['end_date'] != null ? _parseDateTime(json['end_date']) : null,
      requestDate: _parseDateTime(json['request_date']),
      status: json['status'] as String? ?? 'Pending',
      createdBy: json['created_by'] as String? ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedBy: json['updated_by'] as String?,
      updatedAt:
          json['updated_at'] != null ? _parseDateTime(json['updated_at']) : null,
      approvedBy: json['approved_by'] as String?,
      approvedAt:
          json['approved_at'] != null ? _parseDateTime(json['approved_at']) : null,
      rejectedBy: json['rejected_by'] as String?,
      rejectedAt:
          json['rejected_at'] != null ? _parseDateTime(json['rejected_at']) : null,
      createdByName: json['profiles']?['full_name'] as String?,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'mess_id': messId,
      'request_type': requestType,
      'title': title,
      'category': category,
      'amount': amount,
      'payment_method': paymentMethod,
      'note': note,
      'member_id': memberId,
      'member_name': memberName,
      'user_name': userName,
      'user_email': userEmail,
      'photo_url': photoUrl,
      'old_role': oldRole,
      'new_role': newRole,
      'current_role': currentRole,
      'reason': reason,
      'target_user_id': targetUserId,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'start_date': startDate != null ? _dateToString(startDate!) : null,
      'end_date': endDate != null ? _dateToString(endDate!) : null,
      'request_date': _dateToString(requestDate),
      'status': status,
      'created_by': createdBy,
      'created_at': _dateToString(createdAt),
      'updated_by': updatedBy,
      'updated_at': updatedAt != null ? _dateToString(updatedAt!) : null,
      'approved_by': approvedBy,
      'approved_at': approvedAt != null ? _dateToString(approvedAt!) : null,
      'rejected_by': rejectedBy,
      'rejected_at': rejectedAt != null ? _dateToString(rejectedAt!) : null,
    };
  }

  String _dateToString(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
