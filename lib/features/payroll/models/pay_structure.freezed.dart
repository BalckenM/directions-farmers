// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pay_structure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayStructure {

 String get id; String get name; WageType get wageType; double get baseRate; bool get nmwaEnforced; double get overtimeMultiplier; double get sundayMultiplier; double get publicHolidayMultiplier; String? get pieceworkUnit; double? get pieceworkMinUnitsPerDay; DateTime get createdAt;
/// Create a copy of PayStructure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayStructureCopyWith<PayStructure> get copyWith => _$PayStructureCopyWithImpl<PayStructure>(this as PayStructure, _$identity);

  /// Serializes this PayStructure to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayStructure&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.wageType, wageType) || other.wageType == wageType)&&(identical(other.baseRate, baseRate) || other.baseRate == baseRate)&&(identical(other.nmwaEnforced, nmwaEnforced) || other.nmwaEnforced == nmwaEnforced)&&(identical(other.overtimeMultiplier, overtimeMultiplier) || other.overtimeMultiplier == overtimeMultiplier)&&(identical(other.sundayMultiplier, sundayMultiplier) || other.sundayMultiplier == sundayMultiplier)&&(identical(other.publicHolidayMultiplier, publicHolidayMultiplier) || other.publicHolidayMultiplier == publicHolidayMultiplier)&&(identical(other.pieceworkUnit, pieceworkUnit) || other.pieceworkUnit == pieceworkUnit)&&(identical(other.pieceworkMinUnitsPerDay, pieceworkMinUnitsPerDay) || other.pieceworkMinUnitsPerDay == pieceworkMinUnitsPerDay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,wageType,baseRate,nmwaEnforced,overtimeMultiplier,sundayMultiplier,publicHolidayMultiplier,pieceworkUnit,pieceworkMinUnitsPerDay,createdAt);

