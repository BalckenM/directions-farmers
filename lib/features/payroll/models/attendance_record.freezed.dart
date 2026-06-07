// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRecord {

 String get id; String get employeeId; DateTime get date; AttendanceStatus get status; String? get clockInTime; String? get clockOutTime; String get recordedByUserId; AttendanceMethod get method; double? get hoursWorked; double? get overtimeHours; double? get nightShiftHours; String? get shiftId; String? get leaveRequestId; String? get notes; DateTime get createdAt;
/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRecordCopyWith<AttendanceRecord> get copyWith => _$AttendanceRecordCopyWithImpl<AttendanceRecord>(this as AttendanceRecord, _$identity);

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.clockInTime, clockInTime) || other.clockInTime == clockInTime)&&(identical(other.clockOutTime, clockOutTime) || other.clockOutTime == clockOutTime)&&(identical(other.recordedByUserId, recordedByUserId) || other.recordedByUserId == recordedByUserId)&&(identical(other.method, method) || other.method == method)&&(identical(other.hoursWorked, hoursWorked) || other.hoursWorked == hoursWorked)&&(identical(other.overtimeHours, overtimeHours) || other.overtimeHours == overtimeHours)&&(identical(other.nightShiftHours, nightShiftHours) || other.nightShiftHours == nightShiftHours)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.leaveRequestId, leaveRequestId) || other.leaveRequestId == leaveRequestId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,date,status,clockInTime,clockOutTime,recordedByUserId,method,hoursWorked,overtimeHours,nightShiftHours,shiftId,leaveRequestId,notes,createdAt);

@override
String toString() {
  return 'AttendanceRecord(id: $id, employeeId: $employeeId, date: $date, status: $status, clockInTime: $clockInTime, clockOutTime: $clockOutTime, recordedByUserId: $recordedByUserId, method: $method, hoursWorked: $hoursWorked, overtimeHours: $overtimeHours, nightShiftHours: $nightShiftHours, shiftId: $shiftId, leaveRequestId: $leaveRequestId, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceRecordCopyWith<$Res>  {
  factory $AttendanceRecordCopyWith(AttendanceRecord value, $Res Function(AttendanceRecord) _then) = _$AttendanceRecordCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, DateTime date, AttendanceStatus status, String? clockInTime, String? clockOutTime, String recordedByUserId, AttendanceMethod method, double? hoursWorked, double? overtimeHours, double? nightShiftHours, String? shiftId, String? leaveRequestId, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._self, this._then);

  final AttendanceRecord _self;
  final $Res Function(AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? date = null,Object? status = null,Object? clockInTime = freezed,Object? clockOutTime = freezed,Object? recordedByUserId = null,Object? method = null,Object? hoursWorked = freezed,Object? overtimeHours = freezed,Object? nightShiftHours = freezed,Object? shiftId = freezed,Object? leaveRequestId = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,clockInTime: freezed == clockInTime ? _self.clockInTime : clockInTime // ignore: cast_nullable_to_non_nullable
as String?,clockOutTime: freezed == clockOutTime ? _self.clockOutTime : clockOutTime // ignore: cast_nullable_to_non_nullable
as String?,recordedByUserId: null == recordedByUserId ? _self.recordedByUserId : recordedByUserId // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AttendanceMethod,hoursWorked: freezed == hoursWorked ? _self.hoursWorked : hoursWorked // ignore: cast_nullable_to_non_nullable
as double?,overtimeHours: freezed == overtimeHours ? _self.overtimeHours : overtimeHours // ignore: cast_nullable_to_non_nullable
as double?,nightShiftHours: freezed == nightShiftHours ? _self.nightShiftHours : nightShiftHours // ignore: cast_nullable_to_non_nullable
as double?,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,leaveRequestId: freezed == leaveRequestId ? _self.leaveRequestId : leaveRequestId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRecord].
extension AttendanceRecordPatterns on AttendanceRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRecord value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  DateTime date,  AttendanceStatus status,  String? clockInTime,  String? clockOutTime,  String recordedByUserId,  AttendanceMethod method,  double? hoursWorked,  double? overtimeHours,  double? nightShiftHours,  String? shiftId,  String? leaveRequestId,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.id,_that.employeeId,_that.date,_that.status,_that.clockInTime,_that.clockOutTime,_that.recordedByUserId,_that.method,_that.hoursWorked,_that.overtimeHours,_that.nightShiftHours,_that.shiftId,_that.leaveRequestId,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  DateTime date,  AttendanceStatus status,  String? clockInTime,  String? clockOutTime,  String recordedByUserId,  AttendanceMethod method,  double? hoursWorked,  double? overtimeHours,  double? nightShiftHours,  String? shiftId,  String? leaveRequestId,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord():
return $default(_that.id,_that.employeeId,_that.date,_that.status,_that.clockInTime,_that.clockOutTime,_that.recordedByUserId,_that.method,_that.hoursWorked,_that.overtimeHours,_that.nightShiftHours,_that.shiftId,_that.leaveRequestId,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  DateTime date,  AttendanceStatus status,  String? clockInTime,  String? clockOutTime,  String recordedByUserId,  AttendanceMethod method,  double? hoursWorked,  double? overtimeHours,  double? nightShiftHours,  String? shiftId,  String? leaveRequestId,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.id,_that.employeeId,_that.date,_that.status,_that.clockInTime,_that.clockOutTime,_that.recordedByUserId,_that.method,_that.hoursWorked,_that.overtimeHours,_that.nightShiftHours,_that.shiftId,_that.leaveRequestId,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttendanceRecord extends AttendanceRecord {
  const _AttendanceRecord({required this.id, required this.employeeId, required this.date, required this.status, this.clockInTime, this.clockOutTime, required this.recordedByUserId, required this.method, this.hoursWorked, this.overtimeHours, this.nightShiftHours, this.shiftId, this.leaveRequestId, this.notes, required this.createdAt}): super._();
  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  DateTime date;
@override final  AttendanceStatus status;
@override final  String? clockInTime;
@override final  String? clockOutTime;
@override final  String recordedByUserId;
@override final  AttendanceMethod method;
@override final  double? hoursWorked;
@override final  double? overtimeHours;
@override final  double? nightShiftHours;
@override final  String? shiftId;
@override final  String? leaveRequestId;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRecordCopyWith<_AttendanceRecord> get copyWith => __$AttendanceRecordCopyWithImpl<_AttendanceRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.clockInTime, clockInTime) || other.clockInTime == clockInTime)&&(identical(other.clockOutTime, clockOutTime) || other.clockOutTime == clockOutTime)&&(identical(other.recordedByUserId, recordedByUserId) || other.recordedByUserId == recordedByUserId)&&(identical(other.method, method) || other.method == method)&&(identical(other.hoursWorked, hoursWorked) || other.hoursWorked == hoursWorked)&&(identical(other.overtimeHours, overtimeHours) || other.overtimeHours == overtimeHours)&&(identical(other.nightShiftHours, nightShiftHours) || other.nightShiftHours == nightShiftHours)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.leaveRequestId, leaveRequestId) || other.leaveRequestId == leaveRequestId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,date,status,clockInTime,clockOutTime,recordedByUserId,method,hoursWorked,overtimeHours,nightShiftHours,shiftId,leaveRequestId,notes,createdAt);

