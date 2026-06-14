// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mess_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessMemberModel {

 String get messId; String get userId; String get role; DateTime? get joinedAt; String? get invitedBy; bool get isActive;// Denormalized from user_profiles
 String? get fullName; String? get avatarUrl;
/// Create a copy of MessMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessMemberModelCopyWith<MessMemberModel> get copyWith => _$MessMemberModelCopyWithImpl<MessMemberModel>(this as MessMemberModel, _$identity);

  /// Serializes this MessMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessMemberModel&&(identical(other.messId, messId) || other.messId == messId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messId,userId,role,joinedAt,invitedBy,isActive,fullName,avatarUrl);

@override
String toString() {
  return 'MessMemberModel(messId: $messId, userId: $userId, role: $role, joinedAt: $joinedAt, invitedBy: $invitedBy, isActive: $isActive, fullName: $fullName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $MessMemberModelCopyWith<$Res>  {
  factory $MessMemberModelCopyWith(MessMemberModel value, $Res Function(MessMemberModel) _then) = _$MessMemberModelCopyWithImpl;
@useResult
$Res call({
 String messId, String userId, String role, DateTime? joinedAt, String? invitedBy, bool isActive, String? fullName, String? avatarUrl
});




}
/// @nodoc
class _$MessMemberModelCopyWithImpl<$Res>
    implements $MessMemberModelCopyWith<$Res> {
  _$MessMemberModelCopyWithImpl(this._self, this._then);

  final MessMemberModel _self;
  final $Res Function(MessMemberModel) _then;

/// Create a copy of MessMemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messId = null,Object? userId = null,Object? role = null,Object? joinedAt = freezed,Object? invitedBy = freezed,Object? isActive = null,Object? fullName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
messId: null == messId ? _self.messId : messId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessMemberModel].
extension MessMemberModelPatterns on MessMemberModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessMemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessMemberModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessMemberModel value)  $default,){
final _that = this;
switch (_that) {
case _MessMemberModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessMemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _MessMemberModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messId,  String userId,  String role,  DateTime? joinedAt,  String? invitedBy,  bool isActive,  String? fullName,  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessMemberModel() when $default != null:
return $default(_that.messId,_that.userId,_that.role,_that.joinedAt,_that.invitedBy,_that.isActive,_that.fullName,_that.avatarUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messId,  String userId,  String role,  DateTime? joinedAt,  String? invitedBy,  bool isActive,  String? fullName,  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _MessMemberModel():
return $default(_that.messId,_that.userId,_that.role,_that.joinedAt,_that.invitedBy,_that.isActive,_that.fullName,_that.avatarUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messId,  String userId,  String role,  DateTime? joinedAt,  String? invitedBy,  bool isActive,  String? fullName,  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _MessMemberModel() when $default != null:
return $default(_that.messId,_that.userId,_that.role,_that.joinedAt,_that.invitedBy,_that.isActive,_that.fullName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessMemberModel implements MessMemberModel {
  const _MessMemberModel({required this.messId, required this.userId, required this.role, this.joinedAt, this.invitedBy, this.isActive = true, this.fullName, this.avatarUrl});
  factory _MessMemberModel.fromJson(Map<String, dynamic> json) => _$MessMemberModelFromJson(json);

@override final  String messId;
@override final  String userId;
@override final  String role;
@override final  DateTime? joinedAt;
@override final  String? invitedBy;
@override@JsonKey() final  bool isActive;
// Denormalized from user_profiles
@override final  String? fullName;
@override final  String? avatarUrl;

/// Create a copy of MessMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessMemberModelCopyWith<_MessMemberModel> get copyWith => __$MessMemberModelCopyWithImpl<_MessMemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessMemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessMemberModel&&(identical(other.messId, messId) || other.messId == messId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.invitedBy, invitedBy) || other.invitedBy == invitedBy)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messId,userId,role,joinedAt,invitedBy,isActive,fullName,avatarUrl);

@override
String toString() {
  return 'MessMemberModel(messId: $messId, userId: $userId, role: $role, joinedAt: $joinedAt, invitedBy: $invitedBy, isActive: $isActive, fullName: $fullName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$MessMemberModelCopyWith<$Res> implements $MessMemberModelCopyWith<$Res> {
  factory _$MessMemberModelCopyWith(_MessMemberModel value, $Res Function(_MessMemberModel) _then) = __$MessMemberModelCopyWithImpl;
@override @useResult
$Res call({
 String messId, String userId, String role, DateTime? joinedAt, String? invitedBy, bool isActive, String? fullName, String? avatarUrl
});




}
/// @nodoc
class __$MessMemberModelCopyWithImpl<$Res>
    implements _$MessMemberModelCopyWith<$Res> {
  __$MessMemberModelCopyWithImpl(this._self, this._then);

  final _MessMemberModel _self;
  final $Res Function(_MessMemberModel) _then;

/// Create a copy of MessMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messId = null,Object? userId = null,Object? role = null,Object? joinedAt = freezed,Object? invitedBy = freezed,Object? isActive = null,Object? fullName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_MessMemberModel(
messId: null == messId ? _self.messId : messId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,invitedBy: freezed == invitedBy ? _self.invitedBy : invitedBy // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
