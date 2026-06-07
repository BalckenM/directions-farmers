// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payslip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayslipDeductionLine {

 String get code; String get description; double get amount; bool get isStatutory;
/// Create a copy of PayslipDeductionLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayslipDeductionLineCopyWith<PayslipDeductionLine> get copyWith => _$PayslipDeductionLineCopyWithImpl<PayslipDeductionLine>(this as PayslipDeductionLine, _$identity);

  /// Serializes this PayslipDeductionLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayslipDeductionLine&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.isStatutory, isStatutory) || other.isStatutory == isStatutory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,description,amount,isStatutory);

@override
String toString() {
  return 'PayslipDeductionLine(code: $code, description: $description, amount: $amount, isStatutory: $isStatutory)';
}


}

/// @nodoc
abstract mixin class $PayslipDeductionLineCopyWith<$Res>  {
  factory $PayslipDeductionLineCopyWith(PayslipDeductionLine value, $Res Function(PayslipDeductionLine) _then) = _$PayslipDeductionLineCopyWithImpl;
@useResult
$Res call({
 String code, String description, double amount, bool isStatutory
});




}
/// @nodoc
class _$PayslipDeductionLineCopyWithImpl<$Res>
    implements $PayslipDeductionLineCopyWith<$Res> {
  _$PayslipDeductionLineCopyWithImpl(this._self, this._then);

  final PayslipDeductionLine _self;
  final $Res Function(PayslipDeductionLine) _then;

/// Create a copy of PayslipDeductionLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? description = null,Object? amount = null,Object? isStatutory = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,isStatutory: null == isStatutory ? _self.isStatutory : isStatutory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PayslipDeductionLine].
extension PayslipDeductionLinePatterns on PayslipDeductionLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayslipDeductionLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayslipDeductionLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayslipDeductionLine value)  $default,){
final _that = this;
switch (_that) {
case _PayslipDeductionLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayslipDeductionLine value)?  $default,){
final _that = this;
switch (_that) {
case _PayslipDeductionLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String description,  double amount,  bool isStatutory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayslipDeductionLine() when $default != null:
return $default(_that.code,_that.description,_that.amount,_that.isStatutory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String description,  double amount,  bool isStatutory)  $default,) {final _that = this;
switch (_that) {
case _PayslipDeductionLine():
return $default(_that.code,_that.description,_that.amount,_that.isStatutory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String description,  double amount,  bool isStatutory)?  $default,) {final _that = this;
switch (_that) {
case _PayslipDeductionLine() when $default != null:
return $default(_that.code,_that.description,_that.amount,_that.isStatutory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayslipDeductionLine implements PayslipDeductionLine {
  const _PayslipDeductionLine({required this.code, required this.description, required this.amount, required this.isStatutory});
  factory _PayslipDeductionLine.fromJson(Map<String, dynamic> json) => _$PayslipDeductionLineFromJson(json);

@override final  String code;
@override final  String description;
@override final  double amount;
@override final  bool isStatutory;

/// Create a copy of PayslipDeductionLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayslipDeductionLineCopyWith<_PayslipDeductionLine> get copyWith => __$PayslipDeductionLineCopyWithImpl<_PayslipDeductionLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayslipDeductionLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayslipDeductionLine&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.isStatutory, isStatutory) || other.isStatutory == isStatutory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,description,amount,isStatutory);

@override
String toString() {
  return 'PayslipDeductionLine(code: $code, description: $description, amount: $amount, isStatutory: $isStatutory)';
}


}

/// @nodoc
abstract mixin class _$PayslipDeductionLineCopyWith<$Res> implements $PayslipDeductionLineCopyWith<$Res> {
  factory _$PayslipDeductionLineCopyWith(_PayslipDeductionLine value, $Res Function(_PayslipDeductionLine) _then) = __$PayslipDeductionLineCopyWithImpl;
@override @useResult
$Res call({
 String code, String description, double amount, bool isStatutory
});




}
/// @nodoc
class __$PayslipDeductionLineCopyWithImpl<$Res>
    implements _$PayslipDeductionLineCopyWith<$Res> {
  __$PayslipDeductionLineCopyWithImpl(this._self, this._then);

  final _PayslipDeductionLine _self;
  final $Res Function(_PayslipDeductionLine) _then;

/// Create a copy of PayslipDeductionLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? description = null,Object? amount = null,Object? isStatutory = null,}) {
  return _then(_PayslipDeductionLine(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,isStatutory: null == isStatutory ? _self.isStatutory : isStatutory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Payslip {

 String get id; String get payRunId; String get employeeId; DateTime get periodStart; DateTime get periodEnd; DateTime get payDate; double get basicWage; double get overtimePay; double get holidayPay; double get inKindHousing; double get inKindFood; double get otherEarnings; double get grossPay; List<PayslipDeductionLine> get deductions; double get totalDeductions; double get netPay; Map<String, double> get leaveBalanceSnapshot; String? get payslipNumber; DateTime get createdAt;
/// Create a copy of Payslip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayslipCopyWith<Payslip> get copyWith => _$PayslipCopyWithImpl<Payslip>(this as Payslip, _$identity);

  /// Serializes this Payslip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payslip&&(identical(other.id, id) || other.id == id)&&(identical(other.payRunId, payRunId) || other.payRunId == payRunId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.payDate, payDate) || other.payDate == payDate)&&(identical(other.basicWage, basicWage) || other.basicWage == basicWage)&&(identical(other.overtimePay, overtimePay) || other.overtimePay == overtimePay)&&(identical(other.holidayPay, holidayPay) || other.holidayPay == holidayPay)&&(identical(other.inKindHousing, inKindHousing) || other.inKindHousing == inKindHousing)&&(identical(other.inKindFood, inKindFood) || other.inKindFood == inKindFood)&&(identical(other.otherEarnings, otherEarnings) || other.otherEarnings == otherEarnings)&&(identical(other.grossPay, grossPay) || other.grossPay == grossPay)&&const DeepCollectionEquality().equals(other.deductions, deductions)&&(identical(other.totalDeductions, totalDeductions) || other.totalDeductions == totalDeductions)&&(identical(other.netPay, netPay) || other.netPay == netPay)&&const DeepCollectionEquality().equals(other.leaveBalanceSnapshot, leaveBalanceSnapshot)&&(identical(other.payslipNumber, payslipNumber) || other.payslipNumber == payslipNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,payRunId,employeeId,periodStart,periodEnd,payDate,basicWage,overtimePay,holidayPay,inKindHousing,inKindFood,otherEarnings,grossPay,const DeepCollectionEquality().hash(deductions),totalDeductions,netPay,const DeepCollectionEquality().hash(leaveBalanceSnapshot),payslipNumber,createdAt]);

@override
String toString() {
  return 'Payslip(id: $id, payRunId: $payRunId, employeeId: $employeeId, periodStart: $periodStart, periodEnd: $periodEnd, payDate: $payDate, basicWage: $basicWage, overtimePay: $overtimePay, holidayPay: $holidayPay, inKindHousing: $inKindHousing, inKindFood: $inKindFood, otherEarnings: $otherEarnings, grossPay: $grossPay, deductions: $deductions, totalDeductions: $totalDeductions, netPay: $netPay, leaveBalanceSnapshot: $leaveBalanceSnapshot, payslipNumber: $payslipNumber, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PayslipCopyWith<$Res>  {
  factory $PayslipCopyWith(Payslip value, $Res Function(Payslip) _then) = _$PayslipCopyWithImpl;
@useResult
$Res call({
 String id, String payRunId, String employeeId, DateTime periodStart, DateTime periodEnd, DateTime payDate, double basicWage, double overtimePay, double holidayPay, double inKindHousing, double inKindFood, double otherEarnings, double grossPay, List<PayslipDeductionLine> deductions, double totalDeductions, double netPay, Map<String, double> leaveBalanceSnapshot, String? payslipNumber, DateTime createdAt
});




}
/// @nodoc
class _$PayslipCopyWithImpl<$Res>
    implements $PayslipCopyWith<$Res> {
  _$PayslipCopyWithImpl(this._self, this._then);

  final Payslip _self;
  final $Res Function(Payslip) _then;

/// Create a copy of Payslip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? payRunId = null,Object? employeeId = null,Object? periodStart = null,Object? periodEnd = null,Object? payDate = null,Object? basicWage = null,Object? overtimePay = null,Object? holidayPay = null,Object? inKindHousing = null,Object? inKindFood = null,Object? otherEarnings = null,Object? grossPay = null,Object? deductions = null,Object? totalDeductions = null,Object? netPay = null,Object? leaveBalanceSnapshot = null,Object? payslipNumber = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,payRunId: null == payRunId ? _self.payRunId : payRunId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,payDate: null == payDate ? _self.payDate : payDate // ignore: cast_nullable_to_non_nullable
as DateTime,basicWage: null == basicWage ? _self.basicWage : basicWage // ignore: cast_nullable_to_non_nullable
as double,overtimePay: null == overtimePay ? _self.overtimePay : overtimePay // ignore: cast_nullable_to_non_nullable
as double,holidayPay: null == holidayPay ? _self.holidayPay : holidayPay // ignore: cast_nullable_to_non_nullable
as double,inKindHousing: null == inKindHousing ? _self.inKindHousing : inKindHousing // ignore: cast_nullable_to_non_nullable
as double,inKindFood: null == inKindFood ? _self.inKindFood : inKindFood // ignore: cast_nullable_to_non_nullable
as double,otherEarnings: null == otherEarnings ? _self.otherEarnings : otherEarnings // ignore: cast_nullable_to_non_nullable
as double,grossPay: null == grossPay ? _self.grossPay : grossPay // ignore: cast_nullable_to_non_nullable
as double,deductions: null == deductions ? _self.deductions : deductions // ignore: cast_nullable_to_non_nullable
as List<PayslipDeductionLine>,totalDeductions: null == totalDeductions ? _self.totalDeductions : totalDeductions // ignore: cast_nullable_to_non_nullable
as double,netPay: null == netPay ? _self.netPay : netPay // ignore: cast_nullable_to_non_nullable
as double,leaveBalanceSnapshot: null == leaveBalanceSnapshot ? _self.leaveBalanceSnapshot : leaveBalanceSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, double>,payslipNumber: freezed == payslipNumber ? _self.payslipNumber : payslipNumber // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Payslip].
extension PayslipPatterns on Payslip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payslip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payslip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payslip value)  $default,){
final _that = this;
switch (_that) {
case _Payslip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payslip value)?  $default,){
final _that = this;
switch (_that) {
case _Payslip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String payRunId,  String employeeId,  DateTime periodStart,  DateTime periodEnd,  DateTime payDate,  double basicWage,  double overtimePay,  double holidayPay,  double inKindHousing,  double inKindFood,  double otherEarnings,  double grossPay,  List<PayslipDeductionLine> deductions,  double totalDeductions,  double netPay,  Map<String, double> leaveBalanceSnapshot,  String? payslipNumber,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payslip() when $default != null:
return $default(_that.id,_that.payRunId,_that.employeeId,_that.periodStart,_that.periodEnd,_that.payDate,_that.basicWage,_that.overtimePay,_that.holidayPay,_that.inKindHousing,_that.inKindFood,_that.otherEarnings,_that.grossPay,_that.deductions,_that.totalDeductions,_that.netPay,_that.leaveBalanceSnapshot,_that.payslipNumber,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String payRunId,  String employeeId,  DateTime periodStart,  DateTime periodEnd,  DateTime payDate,  double basicWage,  double overtimePay,  double holidayPay,  double inKindHousing,  double inKindFood,  double otherEarnings,  double grossPay,  List<PayslipDeductionLine> deductions,  double totalDeductions,  double netPay,  Map<String, double> leaveBalanceSnapshot,  String? payslipNumber,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Payslip():
return $default(_that.id,_that.payRunId,_that.employeeId,_that.periodStart,_that.periodEnd,_that.payDate,_that.basicWage,_that.overtimePay,_that.holidayPay,_that.inKindHousing,_that.inKindFood,_that.otherEarnings,_that.grossPay,_that.deductions,_that.totalDeductions,_that.netPay,_that.leaveBalanceSnapshot,_that.payslipNumber,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String payRunId,  String employeeId,  DateTime periodStart,  DateTime periodEnd,  DateTime payDate,  double basicWage,  double overtimePay,  double holidayPay,  double inKindHousing,  double inKindFood,  double otherEarnings,  double grossPay,  List<PayslipDeductionLine> deductions,  double totalDeductions,  double netPay,  Map<String, double> leaveBalanceSnapshot,  String? payslipNumber,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Payslip() when $default != null:
return $default(_that.id,_that.payRunId,_that.employeeId,_that.periodStart,_that.periodEnd,_that.payDate,_that.basicWage,_that.overtimePay,_that.holidayPay,_that.inKindHousing,_that.inKindFood,_that.otherEarnings,_that.grossPay,_that.deductions,_that.totalDeductions,_that.netPay,_that.leaveBalanceSnapshot,_that.payslipNumber,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payslip extends Payslip {
  const _Payslip({required this.id, required this.payRunId, required this.employeeId, required this.periodStart, required this.periodEnd, required this.payDate, required this.basicWage, required this.overtimePay, required this.holidayPay, required this.inKindHousing, required this.inKindFood, required this.otherEarnings, required this.grossPay, required final  List<PayslipDeductionLine> deductions, required this.totalDeductions, required this.netPay, required final  Map<String, double> leaveBalanceSnapshot, this.payslipNumber, required this.createdAt}): _deductions = deductions,_leaveBalanceSnapshot = leaveBalanceSnapshot,super._();
  factory _Payslip.fromJson(Map<String, dynamic> json) => _$PayslipFromJson(json);

@override final  String id;
@override final  String payRunId;
@override final  String employeeId;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime payDate;
@override final  double basicWage;
@override final  double overtimePay;
@override final  double holidayPay;
@override final  double inKindHousing;
@override final  double inKindFood;
@override final  double otherEarnings;
@override final  double grossPay;
 final  List<PayslipDeductionLine> _deductions;
@override List<PayslipDeductionLine> get deductions {
  if (_deductions is EqualUnmodifiableListView) return _deductions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deductions);
}

@override final  double totalDeductions;
@override final  double netPay;
 final  Map<String, double> _leaveBalanceSnapshot;
@override Map<String, double> get leaveBalanceSnapshot {
  if (_leaveBalanceSnapshot is EqualUnmodifiableMapView) return _leaveBalanceSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_leaveBalanceSnapshot);
}

@override final  String? payslipNumber;
@override final  DateTime createdAt;

/// Create a copy of Payslip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayslipCopyWith<_Payslip> get copyWith => __$PayslipCopyWithImpl<_Payslip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayslipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payslip&&(identical(other.id, id) || other.id == id)&&(identical(other.payRunId, payRunId) || other.payRunId == payRunId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.payDate, payDate) || other.payDate == payDate)&&(identical(other.basicWage, basicWage) || other.basicWage == basicWage)&&(identical(other.overtimePay, overtimePay) || other.overtimePay == overtimePay)&&(identical(other.holidayPay, holidayPay) || other.holidayPay == holidayPay)&&(identical(other.inKindHousing, inKindHousing) || other.inKindHousing == inKindHousing)&&(identical(other.inKindFood, inKindFood) || other.inKindFood == inKindFood)&&(identical(other.otherEarnings, otherEarnings) || other.otherEarnings == otherEarnings)&&(identical(other.grossPay, grossPay) || other.grossPay == grossPay)&&const DeepCollectionEquality().equals(other._deductions, _deductions)&&(identical(other.totalDeductions, totalDeductions) || other.totalDeductions == totalDeductions)&&(identical(other.netPay, netPay) || other.netPay == netPay)&&const DeepCollectionEquality().equals(other._leaveBalanceSnapshot, _leaveBalanceSnapshot)&&(identical(other.payslipNumber, payslipNumber) || other.payslipNumber == payslipNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,payRunId,employeeId,periodStart,periodEnd,payDate,basicWage,overtimePay,holidayPay,inKindHousing,inKindFood,otherEarnings,grossPay,const DeepCollectionEquality().hash(_deductions),totalDeductions,netPay,const DeepCollectionEquality().hash(_leaveBalanceSnapshot),payslipNumber,createdAt]);

@override
String toString() {
  return 'Payslip(id: $id, payRunId: $payRunId, employeeId: $employeeId, periodStart: $periodStart, periodEnd: $periodEnd, payDate: $payDate, basicWage: $basicWage, overtimePay: $overtimePay, holidayPay: $holidayPay, inKindHousing: $inKindHousing, inKindFood: $inKindFood, otherEarnings: $otherEarnings, grossPay: $grossPay, deductions: $deductions, totalDeductions: $totalDeductions, netPay: $netPay, leaveBalanceSnapshot: $leaveBalanceSnapshot, payslipNumber: $payslipNumber, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PayslipCopyWith<$Res> implements $PayslipCopyWith<$Res> {
  factory _$PayslipCopyWith(_Payslip value, $Res Function(_Payslip) _then) = __$PayslipCopyWithImpl;
@override @useResult
$Res call({
 String id, String payRunId, String employeeId, DateTime periodStart, DateTime periodEnd, DateTime payDate, double basicWage, double overtimePay, double holidayPay, double inKindHousing, double inKindFood, double otherEarnings, double grossPay, List<PayslipDeductionLine> deductions, double totalDeductions, double netPay, Map<String, double> leaveBalanceSnapshot, String? payslipNumber, DateTime createdAt
});




}
/// @nodoc
class __$PayslipCopyWithImpl<$Res>
    implements _$PayslipCopyWith<$Res> {
  __$PayslipCopyWithImpl(this._self, this._then);

  final _Payslip _self;
  final $Res Function(_Payslip) _then;

/// Create a copy of Payslip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? payRunId = null,Object? employeeId = null,Object? periodStart = null,Object? periodEnd = null,Object? payDate = null,Object? basicWage = null,Object? overtimePay = null,Object? holidayPay = null,Object? inKindHousing = null,Object? inKindFood = null,Object? otherEarnings = null,Object? grossPay = null,Object? deductions = null,Object? totalDeductions = null,Object? netPay = null,Object? leaveBalanceSnapshot = null,Object? payslipNumber = freezed,Object? createdAt = null,}) {
  return _then(_Payslip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,payRunId: null == payRunId ? _self.payRunId : payRunId // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,payDate: null == payDate ? _self.payDate : payDate // ignore: cast_nullable_to_non_nullable
as DateTime,basicWage: null == basicWage ? _self.basicWage : basicWage // ignore: cast_nullable_to_non_nullable
as double,overtimePay: null == overtimePay ? _self.overtimePay : overtimePay // ignore: cast_nullable_to_non_nullable
as double,holidayPay: null == holidayPay ? _self.holidayPay : holidayPay // ignore: cast_nullable_to_non_nullable
as double,inKindHousing: null == inKindHousing ? _self.inKindHousing : inKindHousing // ignore: cast_nullable_to_non_nullable
as double,inKindFood: null == inKindFood ? _self.inKindFood : inKindFood // ignore: cast_nullable_to_non_nullable
as double,otherEarnings: null == otherEarnings ? _self.otherEarnings : otherEarnings // ignore: cast_nullable_to_non_nullable
as double,grossPay: null == grossPay ? _self.grossPay : grossPay // ignore: cast_nullable_to_non_nullable
as double,deductions: null == deductions ? _self._deductions : deductions // ignore: cast_nullable_to_non_nullable
as List<PayslipDeductionLine>,totalDeductions: null == totalDeductions ? _self.totalDeductions : totalDeductions // ignore: cast_nullable_to_non_nullable
as double,netPay: null == netPay ? _self.netPay : netPay // ignore: cast_nullable_to_non_nullable
as double,leaveBalanceSnapshot: null == leaveBalanceSnapshot ? _self._leaveBalanceSnapshot : leaveBalanceSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, double>,payslipNumber: freezed == payslipNumber ? _self.payslipNumber : payslipNumber // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
