import 'package:freezed_annotation/freezed_annotation.dart';

part 'mess_model.freezed.dart';
part 'mess_model.g.dart';

@freezed
abstract class MessModel with _$MessModel {
  const factory MessModel({
    required String id,
    required String name,
    required String inviteCode,
    required String createdBy,
    @Default(0) int memberCount,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MessModel;

  factory MessModel.fromJson(Map<String, dynamic> json) =>
      _$MessModelFromJson(json);
}

extension MessModelFirestore on MessModel {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

extension MessModelFirestoreFactory on MessModel {
  static MessModel fromFirestore(String id, Map<String, dynamic> data) {
    return MessModel.fromJson({
      'id': id,
      ...data,
    });
  }
}
