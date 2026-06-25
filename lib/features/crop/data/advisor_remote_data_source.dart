import '../models/advisor_models.dart';
import 'advisor_data_source.dart';

// Stub — advisor module not yet active. No HTTP calls are made.
class AdvisorRemoteDataSource implements AdvisorDataSource {
  AdvisorRemoteDataSource(dynamic _);

  @override Future<AdvisorResponse> getAdvice(AdvisorQuery query) async =>
      throw UnsupportedError('module not active');
  @override Future<List<AdvisorResponse>> getDailyBriefing(String farmId) async => const [];
}
