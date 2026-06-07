// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payroll_employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PayrollEmployee {

 String get id; String get firstName; String get lastName; String get idOrPassportNumber; String? get phone; String? get email; String get address; String get nextOfKinName; String get nextOfKinPhone; EmploymentStatus get status; EngagementType get engagementType; String get occupationTitle; String? get payGroupId; String? get payStructureId; DateTime get startDate; DateTime? get endDate; String? get bankName; String? get bankAccountNumber; String? get bankBranchCode; DisbursementMethod get disbursementMethod; String get preferredLanguage; bool get hasHousingBenefit; double? get housingValuePerMonth; bool get hasFoodBenefit; double? get foodValuePerMonth; DateTime? get dateOfBirth; String? get profileImageUrl; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PayrollEmployee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayrollEmployeeCopyWith<PayrollEmployee> get copyWith => _$PayrollEmployeeCopyWithImpl<PayrollEmployee>(this as PayrollEmployee, _$identity);

  /// Serializes this PayrollEmployee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayrollEmployee&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.idOrPassportNumber, idOrPassportNumber) || other.idOrPassportNumber == idOrPassportNumber)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.nextOfKinName, nextOfKinName) || other.nextOfKinName == nextOfKinName)&&(identical(other.nextOfKinPhone, nextOfKinPhone) || other.nextOfKinPhone == nextOfKinPhone)&&(identical(other.status, status) || other.status == status)&&(identical(other.engagementType, engagementType) || other.engagementType == engagementType)&&(identical(other.occupationTitle, occupationTitle) || other.occupationTitle == occupationTitle)&&(identical(other.payGroupId, payGroupId) || other.payGroupId == payGroupId)&&(identical(other.payStructureId, payStructureId) || other.payStructureId == payStructureId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankBranchCode, bankBranchCode) || other.bankBranchCode == bankBranchCode)&&(identical(other.disbursementMethod, disbursementMethod) || other.disbursementMethod == disbursementMethod)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.hasHousingBenefit, hasHousingBenefit) || other.hasHousingBenefit == hasHousingBenefit)&&(identical(other.housingValuePerMonth, housingValuePerMonth) || other.housingValuePerMonth == housingValuePerMonth)&&(identical(other.hasFoodBenefit, hasFoodBenefit) || other.hasFoodBenefit == hasFoodBenefit)&&(identical(other.foodValuePerMonth, foodValuePerMonth) || other.foodValuePerMonth == foodValuePerMonth)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,idOrPassportNumber,phone,email,address,nextOfKinName,nextOfKinPhone,status,engagementType,occupationTitle,payGroupId,payStructureId,startDate,endDate,bankName,bankAccountNumber,bankBranchCode,disbursementMethod,preferredLanguage,hasHousingBenefit,housingValuePerMonth,hasFoodBenefit,foodValuePerMonth,dateOfBirth,profileImageUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'PayrollEmployee(id: $id, firstName: $firstName, lastName: $lastName, idOrPassportNumber: $idOrPassportNumber, phone: $phone, email: $email, address: $address, nextOfKinName: $nextOfKinName, nextOfKinPhone: $nextOfKinPhone, status: $status, engagementType: $engagementType, occupationTitle: $occupationTitle, payGroupId: $payGroupId, payStructureId: $payStructureId, startDate: $startDate, endDate: $endDate, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankBranchCode: $bankBranchCode, disbursementMethod: $disbursementMethod, preferredLanguage: $preferredLanguage, hasHousingBenefit: $hasHousingBenefit, housingValuePerMonth: $housingValuePerMonth, hasFoodBenefit: $hasFoodBenefit, foodValuePerMonth: $foodValuePerMonth, dateOfBirth: $dateOfBirth, profileImageUrl: $profileImageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PayrollEmployeeCopyWith<$Res>  {
  factory $PayrollEmployeeCopyWith(PayrollEmployee value, $Res Function(PayrollEmployee) _then) = _$PayrollEmployeeCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String idOrPassportNumber, String? phone, String? email, String address, String nextOfKinName, String nextOfKinPhone, EmploymentStatus status, EngagementType engagementType, String occupationTitle, String? payGroupId, String? payStructureId, DateTime startDate, DateTime? endDate, String? bankName, String? bankAccountNumber, String? bankBranchCode, DisbursementMethod disbursementMethod, String preferredLanguage, bool hasHousingBenefit, double? housingValuePerMonth, bool hasFoodBenefit, double? foodValuePerMonth, DateTime? dateOfBirth, String? profileImageUrl, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PayrollEmployeeCopyWithImpl<$Res>
    implements $PayrollEmployeeCopyWith<$Res> {
  _$PayrollEmployeeCopyWithImpl(this._self, this._then);

  final PayrollEmployee _self;
  final $Res Function(PayrollEmployee) _then;

/// Create a copy of PayrollEmployee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? idOrPassportNumber = null,Object? phone = freezed,Object? email = freezed,Object? address = null,Object? nextOfKinName = null,Object? nextOfKinPhone = null,Object? status = null,Object? engagementType = null,Object? occupationTitle = null,Object? payGroupId = freezed,Object? payStructureId = freezed,Object? startDate = null,Object? endDate = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankBranchCode = freezed,Object? disbursementMethod = null,Object? preferredLanguage = null,Object? hasHousingBenefit = null,Object? housingValuePerMonth = freezed,Object? hasFoodBenefit = null,Object? foodValuePerMonth = freezed,Object? dateOfBirth = freezed,Object? profileImageUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,idOrPassportNumber: null == idOrPassportNumber ? _self.idOrPassportNumber : idOrPassportNumber // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,nextOfKinName: null == nextOfKinName ? _self.nextOfKinName : nextOfKinName // ignore: cast_nullable_to_non_nullable
as String,nextOfKinPhone: null == nextOfKinPhone ? _self.nextOfKinPhone : nextOfKinPhone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus,engagementType: null == engagementType ? _self.engagementType : engagementType // ignore: cast_nullable_to_non_nullable
as EngagementType,occupationTitle: null == occupationTitle ? _self.occupationTitle : occupationTitle // ignore: cast_nullable_to_non_nullable
as String,payGroupId: freezed == payGroupId ? _self.payGroupId : payGroupId // ignore: cast_nullable_to_non_nullable
as String?,payStructureId: freezed == payStructureId ? _self.payStructureId : payStructureId // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankBranchCode: freezed == bankBranchCode ? _self.bankBranchCode : bankBranchCode // ignore: cast_nullable_to_non_nullable
as String?,disbursementMethod: null == disbursementMethod ? _self.disbursementMethod : disbursementMethod // ignore: cast_nullable_to_non_nullable
as DisbursementMethod,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,hasHousingBenefit: null == hasHousingBenefit ? _self.hasHousingBenefit : hasHousingBenefit // ignore: cast_nullable_to_non_nullable
as bool,housingValuePerMonth: freezed == housingValuePerMonth ? _self.housingValuePerMonth : housingValuePerMonth // ignore: cast_nullable_to_non_nullable
as double?,hasFoodBenefit: null == hasFoodBenefit ? _self.hasFoodBenefit : hasFoodBenefit // ignore: cast_nullable_to_non_nullable
as bool,foodValuePerMonth: freezed == foodValuePerMonth ? _self.foodValuePerMonth : foodValuePerMonth // ignore: cast_nullable_to_non_nullable
as double?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PayrollEmployee].
extension PayrollEmployeePatterns on PayrollEmployee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayrollEmployee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayrollEmployee() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayrollEmployee value)  $default,){
final _that = this;
switch (_that) {
case _PayrollEmployee():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayrollEmployee value)?  $default,){
final _that = this;
switch (_that) {
case _PayrollEmployee() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String idOrPassportNumber,  String? phone,  String? email,  String address,  String nextOfKinName,  String nextOfKinPhone,  EmploymentStatus status,  EngagementType engagementType,  String occupationTitle,  String? payGroupId,  String? payStructureId,  DateTime startDate,  DateTime? endDate,  String? bankName,  String? bankAccountNumber,  String? bankBranchCode,  DisbursementMethod disbursementMethod,  String preferredLanguage,  bool hasHousingBenefit,  double? housingValuePerMonth,  bool hasFoodBenefit,  double? foodValuePerMonth,  DateTime? dateOfBirth,  String? profileImageUrl,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayrollEmployee() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.idOrPassportNumber,_that.phone,_that.email,_that.address,_that.nextOfKinName,_that.nextOfKinPhone,_that.status,_that.engagementType,_that.occupationTitle,_that.payGroupId,_that.payStructureId,_that.startDate,_that.endDate,_that.bankName,_that.bankAccountNumber,_that.bankBranchCode,_that.disbursementMethod,_that.preferredLanguage,_that.hasHousingBenefit,_that.housingValuePerMonth,_that.hasFoodBenefit,_that.foodValuePerMonth,_that.dateOfBirth,_that.profileImageUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String idOrPassportNumber,  String? phone,  String? email,  String address,  String nextOfKinName,  String nextOfKinPhone,  EmploymentStatus status,  EngagementType engagementType,  String occupationTitle,  String? payGroupId,  String? payStructureId,  DateTime startDate,  DateTime? endDate,  String? bankName,  String? bankAccountNumber,  String? bankBranchCode,  DisbursementMethod disbursementMethod,  String preferredLanguage,  bool hasHousingBenefit,  double? housingValuePerMonth,  bool hasFoodBenefit,  double? foodValuePerMonth,  DateTime? dateOfBirth,  String? profileImageUrl,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PayrollEmployee():
return $default(_that.id,_that.firstName,_that.lastName,_that.idOrPassportNumber,_that.phone,_that.email,_that.address,_that.nextOfKinName,_that.nextOfKinPhone,_that.status,_that.engagementType,_that.occupationTitle,_that.payGroupId,_that.payStructureId,_that.startDate,_that.endDate,_that.bankName,_that.bankAccountNumber,_that.bankBranchCode,_that.disbursementMethod,_that.preferredLanguage,_that.hasHousingBenefit,_that.housingValuePerMonth,_that.hasFoodBenefit,_that.foodValuePerMonth,_that.dateOfBirth,_that.profileImageUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String idOrPassportNumber,  String? phone,  String? email,  String address,  String nextOfKinName,  String nextOfKinPhone,  EmploymentStatus status,  EngagementType engagementType,  String occupationTitle,  String? payGroupId,  String? payStructureId,  DateTime startDate,  DateTime? endDate,  String? bankName,  String? bankAccountNumber,  String? bankBranchCode,  DisbursementMethod disbursementMethod,  String preferredLanguage,  bool hasHousingBenefit,  double? housingValuePerMonth,  bool hasFoodBenefit,  double? foodValuePerMonth,  DateTime? dateOfBirth,  String? profileImageUrl,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PayrollEmployee() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.idOrPassportNumber,_that.phone,_that.email,_that.address,_that.nextOfKinName,_that.nextOfKinPhone,_that.status,_that.engagementType,_that.occupationTitle,_that.payGroupId,_that.payStructureId,_that.startDate,_that.endDate,_that.bankName,_that.bankAccountNumber,_that.bankBranchCode,_that.disbursementMethod,_that.preferredLanguage,_that.hasHousingBenefit,_that.housingValuePerMonth,_that.hasFoodBenefit,_that.foodValuePerMonth,_that.dateOfBirth,_that.profileImageUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PayrollEmployee extends PayrollEmployee {
  const _PayrollEmployee({required this.id, required this.firstName, required this.lastName, required this.idOrPassportNumber, this.phone, this.email, required this.address, required this.nextOfKinName, required this.nextOfKinPhone, required this.status, required this.engagementType, required this.occupationTitle, this.payGroupId, this.payStructureId, required this.startDate, this.endDate, this.bankName, this.bankAccountNumber, this.bankBranchCode, required this.disbursementMethod, required this.preferredLanguage, required this.hasHousingBenefit, this.housingValuePerMonth, required this.hasFoodBenefit, this.foodValuePerMonth, this.dateOfBirth, this.profileImageUrl, required this.createdAt, required this.updatedAt}): super._();
  factory _PayrollEmployee.fromJson(Map<String, dynamic> json) => _$PayrollEmployeeFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String idOrPassportNumber;
@override final  String? phone;
@override final  String? email;
@override final  String address;
@override final  String nextOfKinName;
@override final  String nextOfKinPhone;
@override final  EmploymentStatus status;
@override final  EngagementType engagementType;
@override final  String occupationTitle;
@override final  String? payGroupId;
@override final  String? payStructureId;
@override final  DateTime startDate;
@override final  DateTime? endDate;
@override final  String? bankName;
@override final  String? bankAccountNumber;
@override final  String? bankBranchCode;
@override final  DisbursementMethod disbursementMethod;
@override final  String preferredLanguage;
@override final  bool hasHousingBenefit;
@override final  double? housingValuePerMonth;
@override final  bool hasFoodBenefit;
@override final  double? foodValuePerMonth;
@override final  DateTime? dateOfBirth;
@override final  String? profileImageUrl;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PayrollEmployee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayrollEmployeeCopyWith<_PayrollEmployee> get copyWith => __$PayrollEmployeeCopyWithImpl<_PayrollEmployee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PayrollEmployeeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayrollEmployee&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.idOrPassportNumber, idOrPassportNumber) || other.idOrPassportNumber == idOrPassportNumber)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.nextOfKinName, nextOfKinName) || other.nextOfKinName == nextOfKinName)&&(identical(other.nextOfKinPhone, nextOfKinPhone) || other.nextOfKinPhone == nextOfKinPhone)&&(identical(other.status, status) || other.status == status)&&(identical(other.engagementType, engagementType) || other.engagementType == engagementType)&&(identical(other.occupationTitle, occupationTitle) || other.occupationTitle == occupationTitle)&&(identical(other.payGroupId, payGroupId) || other.payGroupId == payGroupId)&&(identical(other.payStructureId, payStructureId) || other.payStructureId == payStructureId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankAccountNumber, bankAccountNumber) || other.bankAccountNumber == bankAccountNumber)&&(identical(other.bankBranchCode, bankBranchCode) || other.bankBranchCode == bankBranchCode)&&(identical(other.disbursementMethod, disbursementMethod) || other.disbursementMethod == disbursementMethod)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.hasHousingBenefit, hasHousingBenefit) || other.hasHousingBenefit == hasHousingBenefit)&&(identical(other.housingValuePerMonth, housingValuePerMonth) || other.housingValuePerMonth == housingValuePerMonth)&&(identical(other.hasFoodBenefit, hasFoodBenefit) || other.hasFoodBenefit == hasFoodBenefit)&&(identical(other.foodValuePerMonth, foodValuePerMonth) || other.foodValuePerMonth == foodValuePerMonth)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,idOrPassportNumber,phone,email,address,nextOfKinName,nextOfKinPhone,status,engagementType,occupationTitle,payGroupId,payStructureId,startDate,endDate,bankName,bankAccountNumber,bankBranchCode,disbursementMethod,preferredLanguage,hasHousingBenefit,housingValuePerMonth,hasFoodBenefit,foodValuePerMonth,dateOfBirth,profileImageUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'PayrollEmployee(id: $id, firstName: $firstName, lastName: $lastName, idOrPassportNumber: $idOrPassportNumber, phone: $phone, email: $email, address: $address, nextOfKinName: $nextOfKinName, nextOfKinPhone: $nextOfKinPhone, status: $status, engagementType: $engagementType, occupationTitle: $occupationTitle, payGroupId: $payGroupId, payStructureId: $payStructureId, startDate: $startDate, endDate: $endDate, bankName: $bankName, bankAccountNumber: $bankAccountNumber, bankBranchCode: $bankBranchCode, disbursementMethod: $disbursementMethod, preferredLanguage: $preferredLanguage, hasHousingBenefit: $hasHousingBenefit, housingValuePerMonth: $housingValuePerMonth, hasFoodBenefit: $hasFoodBenefit, foodValuePerMonth: $foodValuePerMonth, dateOfBirth: $dateOfBirth, profileImageUrl: $profileImageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PayrollEmployeeCopyWith<$Res> implements $PayrollEmployeeCopyWith<$Res> {
  factory _$PayrollEmployeeCopyWith(_PayrollEmployee value, $Res Function(_PayrollEmployee) _then) = __$PayrollEmployeeCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String idOrPassportNumber, String? phone, String? email, String address, String nextOfKinName, String nextOfKinPhone, EmploymentStatus status, EngagementType engagementType, String occupationTitle, String? payGroupId, String? payStructureId, DateTime startDate, DateTime? endDate, String? bankName, String? bankAccountNumber, String? bankBranchCode, DisbursementMethod disbursementMethod, String preferredLanguage, bool hasHousingBenefit, double? housingValuePerMonth, bool hasFoodBenefit, double? foodValuePerMonth, DateTime? dateOfBirth, String? profileImageUrl, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PayrollEmployeeCopyWithImpl<$Res>
    implements _$PayrollEmployeeCopyWith<$Res> {
  __$PayrollEmployeeCopyWithImpl(this._self, this._then);

  final _PayrollEmployee _self;
  final $Res Function(_PayrollEmployee) _then;

/// Create a copy of PayrollEmployee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? idOrPassportNumber = null,Object? phone = freezed,Object? email = freezed,Object? address = null,Object? nextOfKinName = null,Object? nextOfKinPhone = null,Object? status = null,Object? engagementType = null,Object? occupationTitle = null,Object? payGroupId = freezed,Object? payStructureId = freezed,Object? startDate = null,Object? endDate = freezed,Object? bankName = freezed,Object? bankAccountNumber = freezed,Object? bankBranchCode = freezed,Object? disbursementMethod = null,Object? preferredLanguage = null,Object? hasHousingBenefit = null,Object? housingValuePerMonth = freezed,Object? hasFoodBenefit = null,Object? foodValuePerMonth = freezed,Object? dateOfBirth = freezed,Object? profileImageUrl = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PayrollEmployee(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,idOrPassportNumber: null == idOrPassportNumber ? _self.idOrPassportNumber : idOrPassportNumber // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,nextOfKinName: null == nextOfKinName ? _self.nextOfKinName : nextOfKinName // ignore: cast_nullable_to_non_nullable
as String,nextOfKinPhone: null == nextOfKinPhone ? _self.nextOfKinPhone : nextOfKinPhone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmploymentStatus,engagementType: null == engagementType ? _self.engagementType : engagementType // ignore: cast_nullable_to_non_nullable
as EngagementType,occupationTitle: null == occupationTitle ? _self.occupationTitle : occupationTitle // ignore: cast_nullable_to_non_nullable
as String,payGroupId: freezed == payGroupId ? _self.payGroupId : payGroupId // ignore: cast_nullable_to_non_nullable
as String?,payStructureId: freezed == payStructureId ? _self.payStructureId : payStructureId // ignore: cast_nullable_to_non_nullable
as String?,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankAccountNumber: freezed == bankAccountNumber ? _self.bankAccountNumber : bankAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,bankBranchCode: freezed == bankBranchCode ? _self.bankBranchCode : bankBranchCode // ignore: cast_nullable_to_non_nullable
as String?,disbursementMethod: null == disbursementMethod ? _self.disbursementMethod : disbursementMethod // ignore: cast_nullable_to_non_nullable
as DisbursementMethod,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,hasHousingBenefit: null == hasHousingBenefit ? _self.hasHousingBenefit : hasHousingBenefit // ignore: cast_nullable_to_non_nullable
as bool,housingValuePerMonth: freezed == housingValuePerMonth ? _self.housingValuePerMonth : housingValuePerMonth // ignore: cast_nullable_to_non_nullable
as double?,hasFoodBenefit: null == hasFoodBenefit ? _self.hasFoodBenefit : hasFoodBenefit // ignore: cast_nullable_to_non_nullable
as bool,foodValuePerMonth: freezed == foodValuePerMonth ? _self.foodValuePerMonth : foodValuePerMonth // ignore: cast_nullable_to_non_nullable
as double?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
