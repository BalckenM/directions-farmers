// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BenefitContribution {

 String get id; String get employeeId; BenefitType get type; double get employeeAmount; double get employerAmount; DateTime get effectiveFrom; DateTime? get effectiveTo; String? get fundName; String? get memberNumber;
/// Create a copy of BenefitContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenefitContributionCopyWith<BenefitContribution> get copyWith => _$BenefitContributionCopyWithImpl<BenefitContribution>(this as BenefitContribution, _$identity);

  /// Serializes this BenefitContribution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenefitContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.employeeAmount, employeeAmount) || other.employeeAmount == employeeAmount)&&(identical(other.employerAmount, employerAmount) || other.employerAmount == employerAmount)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.effectiveTo, effectiveTo) || other.effectiveTo == effectiveTo)&&(identical(other.fundName, fundName) || other.fundName == fundName)&&(identical(other.memberNumber, memberNumber) || other.memberNumber == memberNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,type,employeeAmount,employerAmount,effectiveFrom,effectiveTo,fundName,memberNumber);

@override
String toString() {
  return 'BenefitContribution(id: $id, employeeId: $employeeId, type: $type, employeeAmount: $employeeAmount, employerAmount: $employerAmount, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, fundName: $fundName, memberNumber: $memberNumber)';
}


}

/// @nodoc
abstract mixin class $BenefitContributionCopyWith<$Res>  {
  factory $BenefitContributionCopyWith(BenefitContribution value, $Res Function(BenefitContribution) _then) = _$BenefitContributionCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, BenefitType type, double employeeAmount, double employerAmount, DateTime effectiveFrom, DateTime? effectiveTo, String? fundName, String? memberNumber
});




}
/// @nodoc
class _$BenefitContributionCopyWithImpl<$Res>
    implements $BenefitContributionCopyWith<$Res> {
  _$BenefitContributionCopyWithImpl(this._self, this._then);

  final BenefitContribution _self;
  final $Res Function(BenefitContribution) _then;

/// Create a copy of BenefitContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? type = null,Object? employeeAmount = null,Object? employerAmount = null,Object? effectiveFrom = null,Object? effectiveTo = freezed,Object? fundName = freezed,Object? memberNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BenefitType,employeeAmount: null == employeeAmount ? _self.employeeAmount : employeeAmount // ignore: cast_nullable_to_non_nullable
as double,employerAmount: null == employerAmount ? _self.employerAmount : employerAmount // ignore: cast_nullable_to_non_nullable
as double,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as DateTime,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as DateTime?,fundName: freezed == fundName ? _self.fundName : fundName // ignore: cast_nullable_to_non_nullable
as String?,memberNumber: freezed == memberNumber ? _self.memberNumber : memberNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BenefitContribution].
extension BenefitContributionPatterns on BenefitContribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenefitContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenefitContribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenefitContribution value)  $default,){
final _that = this;
switch (_that) {
case _BenefitContribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenefitContribution value)?  $default,){
final _that = this;
switch (_that) {
case _BenefitContribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  BenefitType type,  double employeeAmount,  double employerAmount,  DateTime effectiveFrom,  DateTime? effectiveTo,  String? fundName,  String? memberNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenefitContribution() when $default != null:
return $default(_that.id,_that.employeeId,_that.type,_that.employeeAmount,_that.employerAmount,_that.effectiveFrom,_that.effectiveTo,_that.fundName,_that.memberNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  BenefitType type,  double employeeAmount,  double employerAmount,  DateTime effectiveFrom,  DateTime? effectiveTo,  String? fundName,  String? memberNumber)  $default,) {final _that = this;
switch (_that) {
case _BenefitContribution():
return $default(_that.id,_that.employeeId,_that.type,_that.employeeAmount,_that.employerAmount,_that.effectiveFrom,_that.effectiveTo,_that.fundName,_that.memberNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  BenefitType type,  double employeeAmount,  double employerAmount,  DateTime effectiveFrom,  DateTime? effectiveTo,  String? fundName,  String? memberNumber)?  $default,) {final _that = this;
switch (_that) {
case _BenefitContribution() when $default != null:
return $default(_that.id,_that.employeeId,_that.type,_that.employeeAmount,_that.employerAmount,_that.effectiveFrom,_that.effectiveTo,_that.fundName,_that.memberNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BenefitContribution implements BenefitContribution {
  const _BenefitContribution({required this.id, required this.employeeId, required this.type, required this.employeeAmount, required this.employerAmount, required this.effectiveFrom, this.effectiveTo, this.fundName, this.memberNumber});
  factory _BenefitContribution.fromJson(Map<String, dynamic> json) => _$BenefitContributionFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  BenefitType type;
@override final  double employeeAmount;
@override final  double employerAmount;
@override final  DateTime effectiveFrom;
@override final  DateTime? effectiveTo;
@override final  String? fundName;
@override final  String? memberNumber;

/// Create a copy of BenefitContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenefitContributionCopyWith<_BenefitContribution> get copyWith => __$BenefitContributionCopyWithImpl<_BenefitContribution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BenefitContributionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenefitContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.employeeAmount, employeeAmount) || other.employeeAmount == employeeAmount)&&(identical(other.employerAmount, employerAmount) || other.employerAmount == employerAmount)&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.effectiveTo, effectiveTo) || other.effectiveTo == effectiveTo)&&(identical(other.fundName, fundName) || other.fundName == fundName)&&(identical(other.memberNumber, memberNumber) || other.memberNumber == memberNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,type,employeeAmount,employerAmount,effectiveFrom,effectiveTo,fundName,memberNumber);

@override
String toString() {
  return 'BenefitContribution(id: $id, employeeId: $employeeId, type: $type, employeeAmount: $employeeAmount, employerAmount: $employerAmount, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo, fundName: $fundName, memberNumber: $memberNumber)';
}


}

/// @nodoc
abstract mixin class _$BenefitContributionCopyWith<$Res> implements $BenefitContributionCopyWith<$Res> {
  factory _$BenefitContributionCopyWith(_BenefitContribution value, $Res Function(_BenefitContribution) _then) = __$BenefitContributionCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, BenefitType type, double employeeAmount, double employerAmount, DateTime effectiveFrom, DateTime? effectiveTo, String? fundName, String? memberNumber
});




}
/// @nodoc
class __$BenefitContributionCopyWithImpl<$Res>
    implements _$BenefitContributionCopyWith<$Res> {
  __$BenefitContributionCopyWithImpl(this._self, this._then);

  final _BenefitContribution _self;
  final $Res Function(_BenefitContribution) _then;

/// Create a copy of BenefitContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? type = null,Object? employeeAmount = null,Object? employerAmount = null,Object? effectiveFrom = null,Object? effectiveTo = freezed,Object? fundName = freezed,Object? memberNumber = freezed,}) {
  return _then(_BenefitContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BenefitType,employeeAmount: null == employeeAmount ? _self.employeeAmount : employeeAmount // ignore: cast_nullable_to_non_nullable
as double,employerAmount: null == employerAmount ? _self.employerAmount : employerAmount // ignore: cast_nullable_to_non_nullable
as double,effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as DateTime,effectiveTo: freezed == effectiveTo ? _self.effectiveTo : effectiveTo // ignore: cast_nullable_to_non_nullable
as DateTime?,fundName: freezed == fundName ? _self.fundName : fundName // ignore: cast_nullable_to_non_nullable
as String?,memberNumber: freezed == memberNumber ? _self.memberNumber : memberNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
