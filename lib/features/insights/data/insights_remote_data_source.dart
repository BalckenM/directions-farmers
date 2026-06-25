import 'insights_data_source.dart';

// Stub — insights module not yet active. No HTTP calls are made.
class InsightsRemoteDataSource implements InsightsDataSource {
  InsightsRemoteDataSource(dynamic _);

  @override Future<Map<String, dynamic>> getMarketPrices() async => const {};
}
