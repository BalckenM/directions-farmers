import 'dart:convert';

/// The authenticated farmer user model.
///
/// Fields mirror what the real 4D Farmer API will eventually return.
/// Swap [AuthMockDataSource] for a real HTTP call to go live.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.farmName,
    required this.country,
    required this.province,
    required this.subscriptionPlan,
    this.subscriptionStatus = 'trial',
    this.activatedModules = const [],
    this.mfaEnabled = false,
    this.trialEndsAt,
    this.phone,
    this.role = 'superAdmin',
    this.farmOwnerId,
    this.jobTitle,
  });

  /// UUID string — will match the primary key from the real API.
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String farmName;
  final String country;
  final String province;

  /// 'starter' | 'growth' | 'enterprise'
  final String subscriptionPlan;

  /// 'trial' | 'active' | 'expired'
  final String subscriptionStatus;

  /// Slugs matching Flutter feature routes, e.g. ['cattle', 'poultry', 'crop']
  final List<String> activatedModules;

  final bool mfaEnabled;
  final DateTime? trialEndsAt;
  final String? phone;

  /// Role slug: 'superAdmin' | 'farmManager' | 'farmWorker' | 'veterinarian'
  final String role;

  /// Non-null for staff accounts — points to the owning farmer's [id].
  /// Null means this IS the farm owner account.
  final String? farmOwnerId;

  /// Optional job title displayed on the staff profile, e.g. 'Head Shepherd'.
  final String? jobTitle;

  // ── Convenience ─────────────────────────────────────────────────────────────
  String get fullName => '$firstName $lastName';
  bool get isOnTrial => subscriptionStatus == 'trial';
  bool hasModule(String module) => activatedModules.contains(module);
  bool get isOwner => farmOwnerId == null;

  // ── Serialisation ────────────────────────────────────────────────────────────
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String? ?? '',
    email: json['email'] as String? ?? '',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    farmName: json['farm_name'] as String? ?? '',
    country: json['country'] as String? ?? '',
    province: json['province'] as String? ?? '',
    subscriptionPlan: json['subscription_plan'] as String? ?? 'starter',
    subscriptionStatus: json['subscription_status'] as String? ?? 'trial',
    activatedModules:
        (json['activated_modules'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    mfaEnabled: json['mfa_enabled'] as bool? ?? false,
    trialEndsAt: json['trial_ends_at'] != null
        ? DateTime.tryParse(json['trial_ends_at'] as String)
        : null,
    phone: json['phone'] as String?,
    role: json['role'] as String? ?? 'superAdmin',
    farmOwnerId: json['farm_owner_id'] as String?,
    jobTitle: json['job_title'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'farm_name': farmName,
    'country': country,
    'province': province,
    'subscription_plan': subscriptionPlan,
    'subscription_status': subscriptionStatus,
    'activated_modules': activatedModules,
    'mfa_enabled': mfaEnabled,
    if (trialEndsAt != null) 'trial_ends_at': trialEndsAt!.toIso8601String(),
    if (phone != null) 'phone': phone,
    'role': role,
    if (farmOwnerId != null) 'farm_owner_id': farmOwnerId,
    if (jobTitle != null) 'job_title': jobTitle,
  };

  String toJsonString() => jsonEncode(toJson());

  AuthUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? farmName,
    String? country,
    String? province,
    String? subscriptionPlan,
    String? subscriptionStatus,
    List<String>? activatedModules,
    bool? mfaEnabled,
    DateTime? trialEndsAt,
    String? phone,
    String? role,
    Object? farmOwnerId = _sentinel,
    String? jobTitle,
  }) => AuthUser(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    farmName: farmName ?? this.farmName,
    country: country ?? this.country,
    province: province ?? this.province,
    subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
    subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    activatedModules: activatedModules ?? this.activatedModules,
    mfaEnabled: mfaEnabled ?? this.mfaEnabled,
    trialEndsAt: trialEndsAt ?? this.trialEndsAt,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    farmOwnerId: farmOwnerId == _sentinel
        ? this.farmOwnerId
        : farmOwnerId as String?,
    jobTitle: jobTitle ?? this.jobTitle,
  );
}

// Sentinel to distinguish "not passed" from an explicit null in copyWith.
const Object _sentinel = Object();
