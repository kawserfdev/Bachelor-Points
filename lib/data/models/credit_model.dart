import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks user credit balance and transaction history.
class CreditModel {
  final String id;
  final String userId;
  final int balance;
  final List<CreditTransaction> transactions;

  CreditModel({
    required this.id,
    required this.userId,
    this.balance = 0,
    this.transactions = const [],
  });

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => CreditTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'balance': balance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

class CreditTransaction {
  final String id;
  final String type; // credit, debit
  final int amount;
  final String reason; // unlock_contact, unlock_address, property_post, boost_listing, purchase, referral_bonus
  final String? referenceId; // property_id, referral_id, etc.
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    this.referenceId,
    required this.createdAt,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'debit',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      referenceId: json['reference_id'] as String?,
      createdAt: _parseDateTime(json['created_at']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'reason': reason,
      'reference_id': referenceId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}