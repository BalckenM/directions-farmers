// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compliance_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComplianceAlert {

 String get id; String get code; String get title; String get description; ComplianceSeverity get severity; String? get employeeId; String? get payRunId; bool get isResolved; String? get resolvedByUserId; DateTime? get resolvedAt; String? get resolution; DateTime get raisedAt;
/// Create a copy of ComplianceAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplianceAlertCopyWith<ComplianceAlert> get copyWith => _$ComplianceAlertCopyWithImpl<ComplianceAlert>(this as ComplianceAlert, _$identity);

  /// Serializes this ComplianceAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplianceAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.payRunId, payRunId) || other.payRunId == payRunId)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved)&&(identical(other.resolvedByUserId, resolvedByUserId) || other.resolvedByUserId == resolvedByUserId)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.raisedAt, raisedAt) || other.raisedAt == raisedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,title,description,severity,employeeId,payRunId,isResolved,resolvedByUserId,resolvedAt,resolution,raisedAt);

@override
String toString() {
  return 'ComplianceAlert(id: $id, code: $code, title: $title, description: $description, severity: $severity, employeeId: $employeeId, payRunId: $payRunId, isResolved: $isResolved, resolvedByUserId: $resolvedByUserId, resolvedAt: $resolvedAt, resolution: $resolution, raisedAt: $raisedAt)';
}


}