@override
String toString() {
  return 'PayStructure(id: $id, name: $name, wageType: $wageType, baseRate: $baseRate, nmwaEnforced: $nmwaEnforced, overtimeMultiplier: $overtimeMultiplier, sundayMultiplier: $sundayMultiplier, publicHolidayMultiplier: $publicHolidayMultiplier, pieceworkUnit: $pieceworkUnit, pieceworkMinUnitsPerDay: $pieceworkMinUnitsPerDay, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PayStructureCopyWith<$Res>  {
  factory $PayStructureCopyWith(PayStructure value, $Res Function(PayStructure) _then) = _$PayStructureCopyWithImpl;
@useResult
$Res call({
 String id, String name, WageType wageType, double baseRate, bool nmwaEnforced, double overtimeMultiplier, double sundayMultiplier, double publicHolidayMultiplier, String? pieceworkUnit, double? pieceworkMinUnitsPerDay, DateTime createdAt
});




}
/// @nodoc
class _$PayStructureCopyWithImpl<$Res>
    implements $PayStructureCopyWith<$Res> {
  _$PayStructureCopyWithImpl(this._self, this._then);

  final PayStructure _self;
  final $Res Function(PayStructure) _then;

/// Create a copy of PayStructure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? wageType = null,Object? baseRate = null,Object? nmwaEnforced = null,Object? overtimeMultiplier = null,Object? sundayMultiplier = null,Object? publicHolidayMultiplier = null,Object? pieceworkUnit = freezed,Object? pieceworkMinUnitsPerDay = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,wageType: null == wageType ? _self.wageType : wageType // ignore: cast_nullable_to_non_nullable
as WageType,baseRate: null == baseRate ? _self.baseRate : baseRate // ignore: cast_nullable_to_non_nullable
as double,nmwaEnforced: null == nmwaEnforced ? _self.nmwaEnforced : nmwaEnforced // ignore: cast_nullable_to_non_nullable
as bool,overtimeMultiplier: null == overtimeMultiplier ? _self.overtimeMultiplier : overtimeMultiplier // ignore: cast_nullable_to_non_nullable
as double,sundayMultiplier: null == sundayMultiplier ? _self.sundayMultiplier : sundayMultiplier // ignore: cast_nullable_to_non_nullable
as double,publicHolidayMultiplier: null == publicHolidayMultiplier ? _self.publicHolidayMultiplier : publicHolidayMultiplier // ignore: cast_nullable_to_non_nullable
as double,pieceworkUnit: freezed == pieceworkUnit ? _self.pieceworkUnit : pieceworkUnit // ignore: cast_nullable_to_non_nullable
as String?,pieceworkMinUnitsPerDay: freezed == pieceworkMinUnitsPerDay ? _self.pieceworkMinUnitsPerDay : pieceworkMinUnitsPerDay // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PayStructure].
extension PayStructurePatterns on PayStructure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayStructure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayStructure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayStructure value)  $default,){
final _that = this;
switch (_that) {
case _PayStructure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayStructure value)?  $default,){
final _that = this;
switch (_that) {
case _PayStructure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  WageType wageType,  double baseRate,  bool nmwaEnforced,  double overtimeMultiplier,  double sundayMultiplier,  double publicHolidayMultiplier,  String? pieceworkUnit,  double? pieceworkMinUnitsPerDay,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayStructure() when $default != null:
return $default(_that.id,_that.name,_that.wageType,_that.baseRate,_that.nmwaEnforced,_that.overtimeMultiplier,_that.sundayMultiplier,_that.publicHolidayMultiplier,_that.pieceworkUnit,_that.pieceworkMinUnitsPerDay,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  WageType wageType,  double baseRate,  bool nmwaEnforced,  double overtimeMultiplier,  double sundayMultiplier,  double publicHolidayMultiplier,  String? pieceworkUnit,  double? pieceworkMinUnitsPerDay,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PayStructure():
return $default(_that.id,_that.name,_that.wageType,_that.baseRate,_that.nmwaEnforced,_that.overtimeMultiplier,_that.sundayMultiplier,_that.publicHolidayMultiplier,_that.pieceworkUnit,_that.pieceworkMinUnitsPerDay,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  WageType wageType,  double baseRate,  bool nmwaEnforced,  double overtimeMultiplier,  double sundayMultiplier,  double publicHolidayMultiplier,  String? pieceworkUnit,  double? pieceworkMinUnitsPerDay,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PayStructure() when $default != null:
return $default(_that.id,_that.name,_that.wageType,_that.baseRate,_that.nmwaEnforced,_that.overtimeMultiplier,_that.sundayMultiplier,_that.publicHolidayMultiplier,_that.pieceworkUnit,_that.pieceworkMinUnitsPerDay,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayStructure extends PayStructure {
  const _PayStructure({required this.id, required this.name, required this.wageType, required this.baseRate, this.nmwaEnforced = true, this.overtimeMultiplier = 1.5, this.sundayMultiplier = 2.0, this.publicHolidayMultiplier = 2.0, this.pieceworkUnit, this.pieceworkMinUnitsPerDay, required this.createdAt}): super._();
  factory _PayStructure.fromJson(Map<String, dynamic> json) => _$PayStructureFromJson(json);

@override final  String id;
@override final  String name;
@override final  WageType wageType;
@override final  double baseRate;
@override@JsonKey() final  bool nmwaEnforced;
@override@JsonKey() final  double overtimeMultiplier;
@override@JsonKey() final  double sundayMultiplier;
@override@JsonKey() final  double publicHolidayMultiplier;
@override final  String? pieceworkUnit;
@override final  double? pieceworkMinUnitsPerDay;
@override final  DateTime createdAt;

/// Create a copy of PayStructure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayStructureCopyWith<_PayStructure> get copyWith => __$PayStructureCopyWithImpl<_PayStructure>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayStructureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayStructure&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.wageType, wageType) || other.wageType == wageType)&&(identical(other.baseRate, baseRate) || other.baseRate == baseRate)&&(identical(other.nmwaEnforced, nmwaEnforced) || other.nmwaEnforced == nmwaEnforced)&&(identical(other.overtimeMultiplier, overtimeMultiplier) || other.overtimeMultiplier == overtimeMultiplier)&&(identical(other.sundayMultiplier, sundayMultiplier) || other.sundayMultiplier == sundayMultiplier)&&(identical(other.publicHolidayMultiplier, publicHolidayMultiplier) || other.publicHolidayMultiplier == publicHolidayMultiplier)&&(identical(other.pieceworkUnit, pieceworkUnit) || other.pieceworkUnit == pieceworkUnit)&&(identical(other.pieceworkMinUnitsPerDay, pieceworkMinUnitsPerDay) || other.pieceworkMinUnitsPerDay == pieceworkMinUnitsPerDay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,wageType,baseRate,nmwaEnforced,overtimeMultiplier,sundayMultiplier,publicHolidayMultiplier,pieceworkUnit,pieceworkMinUnitsPerDay,createdAt);

@override
String toString() {
  return 'PayStructure(id: $id, name: $name, wageType: $wageType, baseRate: $baseRate, nmwaEnforced: $nmwaEnforced, overtimeMultiplier: $overtimeMultiplier, sundayMultiplier: $sundayMultiplier, publicHolidayMultiplier: $publicHolidayMultiplier, pieceworkUnit: $pieceworkUnit, pieceworkMinUnitsPerDay: $pieceworkMinUnitsPerDay, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PayStructureCopyWith<$Res> implements $PayStructureCopyWith<$Res> {
  factory _$PayStructureCopyWith(_PayStructure value, $Res Function(_PayStructure) _then) = __$PayStructureCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, WageType wageType, double baseRate, bool nmwaEnforced, double overtimeMultiplier, double sundayMultiplier, double publicHolidayMultiplier, String? pieceworkUnit, double? pieceworkMinUnitsPerDay, DateTime createdAt
});




}
/// @nodoc
class __$PayStructureCopyWithImpl<$Res>
    implements _$PayStructureCopyWith<$Res> {
  __$PayStructureCopyWithImpl(this._self, this._then);

  final _PayStructure _self;
  final $Res Function(_PayStructure) _then;

/// Create a copy of PayStructure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? wageType = null,Object? baseRate = null,Object? nmwaEnforced = null,Object? overtimeMultiplier = null,Object? sundayMultiplier = null,Object? publicHolidayMultiplier = null,Object? pieceworkUnit = freezed,Object? pieceworkMinUnitsPerDay = freezed,Object? createdAt = null,}) {
  return _then(_PayStructure(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,wageType: null == wageType ? _self.wageType : wageType // ignore: cast_nullable_to_non_nullable
as WageType,baseRate: null == baseRate ? _self.baseRate : baseRate // ignore: cast_nullable_to_non_nullable
as double,nmwaEnforced: null == nmwaEnforced ? _self.nmwaEnforced : nmwaEnforced // ignore: cast_nullable_to_non_nullable
as bool,overtimeMultiplier: null == overtimeMultiplier ? _self.overtimeMultiplier : overtimeMultiplier // ignore: cast_nullable_to_non_nullable
as double,sundayMultiplier: null == sundayMultiplier ? _self.sundayMultiplier : sundayMultiplier // ignore: cast_nullable_to_non_nullable
as double,publicHolidayMultiplier: null == publicHolidayMultiplier ? _self.publicHolidayMultiplier : publicHolidayMultiplier // ignore: cast_nullable_to_non_nullable
as double,pieceworkUnit: freezed == pieceworkUnit ? _self.pieceworkUnit : pieceworkUnit // ignore: cast_nullable_to_non_nullable
as String?,pieceworkMinUnitsPerDay: freezed == pieceworkMinUnitsPerDay ? _self.pieceworkMinUnitsPerDay : pieceworkMinUnitsPerDay // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
