// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'communication_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunicationLog {

 String get id; CommunicationChannel get channel; String get templateCode; String get subject; String get body; List<String> get recipientEmployeeIds; String get sentByUserId; int get deliveredCount; int get failedCount; DateTime get sentAt;
/// Create a copy of CommunicationLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunicationLogCopyWith<CommunicationLog> get copyWith => _$CommunicationLogCopyWithImpl<CommunicationLog>(this as CommunicationLog, _$identity);

  /// Serializes this CommunicationLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunicationLog&&(identical(other.id, id) || other.id == id)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.templateCode, templateCode) || other.templateCode == templateCode)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.recipientEmployeeIds, recipientEmployeeIds)&&(identical(other.sentByUserId, sentByUserId) || other.sentByUserId == sentByUserId)&&(identical(other.deliveredCount, deliveredCount) || other.deliveredCount == deliveredCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channel,templateCode,subject,body,const DeepCollectionEquality().hash(recipientEmployeeIds),sentByUserId,deliveredCount,failedCount,sentAt);

@override
String toString() {
  return 'CommunicationLog(id: $id, channel: $channel, templateCode: $templateCode, subject: $subject, body: $body, recipientEmployeeIds: $recipientEmployeeIds, sentByUserId: $sentByUserId, deliveredCount: $deliveredCount, failedCount: $failedCount, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class $CommunicationLogCopyWith<$Res>  {
  factory $CommunicationLogCopyWith(CommunicationLog value, $Res Function(CommunicationLog) _then) = _$CommunicationLogCopyWithImpl;
@useResult
$Res call({
 String id, CommunicationChannel channel, String templateCode, String subject, String body, List<String> recipientEmployeeIds, String sentByUserId, int deliveredCount, int failedCount, DateTime sentAt
});




}
/// @nodoc
class _$CommunicationLogCopyWithImpl<$Res>
    implements $CommunicationLogCopyWith<$Res> {
  _$CommunicationLogCopyWithImpl(this._self, this._then);

  final CommunicationLog _self;
  final $Res Function(CommunicationLog) _then;

/// Create a copy of CommunicationLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? channel = null,Object? templateCode = null,Object? subject = null,Object? body = null,Object? recipientEmployeeIds = null,Object? sentByUserId = null,Object? deliveredCount = null,Object? failedCount = null,Object? sentAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as CommunicationChannel,templateCode: null == templateCode ? _self.templateCode : templateCode // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,recipientEmployeeIds: null == recipientEmployeeIds ? _self.recipientEmployeeIds : recipientEmployeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,sentByUserId: null == sentByUserId ? _self.sentByUserId : sentByUserId // ignore: cast_nullable_to_non_nullable
as String,deliveredCount: null == deliveredCount ? _self.deliveredCount : deliveredCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunicationLog].
extension CommunicationLogPatterns on CommunicationLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunicationLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunicationLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunicationLog value)  $default,){
final _that = this;
switch (_that) {
case _CommunicationLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunicationLog value)?  $default,){
final _that = this;
switch (_that) {
case _CommunicationLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CommunicationChannel channel,  String templateCode,  String subject,  String body,  List<String> recipientEmployeeIds,  String sentByUserId,  int deliveredCount,  int failedCount,  DateTime sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunicationLog() when $default != null:
return $default(_that.id,_that.channel,_that.templateCode,_that.subject,_that.body,_that.recipientEmployeeIds,_that.sentByUserId,_that.deliveredCount,_that.failedCount,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CommunicationChannel channel,  String templateCode,  String subject,  String body,  List<String> recipientEmployeeIds,  String sentByUserId,  int deliveredCount,  int failedCount,  DateTime sentAt)  $default,) {final _that = this;
switch (_that) {
case _CommunicationLog():
return $default(_that.id,_that.channel,_that.templateCode,_that.subject,_that.body,_that.recipientEmployeeIds,_that.sentByUserId,_that.deliveredCount,_that.failedCount,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CommunicationChannel channel,  String templateCode,  String subject,  String body,  List<String> recipientEmployeeIds,  String sentByUserId,  int deliveredCount,  int failedCount,  DateTime sentAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunicationLog() when $default != null:
return $default(_that.id,_that.channel,_that.templateCode,_that.subject,_that.body,_that.recipientEmployeeIds,_that.sentByUserId,_that.deliveredCount,_that.failedCount,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunicationLog extends CommunicationLog {
  const _CommunicationLog({required this.id, required this.channel, required this.templateCode, required this.subject, required this.body, required final  List<String> recipientEmployeeIds, required this.sentByUserId, required this.deliveredCount, required this.failedCount, required this.sentAt}): _recipientEmployeeIds = recipientEmployeeIds,super._();
  factory _CommunicationLog.fromJson(Map<String, dynamic> json) => _$CommunicationLogFromJson(json);

@override final  String id;
@override final  CommunicationChannel channel;
@override final  String templateCode;
@override final  String subject;
@override final  String body;
 final  List<String> _recipientEmployeeIds;
@override List<String> get recipientEmployeeIds {
  if (_recipientEmployeeIds is EqualUnmodifiableListView) return _recipientEmployeeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipientEmployeeIds);
}

@override final  String sentByUserId;
@override final  int deliveredCount;
@override final  int failedCount;
@override final  DateTime sentAt;

/// Create a copy of CommunicationLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunicationLogCopyWith<_CommunicationLog> get copyWith => __$CommunicationLogCopyWithImpl<_CommunicationLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunicationLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunicationLog&&(identical(other.id, id) || other.id == id)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.templateCode, templateCode) || other.templateCode == templateCode)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._recipientEmployeeIds, _recipientEmployeeIds)&&(identical(other.sentByUserId, sentByUserId) || other.sentByUserId == sentByUserId)&&(identical(other.deliveredCount, deliveredCount) || other.deliveredCount == deliveredCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,channel,templateCode,subject,body,const DeepCollectionEquality().hash(_recipientEmployeeIds),sentByUserId,deliveredCount,failedCount,sentAt);

@override
String toString() {
  return 'CommunicationLog(id: $id, channel: $channel, templateCode: $templateCode, subject: $subject, body: $body, recipientEmployeeIds: $recipientEmployeeIds, sentByUserId: $sentByUserId, deliveredCount: $deliveredCount, failedCount: $failedCount, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$CommunicationLogCopyWith<$Res> implements $CommunicationLogCopyWith<$Res> {
  factory _$CommunicationLogCopyWith(_CommunicationLog value, $Res Function(_CommunicationLog) _then) = __$CommunicationLogCopyWithImpl;
@override @useResult
$Res call({
 String id, CommunicationChannel channel, String templateCode, String subject, String body, List<String> recipientEmployeeIds, String sentByUserId, int deliveredCount, int failedCount, DateTime sentAt
});




}
/// @nodoc
class __$CommunicationLogCopyWithImpl<$Res>
    implements _$CommunicationLogCopyWith<$Res> {
  __$CommunicationLogCopyWithImpl(this._self, this._then);

  final _CommunicationLog _self;
  final $Res Function(_CommunicationLog) _then;

/// Create a copy of CommunicationLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? channel = null,Object? templateCode = null,Object? subject = null,Object? body = null,Object? recipientEmployeeIds = null,Object? sentByUserId = null,Object? deliveredCount = null,Object? failedCount = null,Object? sentAt = null,}) {
  return _then(_CommunicationLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as CommunicationChannel,templateCode: null == templateCode ? _self.templateCode : templateCode // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,recipientEmployeeIds: null == recipientEmployeeIds ? _self._recipientEmployeeIds : recipientEmployeeIds // ignore: cast_nullable_to_non_nullable
as List<String>,sentByUserId: null == sentByUserId ? _self.sentByUserId : sentByUserId // ignore: cast_nullable_to_non_nullable
as String,deliveredCount: null == deliveredCount ? _self.deliveredCount : deliveredCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
