// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Shift {

 String get id; DateTime get date; String get startTime; String get endTime; List<String> get employeeIds; String get taskCode; String? get fieldOrArea; ShiftStatus get status; String? get supervisorId; String? get notes; DateTime get createdAt;
/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShiftCopyWith<Shift> get copyWith => _$ShiftCopyWithImpl<Shift>(this as Shift, _$identity);

  /// Serializes this Shift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shift&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.employeeIds, employeeIds)&&(identical(other.taskCode, taskCode) || other.taskCode == taskCode)&&(identical(other.fieldOrArea, fieldOrArea) || other.fieldOrArea == fieldOrArea)&&(identical(other.status, status) || other.status == status)&&(identical(other.supervisorId, supervisorId) || other.supervisorId == supervisorId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,startTime,endTime,const DeepCollectionEquality().hash(employeeIds),taskCode,fieldOrArea,status,supervisorId,notes,createdAt);

@override
String toString() {
  return 'Shift(id: $id, date: $date, startTime: $startTime, endTime: $endTime, employeeIds: $employeeIds, taskCode: $taskCode, fieldOrArea: $fieldOrArea, status: $status, supervisorId: $supervisorId, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ShiftCopyWith<$Res>  {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) _then) = _$ShiftCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, String startTime, String endTime, List<String> employeeIds, String taskCode, String? fieldOrArea, ShiftStatus status, String? supervisorId, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$ShiftCopyWithImpl<$Res>
    implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._self, this._then);

  final Shift _self;
  final $Res Function(Shift) _then;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? startTime = null,Object? endTime = null,Object? employeeIds = null,Object? taskCode = null,Object? fieldOrArea = freezed,Object? status = null,Object? supervisorId = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,employeeIds: null == employeeIds ? _self.employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,taskCode: null == taskCode ? _self.taskCode : taskCode // ignore: cast_nullable_to_non_nullable
as String,fieldOrArea: freezed == fieldOrArea ? _self.fieldOrArea : fieldOrArea // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShiftStatus,supervisorId: freezed == supervisorId ? _self.supervisorId : supervisorId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Shift].
extension ShiftPatterns on Shift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shift value)  $default,){
final _that = this;
switch (_that) {
case _Shift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shift value)?  $default,){
final _that = this;
switch (_that) {
case _Shift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  String startTime,  String endTime,  List<String> employeeIds,  String taskCode,  String? fieldOrArea,  ShiftStatus status,  String? supervisorId,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shift() when $default != null:
return $default(_that.id,_that.date,_that.startTime,_that.endTime,_that.employeeIds,_that.taskCode,_that.fieldOrArea,_that.status,_that.supervisorId,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  String startTime,  String endTime,  List<String> employeeIds,  String taskCode,  String? fieldOrArea,  ShiftStatus status,  String? supervisorId,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Shift():
return $default(_that.id,_that.date,_that.startTime,_that.endTime,_that.employeeIds,_that.taskCode,_that.fieldOrArea,_that.status,_that.supervisorId,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  String startTime,  String endTime,  List<String> employeeIds,  String taskCode,  String? fieldOrArea,  ShiftStatus status,  String? supervisorId,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Shift() when $default != null:
return $default(_that.id,_that.date,_that.startTime,_that.endTime,_that.employeeIds,_that.taskCode,_that.fieldOrArea,_that.status,_that.supervisorId,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shift implements Shift {
  const _Shift({required this.id, required this.date, required this.startTime, required this.endTime, required final  List<String> employeeIds, required this.taskCode, this.fieldOrArea, required this.status, this.supervisorId, this.notes, required this.createdAt}): _employeeIds = employeeIds;
  factory _Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  String startTime;
@override final  String endTime;
 final  List<String> _employeeIds;
@override List<String> get employeeIds {
  if (_employeeIds is EqualUnmodifiableListView) return _employeeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_employeeIds);
}

@override final  String taskCode;
@override final  String? fieldOrArea;
@override final  ShiftStatus status;
@override final  String? supervisorId;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShiftCopyWith<_Shift> get copyWith => __$ShiftCopyWithImpl<_Shift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShiftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shift&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._employeeIds, _employeeIds)&&(identical(other.taskCode, taskCode) || other.taskCode == taskCode)&&(identical(other.fieldOrArea, fieldOrArea) || other.fieldOrArea == fieldOrArea)&&(identical(other.status, status) || other.status == status)&&(identical(other.supervisorId, supervisorId) || other.supervisorId == supervisorId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,startTime,endTime,const DeepCollectionEquality().hash(_employeeIds),taskCode,fieldOrArea,status,supervisorId,notes,createdAt);

@override
String toString() {
  return 'Shift(id: $id, date: $date, startTime: $startTime, endTime: $endTime, employeeIds: $employeeIds, taskCode: $taskCode, fieldOrArea: $fieldOrArea, status: $status, supervisorId: $supervisorId, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ShiftCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$ShiftCopyWith(_Shift value, $Res Function(_Shift) _then) = __$ShiftCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, String startTime, String endTime, List<String> employeeIds, String taskCode, String? fieldOrArea, ShiftStatus status, String? supervisorId, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$ShiftCopyWithImpl<$Res>
    implements _$ShiftCopyWith<$Res> {
  __$ShiftCopyWithImpl(this._self, this._then);

  final _Shift _self;
  final $Res Function(_Shift) _then;

/// Create a copy of Shift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? startTime = null,Object? endTime = null,Object? employeeIds = null,Object? taskCode = null,Object? fieldOrArea = freezed,Object? status = null,Object? supervisorId = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_Shift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,employeeIds: null == employeeIds ? _self._employeeIds : employeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,taskCode: null == taskCode ? _self.taskCode : taskCode // ignore: cast_nullable_to_non_nullable
as String,fieldOrArea: freezed == fieldOrArea ? _self.fieldOrArea : fieldOrArea // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShiftStatus,supervisorId: freezed == supervisorId ? _self.supervisorId : supervisorId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
