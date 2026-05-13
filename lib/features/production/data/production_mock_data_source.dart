import '../models/egg_record.dart';
import '../models/milk_record.dart';
import '../models/wool_record.dart';
import 'production_data_source.dart';

/// In-memory mock production data — no JSON files, no rootBundle.
class ProductionMockDataSource implements ProductionDataSource {
  @override
  Future<List<MilkRecord>> getMilkRecords() async => _milkRecords;

  @override
  Future<List<EggRecord>> getEggRecords() async => _eggRecords;

  @override
  Future<List<WoolRecord>> getWoolRecords() async => _woolRecords;

  static const _milkRecords = [
    MilkRecord(
      id: 'MR-001',
      animalId: 'C-001',
      animalType: 'cattle',
      sessionDate: '2024-04-01',
      session: 'morning',
      yieldLitres: 18.5,
      fatPct: 3.8,
      proteinPct: 3.2,
      sccCellsPerMl: 120000,
    ),
    MilkRecord(
      id: 'MR-002',
      animalId: 'C-001',
      animalType: 'cattle',
      sessionDate: '2024-04-01',
      session: 'evening',
      yieldLitres: 14.2,
      fatPct: 4.1,
      proteinPct: 3.3,
      sccCellsPerMl: 135000,
    ),
    MilkRecord(
      id: 'MR-003',
      animalId: 'C-002',
      animalType: 'cattle',
      sessionDate: '2024-04-02',
      session: 'morning',
      yieldLitres: 21.0,
      fatPct: 3.6,
      proteinPct: 3.1,
      sccCellsPerMl: 95000,
    ),
    MilkRecord(
      id: 'MR-004',
      animalId: 'G-002',
      animalType: 'goats',
      sessionDate: '2024-04-02',
      session: 'morning',
      yieldLitres: 1.8,
      fatPct: 4.5,
      sccCellsPerMl: 180000,
    ),
    MilkRecord(
      id: 'MR-005',
      animalId: 'C-001',
      animalType: 'cattle',
      sessionDate: '2024-04-03',
      session: 'morning',
      yieldLitres: 17.9,
      fatPct: 3.9,
      proteinPct: 3.2,
      sccCellsPerMl: 450000,
    ),
  ];

  static const _eggRecords = [
    EggRecord(
      id: 'ER-001',
      flockId: 'FL-001',
      collectionDate: '2024-04-01',
      collectionSession: 'morning',
      eggsCollected: 240,
      eggsBroken: 3,
      eggsGraded: 237,
    ),
    EggRecord(
      id: 'ER-002',
      flockId: 'FL-001',
      collectionDate: '2024-04-01',
      collectionSession: 'afternoon',
      eggsCollected: 180,
      eggsBroken: 2,
      eggsGraded: 178,
    ),
    EggRecord(
      id: 'ER-003',
      flockId: 'FL-002',
      collectionDate: '2024-04-02',
      collectionSession: 'morning',
      eggsCollected: 310,
      eggsBroken: 5,
      eggsGraded: 305,
    ),
    EggRecord(
      id: 'ER-004',
      flockId: 'FL-001',
      collectionDate: '2024-04-02',
      collectionSession: 'morning',
      eggsCollected: 255,
      eggsBroken: 4,
      eggsGraded: 251,
    ),
  ];

  static const _woolRecords = [
    WoolRecord(
      id: 'WOL-001',
      farmId: 'FARM-001',
      shearingDate: '2024-07-15',
      greasyFleeceWeightKg: 4.8,
      animalId: 'S-001',
      animalType: 'sheep',
      skirtedWeightKg: 4.2,
      woolMicron: 19.5,
      stapleLengthMm: 85.0,
      yieldPct: 68.0,
      colorGrade: WoolColorGrade.aa,
      woolBuyer: WoolBuyer.bkb,
      pricePerKgZar: 85.0,
      baleNumber: 'BKB-2024-0471',
      isMohair: false,
    ),
    WoolRecord(
      id: 'WOL-002',
      farmId: 'FARM-001',
      shearingDate: '2024-07-16',
      greasyFleeceWeightKg: 3.2,
      animalType: 'goats',
      groupId: 'GRP-ANGORA-01',
      animalCount: 12,
      skirtedWeightKg: 2.9,
      woolMicron: 26.0,
      stapleLengthMm: 110.0,
      yieldPct: 72.0,
      woolBuyer: WoolBuyer.capeMohairAuction,
      pricePerKgZar: 220.0,
      isMohair: true,
      notes: 'Kid mohair — first clip',
    ),
  ];
}
