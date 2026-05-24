import '../models/disease_detection.dart';

abstract class DiseaseDataSource {
  /// Returns a catalogue of all known diseases/conditions.
  Future<List<DiseaseInfo>> getDiseaseLibrary();

  /// Analyses an image at [imagePath] and returns detection results.
  /// [cropHint] narrows the candidate list to diseases affecting that crop.
  Future<DiseaseDetectionResult> detectDisease({
    required String imagePath,
    String? cropHint,
  });
}
