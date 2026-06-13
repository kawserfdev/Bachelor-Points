class MemberModel {
  final String id; // member table primary key
  final String messId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  
  // From joined profiles table
  final String? fullName;
  final String? email;

  MemberModel({
    required this.id,
    required this.messId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.fullName,
    this.email,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      messId: json['mess_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: _parseDateTime(json['joined_at']),
      fullName: json['profiles']?['full_name'] as String?,
      email: json['profiles']?['email'] as String?,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    // Firestore Timestamp
    return (value as dynamic).toDate() as DateTime;
  }
}
