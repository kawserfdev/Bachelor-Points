import 'package:cloud_firestore/cloud_firestore.dart';

/// Plain Dart model that maps the Firestore `profiles/{uid}` document.
/// Includes all fields stored during profile creation and editing.
class UserProfileDetail {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String avatarUrl;
  final String nidNumber;
  final String bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfileDetail({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.avatarUrl,
    required this.nidNumber,
    required this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDetail.empty(String uid) => UserProfileDetail(
        uid: uid,
        fullName: '',
        email: '',
        phoneNumber: '',
        address: '',
        avatarUrl: '',
        nidNumber: '',
        bio: '',
      );

  factory UserProfileDetail.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserProfileDetail(
      uid: uid,
      fullName: data['full_name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phone_number'] as String? ?? '',
      address: data['address'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String? ?? '',
      nidNumber: data['nid_number'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      createdAt: _parseTimestamp(data['created_at']),
      updatedAt: _parseTimestamp(data['updated_at']),
    );
  }

  /// Profile completeness score 0.0–1.0 based on five key fields.
  double get completionPercent {
    int filled = 0;
    const total = 5;
    if (fullName.isNotEmpty) filled++;
    if (phoneNumber.isNotEmpty) filled++;
    if (address.isNotEmpty) filled++;
    if (avatarUrl.isNotEmpty) filled++;
    if (nidNumber.isNotEmpty) filled++;
    return filled / total;
  }

  /// First letter of the name for the avatar fallback.
  String get initials =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
