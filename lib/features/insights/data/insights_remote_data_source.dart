import 'insights_data_source.dart';

class InsightsRemoteDataSource implements InsightsDataSource {
  @override
  Future<Map<String, dynamic>> getMarketPrices() =>
      throw UnimplementedError('InsightsRemoteDataSource.getMarketPrices not implemented');
}
