import '../models/disease_detection.dart';
import 'disease_data_source.dart';

// Stub — disease detection module not yet active. No HTTP calls are made.
class DiseaseRemoteDataSource implements DiseaseDataSource {
  DiseaseRemoteDataSource(dynamic _);

  @override Future<List<DiseaseInfo>> getDiseaseLibrary() async => const [];
  @override Future<DiseaseDetectionResult> detectDisease({
    required String imagePath,
    String? cropHint,
  }) async => throw UnsupportedError('module not active');
}
