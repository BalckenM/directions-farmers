import '../models/sow.dart';
import 'pigs_data_source.dart';

/// In-memory mock pigs data — no JSON files, no rootBundle.
class PigsMockDataSource implements PigsDataSource {
  static const _farmId = 'farm-001';

  @override
  Future<List<Sow>> getSows() async => _sows;

  @override
  Future<List<FarrowingRecord>> getFarrowingRecords() async =>
      _farrowingRecords;

  @override
  Future<List<SowServiceRecord>> getSowServiceRecords() async =>
      _serviceRecords;

  static const _sows = [
    Sow(
      id: 'SOW-001',
      farmId: _farmId,
      tagNumber: 'P-SOW-001',
      name: 'Mama',
      category: 'breeding_sow',
      breed: 'Large White',
      status: 'active',
      ageMonths: 24,
      currentWeightKg: 220.0,
      bodyConditionScore: 3.0,
      penId: 'PEN-01',
      pigSpecific: PigSpecific(
        parity: 3,
        currentStage: 'Gestation',
        backfatMm: 18.0,
        weanToServiceDays: 5,
        totalBornAliveLifetime: 28,
        psyCurrentYear: 24.5,
        expectedFarrowingDate: '2024-06-15',
        preWeanMortalityPct: 8.0,
      ),
    ),
    Sow(
      id: 'SOW-002',
      farmId: _farmId,
      tagNumber: 'P-SOW-002',
      name: 'Bertha',
      category: 'breeding_sow',
      breed: 'Landrace',
      status: 'active',
      ageMonths: 30,
      currentWeightKg: 240.0,
      bodyConditionScore: 3.5,
      penId: 'PEN-02',
      pigSpecific: PigSpecific(
        parity: 5,
        currentStage: 'Lactating',
        backfatMm: 15.0,
        weanToServiceDays: 4,
        totalBornAliveLifetime: 52,
        psyCurrentYear: 26.0,
        bornAlive: 11,
        preWeanMortalityPct: 9.1,
      ),
    ),
  ];

  static const _farrowingRecords = [
    FarrowingRecord(
      id: 'FR-001',
      sowId: 'SOW-001',
      sowTag: 'P-SOW-001',
      farrowingDate: '2024-01-20',
      parity: 2,
      totalBorn: 12,
      bornAlive: 11,
      bornDead: 1,
      mummified: 0,
      weaningDate: '2024-02-17',
      weaned: 10,
      avgBirthWeightKg: 1.45,
      preWeanMortalityPct: 9.1,
      status: 'completed',
      attendedBy: 'Jan Botha',
    ),
    FarrowingRecord(
      id: 'FR-002',
      sowId: 'SOW-002',
      sowTag: 'P-SOW-002',
      farrowingDate: '2024-02-05',
      parity: 4,
      totalBorn: 13,
      bornAlive: 12,
      bornDead: 1,
      mummified: 0,
      weaningDate: '2024-03-04',
      weaned: 11,
      avgBirthWeightKg: 1.52,
      preWeanMortalityPct: 8.3,
      status: 'completed',
      attendedBy: 'Thabo Nkosi',
    ),
  ];

  static const _serviceRecords = [
    SowServiceRecord(
      id: 'SR-001',
      sowId: 'SOW-001',
      sowTag: 'P-SOW-001',
      serviceDate: '2024-02-22',
      serviceMethod: 'AI',
      expectedFarrowingDate: '2024-06-15',
      pregnancyCheckDate: '2024-03-15',
      pregnancyResult: 'confirmed_pregnant',
      weanToServiceDays: 5,
    ),
    SowServiceRecord(
      id: 'SR-002',
      sowId: 'SOW-002',
      sowTag: 'P-SOW-002',
      serviceDate: '2024-01-10',
      serviceMethod: 'natural_mating',
      boarTag: 'P-BOAR-001',
      expectedFarrowingDate: '2024-05-04',
      pregnancyCheckDate: '2024-02-01',
      pregnancyResult: 'confirmed_pregnant',
      weanToServiceDays: 4,
    ),
  ];
}
