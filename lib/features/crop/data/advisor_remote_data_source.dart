import '../models/advisor_models.dart';
import 'advisor_data_source.dart';

class AdvisorRemoteDataSource implements AdvisorDataSource {
  @override
  Future<AdvisorResponse> getAdvice(AdvisorQuery query) =>
      throw UnimplementedError('getAdvice not implemented');

  @override
  Future<List<AdvisorResponse>> getDailyBriefing(String farmId) =>
      throw UnimplementedError('getDailyBriefing not implemented');
}
