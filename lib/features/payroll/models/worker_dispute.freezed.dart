// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker_dispute.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkerDispute {

 String get id; String get employeeId; String get employeeName; DisputeType get type; DisputeStatus get status; String get description; DateTime get filedAt; String? get relatedPayRunId; String? get relatedPayslipId; DateTime? get resolvedAt; String? get resolvedBy; String? get resolutionNote;
/// Create a copy of WorkerDispute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerDisputeCopyWith<WorkerDispute> get copyWith => _$WorkerDisputeCopyWithImpl<WorkerDispute>(this as WorkerDispute, _$identity);

  /// Serializes this WorkerDispute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerDispute&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.filedAt, filedAt) || other.filedAt == filedAt)&&(identical(other.relatedPayRunId, relatedPayRunId) || other.relatedPayRunId == relatedPayRunId)&&(identical(other.relatedPayslipId, relatedPayslipId) || other.relatedPayslipId == relatedPayslipId)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,employeeName,type,status,description,filedAt,relatedPayRunId,relatedPayslipId,resolvedAt,resolvedBy,resolutionNote);

@override
String toString() {
  return 'WorkerDispute(id: $id, employeeId: $employeeId, employeeName: $employeeName, type: $type, status: $status, description: $description, filedAt: $filedAt, relatedPayRunId: $relatedPayRunId, relatedPayslipId: $relatedPayslipId, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNote: $resolutionNote)';
}


}

