import 'poultry_data_source.dart';
import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';

class PoultryMockDataSource implements PoultryDataSource {
  static const _farmId = 'FARM-001';

  @override
  Future<List<PoultryFlock>> getFlocks() async => _flocks;

  @override
  Future<List<DailyRecord>> getDailyRecords() async => _dailyRecords;

  @override
  Future<List<VaccinationSchedule>> getVaccinationSchedules() async =>
      _vaccinationSchedules;

  @override
  Future<List<FeedPhase>> getFeedPhases() async => _feedPhases;

  @override
  Future<List<HarvestRecord>> getHarvestRecords() async => _harvestRecords;

  @override
  Future<List<MedicationLog>> getMedicationLogs() async => _medicationLogs;

  @override
  Future<List<DiseaseEvent>> getDiseaseEvents() async => _diseaseEvents;

  @override
  Future<List<EnvironmentReading>> getEnvironmentReadings() async =>
      _environmentReadings;

  @override
  Future<List<InventoryItem>> getInventoryItems() async => _inventoryItems;

  @override
  Future<List<EggSale>> getEggSales() async => _eggSales;

  @override
  Future<List<ChickSale>> getChickSales() async => _chickSales;

  // ── Flocks ─────────────────────────────────────────────────────────────────

  static final _flocks = <PoultryFlock>[
    // ── flock-001: active broiler ──────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-001',
      farmId: _farmId,
      batchName: 'Broiler Batch March 2024',
      species: 'chicken',
      productionType: 'broiler',
      strain: 'Ross 308',
      houseId: 'house-a',
      status: 'active',
      placementDate: '2024-03-01',
      placementCount: 5000,
      currentCount: 4920,
      mortalityTotal: 80,
      mortalityPct: 1.6,
      dayOfAge: 28,
      currentAvgWeightG: 920,
      feedConsumedTotalKg: 3800.0,
      fcrToDate: 1.42,
      targetSlaughterWeightG: 2400,
      projectedSlaughterDate: '2024-04-08',
      unitCostPerChick: 16.50,
      broilerSpecific: BroilerSpecific(
        target7dWeightG: 170,
        target14dWeightG: 380,
        target21dWeightG: 680,
        target28dWeightG: 1060,
        target35dWeightG: 1500,
        target42dWeightG: 2200,
        actual7dWeightG: 172,
        actual14dWeightG: 388,
        actual21dWeightG: 695,
        actual28dWeightG: 920,
        uniformityPct: 82.5,
        targetFcr42d: 1.65,
        epefCurrent: 298,
        lightingProgram: '23L:1D day 1-7, 18L:6D from day 8',
        ventilationMode: 'tunnel',
      ),
    ),
    // ── flock-002: active layer ────────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-002',
      farmId: _farmId,
      batchName: 'Layer Flock Lohmann 2024',
      species: 'chicken',
      productionType: 'layer',
      strain: 'Lohmann Brown Classic',
      houseId: 'house-b',
      status: 'active',
      placementDate: '2024-01-15',
      placementCount: 3000,
      currentCount: 2960,
      mortalityTotal: 40,
      mortalityPct: 1.33,
      dayOfAge: 75,
      weekOfAge: 10,
      currentStage: 'laying',
      livabilityPct: 98.67,
      layerSpecific: LayerSpecific(
        pointOfLayDate: '2024-03-20',
        peakProductionDate: '2024-05-01',
        peakHdpPct: 92.4,
        currentHdpPct: 78.5,
        totalEggsProduced: 56420,
        avgEggWeightG: 61.2,
        feedPerDozenKg: 1.82,
        lightingProgram: '16L:8D',
        henHousedAvgPct: 74.8,
        eggMassGPerHenPerDay: 48.0,
      ),
    ),
    // ── flock-003: active duck_meat ────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-003',
      farmId: _farmId,
      batchName: 'Duck Batch Cherry Valley Q1 2024',
      species: 'duck',
      productionType: 'duck_meat',
      strain: 'Cherry Valley',
      houseId: 'house-c',
      status: 'active',
      placementDate: '2024-02-10',
      placementCount: 2000,
      currentCount: 1965,
      mortalityTotal: 35,
      mortalityPct: 1.75,
      dayOfAge: 32,
      currentAvgWeightG: 1450,
      feedConsumedTotalKg: 2200.0,
      fcrToDate: 2.1,
      targetSlaughterWeightG: 3200,
      projectedSlaughterDate: '2024-03-31',
      duckSpecific: DuckSpecific(
        waterAccess: true,
        target42dWeightG: 3200,
        targetFcr42d: 2.2,
      ),
    ),
    // ── flock-004: harvested broiler ───────────────────────────────────────
    const PoultryFlock(
      id: 'flock-004',
      farmId: _farmId,
      batchName: 'Broiler Batch Cobb500 Jan 2024',
      species: 'chicken',
      productionType: 'broiler',
      strain: 'Cobb 500',
      houseId: 'house-d',
      status: 'harvested',
      placementDate: '2024-01-02',
      placementCount: 4800,
      currentCount: 0,
      mortalityTotal: 120,
      mortalityPct: 2.5,
      dayOfAge: 42,
      currentAvgWeightG: 2380,
      feedConsumedTotalKg: 17200.0,
      fcrToDate: 1.72,
      targetSlaughterWeightG: 2400,
      projectedSlaughterDate: '2024-02-13',
      broilerSpecific: BroilerSpecific(
        target42dWeightG: 2400,
        actual42dWeightG: 2380,
        uniformityPct: 80.1,
        targetFcr42d: 1.70,
        epefCurrent: 261,
        lightingProgram: '23L:1D day 1-7, 18L:6D from day 8',
        ventilationMode: 'tunnel',
      ),
    ),
    // ── flock-005: depleted layer ──────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-005',
      farmId: _farmId,
      batchName: 'Layer Flock Hy-Line 2023',
      species: 'chicken',
      productionType: 'layer',
      strain: 'Hy-Line Brown',
      houseId: 'house-e',
      status: 'depleted',
      placementDate: '2023-01-10',
      placementCount: 2500,
      currentCount: 0,
      mortalityTotal: 312,
      mortalityPct: 12.5,
      dayOfAge: 420,
      weekOfAge: 60,
      currentStage: 'depleted',
      livabilityPct: 87.5,
      layerSpecific: LayerSpecific(
        pointOfLayDate: '2023-06-05',
        peakProductionDate: '2023-08-12',
        peakHdpPct: 91.8,
        currentHdpPct: 0.0,
        totalEggsProduced: 582000,
        avgEggWeightG: 62.4,
        feedPerDozenKg: 1.91,
        lightingProgram: '16L:8D',
        henHousedAvgPct: 63.2,
      ),
    ),
    // ── flock-006: active breeder ──────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-006',
      farmId: _farmId,
      batchName: 'Ross PM3 Breeder Flock 2024',
      species: 'chicken',
      productionType: 'breeder',
      strain: 'Ross PM3',
      houseId: 'house-f',
      status: 'active',
      placementDate: '2023-09-01',
      placementCount: 1200,
      currentCount: 1162,
      mortalityTotal: 38,
      mortalityPct: 3.17,
      dayOfAge: 185,
      weekOfAge: 26,
      currentStage: 'production',
      breederSpecific: BreederSpecific(
        henCount: 1050,
        roosterCount: 112,
        maleFemaleRatio: '1:9.4',
        pointOfLayDate: '2024-01-20',
        peakProductionDate: '2024-03-15',
        peakHdpPct: 84.5,
        currentHdpPct: 82.1,
        fertilityPct: 94.2,
        hatchabilityPct: 88.6,
        totalHatchingEggs: 48500,
        totalChicksProduced: 42970,
        totalChicksSold: 40000,
        avgChickWeightG: 43.5,
        lightingProgram: '8L:16D rearing, 14L:10D production',
        projectedDepletionDate: '2025-06-01',
      ),
    ),
    // ── flock-007: active broiler ──────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-007',
      farmId: _farmId,
      batchName: 'Broiler Batch Ross308 April 2024',
      species: 'chicken',
      productionType: 'broiler',
      strain: 'Ross 308',
      houseId: 'house-g',
      status: 'active',
      placementDate: '2024-04-01',
      placementCount: 5200,
      currentCount: 5145,
      mortalityTotal: 55,
      mortalityPct: 1.06,
      dayOfAge: 15,
      currentAvgWeightG: 385,
      feedConsumedTotalKg: 1620.0,
      fcrToDate: 1.30,
      targetSlaughterWeightG: 2400,
      projectedSlaughterDate: '2024-05-10',
      broilerSpecific: BroilerSpecific(
        target7dWeightG: 170,
        target14dWeightG: 380,
        actual7dWeightG: 175,
        actual14dWeightG: 385,
        uniformityPct: 85.0,
        targetFcr42d: 1.65,
        epefCurrent: 312,
        lightingProgram: '23L:1D day 1-7, 18L:6D from day 8',
        ventilationMode: 'tunnel',
      ),
    ),
    // ── flock-008: active free_range ────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-008',
      farmId: _farmId,
      batchName: 'Free-Range ISA Brown Flock 2024',
      species: 'chicken',
      productionType: 'free_range',
      strain: 'ISA Brown',
      houseId: 'house-h',
      status: 'active',
      placementDate: '2023-10-01',
      placementCount: 2800,
      currentCount: 2761,
      mortalityTotal: 39,
      mortalityPct: 1.39,
      dayOfAge: 185,
      weekOfAge: 26,
      currentStage: 'laying',
      livabilityPct: 98.61,
    ),
    // ── flock-009: active pullet ───────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-009',
      farmId: _farmId,
      batchName: 'Pullet Rearing Cobb500 April 2024',
      species: 'chicken',
      productionType: 'pullet',
      strain: 'Cobb 500',
      houseId: 'house-i',
      status: 'active',
      placementDate: '2024-04-05',
      placementCount: 4600,
      currentCount: 4558,
      mortalityTotal: 42,
      mortalityPct: 0.91,
      dayOfAge: 11,
      currentAvgWeightG: 225,
      feedConsumedTotalKg: 680.0,
      fcrToDate: 1.24,
    ),
    // ── flock-010: active breeder ──────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-010',
      farmId: _farmId,
      batchName: 'Arbor Acres Breeder Flock 2023',
      species: 'chicken',
      productionType: 'breeder',
      strain: 'Arbor Acres Plus',
      houseId: 'house-j',
      status: 'active',
      placementDate: '2023-07-15',
      placementCount: 1000,
      currentCount: 965,
      mortalityTotal: 35,
      mortalityPct: 3.5,
      dayOfAge: 259,
      weekOfAge: 37,
      currentStage: 'production',
      breederSpecific: BreederSpecific(
        henCount: 880,
        roosterCount: 85,
        maleFemaleRatio: '1:10.4',
        pointOfLayDate: '2023-11-10',
        peakProductionDate: '2024-01-20',
        peakHdpPct: 83.8,
        currentHdpPct: 79.5,
        fertilityPct: 93.0,
        hatchabilityPct: 86.4,
        totalHatchingEggs: 96200,
        totalChicksProduced: 83100,
        totalChicksSold: 79000,
        avgChickWeightG: 42.8,
        lightingProgram: '8L:16D rearing, 14L:10D production',
        projectedDepletionDate: '2025-02-01',
      ),
    ),
    // ── flock-011: active turkey_meat ─────────────────────────────────────
    const PoultryFlock(
      id: 'flock-011',
      farmId: _farmId,
      batchName: 'Turkey Batch Nicholas 700 2024',
      species: 'turkey',
      productionType: 'turkey_meat',
      strain: 'Nicholas 700',
      houseId: 'house-k',
      status: 'active',
      placementDate: '2024-01-20',
      placementCount: 800,
      currentCount: 782,
      mortalityTotal: 18,
      mortalityPct: 2.25,
      dayOfAge: 76,
      currentAvgWeightG: 5800,
      feedConsumedTotalKg: 6200.0,
      fcrToDate: 2.48,
      targetSlaughterWeightG: 14000,
      projectedSlaughterDate: '2024-07-15',
    ),
    // ── flock-012: active layer ────────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-012',
      farmId: _farmId,
      batchName: 'Layer Flock Bovans Brown 2024',
      species: 'chicken',
      productionType: 'layer',
      strain: 'Bovans Brown',
      houseId: 'house-l',
      status: 'active',
      placementDate: '2023-12-01',
      placementCount: 3500,
      currentCount: 3448,
      mortalityTotal: 52,
      mortalityPct: 1.49,
      dayOfAge: 133,
      weekOfAge: 19,
      currentStage: 'laying',
      livabilityPct: 98.51,
      layerSpecific: LayerSpecific(
        pointOfLayDate: '2024-03-01',
        currentHdpPct: 88.4,
        totalEggsProduced: 127400,
        avgEggWeightG: 60.8,
        feedPerDozenKg: 1.85,
        lightingProgram: '16L:8D',
        henHousedAvgPct: 85.0,
        eggMassGPerHenPerDay: 53.8,
      ),
    ),
    // ── flock-013: active quail ────────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-013',
      farmId: _farmId,
      batchName: 'Quail Batch Japanese 2024',
      species: 'quail',
      productionType: 'quail',
      strain: 'Japanese Quail',
      houseId: 'house-m',
      status: 'active',
      placementDate: '2024-02-01',
      placementCount: 1500,
      currentCount: 1482,
      mortalityTotal: 18,
      mortalityPct: 1.2,
      dayOfAge: 60,
      currentAvgWeightG: 240,
      feedConsumedTotalKg: 540.0,
      fcrToDate: 3.24,
    ),
    // ── flock-014: active hatchery ─────────────────────────────────────────
    const PoultryFlock(
      id: 'flock-014',
      farmId: _farmId,
      batchName: 'Main Hatchery — Ross PM3',
      species: 'chicken',
      productionType: 'hatchery',
      strain: 'Ross PM3',
      houseId: 'house-n',
      status: 'active',
      placementDate: '2024-01-01',
      placementCount: 50000,
      currentCount: 50000,
      mortalityTotal: 0,
      mortalityPct: 0.0,
      dayOfAge: 120,
    ),
  ];

  // ── Daily Records ──────────────────────────────────────────────────────────

  static final _dailyRecords = <DailyRecord>[
    const DailyRecord(
      id: 'DR-001',
      flockId: 'flock-001',
      date: '2024-03-28',
      dayOfAge: 28,
      mortalityCount: 3,
      mortalityCause: 'sds',
      feedConsumedKg: 198.5,
      waterConsumedLitres: 420.0,
      feedType: 'grower',
      avgHouseTempC: 27.5,
      avgBodyWeightG: 920,
    ),
    const DailyRecord(
      id: 'DR-002',
      flockId: 'flock-002',
      date: '2024-03-28',
      dayOfAge: 75,
      mortalityCount: 0,
      feedConsumedKg: 285.0,
      eggsCollectedAm: 1180,
      eggsCollectedPm: 480,
      brokenEggs: 12,
      avgEggWeightG: 61.5,
      hdpPct: 56.1,
    ),
  ];

  // ── Vaccination Schedules ──────────────────────────────────────────────────

  static final _vaccinationSchedules = <VaccinationSchedule>[
    const VaccinationSchedule(
      id: 'VS-001',
      flockId: 'flock-001',
      productionType: 'broiler',
      strain: 'Ross 308',
      placementDate: '2024-03-01',
      schedule: [
        VaccineItem(
          vaccine: 'Marek\'s Disease',
          targetDay: 1,
          method: 'injection',
          status: 'completed',
          completedDate: '2024-03-01',
        ),
        VaccineItem(
          vaccine: 'Newcastle Disease (ND)',
          targetDay: 7,
          method: 'drinking_water',
          status: 'completed',
          completedDate: '2024-03-08',
        ),
        VaccineItem(
          vaccine: 'Infectious Bronchitis (IB)',
          targetDay: 14,
          method: 'spray',
          status: 'completed',
          completedDate: '2024-03-15',
        ),
        VaccineItem(
          vaccine: 'Gumboro (IBD)',
          targetDay: 18,
          method: 'drinking_water',
          status: 'pending',
          dueDate: '2024-03-19',
        ),
      ],
    ),
  ];

  // ── Feed Phases ────────────────────────────────────────────────────────────

  static final _feedPhases = <FeedPhase>[
    const FeedPhase(
      id: 'FP-001',
      flockId: 'flock-001',
      phaseName: 'Starter',
      feedType: 'starter',
      dayStart: 0,
      dayEnd: 14,
      targetIntakeGPerBirdPerDay: 28.0,
      feedProduct: 'ProStart Broiler 22%',
    ),
    const FeedPhase(
      id: 'FP-002',
      flockId: 'flock-001',
      phaseName: 'Grower',
      feedType: 'grower',
      dayStart: 15,
      dayEnd: 28,
      targetIntakeGPerBirdPerDay: 62.0,
      feedProduct: 'ProGrow Broiler 19%',
    ),
    const FeedPhase(
      id: 'FP-003',
      flockId: 'flock-001',
      phaseName: 'Finisher',
      feedType: 'finisher',
      dayStart: 29,
      dayEnd: 38,
      targetIntakeGPerBirdPerDay: 130.0,
      feedProduct: 'ProFinish Broiler 17%',
    ),
  ];

  // ── Harvest Records ────────────────────────────────────────────────────────

  static final _harvestRecords = <HarvestRecord>[
    const HarvestRecord(
      id: 'HR-001',
      flockId: 'flock-004',
      harvestDate: '2024-02-14',
      birdsHarvested: 4620,
      totalLiveWeightKg: 10995.6,
      processorName: 'Valley Abattoir',
      carcassGradeAPct: 92.8,
      condemnationRatePct: 1.4,
      pricePerKgZar: 24.50,
    ),
  ];

  // ── Medication Logs ────────────────────────────────────────────────────────

  static final _medicationLogs = <MedicationLog>[
    const MedicationLog(
      id: 'ML-001',
      flockId: 'flock-001',
      date: '2024-03-20',
      drugName: 'Amoxicillin',
      dosage: '10 mg/kg BW',
      route: 'drinking_water',
      withdrawalDays: 5,
      diagnosis: 'Mild respiratory signs',
      prescribedBy: 'Dr. Nkosi',
    ),
  ];

  // ── Disease Events ─────────────────────────────────────────────────────────

  static final _diseaseEvents = <DiseaseEvent>[
    const DiseaseEvent(
      id: 'DE-001',
      flockId: 'flock-001',
      date: '2024-03-20',
      disease: 'Chronic Respiratory Disease (CRD)',
      severity: 'low',
      affectedCount: 45,
      symptoms: 'Rales, nasal discharge, reduced feed intake',
      diagnosticTest: 'Field examination',
      testResult: 'Presumptive CRD',
      isNotifiable: false,
      outcome: 'Treated — responding well',
    ),
  ];

  // ── Environment Readings ───────────────────────────────────────────────────

  static final _environmentReadings = <EnvironmentReading>[
    const EnvironmentReading(
      id: 'ER-001',
      flockId: 'flock-001',
      timestamp: '2024-03-28T08:00:00',
      sensorZone: 'north',
      tempC: 27.5,
      humidityPct: 62.0,
      ammoniaPpm: 8.2,
      co2Ppm: 1850.0,
      lightLux: 20.0,
    ),
    const EnvironmentReading(
      id: 'ER-002',
      flockId: 'flock-001',
      timestamp: '2024-03-28T08:00:00',
      sensorZone: 'south',
      tempC: 28.1,
      humidityPct: 64.5,
      ammoniaPpm: 9.8,
      co2Ppm: 1920.0,
      lightLux: 18.5,
    ),
  ];

  // ── Inventory Items ────────────────────────────────────────────────────────

  static final _inventoryItems = <InventoryItem>[
    const InventoryItem(
      id: 'INV-001',
      farmId: _farmId,
      name: 'ProGrow Broiler 19% Pellets',
      category: InventoryCategory.feed,
      unit: 'kg',
      currentStock: 3200.0,
      minThreshold: 500.0,
      pricePerUnit: 8.50,
      lastDeliveryDate: '2024-03-20',
    ),
    const InventoryItem(
      id: 'INV-002',
      farmId: _farmId,
      name: 'Newcastle ND-Clone 30 Vaccine',
      category: InventoryCategory.vaccine,
      unit: 'dose',
      currentStock: 2000.0,
      minThreshold: 200.0,
      pricePerUnit: 0.85,
      lastDeliveryDate: '2024-03-01',
    ),
    const InventoryItem(
      id: 'INV-003',
      farmId: _farmId,
      name: 'Amoxicillin 20% Soluble Powder',
      category: InventoryCategory.medication,
      unit: 'g',
      currentStock: 150.0,
      minThreshold: 200.0,
      pricePerUnit: 12.00,
    ),
  ];

  // ── Egg Sales ──────────────────────────────────────────────────────────────

  static final _eggSales = <EggSale>[
    const EggSale(
      id: 'ES-001',
      flockId: 'flock-002',
      date: '2024-03-25',
      buyerName: 'Sunshine Supermarket',
      dozensTotal: 120.0,
      pricePerDozen: 42.00,
      gradeBreakdown: {'large': 900, 'medium': 480, 'small': 60},
      invoiceRef: 'INV-2024-0325',
    ),
  ];

  // ── Chick Sales ────────────────────────────────────────────────────────────

  static final _chickSales = <ChickSale>[
    const ChickSale(
      id: 'CS-001',
      flockId: 'flock-006',
      hatchDate: '2024-03-20',
      saleDate: '2024-03-21',
      buyerName: 'Green Valley Broiler Farm',
      chickCount: 1200,
      pricePerChick: 18.50,
      totalAmount: 22200.0,
      chickSex: 'mixed',
      avgChickWeightG: 42.0,
    ),
  ];
}
