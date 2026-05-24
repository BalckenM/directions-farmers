import '../models/disease_detection.dart';
import 'disease_data_source.dart';

class DiseaseRemoteDataSource implements DiseaseDataSource {
  @override
  Future<List<DiseaseInfo>> getDiseaseLibrary() =>
      throw UnimplementedError('getDiseaseLibrary not implemented');

  @override
  Future<DiseaseDetectionResult> detectDisease({
    required String imagePath,
    String? cropHint,
  }) =>
      throw UnimplementedError('detectDisease not implemented');
}
