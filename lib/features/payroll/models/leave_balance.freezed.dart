// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaveBalance {

 String get id; String get employeeId; String get leaveTypeId; String get leaveTypeCode; String get leaveTypeName; double get totalEntitled; double get taken; double get pending; DateTime get asOfDate;
/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveBalanceCopyWith<LeaveBalance> get copyWith => _$LeaveBalanceCopyWithImpl<LeaveBalance>(this as LeaveBalance, _$identity);

  /// Serializes this LeaveBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.leaveTypeCode, leaveTypeCode) || other.leaveTypeCode == leaveTypeCode)&&(identical(other.leaveTypeName, leaveTypeName) || other.leaveTypeName == leaveTypeName)&&(identical(other.totalEntitled, totalEntitled) || other.totalEntitled == totalEntitled)&&(identical(other.taken, taken) || other.taken == taken)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.asOfDate, asOfDate) || other.asOfDate == asOfDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,leaveTypeId,leaveTypeCode,leaveTypeName,totalEntitled,taken,pending,asOfDate);

@override
String toString() {
  return 'LeaveBalance(id: $id, employeeId: $employeeId, leaveTypeId: $leaveTypeId, leaveTypeCode: $leaveTypeCode, leaveTypeName: $leaveTypeName, totalEntitled: $totalEntitled, taken: $taken, pending: $pending, asOfDate: $asOfDate)';
}


}

/// @nodoc
abstract mixin class $LeaveBalanceCopyWith<$Res>  {
  factory $LeaveBalanceCopyWith(LeaveBalance value, $Res Function(LeaveBalance) _then) = _$LeaveBalanceCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, String leaveTypeId, String leaveTypeCode, String leaveTypeName, double totalEntitled, double taken, double pending, DateTime asOfDate
});




}
/// @nodoc
class _$LeaveBalanceCopyWithImpl<$Res>
    implements $LeaveBalanceCopyWith<$Res> {
  _$LeaveBalanceCopyWithImpl(this._self, this._then);

  final LeaveBalance _self;
  final $Res Function(LeaveBalance) _then;

/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? leaveTypeId = null,Object? leaveTypeCode = null,Object? leaveTypeName = null,Object? totalEntitled = null,Object? taken = null,Object? pending = null,Object? asOfDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeCode: null == leaveTypeCode ? _self.leaveTypeCode : leaveTypeCode // ignore: cast_nullable_to_non_nullable
as String,leaveTypeName: null == leaveTypeName ? _self.leaveTypeName : leaveTypeName // ignore: cast_nullable_to_non_nullable
as String,totalEntitled: null == totalEntitled ? _self.totalEntitled : totalEntitled // ignore: cast_nullable_to_non_nullable
as double,taken: null == taken ? _self.taken : taken // ignore: cast_nullable_to_non_nullable
as double,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as double,asOfDate: null == asOfDate ? _self.asOfDate : asOfDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveBalance].
extension LeaveBalancePatterns on LeaveBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveBalance value)  $default,){
final _that = this;
switch (_that) {
case _LeaveBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveBalance value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  String leaveTypeId,  String leaveTypeCode,  String leaveTypeName,  double totalEntitled,  double taken,  double pending,  DateTime asOfDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
return $default(_that.id,_that.employeeId,_that.leaveTypeId,_that.leaveTypeCode,_that.leaveTypeName,_that.totalEntitled,_that.taken,_that.pending,_that.asOfDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  String leaveTypeId,  String leaveTypeCode,  String leaveTypeName,  double totalEntitled,  double taken,  double pending,  DateTime asOfDate)  $default,) {final _that = this;
switch (_that) {
case _LeaveBalance():
return $default(_that.id,_that.employeeId,_that.leaveTypeId,_that.leaveTypeCode,_that.leaveTypeName,_that.totalEntitled,_that.taken,_that.pending,_that.asOfDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  String leaveTypeId,  String leaveTypeCode,  String leaveTypeName,  double totalEntitled,  double taken,  double pending,  DateTime asOfDate)?  $default,) {final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
return $default(_that.id,_that.employeeId,_that.leaveTypeId,_that.leaveTypeCode,_that.leaveTypeName,_that.totalEntitled,_that.taken,_that.pending,_that.asOfDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveBalance extends LeaveBalance {
  const _LeaveBalance({required this.id, required this.employeeId, required this.leaveTypeId, required this.leaveTypeCode, required this.leaveTypeName, required this.totalEntitled, required this.taken, required this.pending, required this.asOfDate}): super._();
  factory _LeaveBalance.fromJson(Map<String, dynamic> json) => _$LeaveBalanceFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  String leaveTypeId;
@override final  String leaveTypeCode;
@override final  String leaveTypeName;
@override final  double totalEntitled;
@override final  double taken;
@override final  double pending;
@override final  DateTime asOfDate;

/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveBalanceCopyWith<_LeaveBalance> get copyWith => __$LeaveBalanceCopyWithImpl<_LeaveBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveBalance&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.leaveTypeCode, leaveTypeCode) || other.leaveTypeCode == leaveTypeCode)&&(identical(other.leaveTypeName, leaveTypeName) || other.leaveTypeName == leaveTypeName)&&(identical(other.totalEntitled, totalEntitled) || other.totalEntitled == totalEntitled)&&(identical(other.taken, taken) || other.taken == taken)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.asOfDate, asOfDate) || other.asOfDate == asOfDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,leaveTypeId,leaveTypeCode,leaveTypeName,totalEntitled,taken,pending,asOfDate);

@override
String toString() {
  return 'LeaveBalance(id: $id, employeeId: $employeeId, leaveTypeId: $leaveTypeId, leaveTypeCode: $leaveTypeCode, leaveTypeName: $leaveTypeName, totalEntitled: $totalEntitled, taken: $taken, pending: $pending, asOfDate: $asOfDate)';
}


}

/// @nodoc
abstract mixin class _$LeaveBalanceCopyWith<$Res> implements $LeaveBalanceCopyWith<$Res> {
  factory _$LeaveBalanceCopyWith(_LeaveBalance value, $Res Function(_LeaveBalance) _then) = __$LeaveBalanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, String leaveTypeId, String leaveTypeCode, String leaveTypeName, double totalEntitled, double taken, double pending, DateTime asOfDate
});




}
/// @nodoc
class __$LeaveBalanceCopyWithImpl<$Res>
    implements _$LeaveBalanceCopyWith<$Res> {
  __$LeaveBalanceCopyWithImpl(this._self, this._then);

  final _LeaveBalance _self;
  final $Res Function(_LeaveBalance) _then;

/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? leaveTypeId = null,Object? leaveTypeCode = null,Object? leaveTypeName = null,Object? totalEntitled = null,Object? taken = null,Object? pending = null,Object? asOfDate = null,}) {
  return _then(_LeaveBalance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeCode: null == leaveTypeCode ? _self.leaveTypeCode : leaveTypeCode // ignore: cast_nullable_to_non_nullable
as String,leaveTypeName: null == leaveTypeName ? _self.leaveTypeName : leaveTypeName // ignore: cast_nullable_to_non_nullable
as String,totalEntitled: null == totalEntitled ? _self.totalEntitled : totalEntitled // ignore: cast_nullable_to_non_nullable
as double,taken: null == taken ? _self.taken : taken // ignore: cast_nullable_to_non_nullable
as double,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as double,asOfDate: null == asOfDate ? _self.asOfDate : asOfDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
