// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deduction_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeductionRule {

 String get id; String get code; String get label; DeductionType get type; DeductionBasis get basis; double get value; double? get cappedAt; List<String>? get employeeIds; bool get isActive; DateTime get createdAt;
/// Create a copy of DeductionRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeductionRuleCopyWith<DeductionRule> get copyWith => _$DeductionRuleCopyWithImpl<DeductionRule>(this as DeductionRule, _$identity);

  /// Serializes this DeductionRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeductionRule&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.value, value) || other.value == value)&&(identical(other.cappedAt, cappedAt) || other.cappedAt == cappedAt)&&const DeepCollectionEquality().equals(other.employeeIds, employeeIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,label,type,basis,value,cappedAt,const DeepCollectionEquality().hash(employeeIds),isActive,createdAt);

@override
String toString() {
  return 'DeductionRule(id: $id, code: $code, label: $label, type: $type, basis: $basis, value: $value, cappedAt: $cappedAt, employeeIds: $employeeIds, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DeductionRuleCopyWith<$Res>  {
  factory $DeductionRuleCopyWith(DeductionRule value, $Res Function(DeductionRule) _then) = _$DeductionRuleCopyWithImpl;
@useResult
$Res call({
 String id, String code, String label, DeductionType type, DeductionBasis basis, double value, double? cappedAt, List<String>? employeeIds, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$DeductionRuleCopyWithImpl<$Res>
    implements $DeductionRuleCopyWith<$Res> {
  _$DeductionRuleCopyWithImpl(this._self, this._then);

  final DeductionRule _self;
  final $Res Function(DeductionRule) _then;

/// Create a copy of DeductionRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? label = null,Object? type = null,Object? basis = null,Object? value = null,Object? cappedAt = freezed,Object? employeeIds = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeductionType,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as DeductionBasis,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,cappedAt: freezed == cappedAt ? _self.cappedAt : cappedAt // ignore: cast_nullable_to_non_nullable
as double?,employeeIds: freezed == employeeIds ? _self.employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeductionRule].
extension DeductionRulePatterns on DeductionRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeductionRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeductionRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeductionRule value)  $default,){
final _that = this;
switch (_that) {
case _DeductionRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeductionRule value)?  $default,){
final _that = this;
switch (_that) {
case _DeductionRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String label,  DeductionType type,  DeductionBasis basis,  double value,  double? cappedAt,  List<String>? employeeIds,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeductionRule() when $default != null:
return $default(_that.id,_that.code,_that.label,_that.type,_that.basis,_that.value,_that.cappedAt,_that.employeeIds,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String label,  DeductionType type,  DeductionBasis basis,  double value,  double? cappedAt,  List<String>? employeeIds,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DeductionRule():
return $default(_that.id,_that.code,_that.label,_that.type,_that.basis,_that.value,_that.cappedAt,_that.employeeIds,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String label,  DeductionType type,  DeductionBasis basis,  double value,  double? cappedAt,  List<String>? employeeIds,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DeductionRule() when $default != null:
return $default(_that.id,_that.code,_that.label,_that.type,_that.basis,_that.value,_that.cappedAt,_that.employeeIds,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeductionRule extends DeductionRule {
  const _DeductionRule({required this.id, required this.code, required this.label, required this.type, required this.basis, required this.value, this.cappedAt, final  List<String>? employeeIds, required this.isActive, required this.createdAt}): _employeeIds = employeeIds,super._();
  factory _DeductionRule.fromJson(Map<String, dynamic> json) => _$DeductionRuleFromJson(json);

@override final  String id;
@override final  String code;
@override final  String label;
@override final  DeductionType type;
@override final  DeductionBasis basis;
@override final  double value;
@override final  double? cappedAt;
 final  List<String>? _employeeIds;
@override List<String>? get employeeIds {
  final value = _employeeIds;
  if (value == null) return null;
  if (_employeeIds is EqualUnmodifiableListView) return _employeeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of DeductionRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeductionRuleCopyWith<_DeductionRule> get copyWith => __$DeductionRuleCopyWithImpl<_DeductionRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeductionRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeductionRule&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.value, value) || other.value == value)&&(identical(other.cappedAt, cappedAt) || other.cappedAt == cappedAt)&&const DeepCollectionEquality().equals(other._employeeIds, _employeeIds)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,label,type,basis,value,cappedAt,const DeepCollectionEquality().hash(_employeeIds),isActive,createdAt);

@override
String toString() {
  return 'DeductionRule(id: $id, code: $code, label: $label, type: $type, basis: $basis, value: $value, cappedAt: $cappedAt, employeeIds: $employeeIds, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DeductionRuleCopyWith<$Res> implements $DeductionRuleCopyWith<$Res> {
  factory _$DeductionRuleCopyWith(_DeductionRule value, $Res Function(_DeductionRule) _then) = __$DeductionRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String label, DeductionType type, DeductionBasis basis, double value, double? cappedAt, List<String>? employeeIds, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$DeductionRuleCopyWithImpl<$Res>
    implements _$DeductionRuleCopyWith<$Res> {
  __$DeductionRuleCopyWithImpl(this._self, this._then);

  final _DeductionRule _self;
  final $Res Function(_DeductionRule) _then;

/// Create a copy of DeductionRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? label = null,Object? type = null,Object? basis = null,Object? value = null,Object? cappedAt = freezed,Object? employeeIds = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_DeductionRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DeductionType,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as DeductionBasis,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,cappedAt: freezed == cappedAt ? _self.cappedAt : cappedAt // ignore: cast_nullable_to_non_nullable
as double?,employeeIds: freezed == employeeIds ? _self._employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
