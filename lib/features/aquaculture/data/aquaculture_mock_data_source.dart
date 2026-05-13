import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';
import 'aquaculture_data_source.dart';

/// In-memory mock aquaculture data — no JSON files, no rootBundle.
class AquacultureMockDataSource implements AquacultureDataSource {
  static const _farmId = 'farm-001';

  @override
  Future<List<AquacultureUnit>> getUnits() async => _units;

  @override
  Future<List<WaterQualityLog>> getWaterQualityLogs() async => _waterQualityLogs;

  // StockingBatch uses DateTime, so the list cannot be const.
  static final _units = <AquacultureUnit>[
    AquacultureUnit(
      id: 'POND-001',
      farmId: _farmId,
      unitName: 'Pond A',
      unitType: 'earthen_pond',
      species: 'Tilapia (Oreochromis niloticus)',
      productionSystem: 'semi-intensive',
      areaM2: 2000.0,
      depthM: 1.5,
      status: 'active',
      waterSource: 'borehole',
      aerationType: 'paddle_wheel',
      alerts: [],
      currentDoMgL: 6.2,
      currentPh: 7.4,
      currentTempC: 26.0,
      currentAmmoniaMgL: 0.3,
      doAlert: false,
      phAlert: false,
      ammoniaAlert: false,
      currentBatch: StockingBatch(
        id: 'BATCH-001',
        unitId: 'POND-001',
        species: 'Tilapia',
        strain: 'GIFT',
        stockingDate: DateTime(2024, 1, 10),
        initialCount: 4000,
        currentCount: 3850,
        mortalityCount: 150,
        avgWeightG: 285.0,
        fcrToDate: 1.45,
        daysInCulture: 95,
        targetHarvestWeightG: 500.0,
        status: 'active',
      ),
    ),
    const AquacultureUnit(
      id: 'TANK-001',
      farmId: _farmId,
      unitName: 'RAS Tank 1',
      unitType: 'ras_tank',
      species: 'Trout (Oncorhynchus mykiss)',
      productionSystem: 'intensive',
      capacityM3: 50.0,
      status: 'active',
      waterSource: 'municipal',
      aerationType: 'diffuser',
      alerts: [],
      currentDoMgL: 8.5,
      currentPh: 7.1,
      currentTempC: 14.0,
      currentAmmoniaMgL: 0.1,
    ),
  ];

  static const _waterQualityLogs = [
    WaterQualityLog(
      id: 'WQ-001',
      pondId: 'POND-001',
      recordedAt: '2024-04-15T06:30:00',
      session: 'morning',
      recordedBy: 'Sipho Dlamini',
      temperatureC: 25.8,
      dissolvedOxygenMgL: 6.2,
      ph: 7.4,
      ammoniaMgL: 0.28,
      nitriteMgL: 0.05,
      turbidityNtu: 22.0,
    ),
    WaterQualityLog(
      id: 'WQ-002',
      pondId: 'POND-001',
      recordedAt: '2024-04-15T14:30:00',
      session: 'afternoon',
      recordedBy: 'Sipho Dlamini',
      temperatureC: 28.2,
      dissolvedOxygenMgL: 7.8,
      ph: 7.9,
      ammoniaMgL: 0.35,
    ),
    WaterQualityLog(
      id: 'WQ-003',
      pondId: 'TANK-001',
      recordedAt: '2024-04-15T07:00:00',
      session: 'morning',
      temperatureC: 14.0,
      dissolvedOxygenMgL: 8.5,
      ph: 7.1,
      ammoniaMgL: 0.1,
    ),
  ];
}
