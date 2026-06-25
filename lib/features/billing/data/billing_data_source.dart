import 'package:mobile_app/features/billing/models/plan.dart';
import 'package:mobile_app/features/billing/models/subscription.dart';

abstract class BillingDataSource {
  Future<List<BillingPlan>> getPlans();
  Future<BillingSubscription> getSubscription();

  /// Initiates a Payfast checkout for [planSlug].
  /// Returns `{ 'redirectUrl': String, 'm_payment_id': String }`.
  Future<Map<String, String>> initiateCheckout({
    required String planSlug,
    String billingCycle,
  });
}