@override
String toString() {
  return 'AttendanceRecord(id: $id, employeeId: $employeeId, date: $date, status: $status, clockInTime: $clockInTime, clockOutTime: $clockOutTime, recordedByUserId: $recordedByUserId, method: $method, hoursWorked: $hoursWorked, overtimeHours: $overtimeHours, nightShiftHours: $nightShiftHours, shiftId: $shiftId, leaveRequestId: $leaveRequestId, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRecordCopyWith<$Res> implements $AttendanceRecordCopyWith<$Res> {
  factory _$AttendanceRecordCopyWith(_AttendanceRecord value, $Res Function(_AttendanceRecord) _then) = __$AttendanceRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, DateTime date, AttendanceStatus status, String? clockInTime, String? clockOutTime, String recordedByUserId, AttendanceMethod method, double? hoursWorked, double? overtimeHours, double? nightShiftHours, String? shiftId, String? leaveRequestId, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$AttendanceRecordCopyWithImpl<$Res>
    implements _$AttendanceRecordCopyWith<$Res> {
  __$AttendanceRecordCopyWithImpl(this._self, this._then);

  final _AttendanceRecord _self;
  final $Res Function(_AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? date = null,Object? status = null,Object? clockInTime = freezed,Object? clockOutTime = freezed,Object? recordedByUserId = null,Object? method = null,Object? hoursWorked = freezed,Object? overtimeHours = freezed,Object? nightShiftHours = freezed,Object? shiftId = freezed,Object? leaveRequestId = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_AttendanceRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,clockInTime: freezed == clockInTime ? _self.clockInTime : clockInTime // ignore: cast_nullable_to_non_nullable
as String?,clockOutTime: freezed == clockOutTime ? _self.clockOutTime : clockOutTime // ignore: cast_nullable_to_non_nullable
as String?,recordedByUserId: null == recordedByUserId ? _self.recordedByUserId : recordedByUserId // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AttendanceMethod,hoursWorked: freezed == hoursWorked ? _self.hoursWorked : hoursWorked // ignore: cast_nullable_to_non_nullable
as double?,overtimeHours: freezed == overtimeHours ? _self.overtimeHours : overtimeHours // ignore: cast_nullable_to_non_nullable
as double?,nightShiftHours: freezed == nightShiftHours ? _self.nightShiftHours : nightShiftHours // ignore: cast_nullable_to_non_nullable
as double?,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,leaveRequestId: freezed == leaveRequestId ? _self.leaveRequestId : leaveRequestId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
