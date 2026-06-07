// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employer_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmployerConfig {

 String? get id; String? get farmOwnerId; String get name; String? get companyName; String get registrationNumber; String get payeNumber; String? get taxNumber; String get uifReferenceNumber; String? get uifNumber; String? get sdlNumber; int get payDay; double get overtimeMultiplier; String get currency; String? get notes; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of EmployerConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployerConfigCopyWith<EmployerConfig> get copyWith => _$EmployerConfigCopyWithImpl<EmployerConfig>(this as EmployerConfig, _$identity);

  /// Serializes this EmployerConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployerConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.farmOwnerId, farmOwnerId) || other.farmOwnerId == farmOwnerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.payeNumber, payeNumber) || other.payeNumber == payeNumber)&&(identical(other.taxNumber, taxNumber) || other.taxNumber == taxNumber)&&(identical(other.uifReferenceNumber, uifReferenceNumber) || other.uifReferenceNumber == uifReferenceNumber)&&(identical(other.uifNumber, uifNumber) || other.uifNumber == uifNumber)&&(identical(other.sdlNumber, sdlNumber) || other.sdlNumber == sdlNumber)&&(identical(other.payDay, payDay) || other.payDay == payDay)&&(identical(other.overtimeMultiplier, overtimeMultiplier) || other.overtimeMultiplier == overtimeMultiplier)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,farmOwnerId,name,companyName,registrationNumber,payeNumber,taxNumber,uifReferenceNumber,uifNumber,sdlNumber,payDay,overtimeMultiplier,currency,notes,createdAt,updatedAt);

