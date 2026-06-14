// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mess_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessMemberModel _$MessMemberModelFromJson(Map<String, dynamic> json) =>
    _MessMemberModel(
      messId: json['mess_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      invitedBy: json['invited_by'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$MessMemberModelToJson(_MessMemberModel instance) =>
    <String, dynamic>{
      'mess_id': instance.messId,
      'user_id': instance.userId,
      'role': instance.role,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'invited_by': instance.invitedBy,
      'is_active': instance.isActive,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
    };
