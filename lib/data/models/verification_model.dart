import 'package:cloud_firestore/cloud_firestore.dart';

/// Stores KYC verification details for users, properties, and agencies.
class VerificationModel {
  final String id;
  final String userId;
  final String type; // user_nid, property_utility_bill, property_holding_tax, agency_trade_license
  final String status; // pending, approved, rejected
  final String? documentUrl;
  final String? documentNumber;
  final String? notes;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? referencePropertyId; // if verifying a property
  final String? referenceAgencyId; // if verifying an agency

  VerificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.status = 'pending',
    this.documentUrl,
    this.documentNumber,
    this.notes,
    this.reviewedBy,
    required this.createdAt,
    this.reviewedAt,
    this.referencePropertyId,
    this.referenceAgencyId,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    return VerificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String? ?? 'user_nid',
      status: json['status'] as String? ?? 'pending',
      documentUrl: json['document_url'] as String?,
      documentNumber: json['document_number'] as String?,
      notes: json['notes'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? (json['reviewed_at'] is Timestamp
              ? (json['reviewed_at'] as Timestamp).toDate()
              : DateTime.parse(json['reviewed_at'] as String))
          : null,
      referencePropertyId: json['reference_property_id'] as String?,
      referenceAgencyId: json['reference_agency_id'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'type': type,
      'status': status,
      'document_url': documentUrl,
      'document_number': documentNumber,
      'notes': notes,
      'reviewed_by': reviewedBy,
      'created_at': FieldValue.serverTimestamp(),
      'reviewed_at': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reference_property_id': referencePropertyId,
      'reference_agency_id': referenceAgencyId,
    };
  }
}

/// Represents a user's badge (verified user, verified property, verified agency).
class VerificationBadge {
  final String id;
  final String userId;
  final String badgeType; // verified_user, verified_property, verified_agency
  final DateTime awardedAt;

  VerificationBadge({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.awardedAt,
  });

  factory VerificationBadge.fromJson(Map<String, dynamic> json) {
    return VerificationBadge(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeType: json['badge_type'] as String? ?? '',
      awardedAt: json['awarded_at'] is Timestamp
          ? (json['awarded_at'] as Timestamp).toDate()
          : DateTime.parse(json['awarded_at'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'badge_type': badgeType,
      'awarded_at': FieldValue.serverTimestamp(),
    };
  }
}