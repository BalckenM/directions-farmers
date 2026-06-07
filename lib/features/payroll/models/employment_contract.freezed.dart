// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employment_contract.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmploymentContract {

 String get id; String get employeeId; ContractType get type; DateTime get startDate; DateTime? get endDate; String get jobDescription; double get grossMonthlySalary; String get currency; ContractStatus get status; DateTime? get signedAt; String? get signedByName; String? get signatureImageBase64; String? get pdfPath; int get version; DateTime get createdAt;
/// Create a copy of EmploymentContract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmploymentContractCopyWith<EmploymentContract> get copyWith => _$EmploymentContractCopyWithImpl<EmploymentContract>(this as EmploymentContract, _$identity);

  /// Serializes this EmploymentContract to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmploymentContract&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.jobDescription, jobDescription) || other.jobDescription == jobDescription)&&(identical(other.grossMonthlySalary, grossMonthlySalary) || other.grossMonthlySalary == grossMonthlySalary)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.signatureImageBase64, signatureImageBase64) || other.signatureImageBase64 == signatureImageBase64)&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,type,startDate,endDate,jobDescription,grossMonthlySalary,currency,status,signedAt,signedByName,signatureImageBase64,pdfPath,version,createdAt);

@override
String toString() {
  return 'EmploymentContract(id: $id, employeeId: $employeeId, type: $type, startDate: $startDate, endDate: $endDate, jobDescription: $jobDescription, grossMonthlySalary: $grossMonthlySalary, currency: $currency, status: $status, signedAt: $signedAt, signedByName: $signedByName, signatureImageBase64: $signatureImageBase64, pdfPath: $pdfPath, version: $version, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EmploymentContractCopyWith<$Res>  {
  factory $EmploymentContractCopyWith(EmploymentContract value, $Res Function(EmploymentContract) _then) = _$EmploymentContractCopyWithImpl;
@useResult
$Res call({
 String id, String employeeId, ContractType type, DateTime startDate, DateTime? endDate, String jobDescription, double grossMonthlySalary, String currency, ContractStatus status, DateTime? signedAt, String? signedByName, String? signatureImageBase64, String? pdfPath, int version, DateTime createdAt
});




}
/// @nodoc
class _$EmploymentContractCopyWithImpl<$Res>
    implements $EmploymentContractCopyWith<$Res> {
  _$EmploymentContractCopyWithImpl(this._self, this._then);

  final EmploymentContract _self;
  final $Res Function(EmploymentContract) _then;

/// Create a copy of EmploymentContract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? employeeId = null,Object? type = null,Object? startDate = null,Object? endDate = freezed,Object? jobDescription = null,Object? grossMonthlySalary = null,Object? currency = null,Object? status = null,Object? signedAt = freezed,Object? signedByName = freezed,Object? signatureImageBase64 = freezed,Object? pdfPath = freezed,Object? version = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContractType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,jobDescription: null == jobDescription ? _self.jobDescription : jobDescription // ignore: cast_nullable_to_non_nullable
as String,grossMonthlySalary: null == grossMonthlySalary ? _self.grossMonthlySalary : grossMonthlySalary // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,signedAt: freezed == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,signedByName: freezed == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String?,signatureImageBase64: freezed == signatureImageBase64 ? _self.signatureImageBase64 : signatureImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EmploymentContract].
extension EmploymentContractPatterns on EmploymentContract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmploymentContract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmploymentContract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmploymentContract value)  $default,){
final _that = this;
switch (_that) {
case _EmploymentContract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmploymentContract value)?  $default,){
final _that = this;
switch (_that) {
case _EmploymentContract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String employeeId,  ContractType type,  DateTime startDate,  DateTime? endDate,  String jobDescription,  double grossMonthlySalary,  String currency,  ContractStatus status,  DateTime? signedAt,  String? signedByName,  String? signatureImageBase64,  String? pdfPath,  int version,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmploymentContract() when $default != null:
return $default(_that.id,_that.employeeId,_that.type,_that.startDate,_that.endDate,_that.jobDescription,_that.grossMonthlySalary,_that.currency,_that.status,_that.signedAt,_that.signedByName,_that.signatureImageBase64,_that.pdfPath,_that.version,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String employeeId,  ContractType type,  DateTime startDate,  DateTime? endDate,  String jobDescription,  double grossMonthlySalary,  String currency,  ContractStatus status,  DateTime? signedAt,  String? signedByName,  String? signatureImageBase64,  String? pdfPath,  int version,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _EmploymentContract():
return $default(_that.id,_that.employeeId,_that.type,_that.startDate,_that.endDate,_that.jobDescription,_that.grossMonthlySalary,_that.currency,_that.status,_that.signedAt,_that.signedByName,_that.signatureImageBase64,_that.pdfPath,_that.version,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String employeeId,  ContractType type,  DateTime startDate,  DateTime? endDate,  String jobDescription,  double grossMonthlySalary,  String currency,  ContractStatus status,  DateTime? signedAt,  String? signedByName,  String? signatureImageBase64,  String? pdfPath,  int version,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EmploymentContract() when $default != null:
return $default(_that.id,_that.employeeId,_that.type,_that.startDate,_that.endDate,_that.jobDescription,_that.grossMonthlySalary,_that.currency,_that.status,_that.signedAt,_that.signedByName,_that.signatureImageBase64,_that.pdfPath,_that.version,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmploymentContract extends EmploymentContract {
  const _EmploymentContract({required this.id, required this.employeeId, required this.type, required this.startDate, this.endDate, required this.jobDescription, required this.grossMonthlySalary, this.currency = 'ZAR', required this.status, this.signedAt, this.signedByName, this.signatureImageBase64, this.pdfPath, this.version = 1, required this.createdAt}): super._();
  factory _EmploymentContract.fromJson(Map<String, dynamic> json) => _$EmploymentContractFromJson(json);

@override final  String id;
@override final  String employeeId;
@override final  ContractType type;
@override final  DateTime startDate;
@override final  DateTime? endDate;
@override final  String jobDescription;
@override final  double grossMonthlySalary;
@override@JsonKey() final  String currency;
@override final  ContractStatus status;
@override final  DateTime? signedAt;
@override final  String? signedByName;
@override final  String? signatureImageBase64;
@override final  String? pdfPath;
@override@JsonKey() final  int version;
@override final  DateTime createdAt;

/// Create a copy of EmploymentContract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmploymentContractCopyWith<_EmploymentContract> get copyWith => __$EmploymentContractCopyWithImpl<_EmploymentContract>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmploymentContractToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmploymentContract&&(identical(other.id, id) || other.id == id)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.type, type) || other.type == type)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.jobDescription, jobDescription) || other.jobDescription == jobDescription)&&(identical(other.grossMonthlySalary, grossMonthlySalary) || other.grossMonthlySalary == grossMonthlySalary)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.signedByName, signedByName) || other.signedByName == signedByName)&&(identical(other.signatureImageBase64, signatureImageBase64) || other.signatureImageBase64 == signatureImageBase64)&&(identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath)&&(identical(other.version, version) || other.version == version)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,employeeId,type,startDate,endDate,jobDescription,grossMonthlySalary,currency,status,signedAt,signedByName,signatureImageBase64,pdfPath,version,createdAt);

@override
String toString() {
  return 'EmploymentContract(id: $id, employeeId: $employeeId, type: $type, startDate: $startDate, endDate: $endDate, jobDescription: $jobDescription, grossMonthlySalary: $grossMonthlySalary, currency: $currency, status: $status, signedAt: $signedAt, signedByName: $signedByName, signatureImageBase64: $signatureImageBase64, pdfPath: $pdfPath, version: $version, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EmploymentContractCopyWith<$Res> implements $EmploymentContractCopyWith<$Res> {
  factory _$EmploymentContractCopyWith(_EmploymentContract value, $Res Function(_EmploymentContract) _then) = __$EmploymentContractCopyWithImpl;
@override @useResult
$Res call({
 String id, String employeeId, ContractType type, DateTime startDate, DateTime? endDate, String jobDescription, double grossMonthlySalary, String currency, ContractStatus status, DateTime? signedAt, String? signedByName, String? signatureImageBase64, String? pdfPath, int version, DateTime createdAt
});




}
/// @nodoc
class __$EmploymentContractCopyWithImpl<$Res>
    implements _$EmploymentContractCopyWith<$Res> {
  __$EmploymentContractCopyWithImpl(this._self, this._then);

  final _EmploymentContract _self;
  final $Res Function(_EmploymentContract) _then;

/// Create a copy of EmploymentContract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? employeeId = null,Object? type = null,Object? startDate = null,Object? endDate = freezed,Object? jobDescription = null,Object? grossMonthlySalary = null,Object? currency = null,Object? status = null,Object? signedAt = freezed,Object? signedByName = freezed,Object? signatureImageBase64 = freezed,Object? pdfPath = freezed,Object? version = null,Object? createdAt = null,}) {
  return _then(_EmploymentContract(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContractType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,jobDescription: null == jobDescription ? _self.jobDescription : jobDescription // ignore: cast_nullable_to_non_nullable
as String,grossMonthlySalary: null == grossMonthlySalary ? _self.grossMonthlySalary : grossMonthlySalary // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,signedAt: freezed == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,signedByName: freezed == signedByName ? _self.signedByName : signedByName // ignore: cast_nullable_to_non_nullable
as String?,signatureImageBase64: freezed == signatureImageBase64 ? _self.signatureImageBase64 : signatureImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,pdfPath: freezed == pdfPath ? _self.pdfPath : pdfPath // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
