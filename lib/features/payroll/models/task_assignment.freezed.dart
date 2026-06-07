// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskAssignment {

 String get id; String get employeeId; DateTime get date; String? get shiftId; String get payrollCode; String get description; String? get fieldOrArea; TaskAssignmentStatus get status; String? get notes; DateTime get createdAt;
/// Create a copy of TaskAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskAssignmentCopyWith<TaskAssignment> get copyWith => _$TaskAssignmentCopyWithImpl<TaskAssignment>(this as TaskAssignment, _$identity);

  /// Serializes this TaskAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.date, date) || other.date == date)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.payrollCode, payrollCode) || other.payrollCode == payrollCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.fieldOrArea, fieldOrArea) || other.fieldOrArea == fieldOrArea)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,date,shiftId,payrollCode,description,fieldOrArea,status,notes,createdAt);

@override
String toString() {
  return 'TaskAssignment(id: $id, employeeId: $employeeId, date: $date, shiftId: $shiftId, payrollCode: $payrollCode, description: $description, fieldOrArea: $fieldOrArea, status: $status, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TaskAssignmentCopyWith<$Res>  {
  factory $TaskAssignmentCopyWith(TaskAssignment value, $Res Function(TaskAssignment) _then) = _$TaskAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, DateTime date, String? shiftId, String payrollCode, String description, String? fieldOrArea, TaskAssignmentStatus status, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$TaskAssignmentCopyWithImpl<$Res>
    implements $TaskAssignmentCopyWith<$Res> {
  _$TaskAssignmentCopyWithImpl(this._self, this._then);

  final TaskAssignment _self;
  final $Res Function(TaskAssignment) _then;

/// Create a copy of TaskAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? date = null,Object? shiftId = freezed,Object? payrollCode = null,Object? description = null,Object? fieldOrArea = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,payrollCode: null == payrollCode ? _self.payrollCode : payrollCode // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,fieldOrArea: freezed == fieldOrArea ? _self.fieldOrArea : fieldOrArea // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskAssignmentStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskAssignment].
extension TaskAssignmentPatterns on TaskAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskAssignment value)  $default,){
final _that = this;
switch (_that) {
case _TaskAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _TaskAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  DateTime date,  String? shiftId,  String payrollCode,  String description,  String? fieldOrArea,  TaskAssignmentStatus status,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskAssignment() when $default != null:
return $default(_that.id,_that.employeeId,_that.date,_that.shiftId,_that.payrollCode,_that.description,_that.fieldOrArea,_that.status,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  DateTime date,  String? shiftId,  String payrollCode,  String description,  String? fieldOrArea,  TaskAssignmentStatus status,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TaskAssignment():
return $default(_that.id,_that.employeeId,_that.date,_that.shiftId,_that.payrollCode,_that.description,_that.fieldOrArea,_that.status,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  DateTime date,  String? shiftId,  String payrollCode,  String description,  String? fieldOrArea,  TaskAssignmentStatus status,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskAssignment() when $default != null:
return $default(_that.id,_that.employeeId,_that.date,_that.shiftId,_that.payrollCode,_that.description,_that.fieldOrArea,_that.status,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskAssignment implements TaskAssignment {
  const _TaskAssignment({required this.id, required this.employeeId, required this.date, this.shiftId, required this.payrollCode, required this.description, this.fieldOrArea, required this.status, this.notes, required this.createdAt});
  factory _TaskAssignment.fromJson(Map<String, dynamic> json) => _$TaskAssignmentFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  DateTime date;
@override final  String? shiftId;
@override final  String payrollCode;
@override final  String description;
@override final  String? fieldOrArea;
@override final  TaskAssignmentStatus status;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of TaskAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskAssignmentCopyWith<_TaskAssignment> get copyWith => __$TaskAssignmentCopyWithImpl<_TaskAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.date, date) || other.date == date)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.payrollCode, payrollCode) || other.payrollCode == payrollCode)&&(identical(other.description, description) || other.description == description)&&(identical(other.fieldOrArea, fieldOrArea) || other.fieldOrArea == fieldOrArea)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,date,shiftId,payrollCode,description,fieldOrArea,status,notes,createdAt);

@override
String toString() {
  return 'TaskAssignment(id: $id, employeeId: $employeeId, date: $date, shiftId: $shiftId, payrollCode: $payrollCode, description: $description, fieldOrArea: $fieldOrArea, status: $status, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TaskAssignmentCopyWith<$Res> implements $TaskAssignmentCopyWith<$Res> {
  factory _$TaskAssignmentCopyWith(_TaskAssignment value, $Res Function(_TaskAssignment) _then) = __$TaskAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, DateTime date, String? shiftId, String payrollCode, String description, String? fieldOrArea, TaskAssignmentStatus status, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$TaskAssignmentCopyWithImpl<$Res>
    implements _$TaskAssignmentCopyWith<$Res> {
  __$TaskAssignmentCopyWithImpl(this._self, this._then);

  final _TaskAssignment _self;
  final $Res Function(_TaskAssignment) _then;

/// Create a copy of TaskAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? date = null,Object? shiftId = freezed,Object? payrollCode = null,Object? description = null,Object? fieldOrArea = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_TaskAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,payrollCode: null == payrollCode ? _self.payrollCode : payrollCode // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,fieldOrArea: freezed == fieldOrArea ? _self.fieldOrArea : fieldOrArea // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskAssignmentStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
