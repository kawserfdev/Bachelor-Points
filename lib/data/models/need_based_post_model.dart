import 'package:cloud_firestore/cloud_firestore.dart';

/// A need-based post where a tenant describes what they need,
/// and landlords can contact them.
class NeedBasedPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;

  // Requirements
  final int bedrooms;
  final int bathrooms;
  final String propertyType; // family, bachelor, hostel, mess

  // Location preference
  final String division;
  final String district;
  final String upazila;
  final String area;

  // Budget
  final double minBudget;
  final double maxBudget;
  final String description;

  // Status
  final String status; // active, closed, expired
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  NeedBasedPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.bedrooms = 1,
    this.bathrooms = 1,
    required this.propertyType,
    required this.division,
    required this.district,
    this.upazila = '',
    required this.area,
    this.minBudget = 0,
    this.maxBudget = 0,
    this.description = '',
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory NeedBasedPostModel.fromJson(Map<String, dynamic> json) {
    return NeedBasedPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? '',
      userPhone: json['user_phone'] as String? ?? '',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 1,
      propertyType: json['property_type'] as String? ?? 'bachelor',
      division: json['division'] as String? ?? '',
      district: json['district'] as String? ?? '',
      upazila: json['upazila'] as String? ?? '',
      area: json['area'] as String? ?? '',
      minBudget: (json['min_budget'] as num?)?.toDouble() ?? 0,
      maxBudget: (json['max_budget'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      expiresAt: json['expires_at'] != null ? _parseDateTime(json['expires_at']) : null,
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
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'property_type': propertyType,
      'division': division,
      'district': district,
      'upazila': upazila,
      'area': area,
      'min_budget': minBudget,
      'max_budget': maxBudget,
      'description': description,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }
}