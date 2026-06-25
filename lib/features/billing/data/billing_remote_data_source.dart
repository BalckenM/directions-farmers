import 'package:dio/dio.dart';

import 'package:mobile_app/features/billing/data/billing_data_source.dart';
import 'package:mobile_app/features/billing/models/plan.dart';
import 'package:mobile_app/features/billing/models/subscription.dart';

class BillingRemoteDataSource implements BillingDataSource {
  BillingRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<BillingPlan>> getPlans() async {
    final response = await _dio.get<dynamic>('/billing/plans');
    final body = response.data;

    // Backend may wrap in { data: [...] } or return plain list
    final List<dynamic> list;
    if (body is List) {
      list = body;
    } else if (body is Map<String, dynamic> && body['data'] is List) {
      list = body['data'] as List<dynamic>;
    } else {
      return const [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(BillingPlan.fromJson)
        .toList();
  }

  @override
  Future<BillingSubscription> getSubscription() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/billing/subscription',
    );
    final body = response.data!;
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return BillingSubscription.fromJson(data);
  }

  @override
  Future<Map<String, String>> initiateCheckout({
    required String planSlug,
    String billingCycle = 'monthly',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/billing/checkout',
      data: {'plan_slug': planSlug, 'billing_cycle': billingCycle},
    );
    final body = response.data!;
    return {
      'redirectUrl':
          body['redirectUrl'] as String? ??
          body['redirect_url'] as String? ??
          '',
      'm_payment_id': body['m_payment_id'] as String? ?? '',
    };
  }
}
