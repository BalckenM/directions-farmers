import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

// ── Keys ──────────────────────────────────────────────────────────────────────
const _kSessionKey = 'mock_auth_session';
const _kUsersKey = 'mock_auth_users';

// ── Module slugs (mirrors Flutter feature paths) ──────────────────────────────
abstract final class FarmerModules {
  static const cattle = 'cattle';
  static const goat = 'goat';
  static const poultry = 'poultry';
  static const pigs = 'pigs';
  static const aquaculture = 'aquaculture';
  static const apiculture = 'apiculture';
  static const crop = 'crop';
  static const financial = 'financial';
  static const insights = 'insights';
  static const traceability = 'traceability';
  static const reports = 'reports';
}

// ── Subscription plan definitions ─────────────────────────────────────────────

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.label,
    required this.price,
    required this.currency,
    required this.tagline,
    required this.includedModules,
    required this.features,
  });

  final String id; // 'starter' | 'growth' | 'enterprise'
  final String label;
  final int price; // monthly, in currency units
  final String currency; // 'ZAR'
  final String tagline;
  final List<String> includedModules;
  final List<String> features; // human-readable feature bullets
}

const List<SubscriptionPlan> kSubscriptionPlans = [
  SubscriptionPlan(
    id: 'starter',
    label: 'Starter',
    price: 199,
    currency: 'ZAR',
    tagline: 'Perfect for small family farms',
    includedModules: [
      FarmerModules.cattle,
      FarmerModules.goat,
      FarmerModules.poultry,
      FarmerModules.pigs,
    ],
    features: [
      'Up to 4 livestock species',
      'Health & vaccination tracking',
      'Basic production records',
      'Breeding & calving/kidding records',
      '30-day data history',
    ],
  ),
  SubscriptionPlan(
    id: 'growth',
    label: 'Growth',
    price: 499,
    currency: 'ZAR',
    tagline: 'Scale your farming operation',
    includedModules: [
      FarmerModules.cattle,
      FarmerModules.goat,
      FarmerModules.poultry,
      FarmerModules.pigs,
      FarmerModules.aquaculture,
      FarmerModules.apiculture,
      FarmerModules.crop,
      FarmerModules.financial,
      FarmerModules.insights,
    ],
    features: [
      'Everything in Starter',
      'Crop farming & season planner',
      'Financial records & profitability',
      'Aquaculture & apiculture modules',
      'Analytics & insights dashboard',
      'Unlimited data history',
    ],
  ),
  SubscriptionPlan(
    id: 'enterprise',
    label: 'Enterprise',
    price: 999,
    currency: 'ZAR',
    tagline: 'Full-scale commercial farming',
    includedModules: [
      FarmerModules.cattle,
      FarmerModules.goat,
      FarmerModules.poultry,
      FarmerModules.pigs,
      FarmerModules.aquaculture,
      FarmerModules.apiculture,
      FarmerModules.crop,
      FarmerModules.financial,
      FarmerModules.insights,
      FarmerModules.traceability,
      FarmerModules.reports,
    ],
    features: [
      'Everything in Growth',
      'Animal movement traceability',
      'Automated PDF/CSV reports',
      'Multi-farm support (coming soon)',
      'Priority support',
      'Early access to new features',
    ],
  ),
];

// ── Country → Province data ───────────────────────────────────────────────────

const Map<String, List<String>> kCountryProvinces = {
  'South Africa': [
    'Eastern Cape',
    'Free State',
    'Gauteng',
    'KwaZulu-Natal',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Northern Cape',
    'Western Cape',
  ],
  'Zimbabwe': [
    'Bulawayo',
    'Harare',
    'Manicaland',
    'Mashonaland Central',
    'Mashonaland East',
    'Mashonaland West',
    'Masvingo',
    'Matabeleland North',
    'Matabeleland South',
    'Midlands',
  ],
  'Zambia': [
    'Central',
    'Copperbelt',
    'Eastern',
    'Luapula',
    'Lusaka',
    'Muchinga',
    'Northern',
    'North-Western',
    'Southern',
    'Western',
  ],
  'Kenya': [
    'Central',
    'Coast',
    'Eastern',
    'Nairobi',
    'North Eastern',
    'Nyanza',
    'Rift Valley',
    'Western',
  ],
  'Other': ['N/A'],
};

// ── Mock data source ──────────────────────────────────────────────────────────

/// In-memory + SharedPreferences backed auth source.
///
/// All data is stored in [SharedPreferences] so the session survives hot
/// restarts. Replace this class with a real HTTP client when the backend
/// is ready — the [AuthNotifier] will not need to change.
class AuthMockDataSource {
  const AuthMockDataSource(this._prefs);

  final SharedPreferences _prefs;

  // ── Pre-seeded demo accounts ─────────────────────────────────────────────

