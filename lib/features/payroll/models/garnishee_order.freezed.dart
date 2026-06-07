// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'garnishee_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GarnisheeOrder {

 String get id; String get employeeId; String get courtOrderRef; String get creditorName; double get monthlyDeductionAmount; double get totalOwed; double get amountDeducted; GarnisheeStatus get status; DateTime get createdAt; DateTime? get satisfiedAt; String? get notes;
/// Create a copy of GarnisheeOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GarnisheeOrderCopyWith<GarnisheeOrder> get copyWith => _$GarnisheeOrderCopyWithImpl<GarnisheeOrder>(this as GarnisheeOrder, _$identity);

  /// Serializes this GarnisheeOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GarnisheeOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.courtOrderRef, courtOrderRef) || other.courtOrderRef == courtOrderRef)&&(identical(other.creditorName, creditorName) || other.creditorName == creditorName)&&(identical(other.monthlyDeductionAmount, monthlyDeductionAmount) || other.monthlyDeductionAmount == monthlyDeductionAmount)&&(identical(other.totalOwed, totalOwed) || other.totalOwed == totalOwed)&&(identical(other.amountDeducted, amountDeducted) || other.amountDeducted == amountDeducted)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.satisfiedAt, satisfiedAt) || other.satisfiedAt == satisfiedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,courtOrderRef,creditorName,monthlyDeductionAmount,totalOwed,amountDeducted,status,createdAt,satisfiedAt,notes);

