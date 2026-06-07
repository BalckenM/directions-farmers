// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incident_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IncidentRecord {

 String get id; String get employeeId; IncidentType get type; String get title; String get description; DateTime get incidentDate; IncidentStatus get status; String? get actionTaken; DateTime? get resolvedAt; String? get resolvedByUserId; List<String>? get documentPaths; String get reportedByUserId; DateTime get createdAt;
/// Create a copy of IncidentRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncidentRecordCopyWith<IncidentRecord> get copyWith => _$IncidentRecordCopyWithImpl<IncidentRecord>(this as IncidentRecord, _$identity);

  /// Serializes this IncidentRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncidentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDate, incidentDate) || other.incidentDate == incidentDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedByUserId, resolvedByUserId) || other.resolvedByUserId == resolvedByUserId)&&const DeepCollectionEquality().equals(other.documentPaths, documentPaths)&&(identical(other.reportedByUserId, reportedByUserId) || other.reportedByUserId == reportedByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,type,title,description,incidentDate,status,actionTaken,resolvedAt,resolvedByUserId,const DeepCollectionEquality().hash(documentPaths),reportedByUserId,createdAt);

@override
String toString() {
  return 'IncidentRecord(id: $id, employeeId: $employeeId, type: $type, title: $title, description: $description, incidentDate: $incidentDate, status: $status, actionTaken: $actionTaken, resolvedAt: $resolvedAt, resolvedByUserId: $resolvedByUserId, documentPaths: $documentPaths, reportedByUserId: $reportedByUserId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $IncidentRecordCopyWith<$Res>  {
  factory $IncidentRecordCopyWith(IncidentRecord value, $Res Function(IncidentRecord) _then) = _$IncidentRecordCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, IncidentType type, String title, String description, DateTime incidentDate, IncidentStatus status, String? actionTaken, DateTime? resolvedAt, String? resolvedByUserId, List<String>? documentPaths, String reportedByUserId, DateTime createdAt
});




}
/// @nodoc
class _$IncidentRecordCopyWithImpl<$Res>
    implements $IncidentRecordCopyWith<$Res> {
  _$IncidentRecordCopyWithImpl(this._self, this._then);

  final IncidentRecord _self;
  final $Res Function(IncidentRecord) _then;

/// Create a copy of IncidentRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? type = null,Object? title = null,Object? description = null,Object? incidentDate = null,Object? status = null,Object? actionTaken = freezed,Object? resolvedAt = freezed,Object? resolvedByUserId = freezed,Object? documentPaths = freezed,Object? reportedByUserId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IncidentType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDate: null == incidentDate ? _self.incidentDate : incidentDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,actionTaken: freezed == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedByUserId: freezed == resolvedByUserId ? _self.resolvedByUserId : resolvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,documentPaths: freezed == documentPaths ? _self.documentPaths : documentPaths // ignore: cast_nullable_to_non_nullable
as List<String>?,reportedByUserId: null == reportedByUserId ? _self.reportedByUserId : reportedByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [IncidentRecord].
extension IncidentRecordPatterns on IncidentRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncidentRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncidentRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncidentRecord value)  $default,){
final _that = this;
switch (_that) {
case _IncidentRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncidentRecord value)?  $default,){
final _that = this;
switch (_that) {
case _IncidentRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  IncidentType type,  String title,  String description,  DateTime incidentDate,  IncidentStatus status,  String? actionTaken,  DateTime? resolvedAt,  String? resolvedByUserId,  List<String>? documentPaths,  String reportedByUserId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncidentRecord() when $default != null:
return $default(_that.id,_that.employeeId,_that.type,_that.title,_that.description,_that.incidentDate,_that.status,_that.actionTaken,_that.resolvedAt,_that.resolvedByUserId,_that.documentPaths,_that.reportedByUserId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  IncidentType type,  String title,  String description,  DateTime incidentDate,  IncidentStatus status,  String? actionTaken,  DateTime? resolvedAt,  String? resolvedByUserId,  List<String>? documentPaths,  String reportedByUserId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _IncidentRecord():
return $default(_that.id,_that.employeeId,_that.type,_that.title,_that.description,_that.incidentDate,_that.status,_that.actionTaken,_that.resolvedAt,_that.resolvedByUserId,_that.documentPaths,_that.reportedByUserId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  IncidentType type,  String title,  String description,  DateTime incidentDate,  IncidentStatus status,  String? actionTaken,  DateTime? resolvedAt,  String? resolvedByUserId,  List<String>? documentPaths,  String reportedByUserId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _IncidentRecord() when $default != null:
return $default(_that.id,_that.employeeId,_that.type,_that.title,_that.description,_that.incidentDate,_that.status,_that.actionTaken,_that.resolvedAt,_that.resolvedByUserId,_that.documentPaths,_that.reportedByUserId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IncidentRecord extends IncidentRecord {
  const _IncidentRecord({required this.id, required this.employeeId, required this.type, required this.title, required this.description, required this.incidentDate, required this.status, this.actionTaken, this.resolvedAt, this.resolvedByUserId, final  List<String>? documentPaths, required this.reportedByUserId, required this.createdAt}): _documentPaths = documentPaths,super._();
  factory _IncidentRecord.fromJson(Map<String, dynamic> json) => _$IncidentRecordFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  IncidentType type;
@override final  String title;
@override final  String description;
@override final  DateTime incidentDate;
@override final  IncidentStatus status;
@override final  String? actionTaken;
@override final  DateTime? resolvedAt;
@override final  String? resolvedByUserId;
 final  List<String>? _documentPaths;
@override List<String>? get documentPaths {
  final value = _documentPaths;
  if (value == null) return null;
  if (_documentPaths is EqualUnmodifiableListView) return _documentPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String reportedByUserId;
@override final  DateTime createdAt;

/// Create a copy of IncidentRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncidentRecordCopyWith<_IncidentRecord> get copyWith => __$IncidentRecordCopyWithImpl<_IncidentRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IncidentRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncidentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDate, incidentDate) || other.incidentDate == incidentDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedByUserId, resolvedByUserId) || other.resolvedByUserId == resolvedByUserId)&&const DeepCollectionEquality().equals(other._documentPaths, _documentPaths)&&(identical(other.reportedByUserId, reportedByUserId) || other.reportedByUserId == reportedByUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,type,title,description,incidentDate,status,actionTaken,resolvedAt,resolvedByUserId,const DeepCollectionEquality().hash(_documentPaths),reportedByUserId,createdAt);

@override
String toString() {
  return 'IncidentRecord(id: $id, employeeId: $employeeId, type: $type, title: $title, description: $description, incidentDate: $incidentDate, status: $status, actionTaken: $actionTaken, resolvedAt: $resolvedAt, resolvedByUserId: $resolvedByUserId, documentPaths: $documentPaths, reportedByUserId: $reportedByUserId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$IncidentRecordCopyWith<$Res> implements $IncidentRecordCopyWith<$Res> {
  factory _$IncidentRecordCopyWith(_IncidentRecord value, $Res Function(_IncidentRecord) _then) = __$IncidentRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, IncidentType type, String title, String description, DateTime incidentDate, IncidentStatus status, String? actionTaken, DateTime? resolvedAt, String? resolvedByUserId, List<String>? documentPaths, String reportedByUserId, DateTime createdAt
});




}
/// @nodoc
class __$IncidentRecordCopyWithImpl<$Res>
    implements _$IncidentRecordCopyWith<$Res> {
  __$IncidentRecordCopyWithImpl(this._self, this._then);

  final _IncidentRecord _self;
  final $Res Function(_IncidentRecord) _then;

/// Create a copy of IncidentRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? type = null,Object? title = null,Object? description = null,Object? incidentDate = null,Object? status = null,Object? actionTaken = freezed,Object? resolvedAt = freezed,Object? resolvedByUserId = freezed,Object? documentPaths = freezed,Object? reportedByUserId = null,Object? createdAt = null,}) {
  return _then(_IncidentRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IncidentType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDate: null == incidentDate ? _self.incidentDate : incidentDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,actionTaken: freezed == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedByUserId: freezed == resolvedByUserId ? _self.resolvedByUserId : resolvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,documentPaths: freezed == documentPaths ? _self._documentPaths : documentPaths // ignore: cast_nullable_to_non_nullable
as List<String>?,reportedByUserId: null == reportedByUserId ? _self.reportedByUserId : reportedByUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
