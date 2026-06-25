/// Safely converts a JSON value that may be int, double, or String to int.
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return num.tryParse(v)?.toInt();
  return null;
}

/// Billing plan matching GET /api/v1/billing/plans response.
class BillingPlan {
  const BillingPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.priceMonthly,
    this.priceAnnual,
    required this.features,
    required this.trialEnabled,
    required this.trialDays,
  });

  final int id;
  final String name;
  final String slug; // 'starter' | 'growth' | 'enterprise'
  final int priceMonthly;
  final int? priceAnnual;
  final List<String> features;
  final bool trialEnabled;
  final int trialDays;

  factory BillingPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final List<String> featureList;
    if (rawFeatures is List) {
      featureList = rawFeatures.map((e) => e.toString()).toList();
    } else {
      featureList = const [];
    }

    return BillingPlan(
      id: _toInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      priceMonthly: _toInt(json['price_monthly']) ?? 0,
      priceAnnual: _toInt(json['price_annual']),
      features: featureList,
      trialEnabled: json['trial_enabled'] as bool? ?? false,
      trialDays: _toInt(json['trial_days']) ?? 0,
    );
  }

  /// Human-readable price string, e.g. "R 499 / mo"
  String get priceLabel {
    if (priceMonthly == 0) return 'Free';
    return 'R ${priceMonthly.toString()} / mo';
  }
}
