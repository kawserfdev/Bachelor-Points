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
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? (json['completed_at'] is Timestamp
              ? (json['completed_at'] as Timestamp).toDate()
              : DateTime.parse(json['completed_at'] as String))
          : null,
      withdrawnAt: json['withdrawn_at'] != null
          ? (json['withdrawn_at'] is Timestamp
              ? (json['withdrawn_at'] as Timestamp).toDate()
              : DateTime.parse(json['withdrawn_at'] as String))
          : null,
    );
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