/// @nodoc
abstract mixin class $WorkerDisputeCopyWith<$Res>  {
  factory $WorkerDisputeCopyWith(WorkerDispute value, $Res Function(WorkerDispute) _then) = _$WorkerDisputeCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, String employeeName, DisputeType type, DisputeStatus status, String description, DateTime filedAt, String? relatedPayRunId, String? relatedPayslipId, DateTime? resolvedAt, String? resolvedBy, String? resolutionNote
});




}
/// @nodoc
class _$WorkerDisputeCopyWithImpl<$Res>
    implements $WorkerDisputeCopyWith<$Res> {
  _$WorkerDisputeCopyWithImpl(this._self, this._then);

  final WorkerDispute _self;
  final $Res Function(WorkerDispute) _then;

/// Create a copy of WorkerDispute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? employeeName = null,Object? type = null,Object? status = null,Object? description = null,Object? filedAt = null,Object? relatedPayRunId = freezed,Object? relatedPayslipId = freezed,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolutionNote = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,employeeName: null == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DisputeType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisputeStatus,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,filedAt: null == filedAt ? _self.filedAt : filedAt // ignore: cast_nullable_to_non_nullable
as DateTime,relatedPayRunId: freezed == relatedPayRunId ? _self.relatedPayRunId : relatedPayRunId // ignore: cast_nullable_to_non_nullable
as String?,relatedPayslipId: freezed == relatedPayslipId ? _self.relatedPayslipId : relatedPayslipId // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerDispute].
extension WorkerDisputePatterns on WorkerDispute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerDispute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerDispute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerDispute value)  $default,){
final _that = this;
switch (_that) {
case _WorkerDispute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerDispute value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerDispute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  String employeeName,  DisputeType type,  DisputeStatus status,  String description,  DateTime filedAt,  String? relatedPayRunId,  String? relatedPayslipId,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerDispute() when $default != null:
return $default(_that.id,_that.employeeId,_that.employeeName,_that.type,_that.status,_that.description,_that.filedAt,_that.relatedPayRunId,_that.relatedPayslipId,_that.resolvedAt,_that.resolvedBy,_that.resolutionNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  String employeeName,  DisputeType type,  DisputeStatus status,  String description,  DateTime filedAt,  String? relatedPayRunId,  String? relatedPayslipId,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNote)  $default,) {final _that = this;
switch (_that) {
case _WorkerDispute():
return $default(_that.id,_that.employeeId,_that.employeeName,_that.type,_that.status,_that.description,_that.filedAt,_that.relatedPayRunId,_that.relatedPayslipId,_that.resolvedAt,_that.resolvedBy,_that.resolutionNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  String employeeName,  DisputeType type,  DisputeStatus status,  String description,  DateTime filedAt,  String? relatedPayRunId,  String? relatedPayslipId,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNote)?  $default,) {final _that = this;
switch (_that) {
case _WorkerDispute() when $default != null:
return $default(_that.id,_that.employeeId,_that.employeeName,_that.type,_that.status,_that.description,_that.filedAt,_that.relatedPayRunId,_that.relatedPayslipId,_that.resolvedAt,_that.resolvedBy,_that.resolutionNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkerDispute extends WorkerDispute {
  const _WorkerDispute({required this.id, required this.employeeId, required this.employeeName, required this.type, required this.status, required this.description, required this.filedAt, this.relatedPayRunId, this.relatedPayslipId, this.resolvedAt, this.resolvedBy, this.resolutionNote}): super._();
  factory _WorkerDispute.fromJson(Map<String, dynamic> json) => _$WorkerDisputeFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  String employeeName;
@override final  DisputeType type;
@override final  DisputeStatus status;
@override final  String description;
@override final  DateTime filedAt;
@override final  String? relatedPayRunId;
@override final  String? relatedPayslipId;
@override final  DateTime? resolvedAt;
@override final  String? resolvedBy;
@override final  String? resolutionNote;

/// Create a copy of WorkerDispute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerDisputeCopyWith<_WorkerDispute> get copyWith => __$WorkerDisputeCopyWithImpl<_WorkerDispute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerDisputeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerDispute&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.filedAt, filedAt) || other.filedAt == filedAt)&&(identical(other.relatedPayRunId, relatedPayRunId) || other.relatedPayRunId == relatedPayRunId)&&(identical(other.relatedPayslipId, relatedPayslipId) || other.relatedPayslipId == relatedPayslipId)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolutionNote, resolutionNote) || other.resolutionNote == resolutionNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,employeeName,type,status,description,filedAt,relatedPayRunId,relatedPayslipId,resolvedAt,resolvedBy,resolutionNote);

@override
String toString() {
  return 'WorkerDispute(id: $id, employeeId: $employeeId, employeeName: $employeeName, type: $type, status: $status, description: $description, filedAt: $filedAt, relatedPayRunId: $relatedPayRunId, relatedPayslipId: $relatedPayslipId, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNote: $resolutionNote)';
}


}

/// @nodoc
abstract mixin class _$WorkerDisputeCopyWith<$Res> implements $WorkerDisputeCopyWith<$Res> {
  factory _$WorkerDisputeCopyWith(_WorkerDispute value, $Res Function(_WorkerDispute) _then) = __$WorkerDisputeCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, String employeeName, DisputeType type, DisputeStatus status, String description, DateTime filedAt, String? relatedPayRunId, String? relatedPayslipId, DateTime? resolvedAt, String? resolvedBy, String? resolutionNote
});




}
/// @nodoc
class __$WorkerDisputeCopyWithImpl<$Res>
    implements _$WorkerDisputeCopyWith<$Res> {
  __$WorkerDisputeCopyWithImpl(this._self, this._then);

  final _WorkerDispute _self;
  final $Res Function(_WorkerDispute) _then;

/// Create a copy of WorkerDispute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? employeeName = null,Object? type = null,Object? status = null,Object? description = null,Object? filedAt = null,Object? relatedPayRunId = freezed,Object? relatedPayslipId = freezed,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolutionNote = freezed,}) {
  return _then(_WorkerDispute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,employeeName: null == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DisputeType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DisputeStatus,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,filedAt: null == filedAt ? _self.filedAt : filedAt // ignore: cast_nullable_to_non_nullable
as DateTime,relatedPayRunId: freezed == relatedPayRunId ? _self.relatedPayRunId : relatedPayRunId // ignore: cast_nullable_to_non_nullable
as String?,relatedPayslipId: freezed == relatedPayslipId ? _self.relatedPayslipId : relatedPayslipId // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolutionNote: freezed == resolutionNote ? _self.resolutionNote : resolutionNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
