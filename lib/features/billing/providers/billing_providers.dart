import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/billing/data/billing_data_source.dart';
import 'package:mobile_app/features/billing/data/billing_remote_data_source.dart';
import 'package:mobile_app/features/billing/models/plan.dart';
import 'package:mobile_app/features/billing/models/subscription.dart';

/// Provides the concrete [BillingDataSource] implementation.
final billingDataSourceProvider = Provider<BillingDataSource>((ref) {
  final dio = ref.read(apiDioProvider);
  return BillingRemoteDataSource(dio);
});

/// Fetches the list of available plans from the backend.
/// These are public — no auth required — but the shared Dio instance is fine
/// as the interceptor only injects a token when one exists.
final plansProvider = FutureProvider<List<BillingPlan>>((ref) async {
  return ref.watch(billingDataSourceProvider).getPlans();
});

/// Fetches the current tenant's active subscription. Requires auth.
final subscriptionProvider = FutureProvider<BillingSubscription?>((ref) async {
  try {
    return await ref.watch(billingDataSourceProvider).getSubscription();
  } catch (_) {
    return null;
  }
});
