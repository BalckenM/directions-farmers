// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pay_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayGroup {

 String get id; String get name; PayFrequency get frequency; int get payDayOffset; String? get description; bool get isActive; DateTime get createdAt;
/// Create a copy of PayGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayGroupCopyWith<PayGroup> get copyWith => _$PayGroupCopyWithImpl<PayGroup>(this as PayGroup, _$identity);

  /// Serializes this PayGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.payDayOffset, payDayOffset) || other.payDayOffset == payDayOffset)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,frequency,payDayOffset,description,isActive,createdAt);

@override
String toString() {
  return 'PayGroup(id: $id, name: $name, frequency: $frequency, payDayOffset: $payDayOffset, description: $description, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PayGroupCopyWith<$Res>  {
  factory $PayGroupCopyWith(PayGroup value, $Res Function(PayGroup) _then) = _$PayGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, PayFrequency frequency, int payDayOffset, String? description, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$PayGroupCopyWithImpl<$Res>
    implements $PayGroupCopyWith<$Res> {
  _$PayGroupCopyWithImpl(this._self, this._then);

  final PayGroup _self;
  final $Res Function(PayGroup) _then;

/// Create a copy of PayGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? frequency = null,Object? payDayOffset = null,Object? description = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PayFrequency,payDayOffset: null == payDayOffset ? _self.payDayOffset : payDayOffset // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PayGroup].
extension PayGroupPatterns on PayGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayGroup value)  $default,){
final _that = this;
switch (_that) {
case _PayGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayGroup value)?  $default,){
final _that = this;
switch (_that) {
case _PayGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  PayFrequency frequency,  int payDayOffset,  String? description,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayGroup() when $default != null:
return $default(_that.id,_that.name,_that.frequency,_that.payDayOffset,_that.description,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  PayFrequency frequency,  int payDayOffset,  String? description,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PayGroup():
return $default(_that.id,_that.name,_that.frequency,_that.payDayOffset,_that.description,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  PayFrequency frequency,  int payDayOffset,  String? description,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PayGroup() when $default != null:
return $default(_that.id,_that.name,_that.frequency,_that.payDayOffset,_that.description,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayGroup extends PayGroup {
  const _PayGroup({required this.id, required this.name, required this.frequency, required this.payDayOffset, this.description, required this.isActive, required this.createdAt}): super._();
  factory _PayGroup.fromJson(Map<String, dynamic> json) => _$PayGroupFromJson(json);

@override final  String id;
@override final  String name;
@override final  PayFrequency frequency;
@override final  int payDayOffset;
@override final  String? description;
@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of PayGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayGroupCopyWith<_PayGroup> get copyWith => __$PayGroupCopyWithImpl<_PayGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.payDayOffset, payDayOffset) || other.payDayOffset == payDayOffset)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,frequency,payDayOffset,description,isActive,createdAt);

@override
String toString() {
  return 'PayGroup(id: $id, name: $name, frequency: $frequency, payDayOffset: $payDayOffset, description: $description, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PayGroupCopyWith<$Res> implements $PayGroupCopyWith<$Res> {
  factory _$PayGroupCopyWith(_PayGroup value, $Res Function(_PayGroup) _then) = __$PayGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, PayFrequency frequency, int payDayOffset, String? description, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$PayGroupCopyWithImpl<$Res>
    implements _$PayGroupCopyWith<$Res> {
  __$PayGroupCopyWithImpl(this._self, this._then);

  final _PayGroup _self;
  final $Res Function(_PayGroup) _then;

/// Create a copy of PayGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? frequency = null,Object? payDayOffset = null,Object? description = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_PayGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PayFrequency,payDayOffset: null == payDayOffset ? _self.payDayOffset : payDayOffset // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
