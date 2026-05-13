import '../models/apiculture.dart';
import 'apiculture_data_source.dart';

/// In-memory mock apiculture data — no JSON files, no rootBundle.
class ApicultureMockDataSource implements ApicultureDataSource {
  static const _farmId = 'farm-001';

  @override
  Future<List<Apiary>> getApiaries() async => _apiaries;

  @override
  Future<List<Hive>> getHives() async => _hives;

  @override
  Future<List<HiveInspection>> getHiveInspections() async => _inspections;

  static const _apiaries = [
    Apiary(
      id: 'AP-001',
      farmId: _farmId,
      apiaryName: 'Orchard Apiary',
      totalHives: 12,
      locationDescription: 'Adjacent to apple and citrus orchard, east section',
      forageDescription: 'Mixed fynbos, citrus blossom, macadamia',
      waterSourceNearby: true,
    ),
    Apiary(
      id: 'AP-002',
      farmId: _farmId,
      apiaryName: 'Bush Apiary',
      totalHives: 8,
      locationDescription: 'Northern boundary, indigenous bush',
      forageDescription: 'Indigenous fynbos, aloes, proteas',
      waterSourceNearby: false,
    ),
  ];

  static const _hives = [
    Hive(
      id: 'H-001',
      apiaryId: 'AP-001',
      farmId: _farmId,
      hiveNumber: 'H-001',
      hiveType: 'Langstroth',
      beeSubspecies: 'Apis mellifera scutellata',
      hiveStatus: 'active',
      installationDate: '2022-09-01',
      colonyStrengthScore: 8,
      supersOn: 2,
      honeyStoresFrames: 6.0,
      lastInspectionDate: '2024-04-01',
      nextInspectionDue: '2024-04-29',
      inspectionOverdue: false,
      queenAgeMonths: 18,
      queenMarked: true,
      queenColorYear: 'yellow',
      queenStatus: 'present_laying',
      varroaLastCountDate: '2024-03-15',
      varroaInfestationRatePct: 1.8,
      totalHoneyHarvestedKg: 42.5,
    ),
    Hive(
      id: 'H-002',
      apiaryId: 'AP-001',
      farmId: _farmId,
      hiveNumber: 'H-002',
      hiveType: 'Langstroth',
      beeSubspecies: 'Apis mellifera capensis',
      hiveStatus: 'active',
      installationDate: '2023-02-14',
      colonyStrengthScore: 6,
      supersOn: 1,
      honeyStoresFrames: 4.0,
      lastInspectionDate: '2024-04-01',
      nextInspectionDue: '2024-04-29',
      inspectionOverdue: false,
      queenAgeMonths: 14,
      queenMarked: false,
      queenStatus: 'present_laying',
      varroaLastCountDate: '2024-03-15',
      varroaInfestationRatePct: 3.5,
      totalHoneyHarvestedKg: 28.0,
    ),
    Hive(
      id: 'H-003',
      apiaryId: 'AP-002',
      farmId: _farmId,
      hiveNumber: 'H-003',
      hiveType: 'Warre',
      beeSubspecies: 'Apis mellifera scutellata',
      hiveStatus: 'queenless',
      installationDate: '2021-11-20',
      colonyStrengthScore: 3,
      supersOn: 0,
      honeyStoresFrames: 2.0,
      lastInspectionDate: '2024-03-20',
      nextInspectionDue: '2024-04-17',
      inspectionOverdue: true,
      queenStatus: 'absent',
      totalHoneyHarvestedKg: 15.0,
    ),
  ];

  static const _inspections = [
    HiveInspection(
      id: 'INS-001',
      hiveId: 'H-001',
      inspectionDate: '2024-04-01',
      inspector: 'Koos van der Berg',
      weather: 'sunny, light breeze',
      colonyTemperament: 'calm',
      beePopulationFrames: 8,
      broodFrames: 5,
      broodPattern: 'solid',
      queenSeen: true,
      queenCondition: 'healthy',
      eggsSeen: true,
      honeyStoresFrames: 6.0,
      swarmCellsPresent: false,
      supersedureCells: false,
      diseaseSigns: 'none',
      actionTaken: 'added super',
      nextInspectionDate: '2024-04-29',
    ),
    HiveInspection(
      id: 'INS-002',
      hiveId: 'H-002',
      inspectionDate: '2024-04-01',
      inspector: 'Koos van der Berg',
      weather: 'sunny',
      colonyTemperament: 'slightly_defensive',
      beePopulationFrames: 6,
      broodFrames: 4,
      broodPattern: 'solid',
      queenSeen: false,
      eggsSeen: true,
      honeyStoresFrames: 4.0,
      swarmCellsPresent: false,
      actionTaken: 'applied oxalic acid vaporisation with varroa count on 2024-03-15',
      nextInspectionDate: '2024-04-29',
    ),
  ];
}
