// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentTransaction {

 String get id; String get payRunId; String get employeeId; String get type; String get description; double get amount; String get currency; String get method; TransactionStatus get status; String? get reference; String? get bankName; String? get accountNumber; DateTime? get initiatedAt; DateTime? get completedAt; String? get failureReason; DateTime get transactionDate; DateTime get createdAt;
/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentTransactionCopyWith<PaymentTransaction> get copyWith => _$PaymentTransactionCopyWithImpl<PaymentTransaction>(this as PaymentTransaction, _$identity);

  /// Serializes this PaymentTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.payRunId, payRunId) || other.payRunId == payRunId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.initiatedAt, initiatedAt) || other.initiatedAt == initiatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,payRunId,employeeId,type,description,amount,currency,method,status,reference,bankName,accountNumber,initiatedAt,completedAt,failureReason,transactionDate,createdAt);

@override
String toString() {
  return 'PaymentTransaction(id: $id, payRunId: $payRunId, employeeId: $employeeId, type: $type, description: $description, amount: $amount, currency: $currency, method: $method, status: $status, reference: $reference, bankName: $bankName, accountNumber: $accountNumber, initiatedAt: $initiatedAt, completedAt: $completedAt, failureReason: $failureReason, transactionDate: $transactionDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PaymentTransactionCopyWith<$Res>  {
  factory $PaymentTransactionCopyWith(PaymentTransaction value, $Res Function(PaymentTransaction) _then) = _$PaymentTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String payRunId, String employeeId, String type, String description, double amount, String currency, String method, TransactionStatus status, String? reference, String? bankName, String? accountNumber, DateTime? initiatedAt, DateTime? completedAt, String? failureReason, DateTime transactionDate, DateTime createdAt
});




}
/// @nodoc
class _$PaymentTransactionCopyWithImpl<$Res>
    implements $PaymentTransactionCopyWith<$Res> {
  _$PaymentTransactionCopyWithImpl(this._self, this._then);

  final PaymentTransaction _self;
  final $Res Function(PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? payRunId = null,Object? employeeId = null,Object? type = null,Object? description = null,Object? amount = null,Object? currency = null,Object? method = null,Object? status = null,Object? reference = freezed,Object? bankName = freezed,Object? accountNumber = freezed,Object? initiatedAt = freezed,Object? completedAt = freezed,Object? failureReason = freezed,Object? transactionDate = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,payRunId: null == payRunId ? _self.payRunId : payRunId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,initiatedAt: freezed == initiatedAt ? _self.initiatedAt : initiatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentTransaction].
extension PaymentTransactionPatterns on PaymentTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String payRunId,  String employeeId,  String type,  String description,  double amount,  String currency,  String method,  TransactionStatus status,  String? reference,  String? bankName,  String? accountNumber,  DateTime? initiatedAt,  DateTime? completedAt,  String? failureReason,  DateTime transactionDate,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.payRunId,_that.employeeId,_that.type,_that.description,_that.amount,_that.currency,_that.method,_that.status,_that.reference,_that.bankName,_that.accountNumber,_that.initiatedAt,_that.completedAt,_that.failureReason,_that.transactionDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String payRunId,  String employeeId,  String type,  String description,  double amount,  String currency,  String method,  TransactionStatus status,  String? reference,  String? bankName,  String? accountNumber,  DateTime? initiatedAt,  DateTime? completedAt,  String? failureReason,  DateTime transactionDate,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction():
return $default(_that.id,_that.payRunId,_that.employeeId,_that.type,_that.description,_that.amount,_that.currency,_that.method,_that.status,_that.reference,_that.bankName,_that.accountNumber,_that.initiatedAt,_that.completedAt,_that.failureReason,_that.transactionDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String payRunId,  String employeeId,  String type,  String description,  double amount,  String currency,  String method,  TransactionStatus status,  String? reference,  String? bankName,  String? accountNumber,  DateTime? initiatedAt,  DateTime? completedAt,  String? failureReason,  DateTime transactionDate,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.payRunId,_that.employeeId,_that.type,_that.description,_that.amount,_that.currency,_that.method,_that.status,_that.reference,_that.bankName,_that.accountNumber,_that.initiatedAt,_that.completedAt,_that.failureReason,_that.transactionDate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentTransaction extends PaymentTransaction {
  const _PaymentTransaction({required this.id, required this.payRunId, required this.employeeId, required this.type, required this.description, required this.amount, required this.currency, required this.method, required this.status, this.reference, this.bankName, this.accountNumber, this.initiatedAt, this.completedAt, this.failureReason, required this.transactionDate, required this.createdAt}): super._();
  factory _PaymentTransaction.fromJson(Map<String, dynamic> json) => _$PaymentTransactionFromJson(json);

@override final  String id;
@override final  String payRunId;
@override final  String employeeId;
@override final  String type;
@override final  String description;
@override final  double amount;
@override final  String currency;
@override final  String method;
@override final  TransactionStatus status;
@override final  String? reference;
@override final  String? bankName;
@override final  String? accountNumber;
@override final  DateTime? initiatedAt;
@override final  DateTime? completedAt;
@override final  String? failureReason;
@override final  DateTime transactionDate;
@override final  DateTime createdAt;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentTransactionCopyWith<_PaymentTransaction> get copyWith => __$PaymentTransactionCopyWithImpl<_PaymentTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.payRunId, payRunId) || other.payRunId == payRunId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.initiatedAt, initiatedAt) || other.initiatedAt == initiatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,payRunId,employeeId,type,description,amount,currency,method,status,reference,bankName,accountNumber,initiatedAt,completedAt,failureReason,transactionDate,createdAt);

@override
String toString() {
  return 'PaymentTransaction(id: $id, payRunId: $payRunId, employeeId: $employeeId, type: $type, description: $description, amount: $amount, currency: $currency, method: $method, status: $status, reference: $reference, bankName: $bankName, accountNumber: $accountNumber, initiatedAt: $initiatedAt, completedAt: $completedAt, failureReason: $failureReason, transactionDate: $transactionDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentTransactionCopyWith<$Res> implements $PaymentTransactionCopyWith<$Res> {
  factory _$PaymentTransactionCopyWith(_PaymentTransaction value, $Res Function(_PaymentTransaction) _then) = __$PaymentTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String payRunId, String employeeId, String type, String description, double amount, String currency, String method, TransactionStatus status, String? reference, String? bankName, String? accountNumber, DateTime? initiatedAt, DateTime? completedAt, String? failureReason, DateTime transactionDate, DateTime createdAt
});




}
/// @nodoc
class __$PaymentTransactionCopyWithImpl<$Res>
    implements _$PaymentTransactionCopyWith<$Res> {
  __$PaymentTransactionCopyWithImpl(this._self, this._then);

  final _PaymentTransaction _self;
  final $Res Function(_PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? payRunId = null,Object? employeeId = null,Object? type = null,Object? description = null,Object? amount = null,Object? currency = null,Object? method = null,Object? status = null,Object? reference = freezed,Object? bankName = freezed,Object? accountNumber = freezed,Object? initiatedAt = freezed,Object? completedAt = freezed,Object? failureReason = freezed,Object? transactionDate = null,Object? createdAt = null,}) {
  return _then(_PaymentTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,payRunId: null == payRunId ? _self.payRunId : payRunId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,initiatedAt: freezed == initiatedAt ? _self.initiatedAt : initiatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
