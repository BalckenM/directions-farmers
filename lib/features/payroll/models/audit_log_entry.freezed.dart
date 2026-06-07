// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLogEntry {

 String get id; String get entityType; String get entityId; String get action; String get changedByUserId; String get changedByName; Map<String, dynamic>? get beforeSnapshot; Map<String, dynamic>? get afterSnapshot; String? get description; DateTime get occurredAt;
/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryCopyWith<AuditLogEntry> get copyWith => _$AuditLogEntryCopyWithImpl<AuditLogEntry>(this as AuditLogEntry, _$identity);

  /// Serializes this AuditLogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.action, action) || other.action == action)&&(identical(other.changedByUserId, changedByUserId) || other.changedByUserId == changedByUserId)&&(identical(other.changedByName, changedByName) || other.changedByName == changedByName)&&const DeepCollectionEquality().equals(other.beforeSnapshot, beforeSnapshot)&&const DeepCollectionEquality().equals(other.afterSnapshot, afterSnapshot)&&(identical(other.description, description) || other.description == description)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityType,entityId,action,changedByUserId,changedByName,const DeepCollectionEquality().hash(beforeSnapshot),const DeepCollectionEquality().hash(afterSnapshot),description,occurredAt);

@override
String toString() {
  return 'AuditLogEntry(id: $id, entityType: $entityType, entityId: $entityId, action: $action, changedByUserId: $changedByUserId, changedByName: $changedByName, beforeSnapshot: $beforeSnapshot, afterSnapshot: $afterSnapshot, description: $description, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryCopyWith<$Res>  {
  factory $AuditLogEntryCopyWith(AuditLogEntry value, $Res Function(AuditLogEntry) _then) = _$AuditLogEntryCopyWithImpl;
@useResult
$Res call({
 String id, String entityType, String entityId, String action, String changedByUserId, String changedByName, Map<String, dynamic>? beforeSnapshot, Map<String, dynamic>? afterSnapshot, String? description, DateTime occurredAt
});




}
/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._self, this._then);

  final AuditLogEntry _self;
  final $Res Function(AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entityType = null,Object? entityId = null,Object? action = null,Object? changedByUserId = null,Object? changedByName = null,Object? beforeSnapshot = freezed,Object? afterSnapshot = freezed,Object? description = freezed,Object? occurredAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,changedByUserId: null == changedByUserId ? _self.changedByUserId : changedByUserId // ignore: cast_nullable_to_non_nullable
as String,changedByName: null == changedByName ? _self.changedByName : changedByName // ignore: cast_nullable_to_non_nullable
as String,beforeSnapshot: freezed == beforeSnapshot ? _self.beforeSnapshot : beforeSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,afterSnapshot: freezed == afterSnapshot ? _self.afterSnapshot : afterSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntry].
extension AuditLogEntryPatterns on AuditLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String entityType,  String entityId,  String action,  String changedByUserId,  String changedByName,  Map<String, dynamic>? beforeSnapshot,  Map<String, dynamic>? afterSnapshot,  String? description,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.entityType,_that.entityId,_that.action,_that.changedByUserId,_that.changedByName,_that.beforeSnapshot,_that.afterSnapshot,_that.description,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String entityType,  String entityId,  String action,  String changedByUserId,  String changedByName,  Map<String, dynamic>? beforeSnapshot,  Map<String, dynamic>? afterSnapshot,  String? description,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that.id,_that.entityType,_that.entityId,_that.action,_that.changedByUserId,_that.changedByName,_that.beforeSnapshot,_that.afterSnapshot,_that.description,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String entityType,  String entityId,  String action,  String changedByUserId,  String changedByName,  Map<String, dynamic>? beforeSnapshot,  Map<String, dynamic>? afterSnapshot,  String? description,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.entityType,_that.entityId,_that.action,_that.changedByUserId,_that.changedByName,_that.beforeSnapshot,_that.afterSnapshot,_that.description,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogEntry implements AuditLogEntry {
  const _AuditLogEntry({required this.id, required this.entityType, required this.entityId, required this.action, required this.changedByUserId, required this.changedByName, final  Map<String, dynamic>? beforeSnapshot, final  Map<String, dynamic>? afterSnapshot, this.description, required this.occurredAt}): _beforeSnapshot = beforeSnapshot,_afterSnapshot = afterSnapshot;
  factory _AuditLogEntry.fromJson(Map<String, dynamic> json) => _$AuditLogEntryFromJson(json);

@override final  String id;
@override final  String entityType;
@override final  String entityId;
@override final  String action;
@override final  String changedByUserId;
@override final  String changedByName;
 final  Map<String, dynamic>? _beforeSnapshot;
@override Map<String, dynamic>? get beforeSnapshot {
  final value = _beforeSnapshot;
  if (value == null) return null;
  if (_beforeSnapshot is EqualUnmodifiableMapView) return _beforeSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _afterSnapshot;
@override Map<String, dynamic>? get afterSnapshot {
  final value = _afterSnapshot;
  if (value == null) return null;
  if (_afterSnapshot is EqualUnmodifiableMapView) return _afterSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? description;
@override final  DateTime occurredAt;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryCopyWith<_AuditLogEntry> get copyWith => __$AuditLogEntryCopyWithImpl<_AuditLogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.action, action) || other.action == action)&&(identical(other.changedByUserId, changedByUserId) || other.changedByUserId == changedByUserId)&&(identical(other.changedByName, changedByName) || other.changedByName == changedByName)&&const DeepCollectionEquality().equals(other._beforeSnapshot, _beforeSnapshot)&&const DeepCollectionEquality().equals(other._afterSnapshot, _afterSnapshot)&&(identical(other.description, description) || other.description == description)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityType,entityId,action,changedByUserId,changedByName,const DeepCollectionEquality().hash(_beforeSnapshot),const DeepCollectionEquality().hash(_afterSnapshot),description,occurredAt);

@override
String toString() {
  return 'AuditLogEntry(id: $id, entityType: $entityType, entityId: $entityId, action: $action, changedByUserId: $changedByUserId, changedByName: $changedByName, beforeSnapshot: $beforeSnapshot, afterSnapshot: $afterSnapshot, description: $description, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryCopyWith<$Res> implements $AuditLogEntryCopyWith<$Res> {
  factory _$AuditLogEntryCopyWith(_AuditLogEntry value, $Res Function(_AuditLogEntry) _then) = __$AuditLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String entityType, String entityId, String action, String changedByUserId, String changedByName, Map<String, dynamic>? beforeSnapshot, Map<String, dynamic>? afterSnapshot, String? description, DateTime occurredAt
});




}
/// @nodoc
class __$AuditLogEntryCopyWithImpl<$Res>
    implements _$AuditLogEntryCopyWith<$Res> {
  __$AuditLogEntryCopyWithImpl(this._self, this._then);

  final _AuditLogEntry _self;
  final $Res Function(_AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entityType = null,Object? entityId = null,Object? action = null,Object? changedByUserId = null,Object? changedByName = null,Object? beforeSnapshot = freezed,Object? afterSnapshot = freezed,Object? description = freezed,Object? occurredAt = null,}) {
  return _then(_AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,changedByUserId: null == changedByUserId ? _self.changedByUserId : changedByUserId // ignore: cast_nullable_to_non_nullable
as String,changedByName: null == changedByName ? _self.changedByName : changedByName // ignore: cast_nullable_to_non_nullable
as String,beforeSnapshot: freezed == beforeSnapshot ? _self._beforeSnapshot : beforeSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,afterSnapshot: freezed == afterSnapshot ? _self._afterSnapshot : afterSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
