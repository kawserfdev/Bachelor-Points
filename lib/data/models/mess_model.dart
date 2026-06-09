import 'package:cloud_firestore/cloud_firestore.dart';

class MessModel {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;

  MessModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
  });

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      createdBy: json['created_by'] as String,
      createdAt: json['created_at'] is Timestamp ? (json['created_at'] as Timestamp).toDate() : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
