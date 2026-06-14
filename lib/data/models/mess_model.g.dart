// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessModel _$MessModelFromJson(Map<String, dynamic> json) => _MessModel(
  id: json['id'] as String,
  name: json['name'] as String,
  inviteCode: json['invite_code'] as String,
  createdBy: json['created_by'] as String,
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MessModelToJson(_MessModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'invite_code': instance.inviteCode,
      'created_by': instance.createdBy,
      'member_count': instance.memberCount,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
