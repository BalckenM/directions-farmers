// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaveRequest {

 String get id; String get employeeId; String get leaveTypeId; DateTime get startDate; DateTime get endDate; double get daysRequested; String get reason; LeaveStatus get status; String? get reviewedByUserId; DateTime? get reviewedAt; String? get rejectionReason; DateTime get submittedAt;
/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveRequestCopyWith<LeaveRequest> get copyWith => _$LeaveRequestCopyWithImpl<LeaveRequest>(this as LeaveRequest, _$identity);

  /// Serializes this LeaveRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysRequested, daysRequested) || other.daysRequested == daysRequested)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedByUserId, reviewedByUserId) || other.reviewedByUserId == reviewedByUserId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,leaveTypeId,startDate,endDate,daysRequested,reason,status,reviewedByUserId,reviewedAt,rejectionReason,submittedAt);

@override
String toString() {
  return 'LeaveRequest(id: $id, employeeId: $employeeId, leaveTypeId: $leaveTypeId, startDate: $startDate, endDate: $endDate, daysRequested: $daysRequested, reason: $reason, status: $status, reviewedByUserId: $reviewedByUserId, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class $LeaveRequestCopyWith<$Res>  {
  factory $LeaveRequestCopyWith(LeaveRequest value, $Res Function(LeaveRequest) _then) = _$LeaveRequestCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, String leaveTypeId, DateTime startDate, DateTime endDate, double daysRequested, String reason, LeaveStatus status, String? reviewedByUserId, DateTime? reviewedAt, String? rejectionReason, DateTime submittedAt
});




}
/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._self, this._then);

  final LeaveRequest _self;
  final $Res Function(LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? leaveTypeId = null,Object? startDate = null,Object? endDate = null,Object? daysRequested = null,Object? reason = null,Object? status = null,Object? reviewedByUserId = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,Object? submittedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,daysRequested: null == daysRequested ? _self.daysRequested : daysRequested // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeaveStatus,reviewedByUserId: freezed == reviewedByUserId ? _self.reviewedByUserId : reviewedByUserId // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveRequest].
extension LeaveRequestPatterns on LeaveRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveRequest value)  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  String leaveTypeId,  DateTime startDate,  DateTime endDate,  double daysRequested,  String reason,  LeaveStatus status,  String? reviewedByUserId,  DateTime? reviewedAt,  String? rejectionReason,  DateTime submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.employeeId,_that.leaveTypeId,_that.startDate,_that.endDate,_that.daysRequested,_that.reason,_that.status,_that.reviewedByUserId,_that.reviewedAt,_that.rejectionReason,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  String leaveTypeId,  DateTime startDate,  DateTime endDate,  double daysRequested,  String reason,  LeaveStatus status,  String? reviewedByUserId,  DateTime? reviewedAt,  String? rejectionReason,  DateTime submittedAt)  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest():
return $default(_that.id,_that.employeeId,_that.leaveTypeId,_that.startDate,_that.endDate,_that.daysRequested,_that.reason,_that.status,_that.reviewedByUserId,_that.reviewedAt,_that.rejectionReason,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  String leaveTypeId,  DateTime startDate,  DateTime endDate,  double daysRequested,  String reason,  LeaveStatus status,  String? reviewedByUserId,  DateTime? reviewedAt,  String? rejectionReason,  DateTime submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.employeeId,_that.leaveTypeId,_that.startDate,_that.endDate,_that.daysRequested,_that.reason,_that.status,_that.reviewedByUserId,_that.reviewedAt,_that.rejectionReason,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaveRequest extends LeaveRequest {
  const _LeaveRequest({required this.id, required this.employeeId, required this.leaveTypeId, required this.startDate, required this.endDate, required this.daysRequested, required this.reason, required this.status, this.reviewedByUserId, this.reviewedAt, this.rejectionReason, required this.submittedAt}): super._();
  factory _LeaveRequest.fromJson(Map<String, dynamic> json) => _$LeaveRequestFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  String leaveTypeId;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  double daysRequested;
@override final  String reason;
@override final  LeaveStatus status;
@override final  String? reviewedByUserId;
@override final  DateTime? reviewedAt;
@override final  String? rejectionReason;
@override final  DateTime submittedAt;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveRequestCopyWith<_LeaveRequest> get copyWith => __$LeaveRequestCopyWithImpl<_LeaveRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaveRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.leaveTypeId, leaveTypeId) || other.leaveTypeId == leaveTypeId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.daysRequested, daysRequested) || other.daysRequested == daysRequested)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedByUserId, reviewedByUserId) || other.reviewedByUserId == reviewedByUserId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,leaveTypeId,startDate,endDate,daysRequested,reason,status,reviewedByUserId,reviewedAt,rejectionReason,submittedAt);

@override
String toString() {
  return 'LeaveRequest(id: $id, employeeId: $employeeId, leaveTypeId: $leaveTypeId, startDate: $startDate, endDate: $endDate, daysRequested: $daysRequested, reason: $reason, status: $status, reviewedByUserId: $reviewedByUserId, reviewedAt: $reviewedAt, rejectionReason: $rejectionReason, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$LeaveRequestCopyWith<$Res> implements $LeaveRequestCopyWith<$Res> {
  factory _$LeaveRequestCopyWith(_LeaveRequest value, $Res Function(_LeaveRequest) _then) = __$LeaveRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, String leaveTypeId, DateTime startDate, DateTime endDate, double daysRequested, String reason, LeaveStatus status, String? reviewedByUserId, DateTime? reviewedAt, String? rejectionReason, DateTime submittedAt
});




}
/// @nodoc
class __$LeaveRequestCopyWithImpl<$Res>
    implements _$LeaveRequestCopyWith<$Res> {
  __$LeaveRequestCopyWithImpl(this._self, this._then);

  final _LeaveRequest _self;
  final $Res Function(_LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? leaveTypeId = null,Object? startDate = null,Object? endDate = null,Object? daysRequested = null,Object? reason = null,Object? status = null,Object? reviewedByUserId = freezed,Object? reviewedAt = freezed,Object? rejectionReason = freezed,Object? submittedAt = null,}) {
  return _then(_LeaveRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,leaveTypeId: null == leaveTypeId ? _self.leaveTypeId : leaveTypeId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,daysRequested: null == daysRequested ? _self.daysRequested : daysRequested // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeaveStatus,reviewedByUserId: freezed == reviewedByUserId ? _self.reviewedByUserId : reviewedByUserId // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