/// @nodoc
abstract mixin class $ComplianceAlertCopyWith<$Res>  {
  factory $ComplianceAlertCopyWith(ComplianceAlert value, $Res Function(ComplianceAlert) _then) = _$ComplianceAlertCopyWithImpl;
@useResult
$Res call({
 String id, String code, String title, String description, ComplianceSeverity severity, String? employeeId, String? payRunId, bool isResolved, String? resolvedByUserId, DateTime? resolvedAt, String? resolution, DateTime raisedAt
});




}
/// @nodoc
class _$ComplianceAlertCopyWithImpl<$Res>
    implements $ComplianceAlertCopyWith<$Res> {
  _$ComplianceAlertCopyWithImpl(this._self, this._then);

  final ComplianceAlert _self;
  final $Res Function(ComplianceAlert) _then;

/// Create a copy of ComplianceAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? title = null,Object? description = null,Object? severity = null,Object? employeeId = freezed,Object? payRunId = freezed,Object? isResolved = null,Object? resolvedByUserId = freezed,Object? resolvedAt = freezed,Object? resolution = freezed,Object? raisedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as ComplianceSeverity,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,payRunId: freezed == payRunId ? _self.payRunId : payRunId // ignore: cast_nullable_to_non_nullable
as String?,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,resolvedByUserId: freezed == resolvedByUserId ? _self.resolvedByUserId : resolvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,raisedAt: null == raisedAt ? _self.raisedAt : raisedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplianceAlert].
extension ComplianceAlertPatterns on ComplianceAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplianceAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplianceAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplianceAlert value)  $default,){
final _that = this;
switch (_that) {
case _ComplianceAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplianceAlert value)?  $default,){
final _that = this;
switch (_that) {
case _ComplianceAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String title,  String description,  ComplianceSeverity severity,  String? employeeId,  String? payRunId,  bool isResolved,  String? resolvedByUserId,  DateTime? resolvedAt,  String? resolution,  DateTime raisedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplianceAlert() when $default != null:
return $default(_that.id,_that.code,_that.title,_that.description,_that.severity,_that.employeeId,_that.payRunId,_that.isResolved,_that.resolvedByUserId,_that.resolvedAt,_that.resolution,_that.raisedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String title,  String description,  ComplianceSeverity severity,  String? employeeId,  String? payRunId,  bool isResolved,  String? resolvedByUserId,  DateTime? resolvedAt,  String? resolution,  DateTime raisedAt)  $default,) {final _that = this;
switch (_that) {
case _ComplianceAlert():
return $default(_that.id,_that.code,_that.title,_that.description,_that.severity,_that.employeeId,_that.payRunId,_that.isResolved,_that.resolvedByUserId,_that.resolvedAt,_that.resolution,_that.raisedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String title,  String description,  ComplianceSeverity severity,  String? employeeId,  String? payRunId,  bool isResolved,  String? resolvedByUserId,  DateTime? resolvedAt,  String? resolution,  DateTime raisedAt)?  $default,) {final _that = this;
switch (_that) {
case _ComplianceAlert() when $default != null:
return $default(_that.id,_that.code,_that.title,_that.description,_that.severity,_that.employeeId,_that.payRunId,_that.isResolved,_that.resolvedByUserId,_that.resolvedAt,_that.resolution,_that.raisedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplianceAlert extends ComplianceAlert {
  const _ComplianceAlert({required this.id, required this.code, required this.title, required this.description, required this.severity, this.employeeId, this.payRunId, required this.isResolved, this.resolvedByUserId, this.resolvedAt, this.resolution, required this.raisedAt}): super._();
  factory _ComplianceAlert.fromJson(Map<String, dynamic> json) => _$ComplianceAlertFromJson(json);

@override final  String id;
@override final  String code;
@override final  String title;
@override final  String description;
@override final  ComplianceSeverity severity;
@override final  String? employeeId;
@override final  String? payRunId;
@override final  bool isResolved;
@override final  String? resolvedByUserId;
@override final  DateTime? resolvedAt;
@override final  String? resolution;
@override final  DateTime raisedAt;

/// Create a copy of ComplianceAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplianceAlertCopyWith<_ComplianceAlert> get copyWith => __$ComplianceAlertCopyWithImpl<_ComplianceAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplianceAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplianceAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.payRunId, payRunId) || other.payRunId == payRunId)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved)&&(identical(other.resolvedByUserId, resolvedByUserId) || other.resolvedByUserId == resolvedByUserId)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.raisedAt, raisedAt) || other.raisedAt == raisedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,title,description,severity,employeeId,payRunId,isResolved,resolvedByUserId,resolvedAt,resolution,raisedAt);

@override
String toString() {
  return 'ComplianceAlert(id: $id, code: $code, title: $title, description: $description, severity: $severity, employeeId: $employeeId, payRunId: $payRunId, isResolved: $isResolved, resolvedByUserId: $resolvedByUserId, resolvedAt: $resolvedAt, resolution: $resolution, raisedAt: $raisedAt)';
}


}

/// @nodoc
abstract mixin class _$ComplianceAlertCopyWith<$Res> implements $ComplianceAlertCopyWith<$Res> {
  factory _$ComplianceAlertCopyWith(_ComplianceAlert value, $Res Function(_ComplianceAlert) _then) = __$ComplianceAlertCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String title, String description, ComplianceSeverity severity, String? employeeId, String? payRunId, bool isResolved, String? resolvedByUserId, DateTime? resolvedAt, String? resolution, DateTime raisedAt
});




}
/// @nodoc
class __$ComplianceAlertCopyWithImpl<$Res>
    implements _$ComplianceAlertCopyWith<$Res> {
  __$ComplianceAlertCopyWithImpl(this._self, this._then);

  final _ComplianceAlert _self;
  final $Res Function(_ComplianceAlert) _then;

/// Create a copy of ComplianceAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? title = null,Object? description = null,Object? severity = null,Object? employeeId = freezed,Object? payRunId = freezed,Object? isResolved = null,Object? resolvedByUserId = freezed,Object? resolvedAt = freezed,Object? resolution = freezed,Object? raisedAt = null,}) {
  return _then(_ComplianceAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as ComplianceSeverity,employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String?,payRunId: freezed == payRunId ? _self.payRunId : payRunId // ignore: cast_nullable_to_non_nullable
as String?,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,resolvedByUserId: freezed == resolvedByUserId ? _self.resolvedByUserId : resolvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,raisedAt: null == raisedAt ? _self.raisedAt : raisedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
