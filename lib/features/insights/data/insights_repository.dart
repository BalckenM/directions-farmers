import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import 'insights_data_source.dart';
import 'insights_mock_data_source.dart';
import 'insights_remote_data_source.dart';

class InsightsRepository {
  InsightsRepository(this._source);

  final InsightsDataSource _source;

  Future<Map<String, dynamic>> getMarketPrices() async {
    try {
      return await _source.getMarketPrices();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  final InsightsDataSource source = AppConstants.useMockData
      ? InsightsMockDataSource()
      : InsightsRemoteDataSource();
  return InsightsRepository(source);
});