@override
String toString() {
  return 'GarnisheeOrder(id: $id, employeeId: $employeeId, courtOrderRef: $courtOrderRef, creditorName: $creditorName, monthlyDeductionAmount: $monthlyDeductionAmount, totalOwed: $totalOwed, amountDeducted: $amountDeducted, status: $status, createdAt: $createdAt, satisfiedAt: $satisfiedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $GarnisheeOrderCopyWith<$Res>  {
  factory $GarnisheeOrderCopyWith(GarnisheeOrder value, $Res Function(GarnisheeOrder) _then) = _$GarnisheeOrderCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, String courtOrderRef, String creditorName, double monthlyDeductionAmount, double totalOwed, double amountDeducted, GarnisheeStatus status, DateTime createdAt, DateTime? satisfiedAt, String? notes
});




}
/// @nodoc
class _$GarnisheeOrderCopyWithImpl<$Res>
    implements $GarnisheeOrderCopyWith<$Res> {
  _$GarnisheeOrderCopyWithImpl(this._self, this._then);

  final GarnisheeOrder _self;
  final $Res Function(GarnisheeOrder) _then;

/// Create a copy of GarnisheeOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? courtOrderRef = null,Object? creditorName = null,Object? monthlyDeductionAmount = null,Object? totalOwed = null,Object? amountDeducted = null,Object? status = null,Object? createdAt = null,Object? satisfiedAt = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,courtOrderRef: null == courtOrderRef ? _self.courtOrderRef : courtOrderRef // ignore: cast_nullable_to_non_nullable
as String,creditorName: null == creditorName ? _self.creditorName : creditorName // ignore: cast_nullable_to_non_nullable
as String,monthlyDeductionAmount: null == monthlyDeductionAmount ? _self.monthlyDeductionAmount : monthlyDeductionAmount // ignore: cast_nullable_to_non_nullable
as double,totalOwed: null == totalOwed ? _self.totalOwed : totalOwed // ignore: cast_nullable_to_non_nullable
as double,amountDeducted: null == amountDeducted ? _self.amountDeducted : amountDeducted // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GarnisheeStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,satisfiedAt: freezed == satisfiedAt ? _self.satisfiedAt : satisfiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GarnisheeOrder].
extension GarnisheeOrderPatterns on GarnisheeOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GarnisheeOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GarnisheeOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GarnisheeOrder value)  $default,){
final _that = this;
switch (_that) {
case _GarnisheeOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GarnisheeOrder value)?  $default,){
final _that = this;
switch (_that) {
case _GarnisheeOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  String courtOrderRef,  String creditorName,  double monthlyDeductionAmount,  double totalOwed,  double amountDeducted,  GarnisheeStatus status,  DateTime createdAt,  DateTime? satisfiedAt,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GarnisheeOrder() when $default != null:
return $default(_that.id,_that.employeeId,_that.courtOrderRef,_that.creditorName,_that.monthlyDeductionAmount,_that.totalOwed,_that.amountDeducted,_that.status,_that.createdAt,_that.satisfiedAt,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  String courtOrderRef,  String creditorName,  double monthlyDeductionAmount,  double totalOwed,  double amountDeducted,  GarnisheeStatus status,  DateTime createdAt,  DateTime? satisfiedAt,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _GarnisheeOrder():
return $default(_that.id,_that.employeeId,_that.courtOrderRef,_that.creditorName,_that.monthlyDeductionAmount,_that.totalOwed,_that.amountDeducted,_that.status,_that.createdAt,_that.satisfiedAt,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  String courtOrderRef,  String creditorName,  double monthlyDeductionAmount,  double totalOwed,  double amountDeducted,  GarnisheeStatus status,  DateTime createdAt,  DateTime? satisfiedAt,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _GarnisheeOrder() when $default != null:
return $default(_that.id,_that.employeeId,_that.courtOrderRef,_that.creditorName,_that.monthlyDeductionAmount,_that.totalOwed,_that.amountDeducted,_that.status,_that.createdAt,_that.satisfiedAt,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GarnisheeOrder extends GarnisheeOrder {
  const _GarnisheeOrder({required this.id, required this.employeeId, required this.courtOrderRef, required this.creditorName, required this.monthlyDeductionAmount, required this.totalOwed, required this.amountDeducted, required this.status, required this.createdAt, this.satisfiedAt, this.notes}): super._();
  factory _GarnisheeOrder.fromJson(Map<String, dynamic> json) => _$GarnisheeOrderFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  String courtOrderRef;
@override final  String creditorName;
@override final  double monthlyDeductionAmount;
@override final  double totalOwed;
@override final  double amountDeducted;
@override final  GarnisheeStatus status;
@override final  DateTime createdAt;
@override final  DateTime? satisfiedAt;
@override final  String? notes;

/// Create a copy of GarnisheeOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GarnisheeOrderCopyWith<_GarnisheeOrder> get copyWith => __$GarnisheeOrderCopyWithImpl<_GarnisheeOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GarnisheeOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GarnisheeOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.courtOrderRef, courtOrderRef) || other.courtOrderRef == courtOrderRef)&&(identical(other.creditorName, creditorName) || other.creditorName == creditorName)&&(identical(other.monthlyDeductionAmount, monthlyDeductionAmount) || other.monthlyDeductionAmount == monthlyDeductionAmount)&&(identical(other.totalOwed, totalOwed) || other.totalOwed == totalOwed)&&(identical(other.amountDeducted, amountDeducted) || other.amountDeducted == amountDeducted)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.satisfiedAt, satisfiedAt) || other.satisfiedAt == satisfiedAt)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,courtOrderRef,creditorName,monthlyDeductionAmount,totalOwed,amountDeducted,status,createdAt,satisfiedAt,notes);

@override
String toString() {
  return 'GarnisheeOrder(id: $id, employeeId: $employeeId, courtOrderRef: $courtOrderRef, creditorName: $creditorName, monthlyDeductionAmount: $monthlyDeductionAmount, totalOwed: $totalOwed, amountDeducted: $amountDeducted, status: $status, createdAt: $createdAt, satisfiedAt: $satisfiedAt, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$GarnisheeOrderCopyWith<$Res> implements $GarnisheeOrderCopyWith<$Res> {
  factory _$GarnisheeOrderCopyWith(_GarnisheeOrder value, $Res Function(_GarnisheeOrder) _then) = __$GarnisheeOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, String courtOrderRef, String creditorName, double monthlyDeductionAmount, double totalOwed, double amountDeducted, GarnisheeStatus status, DateTime createdAt, DateTime? satisfiedAt, String? notes
});




}
/// @nodoc
class __$GarnisheeOrderCopyWithImpl<$Res>
    implements _$GarnisheeOrderCopyWith<$Res> {
  __$GarnisheeOrderCopyWithImpl(this._self, this._then);

  final _GarnisheeOrder _self;
  final $Res Function(_GarnisheeOrder) _then;

/// Create a copy of GarnisheeOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? courtOrderRef = null,Object? creditorName = null,Object? monthlyDeductionAmount = null,Object? totalOwed = null,Object? amountDeducted = null,Object? status = null,Object? createdAt = null,Object? satisfiedAt = freezed,Object? notes = freezed,}) {
  return _then(_GarnisheeOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,courtOrderRef: null == courtOrderRef ? _self.courtOrderRef : courtOrderRef // ignore: cast_nullable_to_non_nullable
as String,creditorName: null == creditorName ? _self.creditorName : creditorName // ignore: cast_nullable_to_non_nullable
as String,monthlyDeductionAmount: null == monthlyDeductionAmount ? _self.monthlyDeductionAmount : monthlyDeductionAmount // ignore: cast_nullable_to_non_nullable
as double,totalOwed: null == totalOwed ? _self.totalOwed : totalOwed // ignore: cast_nullable_to_non_nullable
as double,amountDeducted: null == amountDeducted ? _self.amountDeducted : amountDeducted // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GarnisheeStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,satisfiedAt: freezed == satisfiedAt ? _self.satisfiedAt : satisfiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
