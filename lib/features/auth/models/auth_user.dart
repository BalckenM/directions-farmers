import 'dart:convert';

/// The authenticated farmer user model.
///
/// Fields mirror what the real 4D Farmer API will eventually return.
/// User model returned by the auth API.
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

  /// Alias: company name (backend field) == farmName (legacy Flutter field).
  String get companyName => farmName;

  /// Alias: features list from backend JWT == activatedModules.
  List<String> get features => activatedModules;

  /// True when backend status is 'trialing' (or legacy 'trial').
  bool get isTrialing =>
      subscriptionStatus == 'trialing' || subscriptionStatus == 'trial';

  /// True when subscription allows full access.
  bool get isActive =>
      subscriptionStatus == 'active' ||
      subscriptionStatus == 'trialing' ||
      subscriptionStatus == 'trial';

  /// Backward-compat alias — prefer [isTrialing].
  bool get isOnTrial => isTrialing;

  bool hasModule(String module) => activatedModules.contains(module);

  /// True when the user has a specific backend feature flag (e.g. 'payroll').
  bool hasFeature(String key) => activatedModules.contains(key);

  bool get isOwner => farmOwnerId == null;

  // ── Serialisation ────────────────────────────────────────────────────────────
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // ── Name splitting ──────────────────────────────────────────────────────
    // Backend JWT payload returns a single `name` field.
    // Legacy/Flutter-side payloads may have firstName / first_name separately.
    String firstName =
        (json['firstName'] ?? json['first_name']) as String? ?? '';
    String lastName = (json['lastName'] ?? json['last_name']) as String? ?? '';
    if (firstName.isEmpty && lastName.isEmpty) {
      final fullName = (json['name'] as String? ?? '').trim();
      final spaceIdx = fullName.indexOf(' ');
      if (spaceIdx > 0) {
        firstName = fullName.substring(0, spaceIdx);
        lastName = fullName.substring(spaceIdx + 1);
      } else {
        firstName = fullName;
        lastName = '';
      }
    }

    // ── Activated modules ───────────────────────────────────────────────────
    // Backend JWT payload uses `features`; Flutter-side uses `activatedModules`
    // or `activated_modules`.
    final rawModules =
        json['activatedModules'] ??
        json['activated_modules'] ??
        json['features'];
    final modules =
        (rawModules as List<dynamic>?)?.map((e) => e as String).toList() ??
        const <String>[];

    // ── Subscription status ─────────────────────────────────────────────────
    // Backend uses `subscription_status`; map 'trialing' → 'trial' for display.
    final subscriptionStatus =
        (json['subscriptionStatus'] ?? json['subscription_status'])
            as String? ??
        'trialing';

    // ── Subscription plan ───────────────────────────────────────────────────
    // Derived from plan features on the backend; stored in `plan_slug` or
    // inferred from the user object where available.
    final subscriptionPlan =
        (json['subscriptionPlan'] ??
                json['subscription_plan'] ??
                json['plan_slug'])
            as String? ??
        'starter';

    return AuthUser(
      id: (json['id'] ?? '').toString(),
      email: json['email'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      farmName:
          (json['farmName'] ?? json['farm_name'] ?? json['company_name'] ?? '')
              as String? ??
          '',
      country: json['country'] as String? ?? '',
      province: json['province'] as String? ?? '',
      subscriptionPlan: subscriptionPlan,
      subscriptionStatus: subscriptionStatus,
      activatedModules: modules,
      mfaEnabled: (json['mfaEnabled'] ?? json['mfa_enabled']) as bool? ?? false,
      trialEndsAt: _parseDateTime(json['trialEndsAt'] ?? json['trial_ends_at']),
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'superAdmin',
      farmOwnerId: (json['farmOwnerId'] ?? json['farm_owner_id']) as String?,
      jobTitle: (json['jobTitle'] ?? json['job_title']) as String?,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

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
