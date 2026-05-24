import '../models/advisor_models.dart';

abstract class AdvisorDataSource {
  /// Returns a response for the given [query] using farm context.
  Future<AdvisorResponse> getAdvice(AdvisorQuery query);

  /// Returns a list of pre-generated top recommendations for a farm.
  Future<List<AdvisorResponse>> getDailyBriefing(String farmId);
}
