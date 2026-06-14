import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
abstract class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String uid,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}

extension UserProfileModelFirestore on UserProfileModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid');
    return json;
  }
}

extension UserProfileModelFirestoreFactory on UserProfileModel {
  static UserProfileModel fromFirestore(String uid, Map<String, dynamic> data) {
    return UserProfileModel.fromJson({
      'uid': uid,
      ...data,
    });
  }
}