@override
String toString() {
  return 'EmployerConfig(id: $id, farmOwnerId: $farmOwnerId, name: $name, companyName: $companyName, registrationNumber: $registrationNumber, payeNumber: $payeNumber, taxNumber: $taxNumber, uifReferenceNumber: $uifReferenceNumber, uifNumber: $uifNumber, sdlNumber: $sdlNumber, payDay: $payDay, overtimeMultiplier: $overtimeMultiplier, currency: $currency, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmployerConfigCopyWith<$Res>  {
  factory $EmployerConfigCopyWith(EmployerConfig value, $Res Function(EmployerConfig) _then) = _$EmployerConfigCopyWithImpl;
@useResult
$Res call({
 String? id, String? farmOwnerId, String name, String? companyName, String registrationNumber, String payeNumber, String? taxNumber, String uifReferenceNumber, String? uifNumber, String? sdlNumber, int payDay, double overtimeMultiplier, String currency, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$EmployerConfigCopyWithImpl<$Res>
    implements $EmployerConfigCopyWith<$Res> {
  _$EmployerConfigCopyWithImpl(this._self, this._then);

  final EmployerConfig _self;
  final $Res Function(EmployerConfig) _then;

/// Create a copy of EmployerConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? farmOwnerId = freezed,Object? name = null,Object? companyName = freezed,Object? registrationNumber = null,Object? payeNumber = null,Object? taxNumber = freezed,Object? uifReferenceNumber = null,Object? uifNumber = freezed,Object? sdlNumber = freezed,Object? payDay = null,Object? overtimeMultiplier = null,Object? currency = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,farmOwnerId: freezed == farmOwnerId ? _self.farmOwnerId : farmOwnerId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,payeNumber: null == payeNumber ? _self.payeNumber : payeNumber // ignore: cast_nullable_to_non_nullable
as String,taxNumber: freezed == taxNumber ? _self.taxNumber : taxNumber // ignore: cast_nullable_to_non_nullable
as String?,uifReferenceNumber: null == uifReferenceNumber ? _self.uifReferenceNumber : uifReferenceNumber // ignore: cast_nullable_to_non_nullable
as String,uifNumber: freezed == uifNumber ? _self.uifNumber : uifNumber // ignore: cast_nullable_to_non_nullable
as String?,sdlNumber: freezed == sdlNumber ? _self.sdlNumber : sdlNumber // ignore: cast_nullable_to_non_nullable
as String?,payDay: null == payDay ? _self.payDay : payDay // ignore: cast_nullable_to_non_nullable
as int,overtimeMultiplier: null == overtimeMultiplier ? _self.overtimeMultiplier : overtimeMultiplier // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployerConfig].
extension EmployerConfigPatterns on EmployerConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployerConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployerConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployerConfig value)  $default,){
final _that = this;
switch (_that) {
case _EmployerConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployerConfig value)?  $default,){
final _that = this;
switch (_that) {
case _EmployerConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? farmOwnerId,  String name,  String? companyName,  String registrationNumber,  String payeNumber,  String? taxNumber,  String uifReferenceNumber,  String? uifNumber,  String? sdlNumber,  int payDay,  double overtimeMultiplier,  String currency,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployerConfig() when $default != null:
return $default(_that.id,_that.farmOwnerId,_that.name,_that.companyName,_that.registrationNumber,_that.payeNumber,_that.taxNumber,_that.uifReferenceNumber,_that.uifNumber,_that.sdlNumber,_that.payDay,_that.overtimeMultiplier,_that.currency,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? farmOwnerId,  String name,  String? companyName,  String registrationNumber,  String payeNumber,  String? taxNumber,  String uifReferenceNumber,  String? uifNumber,  String? sdlNumber,  int payDay,  double overtimeMultiplier,  String currency,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmployerConfig():
return $default(_that.id,_that.farmOwnerId,_that.name,_that.companyName,_that.registrationNumber,_that.payeNumber,_that.taxNumber,_that.uifReferenceNumber,_that.uifNumber,_that.sdlNumber,_that.payDay,_that.overtimeMultiplier,_that.currency,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? farmOwnerId,  String name,  String? companyName,  String registrationNumber,  String payeNumber,  String? taxNumber,  String uifReferenceNumber,  String? uifNumber,  String? sdlNumber,  int payDay,  double overtimeMultiplier,  String currency,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmployerConfig() when $default != null:
return $default(_that.id,_that.farmOwnerId,_that.name,_that.companyName,_that.registrationNumber,_that.payeNumber,_that.taxNumber,_that.uifReferenceNumber,_that.uifNumber,_that.sdlNumber,_that.payDay,_that.overtimeMultiplier,_that.currency,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmployerConfig extends EmployerConfig {
  const _EmployerConfig({this.id, this.farmOwnerId, required this.name, this.companyName, required this.registrationNumber, required this.payeNumber, this.taxNumber, required this.uifReferenceNumber, this.uifNumber, this.sdlNumber, this.payDay = 25, this.overtimeMultiplier = 1.5, this.currency = 'ZAR', this.notes, this.createdAt, this.updatedAt}): super._();
  factory _EmployerConfig.fromJson(Map<String, dynamic> json) => _$EmployerConfigFromJson(json);

@override final  String? id;
@override final  String? farmOwnerId;
@override final  String name;
@override final  String? companyName;
@override final  String registrationNumber;
@override final  String payeNumber;
@override final  String? taxNumber;
@override final  String uifReferenceNumber;
@override final  String? uifNumber;
@override final  String? sdlNumber;
@override@JsonKey() final  int payDay;
@override@JsonKey() final  double overtimeMultiplier;
@override@JsonKey() final  String currency;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of EmployerConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployerConfigCopyWith<_EmployerConfig> get copyWith => __$EmployerConfigCopyWithImpl<_EmployerConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmployerConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployerConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.farmOwnerId, farmOwnerId) || other.farmOwnerId == farmOwnerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.payeNumber, payeNumber) || other.payeNumber == payeNumber)&&(identical(other.taxNumber, taxNumber) || other.taxNumber == taxNumber)&&(identical(other.uifReferenceNumber, uifReferenceNumber) || other.uifReferenceNumber == uifReferenceNumber)&&(identical(other.uifNumber, uifNumber) || other.uifNumber == uifNumber)&&(identical(other.sdlNumber, sdlNumber) || other.sdlNumber == sdlNumber)&&(identical(other.payDay, payDay) || other.payDay == payDay)&&(identical(other.overtimeMultiplier, overtimeMultiplier) || other.overtimeMultiplier == overtimeMultiplier)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,farmOwnerId,name,companyName,registrationNumber,payeNumber,taxNumber,uifReferenceNumber,uifNumber,sdlNumber,payDay,overtimeMultiplier,currency,notes,createdAt,updatedAt);

@override
String toString() {
  return 'EmployerConfig(id: $id, farmOwnerId: $farmOwnerId, name: $name, companyName: $companyName, registrationNumber: $registrationNumber, payeNumber: $payeNumber, taxNumber: $taxNumber, uifReferenceNumber: $uifReferenceNumber, uifNumber: $uifNumber, sdlNumber: $sdlNumber, payDay: $payDay, overtimeMultiplier: $overtimeMultiplier, currency: $currency, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmployerConfigCopyWith<$Res> implements $EmployerConfigCopyWith<$Res> {
  factory _$EmployerConfigCopyWith(_EmployerConfig value, $Res Function(_EmployerConfig) _then) = __$EmployerConfigCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? farmOwnerId, String name, String? companyName, String registrationNumber, String payeNumber, String? taxNumber, String uifReferenceNumber, String? uifNumber, String? sdlNumber, int payDay, double overtimeMultiplier, String currency, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$EmployerConfigCopyWithImpl<$Res>
    implements _$EmployerConfigCopyWith<$Res> {
  __$EmployerConfigCopyWithImpl(this._self, this._then);

  final _EmployerConfig _self;
  final $Res Function(_EmployerConfig) _then;

/// Create a copy of EmployerConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? farmOwnerId = freezed,Object? name = null,Object? companyName = freezed,Object? registrationNumber = null,Object? payeNumber = null,Object? taxNumber = freezed,Object? uifReferenceNumber = null,Object? uifNumber = freezed,Object? sdlNumber = freezed,Object? payDay = null,Object? overtimeMultiplier = null,Object? currency = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_EmployerConfig(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,farmOwnerId: freezed == farmOwnerId ? _self.farmOwnerId : farmOwnerId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: null == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String,payeNumber: null == payeNumber ? _self.payeNumber : payeNumber // ignore: cast_nullable_to_non_nullable
as String,taxNumber: freezed == taxNumber ? _self.taxNumber : taxNumber // ignore: cast_nullable_to_non_nullable
as String?,uifReferenceNumber: null == uifReferenceNumber ? _self.uifReferenceNumber : uifReferenceNumber // ignore: cast_nullable_to_non_nullable
as String,uifNumber: freezed == uifNumber ? _self.uifNumber : uifNumber // ignore: cast_nullable_to_non_nullable
as String?,sdlNumber: freezed == sdlNumber ? _self.sdlNumber : sdlNumber // ignore: cast_nullable_to_non_nullable
as String?,payDay: null == payDay ? _self.payDay : payDay // ignore: cast_nullable_to_non_nullable
as int,overtimeMultiplier: null == overtimeMultiplier ? _self.overtimeMultiplier : overtimeMultiplier // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
