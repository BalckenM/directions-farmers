import 'package:mobile_app/features/billing/models/plan.dart';

/// Active subscription matching GET /api/v1/billing/subscription response.
class BillingSubscription {
  const BillingSubscription({
    required this.id,
    required this.status,
    required this.billingCycle,
    this.trialEndsAt,
    this.currentPeriodEnd,
    required this.plan,
  });

  final int id;

  /// One of: 'trialing' | 'active' | 'past_due' | 'suspended' | 'cancelled'
  final String status;

  /// 'monthly' | 'annual'
  final String billingCycle;

  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final BillingPlan plan;

  bool get isActive => status == 'active' || status == 'trialing';

  factory BillingSubscription.fromJson(Map<String, dynamic> json) {
    final planJson = json['plan'] as Map<String, dynamic>? ?? {};
    return BillingSubscription(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'cancelled',
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      trialEndsAt: _parse(json['trial_ends_at']),
      currentPeriodEnd: _parse(json['current_period_end']),
      plan: BillingPlan.fromJson(planJson),
    );
  }

  static DateTime? _parse(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
