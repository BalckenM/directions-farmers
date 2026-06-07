// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piecework_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PieceworkLog {

 String get id; String get employeeId; DateTime get date; String? get shiftId; String get payrollCode; String get unit; double get quantity; double get ratePerUnit; String get recordedByUserId; String? get notes; DateTime get createdAt;
/// Create a copy of PieceworkLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceworkLogCopyWith<PieceworkLog> get copyWith => _$PieceworkLogCopyWithImpl<PieceworkLog>(this as PieceworkLog, _$identity);

  /// Serializes this PieceworkLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceworkLog&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.date, date) || other.date == date)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.payrollCode, payrollCode) || other.payrollCode == payrollCode)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.ratePerUnit, ratePerUnit) || other.ratePerUnit == ratePerUnit)&&(identical(other.recordedByUserId, recordedByUserId) || other.recordedByUserId == recordedByUserId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,date,shiftId,payrollCode,unit,quantity,ratePerUnit,recordedByUserId,notes,createdAt);

@override
String toString() {
  return 'PieceworkLog(id: $id, employeeId: $employeeId, date: $date, shiftId: $shiftId, payrollCode: $payrollCode, unit: $unit, quantity: $quantity, ratePerUnit: $ratePerUnit, recordedByUserId: $recordedByUserId, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PieceworkLogCopyWith<$Res>  {
  factory $PieceworkLogCopyWith(PieceworkLog value, $Res Function(PieceworkLog) _then) = _$PieceworkLogCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, DateTime date, String? shiftId, String payrollCode, String unit, double quantity, double ratePerUnit, String recordedByUserId, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$PieceworkLogCopyWithImpl<$Res>
    implements $PieceworkLogCopyWith<$Res> {
  _$PieceworkLogCopyWithImpl(this._self, this._then);

  final PieceworkLog _self;
  final $Res Function(PieceworkLog) _then;

/// Create a copy of PieceworkLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? date = null,Object? shiftId = freezed,Object? payrollCode = null,Object? unit = null,Object? quantity = null,Object? ratePerUnit = null,Object? recordedByUserId = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,payrollCode: null == payrollCode ? _self.payrollCode : payrollCode // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,ratePerUnit: null == ratePerUnit ? _self.ratePerUnit : ratePerUnit // ignore: cast_nullable_to_non_nullable
as double,recordedByUserId: null == recordedByUserId ? _self.recordedByUserId : recordedByUserId // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PieceworkLog].
extension PieceworkLogPatterns on PieceworkLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceworkLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceworkLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceworkLog value)  $default,){
final _that = this;
switch (_that) {
case _PieceworkLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceworkLog value)?  $default,){
final _that = this;
switch (_that) {
case _PieceworkLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  DateTime date,  String? shiftId,  String payrollCode,  String unit,  double quantity,  double ratePerUnit,  String recordedByUserId,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceworkLog() when $default != null:
return $default(_that.id,_that.employeeId,_that.date,_that.shiftId,_that.payrollCode,_that.unit,_that.quantity,_that.ratePerUnit,_that.recordedByUserId,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  DateTime date,  String? shiftId,  String payrollCode,  String unit,  double quantity,  double ratePerUnit,  String recordedByUserId,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PieceworkLog():
return $default(_that.id,_that.employeeId,_that.date,_that.shiftId,_that.payrollCode,_that.unit,_that.quantity,_that.ratePerUnit,_that.recordedByUserId,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  DateTime date,  String? shiftId,  String payrollCode,  String unit,  double quantity,  double ratePerUnit,  String recordedByUserId,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PieceworkLog() when $default != null:
return $default(_that.id,_that.employeeId,_that.date,_that.shiftId,_that.payrollCode,_that.unit,_that.quantity,_that.ratePerUnit,_that.recordedByUserId,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceworkLog extends PieceworkLog {
  const _PieceworkLog({required this.id, required this.employeeId, required this.date, this.shiftId, required this.payrollCode, required this.unit, required this.quantity, required this.ratePerUnit, required this.recordedByUserId, this.notes, required this.createdAt}): super._();
  factory _PieceworkLog.fromJson(Map<String, dynamic> json) => _$PieceworkLogFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  DateTime date;
@override final  String? shiftId;
@override final  String payrollCode;
@override final  String unit;
@override final  double quantity;
@override final  double ratePerUnit;
@override final  String recordedByUserId;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of PieceworkLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceworkLogCopyWith<_PieceworkLog> get copyWith => __$PieceworkLogCopyWithImpl<_PieceworkLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceworkLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceworkLog&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.date, date) || other.date == date)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.payrollCode, payrollCode) || other.payrollCode == payrollCode)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.ratePerUnit, ratePerUnit) || other.ratePerUnit == ratePerUnit)&&(identical(other.recordedByUserId, recordedByUserId) || other.recordedByUserId == recordedByUserId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,date,shiftId,payrollCode,unit,quantity,ratePerUnit,recordedByUserId,notes,createdAt);

@override
String toString() {
  return 'PieceworkLog(id: $id, employeeId: $employeeId, date: $date, shiftId: $shiftId, payrollCode: $payrollCode, unit: $unit, quantity: $quantity, ratePerUnit: $ratePerUnit, recordedByUserId: $recordedByUserId, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PieceworkLogCopyWith<$Res> implements $PieceworkLogCopyWith<$Res> {
  factory _$PieceworkLogCopyWith(_PieceworkLog value, $Res Function(_PieceworkLog) _then) = __$PieceworkLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, DateTime date, String? shiftId, String payrollCode, String unit, double quantity, double ratePerUnit, String recordedByUserId, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$PieceworkLogCopyWithImpl<$Res>
    implements _$PieceworkLogCopyWith<$Res> {
  __$PieceworkLogCopyWithImpl(this._self, this._then);

  final _PieceworkLog _self;
  final $Res Function(_PieceworkLog) _then;

/// Create a copy of PieceworkLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? date = null,Object? shiftId = freezed,Object? payrollCode = null,Object? unit = null,Object? quantity = null,Object? ratePerUnit = null,Object? recordedByUserId = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_PieceworkLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,payrollCode: null == payrollCode ? _self.payrollCode : payrollCode // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,ratePerUnit: null == ratePerUnit ? _self.ratePerUnit : ratePerUnit // ignore: cast_nullable_to_non_nullable
as double,recordedByUserId: null == recordedByUserId ? _self.recordedByUserId : recordedByUserId // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
