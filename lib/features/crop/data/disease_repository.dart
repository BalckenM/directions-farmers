import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/core/errors/failure.dart';
import 'package:mobile_app/features/crop/models/disease_detection.dart';
import 'package:mobile_app/features/crop/data/disease_data_source.dart';

class DiseaseRepository {
  DiseaseRepository(this._source);

  final DiseaseDataSource _source;

  // Cache the disease library — it never changes between sessions.
  List<DiseaseInfo>? _libraryCache;

  Future<List<DiseaseInfo>> getDiseaseLibrary() async {
    try {
      _libraryCache ??= await _source.getDiseaseLibrary();
      return List.unmodifiable(_libraryCache!);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<DiseaseDetectionResult> detectDisease({
    required String imagePath,
    String? cropHint,
  }) async {
    try {
      return await _source.detectDisease(
        imagePath: imagePath,
        cropHint: cropHint,
      );
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}
