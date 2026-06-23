import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks referral relationships and commissions.
class ReferralModel {
  final String id;
  final String referrerId;
  final String referredUserId;
  final String status; // pending, completed, cancelled
  final int commissionAmount;
  final bool isWithdrawn;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? withdrawnAt;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    this.status = 'pending',
    this.commissionAmount = 0,
    this.isWithdrawn = false,
    required this.createdAt,
    this.completedAt,
    this.withdrawnAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String,
      referrerId: json['referrer_id'] as String,
      referredUserId: json['referred_user_id'] as String,
      status: json['status'] as String? ?? 'pending',
      commissionAmount: (json['commission_amount'] as num?)?.toInt() ?? 0,
      isWithdrawn: json['is_withdrawn'] as bool? ?? false,
      createdAt: _parseDateTime(json['created_at']),
      completedAt: json['completed_at'] != null ? _parseDateTime(json['completed_at']) : null,
      withdrawnAt: json['withdrawn_at'] != null ? _parseDateTime(json['withdrawn_at']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      if (value.isEmpty) return DateTime.now();
      return DateTime.parse(value);
    }
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'referrer_id': referrerId,
      'referred_user_id': referredUserId,
      'status': status,
      'commission_amount': commissionAmount,
      'is_withdrawn': isWithdrawn,
      'created_at': FieldValue.serverTimestamp(),
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'withdrawn_at': withdrawnAt != null ? Timestamp.fromDate(withdrawnAt!) : null,
    };
  }
}