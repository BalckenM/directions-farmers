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

  // ── Convenience ─────────────────────────────────────────────────────────────
  String get fullName => '$firstName $lastName';
  bool get isOnTrial => subscriptionStatus == 'trial';
  bool hasModule(String module) => activatedModules.contains(module);

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
        activatedModules: (json['activated_modules'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        mfaEnabled: json['mfa_enabled'] as bool? ?? false,
        trialEndsAt: json['trial_ends_at'] != null
            ? DateTime.tryParse(json['trial_ends_at'] as String)
            : null,
        phone: json['phone'] as String?,
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
      };

  String toJsonString() => jsonEncode(toJson());
}
