// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pay_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApprovalEntry {

 String get userId; String get displayName; String get role; DateTime get decidedAt; bool get approved; String? get comment;
/// Create a copy of ApprovalEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovalEntryCopyWith<ApprovalEntry> get copyWith => _$ApprovalEntryCopyWithImpl<ApprovalEntry>(this as ApprovalEntry, _$identity);

  /// Serializes this ApprovalEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovalEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,role,decidedAt,approved,comment);

@override
String toString() {
  return 'ApprovalEntry(userId: $userId, displayName: $displayName, role: $role, decidedAt: $decidedAt, approved: $approved, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $ApprovalEntryCopyWith<$Res>  {
  factory $ApprovalEntryCopyWith(ApprovalEntry value, $Res Function(ApprovalEntry) _then) = _$ApprovalEntryCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String role, DateTime decidedAt, bool approved, String? comment
});




}
/// @nodoc
class _$ApprovalEntryCopyWithImpl<$Res>
    implements $ApprovalEntryCopyWith<$Res> {
  _$ApprovalEntryCopyWithImpl(this._self, this._then);

  final ApprovalEntry _self;
  final $Res Function(ApprovalEntry) _then;

/// Create a copy of ApprovalEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? role = null,Object? decidedAt = null,Object? approved = null,Object? comment = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,decidedAt: null == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApprovalEntry].
extension ApprovalEntryPatterns on ApprovalEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApprovalEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApprovalEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApprovalEntry value)  $default,){
final _that = this;
switch (_that) {
case _ApprovalEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApprovalEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ApprovalEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String role,  DateTime decidedAt,  bool approved,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApprovalEntry() when $default != null:
return $default(_that.userId,_that.displayName,_that.role,_that.decidedAt,_that.approved,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String role,  DateTime decidedAt,  bool approved,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _ApprovalEntry():
return $default(_that.userId,_that.displayName,_that.role,_that.decidedAt,_that.approved,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String role,  DateTime decidedAt,  bool approved,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _ApprovalEntry() when $default != null:
return $default(_that.userId,_that.displayName,_that.role,_that.decidedAt,_that.approved,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApprovalEntry implements ApprovalEntry {
  const _ApprovalEntry({required this.userId, required this.displayName, required this.role, required this.decidedAt, required this.approved, this.comment});
  factory _ApprovalEntry.fromJson(Map<String, dynamic> json) => _$ApprovalEntryFromJson(json);

@override final  String userId;
@override final  String displayName;
@override final  String role;
@override final  DateTime decidedAt;
@override final  bool approved;
@override final  String? comment;

/// Create a copy of ApprovalEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApprovalEntryCopyWith<_ApprovalEntry> get copyWith => __$ApprovalEntryCopyWithImpl<_ApprovalEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApprovalEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApprovalEntry&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,role,decidedAt,approved,comment);

@override
String toString() {
  return 'ApprovalEntry(userId: $userId, displayName: $displayName, role: $role, decidedAt: $decidedAt, approved: $approved, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ApprovalEntryCopyWith<$Res> implements $ApprovalEntryCopyWith<$Res> {
  factory _$ApprovalEntryCopyWith(_ApprovalEntry value, $Res Function(_ApprovalEntry) _then) = __$ApprovalEntryCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String role, DateTime decidedAt, bool approved, String? comment
});




}
/// @nodoc
class __$ApprovalEntryCopyWithImpl<$Res>
    implements _$ApprovalEntryCopyWith<$Res> {
  __$ApprovalEntryCopyWithImpl(this._self, this._then);

  final _ApprovalEntry _self;
  final $Res Function(_ApprovalEntry) _then;

/// Create a copy of ApprovalEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? role = null,Object? decidedAt = null,Object? approved = null,Object? comment = freezed,}) {
  return _then(_ApprovalEntry(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,decidedAt: null == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PayslipLineItem {

 String get code; String get description; double get quantity; double get rate; double get amount; bool get isStatutory;
/// Create a copy of PayslipLineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayslipLineItemCopyWith<PayslipLineItem> get copyWith => _$PayslipLineItemCopyWithImpl<PayslipLineItem>(this as PayslipLineItem, _$identity);

  /// Serializes this PayslipLineItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayslipLineItem&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.isStatutory, isStatutory) || other.isStatutory == isStatutory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,description,quantity,rate,amount,isStatutory);

@override
String toString() {
  return 'PayslipLineItem(code: $code, description: $description, quantity: $quantity, rate: $rate, amount: $amount, isStatutory: $isStatutory)';
}


}

/// @nodoc
abstract mixin class $PayslipLineItemCopyWith<$Res>  {
  factory $PayslipLineItemCopyWith(PayslipLineItem value, $Res Function(PayslipLineItem) _then) = _$PayslipLineItemCopyWithImpl;
@useResult
$Res call({
 String code, String description, double quantity, double rate, double amount, bool isStatutory
});




}
/// @nodoc
class _$PayslipLineItemCopyWithImpl<$Res>
    implements $PayslipLineItemCopyWith<$Res> {
  _$PayslipLineItemCopyWithImpl(this._self, this._then);

  final PayslipLineItem _self;
  final $Res Function(PayslipLineItem) _then;

/// Create a copy of PayslipLineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? description = null,Object? quantity = null,Object? rate = null,Object? amount = null,Object? isStatutory = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,isStatutory: null == isStatutory ? _self.isStatutory : isStatutory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PayslipLineItem].
extension PayslipLineItemPatterns on PayslipLineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayslipLineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayslipLineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayslipLineItem value)  $default,){
final _that = this;
switch (_that) {
case _PayslipLineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayslipLineItem value)?  $default,){
final _that = this;
switch (_that) {
case _PayslipLineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String description,  double quantity,  double rate,  double amount,  bool isStatutory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayslipLineItem() when $default != null:
return $default(_that.code,_that.description,_that.quantity,_that.rate,_that.amount,_that.isStatutory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String description,  double quantity,  double rate,  double amount,  bool isStatutory)  $default,) {final _that = this;
switch (_that) {
case _PayslipLineItem():
return $default(_that.code,_that.description,_that.quantity,_that.rate,_that.amount,_that.isStatutory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String description,  double quantity,  double rate,  double amount,  bool isStatutory)?  $default,) {final _that = this;
switch (_that) {
case _PayslipLineItem() when $default != null:
return $default(_that.code,_that.description,_that.quantity,_that.rate,_that.amount,_that.isStatutory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayslipLineItem implements PayslipLineItem {
  const _PayslipLineItem({required this.code, required this.description, required this.quantity, required this.rate, required this.amount, this.isStatutory = false});
  factory _PayslipLineItem.fromJson(Map<String, dynamic> json) => _$PayslipLineItemFromJson(json);

@override final  String code;
@override final  String description;
@override final  double quantity;
@override final  double rate;
@override final  double amount;
@override@JsonKey() final  bool isStatutory;

/// Create a copy of PayslipLineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayslipLineItemCopyWith<_PayslipLineItem> get copyWith => __$PayslipLineItemCopyWithImpl<_PayslipLineItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayslipLineItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayslipLineItem&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.isStatutory, isStatutory) || other.isStatutory == isStatutory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,description,quantity,rate,amount,isStatutory);

@override
String toString() {
  return 'PayslipLineItem(code: $code, description: $description, quantity: $quantity, rate: $rate, amount: $amount, isStatutory: $isStatutory)';
}


}

/// @nodoc
abstract mixin class _$PayslipLineItemCopyWith<$Res> implements $PayslipLineItemCopyWith<$Res> {
  factory _$PayslipLineItemCopyWith(_PayslipLineItem value, $Res Function(_PayslipLineItem) _then) = __$PayslipLineItemCopyWithImpl;
@override @useResult
$Res call({
 String code, String description, double quantity, double rate, double amount, bool isStatutory
});




}
/// @nodoc
class __$PayslipLineItemCopyWithImpl<$Res>
    implements _$PayslipLineItemCopyWith<$Res> {
  __$PayslipLineItemCopyWithImpl(this._self, this._then);

  final _PayslipLineItem _self;
  final $Res Function(_PayslipLineItem) _then;

/// Create a copy of PayslipLineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? description = null,Object? quantity = null,Object? rate = null,Object? amount = null,Object? isStatutory = null,}) {
  return _then(_PayslipLineItem(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,isStatutory: null == isStatutory ? _self.isStatutory : isStatutory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PayRun {

 String get id; String get payGroupId; DateTime get periodStart; DateTime get periodEnd; DateTime get payDate; PayRunStatus get status; double get totalGross; double get totalDeductions; double get totalNet; int get employeeCount; String? get approvedByUserId; DateTime? get approvedAt; DateTime? get disbursedAt; String? get notes; List<String> get complianceAlertIds; List<PayslipLineItem> get lineItems; double get sdlContribution; double get etiCredit; double get totalCoidaContribution; List<ApprovalEntry> get approvalChain; int get requiredApprovers; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PayRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayRunCopyWith<PayRun> get copyWith => _$PayRunCopyWithImpl<PayRun>(this as PayRun, _$identity);

  /// Serializes this PayRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayRun&&(identical(other.id, id) || other.id == id)&&(identical(other.payGroupId, payGroupId) || other.payGroupId == payGroupId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.payDate, payDate) || other.payDate == payDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalGross, totalGross) || other.totalGross == totalGross)&&(identical(other.totalDeductions, totalDeductions) || other.totalDeductions == totalDeductions)&&(identical(other.totalNet, totalNet) || other.totalNet == totalNet)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.approvedByUserId, approvedByUserId) || other.approvedByUserId == approvedByUserId)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.disbursedAt, disbursedAt) || other.disbursedAt == disbursedAt)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.complianceAlertIds, complianceAlertIds)&&const DeepCollectionEquality().equals(other.lineItems, lineItems)&&(identical(other.sdlContribution, sdlContribution) || other.sdlContribution == sdlContribution)&&(identical(other.etiCredit, etiCredit) || other.etiCredit == etiCredit)&&(identical(other.totalCoidaContribution, totalCoidaContribution) || other.totalCoidaContribution == totalCoidaContribution)&&const DeepCollectionEquality().equals(other.approvalChain, approvalChain)&&(identical(other.requiredApprovers, requiredApprovers) || other.requiredApprovers == requiredApprovers)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,payGroupId,periodStart,periodEnd,payDate,status,totalGross,totalDeductions,totalNet,employeeCount,approvedByUserId,approvedAt,disbursedAt,notes,const DeepCollectionEquality().hash(complianceAlertIds),const DeepCollectionEquality().hash(lineItems),sdlContribution,etiCredit,totalCoidaContribution,const DeepCollectionEquality().hash(approvalChain),requiredApprovers,createdAt,updatedAt]);

@override
String toString() {
  return 'PayRun(id: $id, payGroupId: $payGroupId, periodStart: $periodStart, periodEnd: $periodEnd, payDate: $payDate, status: $status, totalGross: $totalGross, totalDeductions: $totalDeductions, totalNet: $totalNet, employeeCount: $employeeCount, approvedByUserId: $approvedByUserId, approvedAt: $approvedAt, disbursedAt: $disbursedAt, notes: $notes, complianceAlertIds: $complianceAlertIds, lineItems: $lineItems, sdlContribution: $sdlContribution, etiCredit: $etiCredit, totalCoidaContribution: $totalCoidaContribution, approvalChain: $approvalChain, requiredApprovers: $requiredApprovers, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PayRunCopyWith<$Res>  {
  factory $PayRunCopyWith(PayRun value, $Res Function(PayRun) _then) = _$PayRunCopyWithImpl;
@useResult
$Res call({
 String id, String payGroupId, DateTime periodStart, DateTime periodEnd, DateTime payDate, PayRunStatus status, double totalGross, double totalDeductions, double totalNet, int employeeCount, String? approvedByUserId, DateTime? approvedAt, DateTime? disbursedAt, String? notes, List<String> complianceAlertIds, List<PayslipLineItem> lineItems, double sdlContribution, double etiCredit, double totalCoidaContribution, List<ApprovalEntry> approvalChain, int requiredApprovers, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PayRunCopyWithImpl<$Res>
    implements $PayRunCopyWith<$Res> {
  _$PayRunCopyWithImpl(this._self, this._then);

  final PayRun _self;
  final $Res Function(PayRun) _then;

/// Create a copy of PayRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? payGroupId = null,Object? periodStart = null,Object? periodEnd = null,Object? payDate = null,Object? status = null,Object? totalGross = null,Object? totalDeductions = null,Object? totalNet = null,Object? employeeCount = null,Object? approvedByUserId = freezed,Object? approvedAt = freezed,Object? disbursedAt = freezed,Object? notes = freezed,Object? complianceAlertIds = null,Object? lineItems = null,Object? sdlContribution = null,Object? etiCredit = null,Object? totalCoidaContribution = null,Object? approvalChain = null,Object? requiredApprovers = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,payGroupId: null == payGroupId ? _self.payGroupId : payGroupId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,payDate: null == payDate ? _self.payDate : payDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayRunStatus,totalGross: null == totalGross ? _self.totalGross : totalGross // ignore: cast_nullable_to_non_nullable
as double,totalDeductions: null == totalDeductions ? _self.totalDeductions : totalDeductions // ignore: cast_nullable_to_non_nullable
as double,totalNet: null == totalNet ? _self.totalNet : totalNet // ignore: cast_nullable_to_non_nullable
as double,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,approvedByUserId: freezed == approvedByUserId ? _self.approvedByUserId : approvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disbursedAt: freezed == disbursedAt ? _self.disbursedAt : disbursedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,complianceAlertIds: null == complianceAlertIds ? _self.complianceAlertIds : complianceAlertIds // ignore: cast_nullable_to_non_nullable
as List<String>,lineItems: null == lineItems ? _self.lineItems : lineItems // ignore: cast_nullable_to_non_nullable
as List<PayslipLineItem>,sdlContribution: null == sdlContribution ? _self.sdlContribution : sdlContribution // ignore: cast_nullable_to_non_nullable
as double,etiCredit: null == etiCredit ? _self.etiCredit : etiCredit // ignore: cast_nullable_to_non_nullable
as double,totalCoidaContribution: null == totalCoidaContribution ? _self.totalCoidaContribution : totalCoidaContribution // ignore: cast_nullable_to_non_nullable
as double,approvalChain: null == approvalChain ? _self.approvalChain : approvalChain // ignore: cast_nullable_to_non_nullable
as List<ApprovalEntry>,requiredApprovers: null == requiredApprovers ? _self.requiredApprovers : requiredApprovers // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PayRun].
extension PayRunPatterns on PayRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayRun value)  $default,){
final _that = this;
switch (_that) {
case _PayRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayRun value)?  $default,){
final _that = this;
switch (_that) {
case _PayRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String payGroupId,  DateTime periodStart,  DateTime periodEnd,  DateTime payDate,  PayRunStatus status,  double totalGross,  double totalDeductions,  double totalNet,  int employeeCount,  String? approvedByUserId,  DateTime? approvedAt,  DateTime? disbursedAt,  String? notes,  List<String> complianceAlertIds,  List<PayslipLineItem> lineItems,  double sdlContribution,  double etiCredit,  double totalCoidaContribution,  List<ApprovalEntry> approvalChain,  int requiredApprovers,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayRun() when $default != null:
return $default(_that.id,_that.payGroupId,_that.periodStart,_that.periodEnd,_that.payDate,_that.status,_that.totalGross,_that.totalDeductions,_that.totalNet,_that.employeeCount,_that.approvedByUserId,_that.approvedAt,_that.disbursedAt,_that.notes,_that.complianceAlertIds,_that.lineItems,_that.sdlContribution,_that.etiCredit,_that.totalCoidaContribution,_that.approvalChain,_that.requiredApprovers,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String payGroupId,  DateTime periodStart,  DateTime periodEnd,  DateTime payDate,  PayRunStatus status,  double totalGross,  double totalDeductions,  double totalNet,  int employeeCount,  String? approvedByUserId,  DateTime? approvedAt,  DateTime? disbursedAt,  String? notes,  List<String> complianceAlertIds,  List<PayslipLineItem> lineItems,  double sdlContribution,  double etiCredit,  double totalCoidaContribution,  List<ApprovalEntry> approvalChain,  int requiredApprovers,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PayRun():
return $default(_that.id,_that.payGroupId,_that.periodStart,_that.periodEnd,_that.payDate,_that.status,_that.totalGross,_that.totalDeductions,_that.totalNet,_that.employeeCount,_that.approvedByUserId,_that.approvedAt,_that.disbursedAt,_that.notes,_that.complianceAlertIds,_that.lineItems,_that.sdlContribution,_that.etiCredit,_that.totalCoidaContribution,_that.approvalChain,_that.requiredApprovers,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String payGroupId,  DateTime periodStart,  DateTime periodEnd,  DateTime payDate,  PayRunStatus status,  double totalGross,  double totalDeductions,  double totalNet,  int employeeCount,  String? approvedByUserId,  DateTime? approvedAt,  DateTime? disbursedAt,  String? notes,  List<String> complianceAlertIds,  List<PayslipLineItem> lineItems,  double sdlContribution,  double etiCredit,  double totalCoidaContribution,  List<ApprovalEntry> approvalChain,  int requiredApprovers,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PayRun() when $default != null:
return $default(_that.id,_that.payGroupId,_that.periodStart,_that.periodEnd,_that.payDate,_that.status,_that.totalGross,_that.totalDeductions,_that.totalNet,_that.employeeCount,_that.approvedByUserId,_that.approvedAt,_that.disbursedAt,_that.notes,_that.complianceAlertIds,_that.lineItems,_that.sdlContribution,_that.etiCredit,_that.totalCoidaContribution,_that.approvalChain,_that.requiredApprovers,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayRun extends PayRun {
  const _PayRun({required this.id, required this.payGroupId, required this.periodStart, required this.periodEnd, required this.payDate, required this.status, required this.totalGross, required this.totalDeductions, required this.totalNet, required this.employeeCount, this.approvedByUserId, this.approvedAt, this.disbursedAt, this.notes, required final  List<String> complianceAlertIds, required final  List<PayslipLineItem> lineItems, this.sdlContribution = 0.0, this.etiCredit = 0.0, this.totalCoidaContribution = 0.0, final  List<ApprovalEntry> approvalChain = const [], this.requiredApprovers = 1, required this.createdAt, required this.updatedAt}): _complianceAlertIds = complianceAlertIds,_lineItems = lineItems,_approvalChain = approvalChain,super._();
  factory _PayRun.fromJson(Map<String, dynamic> json) => _$PayRunFromJson(json);

@override final  String id;
@override final  String payGroupId;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime payDate;
@override final  PayRunStatus status;
@override final  double totalGross;
@override final  double totalDeductions;
@override final  double totalNet;
@override final  int employeeCount;
@override final  String? approvedByUserId;
@override final  DateTime? approvedAt;
@override final  DateTime? disbursedAt;
@override final  String? notes;
 final  List<String> _complianceAlertIds;
@override List<String> get complianceAlertIds {
  if (_complianceAlertIds is EqualUnmodifiableListView) return _complianceAlertIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_complianceAlertIds);
}

 final  List<PayslipLineItem> _lineItems;
@override List<PayslipLineItem> get lineItems {
  if (_lineItems is EqualUnmodifiableListView) return _lineItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineItems);
}

@override@JsonKey() final  double sdlContribution;
@override@JsonKey() final  double etiCredit;
@override@JsonKey() final  double totalCoidaContribution;
 final  List<ApprovalEntry> _approvalChain;
@override@JsonKey() List<ApprovalEntry> get approvalChain {
  if (_approvalChain is EqualUnmodifiableListView) return _approvalChain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approvalChain);
}

@override@JsonKey() final  int requiredApprovers;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PayRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayRunCopyWith<_PayRun> get copyWith => __$PayRunCopyWithImpl<_PayRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayRun&&(identical(other.id, id) || other.id == id)&&(identical(other.payGroupId, payGroupId) || other.payGroupId == payGroupId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.payDate, payDate) || other.payDate == payDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalGross, totalGross) || other.totalGross == totalGross)&&(identical(other.totalDeductions, totalDeductions) || other.totalDeductions == totalDeductions)&&(identical(other.totalNet, totalNet) || other.totalNet == totalNet)&&(identical(other.employeeCount, employeeCount) || other.employeeCount == employeeCount)&&(identical(other.approvedByUserId, approvedByUserId) || other.approvedByUserId == approvedByUserId)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.disbursedAt, disbursedAt) || other.disbursedAt == disbursedAt)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._complianceAlertIds, _complianceAlertIds)&&const DeepCollectionEquality().equals(other._lineItems, _lineItems)&&(identical(other.sdlContribution, sdlContribution) || other.sdlContribution == sdlContribution)&&(identical(other.etiCredit, etiCredit) || other.etiCredit == etiCredit)&&(identical(other.totalCoidaContribution, totalCoidaContribution) || other.totalCoidaContribution == totalCoidaContribution)&&const DeepCollectionEquality().equals(other._approvalChain, _approvalChain)&&(identical(other.requiredApprovers, requiredApprovers) || other.requiredApprovers == requiredApprovers)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,payGroupId,periodStart,periodEnd,payDate,status,totalGross,totalDeductions,totalNet,employeeCount,approvedByUserId,approvedAt,disbursedAt,notes,const DeepCollectionEquality().hash(_complianceAlertIds),const DeepCollectionEquality().hash(_lineItems),sdlContribution,etiCredit,totalCoidaContribution,const DeepCollectionEquality().hash(_approvalChain),requiredApprovers,createdAt,updatedAt]);

@override
String toString() {
  return 'PayRun(id: $id, payGroupId: $payGroupId, periodStart: $periodStart, periodEnd: $periodEnd, payDate: $payDate, status: $status, totalGross: $totalGross, totalDeductions: $totalDeductions, totalNet: $totalNet, employeeCount: $employeeCount, approvedByUserId: $approvedByUserId, approvedAt: $approvedAt, disbursedAt: $disbursedAt, notes: $notes, complianceAlertIds: $complianceAlertIds, lineItems: $lineItems, sdlContribution: $sdlContribution, etiCredit: $etiCredit, totalCoidaContribution: $totalCoidaContribution, approvalChain: $approvalChain, requiredApprovers: $requiredApprovers, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayRunCopyWith<$Res> implements $PayRunCopyWith<$Res> {
  factory _$PayRunCopyWith(_PayRun value, $Res Function(_PayRun) _then) = __$PayRunCopyWithImpl;
@override @useResult
$Res call({
 String id, String payGroupId, DateTime periodStart, DateTime periodEnd, DateTime payDate, PayRunStatus status, double totalGross, double totalDeductions, double totalNet, int employeeCount, String? approvedByUserId, DateTime? approvedAt, DateTime? disbursedAt, String? notes, List<String> complianceAlertIds, List<PayslipLineItem> lineItems, double sdlContribution, double etiCredit, double totalCoidaContribution, List<ApprovalEntry> approvalChain, int requiredApprovers, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PayRunCopyWithImpl<$Res>
    implements _$PayRunCopyWith<$Res> {
  __$PayRunCopyWithImpl(this._self, this._then);

  final _PayRun _self;
  final $Res Function(_PayRun) _then;

/// Create a copy of PayRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? payGroupId = null,Object? periodStart = null,Object? periodEnd = null,Object? payDate = null,Object? status = null,Object? totalGross = null,Object? totalDeductions = null,Object? totalNet = null,Object? employeeCount = null,Object? approvedByUserId = freezed,Object? approvedAt = freezed,Object? disbursedAt = freezed,Object? notes = freezed,Object? complianceAlertIds = null,Object? lineItems = null,Object? sdlContribution = null,Object? etiCredit = null,Object? totalCoidaContribution = null,Object? approvalChain = null,Object? requiredApprovers = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PayRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,payGroupId: null == payGroupId ? _self.payGroupId : payGroupId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,payDate: null == payDate ? _self.payDate : payDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayRunStatus,totalGross: null == totalGross ? _self.totalGross : totalGross // ignore: cast_nullable_to_non_nullable
as double,totalDeductions: null == totalDeductions ? _self.totalDeductions : totalDeductions // ignore: cast_nullable_to_non_nullable
as double,totalNet: null == totalNet ? _self.totalNet : totalNet // ignore: cast_nullable_to_non_nullable
as double,employeeCount: null == employeeCount ? _self.employeeCount : employeeCount // ignore: cast_nullable_to_non_nullable
as int,approvedByUserId: freezed == approvedByUserId ? _self.approvedByUserId : approvedByUserId // ignore: cast_nullable_to_non_nullable
as String?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disbursedAt: freezed == disbursedAt ? _self.disbursedAt : disbursedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,complianceAlertIds: null == complianceAlertIds ? _self._complianceAlertIds : complianceAlertIds // ignore: cast_nullable_to_non_nullable
as List<String>,lineItems: null == lineItems ? _self._lineItems : lineItems // ignore: cast_nullable_to_non_nullable
as List<PayslipLineItem>,sdlContribution: null == sdlContribution ? _self.sdlContribution : sdlContribution // ignore: cast_nullable_to_non_nullable
as double,etiCredit: null == etiCredit ? _self.etiCredit : etiCredit // ignore: cast_nullable_to_non_nullable
as double,totalCoidaContribution: null == totalCoidaContribution ? _self.totalCoidaContribution : totalCoidaContribution // ignore: cast_nullable_to_non_nullable
as double,approvalChain: null == approvalChain ? _self._approvalChain : approvalChain // ignore: cast_nullable_to_non_nullable
as List<ApprovalEntry>,requiredApprovers: null == requiredApprovers ? _self.requiredApprovers : requiredApprovers // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