  static final _seedUsers = <String, Map<String, dynamic>>{
    'demo@4dfarmer.com': {
      'password': 'demo1234',
      'user': AuthUser(
        id: 'farmer_demo_001',
        email: 'demo@4dfarmer.com',
        firstName: 'John',
        lastName: 'Dlamini',
        farmName: 'Green Valley Farm',
        country: 'South Africa',
        province: 'KwaZulu-Natal',
        subscriptionPlan: 'growth',
        subscriptionStatus: 'active',
        activatedModules: [
          FarmerModules.cattle,
          FarmerModules.goat,
          FarmerModules.poultry,
          FarmerModules.pigs,
          FarmerModules.crop,
          FarmerModules.financial,
          FarmerModules.insights,
        ],
        phone: '+27 82 555 0101',
      ),
    },
    'starter@4dfarmer.com': {
      'password': 'demo1234',
      'user': AuthUser(
        id: 'farmer_demo_002',
        email: 'starter@4dfarmer.com',
        firstName: 'Amara',
        lastName: 'Moyo',
        farmName: 'Sunrise Livestock',
        country: 'Zimbabwe',
        province: 'Mashonaland East',
        subscriptionPlan: 'starter',
        subscriptionStatus: 'trial',
        activatedModules: [
          FarmerModules.cattle,
          FarmerModules.goat,
          FarmerModules.poultry,
          FarmerModules.pigs,
        ],
        trialEndsAt: DateTime.now().add(const Duration(days: 14)),
      ),
    },
    'enterprise@4dfarmer.com': {
      'password': 'demo1234',
      'user': AuthUser(
        id: 'farmer_demo_003',
        email: 'enterprise@4dfarmer.com',
        firstName: 'Thabo',
        lastName: 'Nkosi',
        farmName: 'Nkosi Agri Holdings',
        country: 'South Africa',
        province: 'Limpopo',
        subscriptionPlan: 'enterprise',
        subscriptionStatus: 'active',
        activatedModules: [
          FarmerModules.cattle,
          FarmerModules.goat,
          FarmerModules.poultry,
          FarmerModules.pigs,
          FarmerModules.aquaculture,
          FarmerModules.apiculture,
          FarmerModules.crop,
          FarmerModules.financial,
          FarmerModules.insights,
          FarmerModules.traceability,
          FarmerModules.reports,
        ],
        phone: '+27 71 555 0202',
      ),
    },
  };

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the full user registry (seed + any self-registered users).
  Map<String, Map<String, dynamic>> _loadRegistry() {
    final json = _prefs.getString(_kUsersKey);
    if (json == null) return {};

    final decoded = jsonDecode(json) as Map<String, dynamic>;
    final result = <String, Map<String, dynamic>>{};
    for (final entry in decoded.entries) {
      final value = entry.value as Map<String, dynamic>;
      result[entry.key] = {
        'password': value['password'] as String,
        'user': AuthUser.fromJson(value['user'] as Map<String, dynamic>),
      };
    }
    return result;
  }

  Future<void> _saveRegistry(Map<String, Map<String, dynamic>> registry) async {
    final serialisable = <String, dynamic>{};
    for (final entry in registry.entries) {
      serialisable[entry.key] = {
        'password': entry.value['password'],
        'user': (entry.value['user'] as AuthUser).toJson(),
      };
    }
    await _prefs.setString(_kUsersKey, jsonEncode(serialisable));
  }

  /// Merges seed users (read-only) with any persisted registered users.
  Map<String, Map<String, dynamic>> _allUsers() {
    return {
      ..._seedUsers,
      ..._loadRegistry(),
    };
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Authenticates with email + password.
  ///
  /// Returns [AuthUser] on success, throws [MockAuthException] on failure.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // Simulate network

    final normalised = email.trim().toLowerCase();
    final all = _allUsers();

    if (!all.containsKey(normalised)) {
      throw const MockAuthException('No account found with that email address.');
    }

    final record = all[normalised]!;
    if (record['password'] as String != password) {
      throw const MockAuthException('Incorrect password. Please try again.');
    }

    final user = record['user'] as AuthUser;
    await _persistSession(user);
    return user;
  }

  /// Registers a new farmer account.
  ///
  /// Throws [MockAuthException] if the email is already taken.
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String farmName,
    required String country,
    required String province,
    required String subscriptionPlan,
    required List<String> activatedModules,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900)); // Simulate network

    final normalised = email.trim().toLowerCase();
    final all = _allUsers();

    if (all.containsKey(normalised)) {
      throw const MockAuthException(
          'An account with that email already exists. Please sign in.');
    }

    final user = AuthUser(
      id: 'farmer_${DateTime.now().millisecondsSinceEpoch}',
      email: normalised,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      farmName: farmName.trim(),
      country: country,
      province: province,
      subscriptionPlan: subscriptionPlan,
      subscriptionStatus: 'trial',
      activatedModules: activatedModules,
      trialEndsAt: DateTime.now().add(const Duration(days: 30)),
      phone: phone?.trim(),
    );

    // Persist to registry
    final registry = _loadRegistry();
    registry[normalised] = {'password': password, 'user': user};
    await _saveRegistry(registry);

    await _persistSession(user);
    return user;
  }

  /// Restores a previously saved session.
  ///
  /// Returns [AuthUser] if a valid session token is found, null otherwise.
  AuthUser? restoreSession() {
    final json = _prefs.getString(_kSessionKey);
    if (json == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Clears the stored session (signs out).
  Future<void> clearSession() async {
    await _prefs.remove(_kSessionKey);
  }

  // ── Private ──────────────────────────────────────────────────────────────

  Future<void> _persistSession(AuthUser user) async {
    await _prefs.setString(_kSessionKey, jsonEncode(user.toJson()));
  }
}

// ── Exception ─────────────────────────────────────────────────────────────────

class MockAuthException implements Exception {
  const MockAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
