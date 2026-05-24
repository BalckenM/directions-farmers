import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import 'insights_data_source.dart';

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

