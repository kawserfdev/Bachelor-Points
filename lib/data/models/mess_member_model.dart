import 'package:freezed_annotation/freezed_annotation.dart';

part 'mess_member_model.freezed.dart';
part 'mess_member_model.g.dart';

@freezed
abstract class MessMemberModel with _$MessMemberModel {
  const factory MessMemberModel({
    required String messId,
    required String userId,
    required String role,
    DateTime? joinedAt,
    String? invitedBy,
    @Default(true) bool isActive,
    // Denormalized from user_profiles
    String? fullName,
    String? avatarUrl,
  }) = _MessMemberModel;

  factory MessMemberModel.fromJson(Map<String, dynamic> json) =>
      _$MessMemberModelFromJson(json);
}

extension MessMemberModelFirestore on MessMemberModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('mess_id');
    json.remove('user_id');
    json.remove('full_name');
    json.remove('avatar_url');
    return json;
  }
}

extension MessMemberModelFirestoreFactory on MessMemberModel {
  static MessMemberModel fromFirestore(
      String messId, String userId, Map<String, dynamic> data) {
    return MessMemberModel.fromJson({
      'mess_id': messId,
      'user_id': userId,
      ...data,
    });
  }
}