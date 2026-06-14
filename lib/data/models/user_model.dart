import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? phone,
    @Default([]) List<String> authProviders,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelFirestore on UserModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid');
    return json;
  }
}

extension UserModelFirestoreFactory on UserModel {
  static UserModel fromFirestore(String uid, Map<String, dynamic> data) {
    return UserModel.fromJson({
      'uid': uid,
      ...data,
    });
  }
}