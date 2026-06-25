import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/core/errors/failure.dart';
import 'package:mobile_app/features/crop/models/advisor_models.dart';
import 'package:mobile_app/features/crop/data/advisor_data_source.dart';

class AdvisorRepository {
  AdvisorRepository(this._source);

  final AdvisorDataSource _source;

  Future<AdvisorResponse> getAdvice(AdvisorQuery query) async {
    try {
      return await _source.getAdvice(query);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<AdvisorResponse>> getDailyBriefing(String farmId) async {
    try {
      return await _source.getDailyBriefing(farmId);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}
