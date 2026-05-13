import '../models/goat_animal.dart';
import '../models/goat_records.dart';
import 'goat_data_source.dart';

/// In-memory mock data source for the goat module.
///
/// 6 herds across South African provinces; 14 individually-tracked goats.
class GoatMockDataSource implements GoatDataSource {
  // ── Animals ────────────────────────────────────────────────────────────────

  static const _farmId = 'FARM-001';

  static const _animals = <GoatAnimal>[
    // ── Herd A — Boer Commercial (meat, Limpopo) ────────────────────────────
    GoatAnimal(
      id: 'goat-001',
      farmId: _farmId,
      tagNumber: 'BC-001',
      name: 'Bella',
      breed: 'Boer',
      productionType: 'meat',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-a',
      dateOfBirth: '2021-03-10',
      currentWeightKg: 68.0,
      targetWeightKg: 72.0,
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedKiddingDate: '2025-06-15',
      lastKiddingDate: '2024-06-20',
      totalKidsRaised: 4,
      isLactating: false,
      lastDewormingDate: '2025-01-10',
      famachaScore: 2,
      meatSpecific: MeatSpecific(
        adgGPerDay: 180.0,
        targetSlaughterAgeMonths: null,
        dressingPct: 48.0,
      ),
    ),
    GoatAnimal(
      id: 'goat-002',
      farmId: _farmId,
      tagNumber: 'BC-002',
      name: 'Daisy',
      breed: 'Boer',
      productionType: 'meat',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-a',
      dateOfBirth: '2021-05-22',
      currentWeightKg: 64.5,
      targetWeightKg: 70.0,
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: true,
      currentMilkLitrePd: 1.2,
      lactationNumber: 3,
      lastKiddingDate: '2025-03-01',
      totalKidsRaised: 5,
      lastDewormingDate: '2025-02-15',
      famachaScore: 2,
    ),
    GoatAnimal(
      id: 'goat-003',
      farmId: _farmId,
      tagNumber: 'BC-003',
      name: 'Thor',
      breed: 'Boer',
      productionType: 'meat',
      sex: 'buck',
      status: 'active',
      herdId: 'herd-a',
      dateOfBirth: '2020-08-14',
      currentWeightKg: 112.0,
      targetWeightKg: 115.0,
      bodyConditionScore: 4.0,
      isPregnant: false,
      isLactating: false,
      lastDewormingDate: '2025-01-05',
      famachaScore: 1,
      meatSpecific: MeatSpecific(
        adgGPerDay: 220.0,
        targetSlaughterAgeMonths: null,
        dressingPct: 50.0,
      ),
      breederSpecific: BreederSpecific(
        registeredBreeder: true,
        studBookNumber: 'SA-BOER-4412',
        doesServedCount: 32,
        kidRatio: 1.85,
        breedingFee: 850.0,
      ),
    ),
    // ── Herd B — Kalahari Red (meat, Northern Cape) ────────────────────────
    GoatAnimal(
      id: 'goat-004',
      farmId: _farmId,
      tagNumber: 'KR-001',
      name: 'Ruby',
      breed: 'Kalahari Red',
      productionType: 'meat',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-b',
      dateOfBirth: '2022-01-18',
      currentWeightKg: 52.0,
      targetWeightKg: 58.0,
      bodyConditionScore: 3.0,
      isPregnant: true,
      expectedKiddingDate: '2025-06-25',
      lastKiddingDate: '2024-07-05',
      totalKidsRaised: 2,
      isLactating: false,
      lastDewormingDate: '2024-12-20',
      famachaScore: 3,
      // goat-004 has an overdue Pasteurella vaccination — triggers alert
    ),
    GoatAnimal(
      id: 'goat-005',
      farmId: _farmId,
      tagNumber: 'KR-002',
      breed: 'Kalahari Red',
      productionType: 'meat',
      sex: 'wether',
      status: 'active',
      herdId: 'herd-b',
      dateOfBirth: '2023-04-12',
      currentWeightKg: 43.0,
      targetWeightKg: 50.0,
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: false,
      lastDewormingDate: '2025-02-01',
      famachaScore: 2,
      meatSpecific: MeatSpecific(
        adgGPerDay: 165.0,
        targetSlaughterAgeMonths: 18,
        dressingPct: 47.0,
      ),
    ),
    // ── Herd C — Angora Fiber (fiber, Eastern Cape) ─────────────────────────
    GoatAnimal(
      id: 'goat-006',
      farmId: _farmId,
      tagNumber: 'ANG-001',
      name: 'Fluffy',
      breed: 'Angora',
      productionType: 'fiber',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-c',
      dateOfBirth: '2020-09-30',
      currentWeightKg: 38.0,
      targetWeightKg: 40.0,
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: false,
      lastShearingDate: '2024-09-05',
      lastDewormingDate: '2025-01-20',
      famachaScore: 2,
      fiberSpecific: FiberSpecific(
        avgFleeceMassKg: 3.8,
        stapleLength: 115.0,
        micronRating: 28.5,
        colorGrade: 'White',
        lastMohairPricePerKg: 420.0,
      ),
    ),
    GoatAnimal(
      id: 'goat-007',
      farmId: _farmId,
      tagNumber: 'ANG-002',
      name: 'Cloud',
      breed: 'Angora',
      productionType: 'fiber',
      sex: 'buck',
      status: 'active',
      herdId: 'herd-c',
      dateOfBirth: '2019-11-15',
      currentWeightKg: 55.0,
      targetWeightKg: 57.0,
      bodyConditionScore: 4.0,
      isPregnant: false,
      isLactating: false,
      lastShearingDate: '2024-08-20',
      lastDewormingDate: '2025-01-20',
      famachaScore: 1,
      fiberSpecific: FiberSpecific(
        avgFleeceMassKg: 4.5,
        stapleLength: 120.0,
        micronRating: 26.0,
        colorGrade: 'White',
        lastMohairPricePerKg: 450.0,
      ),
    ),
    // ── Herd D — Saanen Dairy (dairy, Western Cape) ─────────────────────────
    GoatAnimal(
      id: 'goat-008',
      farmId: _farmId,
      tagNumber: 'SD-001',
      name: 'Milka',
      breed: 'Saanen',
      productionType: 'dairy',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-d',
      dateOfBirth: '2021-07-08',
      currentWeightKg: 62.0,
      targetWeightKg: 65.0,
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: true,
      currentMilkLitrePd: 3.8,
      lactationNumber: 3,
      lastKiddingDate: '2025-02-10',
      totalKidsRaised: 6,
      lastDewormingDate: '2025-01-15',
      // FAMACHA score 4 → triggers alert
      famachaScore: 4,
      dairySpecific: DairySpecific(
        peakMilkLitrePd: 4.5,
        totalMilkThisLactation: 285.0,
        milkFatPct: 3.9,
        milkProteinPct: 3.2,
        projectedDryOffDate: '2025-11-10',
      ),
    ),
    GoatAnimal(
      id: 'goat-009',
      farmId: _farmId,
      tagNumber: 'SD-002',
      name: 'Cream',
      breed: 'Saanen',
      productionType: 'dairy',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-d',
      dateOfBirth: '2022-04-25',
      currentWeightKg: 58.0,
      targetWeightKg: 62.0,
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedKiddingDate: '2025-07-02',
      isLactating: false,
      dryOffDate: '2025-04-01',
      lastKiddingDate: '2024-07-02',
      totalKidsRaised: 2,
      lastDewormingDate: '2025-02-10',
      famachaScore: 2,
      dairySpecific: DairySpecific(
        peakMilkLitrePd: 3.9,
        totalMilkThisLactation: 0.0,
        milkFatPct: 4.1,
        milkProteinPct: 3.3,
      ),
    ),
    // ── Herd E — Communal Mixed (KwaZulu-Natal) ─────────────────────────────
    GoatAnimal(
      id: 'goat-010',
      farmId: _farmId,
      tagNumber: 'CM-001',
      breed: 'Indigenous/Nguni Cross',
      productionType: 'communal',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-e',
      dateOfBirth: '2023-10-05',
      damId: 'goat-001',
      currentWeightKg: 28.0,
      targetWeightKg: 40.0,
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: false,
      lastDewormingDate: '2025-01-30',
      famachaScore: 2,
    ),
    GoatAnimal(
      id: 'goat-011',
      farmId: _farmId,
      tagNumber: 'CM-002',
      breed: 'Nguni',
      productionType: 'communal',
      sex: 'buck',
      status: 'active',
      herdId: 'herd-e',
      dateOfBirth: '2020-06-17',
      currentWeightKg: 48.0,
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: false,
      lastDewormingDate: '2024-12-10',
      famachaScore: 3,
    ),
    // ── Herd F — Savanna Breeding Stud (Free State) ──────────────────────────
    GoatAnimal(
      id: 'goat-012',
      farmId: _farmId,
      tagNumber: 'SB-001',
      name: 'Atlas',
      breed: 'Savanna',
      productionType: 'breeding',
      sex: 'buck',
      status: 'active',
      herdId: 'herd-f',
      dateOfBirth: '2019-05-02',
      currentWeightKg: 108.0,
      targetWeightKg: 110.0,
      bodyConditionScore: 4.0,
      isPregnant: false,
      isLactating: false,
      lastDewormingDate: '2025-02-01',
      famachaScore: 1,
      registrationNumber: 'SASBA-2019-0412',
      breederSpecific: BreederSpecific(
        studBookNumber: 'SASBA-2019-0412',
        registeredBreeder: true,
        doesServedCount: 45,
        kidRatio: 1.92,
        breedingFee: 1200.0,
      ),
    ),
    GoatAnimal(
      id: 'goat-013',
      farmId: _farmId,
      tagNumber: 'SB-002',
      name: 'Duchess',
      breed: 'Savanna',
      productionType: 'breeding',
      sex: 'doe',
      status: 'active',
      herdId: 'herd-f',
      dateOfBirth: '2020-10-12',
      currentWeightKg: 75.0,
      targetWeightKg: 78.0,
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedKiddingDate: '2025-06-28',
      lastKiddingDate: '2024-06-28',
      totalKidsRaised: 8,
      isLactating: false,
      lastDewormingDate: '2025-01-25',
      famachaScore: 2,
      registrationNumber: 'SASBA-2020-1122',
      breederSpecific: BreederSpecific(
        studBookNumber: 'SASBA-2020-1122',
        registeredBreeder: true,
        kidRatio: 1.95,
      ),
    ),
    GoatAnimal(
      id: 'goat-014',
      farmId: _farmId,
      tagNumber: 'SB-003',
      name: 'Prince',
      breed: 'Boer × Savanna',
      productionType: 'breeding',
      sex: 'buck',
      status: 'active',
      herdId: 'herd-f',
      dateOfBirth: '2022-02-28',
      currentWeightKg: 88.0,
      targetWeightKg: 95.0,
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: false,
      lastDewormingDate: '2025-02-10',
      famachaScore: 2,
      meatSpecific: MeatSpecific(
        adgGPerDay: 210.0,
        dressingPct: 49.0,
      ),
      breederSpecific: BreederSpecific(
        registeredBreeder: false,
        doesServedCount: 18,
        kidRatio: 1.78,
        breedingFee: 600.0,
      ),
    ),
  ];

  // ── Weight records ─────────────────────────────────────────────────────────

  static const _weightRecords = <WeightRecord>[
    WeightRecord(id: 'wr-001', animalId: 'goat-001', date: '2025-01-15', weightKg: 65.0, bodyConditionScore: 3.0),
    WeightRecord(id: 'wr-002', animalId: 'goat-001', date: '2025-03-01', weightKg: 67.0, bodyConditionScore: 3.5),
    WeightRecord(id: 'wr-003', animalId: 'goat-001', date: '2025-05-01', weightKg: 68.0, bodyConditionScore: 3.5),
    WeightRecord(id: 'wr-004', animalId: 'goat-003', date: '2025-01-15', weightKg: 108.0, bodyConditionScore: 4.0),
    WeightRecord(id: 'wr-005', animalId: 'goat-003', date: '2025-04-10', weightKg: 112.0, bodyConditionScore: 4.0),
    WeightRecord(id: 'wr-006', animalId: 'goat-008', date: '2025-02-10', weightKg: 58.0, bodyConditionScore: 2.5, notes: 'Post-kidding weight'),
    WeightRecord(id: 'wr-007', animalId: 'goat-008', date: '2025-04-15', weightKg: 62.0, bodyConditionScore: 3.0),
    WeightRecord(id: 'wr-008', animalId: 'goat-005', date: '2025-03-20', weightKg: 40.0, bodyConditionScore: 3.0),
    WeightRecord(id: 'wr-009', animalId: 'goat-005', date: '2025-05-05', weightKg: 43.0, bodyConditionScore: 3.5),
    WeightRecord(id: 'wr-010', animalId: 'goat-012', date: '2025-02-01', weightKg: 105.0, bodyConditionScore: 3.5),
    WeightRecord(id: 'wr-011', animalId: 'goat-012', date: '2025-05-01', weightKg: 108.0, bodyConditionScore: 4.0),
  ];

  // ── Mating records ─────────────────────────────────────────────────────────

  static const _matingRecords = <MatingRecord>[
    MatingRecord(
      id: 'mat-001',
      doeId: 'goat-001',
      buckId: 'goat-003',
      serviceDate: '2025-01-20',
      serviceMethod: 'natural',
      expectedKiddingDate: '2025-06-15',
      outcome: 'pregnant',
    ),
    MatingRecord(
      id: 'mat-002',
      doeId: 'goat-004',
      buckId: 'goat-003',
      serviceDate: '2025-01-24',
      serviceMethod: 'natural',
      expectedKiddingDate: '2025-06-25',
      outcome: 'pregnant',
    ),
    MatingRecord(
      id: 'mat-003',
      doeId: 'goat-009',
      buckId: 'goat-012',
      serviceDate: '2025-01-28',
      serviceMethod: 'natural',
      expectedKiddingDate: '2025-07-02',
      outcome: 'pregnant',
    ),
    MatingRecord(
      id: 'mat-004',
      doeId: 'goat-013',
      buckId: 'goat-012',
      serviceDate: '2025-01-30',
      serviceMethod: 'natural',
      expectedKiddingDate: '2025-06-28',
      outcome: 'pregnant',
    ),
  ];

  // ── Pregnancy checks ───────────────────────────────────────────────────────

  static const _pregnancyChecks = <PregnancyCheck>[
    PregnancyCheck(
      id: 'pc-001',
      animalId: 'goat-001',
      date: '2025-02-20',
      method: 'ultrasound',
      result: 'pregnant',
      expectedKiddingDate: '2025-06-15',
      daysPregnant: 31,
    ),
    PregnancyCheck(
      id: 'pc-002',
      animalId: 'goat-009',
      date: '2025-03-10',
      method: 'ultrasound',
      result: 'pregnant',
      expectedKiddingDate: '2025-07-02',
      daysPregnant: 42,
    ),
  ];

  // ── Kidding events ─────────────────────────────────────────────────────────

  static const _kiddingEvents = <KiddingEvent>[
    KiddingEvent(
      id: 'kid-001',
      damId: 'goat-001',
      kiddingDate: '2024-06-20',
      totalKidsBorn: 2,
      kidsAliveBorn: 2,
      kidsStillborn: 0,
      birthWeights: [3.8, 4.1],
      kidIds: ['goat-010'],
      assisted: false,
    ),
    KiddingEvent(
      id: 'kid-002',
      damId: 'goat-002',
      kiddingDate: '2025-03-01',
      totalKidsBorn: 3,
      kidsAliveBorn: 2,
      kidsStillborn: 1,
      birthWeights: [3.2, 3.5, null],
      kidIds: [],
      assisted: true,
      complications: 'Dystocia — one kid stillborn',
    ),
    KiddingEvent(
      id: 'kid-003',
      damId: 'goat-008',
      kiddingDate: '2025-02-10',
      totalKidsBorn: 2,
      kidsAliveBorn: 2,
      kidsStillborn: 0,
      birthWeights: [3.6, 3.9],
      kidIds: [],
      assisted: false,
    ),
  ];

  // ── Daily milk records ─────────────────────────────────────────────────────

  static const _milkRecords = <DailyMilkRecord>[
    DailyMilkRecord(id: 'mlk-001', animalId: 'goat-008', date: '2025-05-01', morningLitres: 2.0, eveningLitres: 1.8, lactationDay: 80),
    DailyMilkRecord(id: 'mlk-002', animalId: 'goat-008', date: '2025-05-02', morningLitres: 2.0, eveningLitres: 1.9, lactationDay: 81),
    DailyMilkRecord(id: 'mlk-003', animalId: 'goat-008', date: '2025-05-03', morningLitres: 1.9, eveningLitres: 1.8, lactationDay: 82),
    DailyMilkRecord(id: 'mlk-004', animalId: 'goat-008', date: '2025-05-04', morningLitres: 2.1, eveningLitres: 1.7, lactationDay: 83),
    DailyMilkRecord(id: 'mlk-005', animalId: 'goat-002', date: '2025-05-01', morningLitres: 0.6, eveningLitres: 0.6, lactationDay: 61),
    DailyMilkRecord(id: 'mlk-006', animalId: 'goat-002', date: '2025-05-02', morningLitres: 0.6, eveningLitres: 0.5, lactationDay: 62),
    DailyMilkRecord(id: 'mlk-007', animalId: 'goat-002', date: '2025-05-03', morningLitres: 0.7, eveningLitres: 0.5, lactationDay: 63),
  ];

  // ── Shearing records ───────────────────────────────────────────────────────

  static const _shearingRecords = <ShearingRecord>[
    ShearingRecord(
      id: 'sh-001',
      animalId: 'goat-006',
      shearingDate: '2024-09-05',
      fleeceWeightKg: 3.6,
      stapleLength: 112.0,
      micron: 29.0,
      colorGrade: 'White',
      pricePerKg: 415.0,
    ),
    ShearingRecord(
      id: 'sh-002',
      animalId: 'goat-006',
      shearingDate: '2024-03-10',
      fleeceWeightKg: 3.8,
      stapleLength: 118.0,
      micron: 28.5,
      colorGrade: 'White',
      pricePerKg: 420.0,
    ),
    ShearingRecord(
      id: 'sh-003',
      animalId: 'goat-007',
      shearingDate: '2024-08-20',
      fleeceWeightKg: 4.4,
      stapleLength: 122.0,
      micron: 26.5,
      colorGrade: 'White',
      pricePerKg: 445.0,
    ),
  ];

  // ── Health events ──────────────────────────────────────────────────────────

  static const _healthEvents = <GoatHealthEvent>[
    GoatHealthEvent(
      id: 'he-001',
      animalId: 'goat-008',
      date: '2025-04-10',
      condition: 'Haemonchosis',
      severity: 'moderate',
      treatment: 'Closantel 10mg/kg oral',
      outcome: 'monitoring',
    ),
    GoatHealthEvent(
      id: 'he-002',
      animalId: 'goat-004',
      date: '2025-03-22',
      condition: 'Foot rot',
      severity: 'mild',
      treatment: 'Zinc sulphate foot bath',
      outcome: 'resolved',
    ),
    GoatHealthEvent(
      id: 'he-003',
      animalId: 'goat-011',
      date: '2025-02-05',
      condition: 'Pinkeye (Infectious Keratoconjunctivitis)',
      severity: 'moderate',
      treatment: 'Oxytetracycline eye ointment',
      outcome: 'resolved',
    ),
    GoatHealthEvent(
      id: 'he-004',
      animalId: 'goat-002',
      date: '2025-03-05',
      condition: 'Dystocia',
      severity: 'severe',
      treatment: 'Manual correction; veterinary assist',
      vet: 'Dr. van der Merwe',
      outcome: 'resolved',
    ),
    GoatHealthEvent(
      id: 'he-005',
      animalId: 'goat-005',
      date: '2025-01-18',
      condition: 'Worms (mixed)',
      severity: 'mild',
      treatment: 'Albendazole 5mg/kg oral',
      outcome: 'resolved',
    ),
    GoatHealthEvent(
      id: 'he-006',
      animalId: 'goat-013',
      date: '2025-04-02',
      condition: 'Lumpy Skin Disease (suspected)',
      severity: 'mild',
      treatment: 'Supportive care; isolation',
      vet: 'Dr. Pretorius',
      outcome: 'monitoring',
    ),
  ];

  // ── Medication logs ────────────────────────────────────────────────────────

  static const _medicationLogs = <GoatMedicationLog>[
    GoatMedicationLog(
      id: 'med-001',
      animalId: 'goat-008',
      date: '2025-04-10',
      drug: 'Closantel 10%',
      dose: '68ml oral (10mg/kg)',
      route: 'oral',
      reason: 'Haemonchosis',
      withdrawalDays: 28,
      administeredBy: 'Farm Manager',
    ),
    GoatMedicationLog(
      id: 'med-002',
      animalId: 'goat-001',
      date: '2025-01-10',
      drug: 'Ivermectin 1%',
      dose: '0.2mg/kg SC',
      route: 'injection',
      reason: 'Routine deworming',
      withdrawalDays: 35,
      administeredBy: 'Farm Manager',
    ),
    GoatMedicationLog(
      id: 'med-003',
      animalId: 'goat-005',
      date: '2025-01-18',
      drug: 'Albendazole 2.5%',
      dose: '7.5mg/kg oral',
      route: 'oral',
      reason: 'Mixed worm burden',
      withdrawalDays: 14,
    ),
    GoatMedicationLog(
      id: 'med-004',
      animalId: 'goat-004',
      date: '2025-03-22',
      drug: 'Zinc sulphate 20%',
      dose: 'Foot bath 15 min',
      route: 'topical',
      reason: 'Foot rot',
      withdrawalDays: 0,
    ),
    GoatMedicationLog(
      id: 'med-005',
      animalId: 'goat-011',
      date: '2025-02-05',
      drug: 'Oxytetracycline eye ointment',
      dose: 'Apply BD × 5 days',
      route: 'topical',
      reason: 'Pinkeye',
      withdrawalDays: 0,
    ),
  ];

  // ── Vaccinations ───────────────────────────────────────────────────────────

  static const _vaccinations = <GoatVaccination>[
    // goat-004 — Pasteurella overdue → triggers alert
    GoatVaccination(
      id: 'vac-001',
      animalId: 'goat-004',
      vaccineName: 'Pasteurella',
      dueDate: '2024-04-20',
      nextDueDate: '2025-04-20',
    ),
    GoatVaccination(
      id: 'vac-002',
      animalId: 'goat-001',
      vaccineName: 'Pasteurella',
      dueDate: '2025-06-01',
      batchNumber: 'PAV-2025-01',
    ),
    GoatVaccination(
      id: 'vac-003',
      animalId: 'goat-001',
      vaccineName: 'Pulpy kidney (Clostridium D)',
      dueDate: '2024-12-01',
      givenDate: '2024-12-03',
      batchNumber: 'CLO-2024-22',
      administeredBy: 'Farm Manager',
    ),
    GoatVaccination(
      id: 'vac-004',
      animalId: 'goat-003',
      vaccineName: 'Pulpy kidney (Clostridium D)',
      dueDate: '2025-05-01',
      givenDate: '2025-05-05',
      batchNumber: 'CLO-2025-08',
      administeredBy: 'Farm Manager',
    ),
    GoatVaccination(
      id: 'vac-005',
      animalId: 'goat-008',
      vaccineName: 'Brucellosis Rev.1',
      dueDate: '2025-03-01',
      givenDate: '2025-03-04',
      batchNumber: 'BRU-2025-02',
    ),
    GoatVaccination(
      id: 'vac-006',
      animalId: 'goat-012',
      vaccineName: 'Pasteurella',
      dueDate: '2025-07-01',
    ),
    GoatVaccination(
      id: 'vac-007',
      animalId: 'goat-013',
      vaccineName: 'Pulpy kidney (Clostridium D)',
      dueDate: '2025-06-15',
    ),
    GoatVaccination(
      id: 'vac-008',
      animalId: 'goat-006',
      vaccineName: 'Orf (Contagious ecthyma)',
      dueDate: '2025-04-10',
      givenDate: '2025-04-12',
      batchNumber: 'ORF-2025-01',
    ),
  ];

  // ── Sale records ───────────────────────────────────────────────────────────

  static const _saleRecords = <GoatSaleRecord>[
    GoatSaleRecord(
      id: 'sale-001',
      animalId: 'goat-005',
      saleDate: '2025-03-15',
      buyerName: 'N. Steyn (NC Abattoir)',
      saleWeightKg: 38.0,
      pricePerKg: 52.0,
      totalRevenue: 1976.0,
      invoiceRef: 'INV-2025-014',
    ),
    GoatSaleRecord(
      id: 'sale-002',
      animalId: 'goat-010',
      saleDate: '2025-04-20',
      buyerName: 'Tribal Authority Market',
      totalRevenue: 1500.0,
    ),
  ];

  // ── Feed records ───────────────────────────────────────────────────────────

  static const _feedRecords = <GoatFeedRecord>[
    GoatFeedRecord(id: 'feed-001', herdId: 'herd-a', date: '2025-05-01', feedType: 'Game cubes', quantityKg: 45.0, costPerKg: 8.50),
    GoatFeedRecord(id: 'feed-002', herdId: 'herd-a', date: '2025-05-02', feedType: 'Game cubes', quantityKg: 45.0, costPerKg: 8.50),
    GoatFeedRecord(id: 'feed-003', herdId: 'herd-d', date: '2025-05-01', feedType: 'Dairy goat pellet', quantityKg: 20.0, costPerKg: 12.0),
    GoatFeedRecord(id: 'feed-004', herdId: 'herd-d', date: '2025-05-02', feedType: 'Dairy goat pellet', quantityKg: 20.0, costPerKg: 12.0),
    GoatFeedRecord(id: 'feed-005', herdId: 'herd-c', date: '2025-05-01', feedType: 'Veld hay', quantityKg: 30.0, costPerKg: 3.20),
    GoatFeedRecord(id: 'feed-006', herdId: 'herd-f', date: '2025-05-01', feedType: 'Game cubes', quantityKg: 55.0, costPerKg: 8.50),
  ];

  // ── Pasture records ────────────────────────────────────────────────────────

  static const _pastureRecords = <PastureRecord>[
    PastureRecord(id: 'pas-001', herdId: 'herd-a', campId: 'Camp-A1', entryDate: '2025-04-01', estimatedHa: 12.5, veldCondition: 'good'),
    PastureRecord(id: 'pas-002', herdId: 'herd-b', campId: 'Camp-B3', entryDate: '2025-03-15', exitDate: '2025-04-14', estimatedHa: 25.0, veldCondition: 'fair'),
    PastureRecord(id: 'pas-003', herdId: 'herd-b', campId: 'Camp-B4', entryDate: '2025-04-15', estimatedHa: 28.0, veldCondition: 'good'),
    PastureRecord(id: 'pas-004', herdId: 'herd-e', campId: 'Communal-1', entryDate: '2025-01-01', estimatedHa: 8.0, veldCondition: 'poor'),
  ];

  // ── FAMACHA records ────────────────────────────────────────────────────────

  static const _famachaRecords = <FamachaRecord>[
    FamachaRecord(id: 'fam-001', animalId: 'goat-008', date: '2025-05-02', score: 4, actionTaken: 'drenched', notes: 'Closantel administered'),
    FamachaRecord(id: 'fam-002', animalId: 'goat-004', date: '2025-05-02', score: 3, actionTaken: 'monitored'),
    FamachaRecord(id: 'fam-003', animalId: 'goat-011', date: '2025-05-02', score: 3, actionTaken: 'monitored'),
    FamachaRecord(id: 'fam-004', animalId: 'goat-001', date: '2025-05-02', score: 2, actionTaken: 'none'),
    FamachaRecord(id: 'fam-005', animalId: 'goat-002', date: '2025-05-02', score: 2, actionTaken: 'none'),
    FamachaRecord(id: 'fam-006', animalId: 'goat-005', date: '2025-05-02', score: 2, actionTaken: 'none'),
  ];

  // ── Body condition records ─────────────────────────────────────────────────

  static const _bcsRecords = <BodyConditionRecord>[
    BodyConditionRecord(id: 'bcs-001', animalId: 'goat-001', date: '2025-05-01', score: 3.5),
    BodyConditionRecord(id: 'bcs-002', animalId: 'goat-008', date: '2025-04-15', score: 3.0, notes: 'Lactation stress visible'),
    BodyConditionRecord(id: 'bcs-003', animalId: 'goat-003', date: '2025-04-10', score: 4.0),
    BodyConditionRecord(id: 'bcs-004', animalId: 'goat-012', date: '2025-05-01', score: 4.0),
    BodyConditionRecord(id: 'bcs-005', animalId: 'goat-013', date: '2025-05-01', score: 3.5, notes: 'Pregnancy drain expected'),
  ];

  // ── DataSource interface ───────────────────────────────────────────────────

  // ── GET ──────────────────────────────────────────────────────────────────

  @override
  Future<List<GoatAnimal>> getAnimals() async => _animals;

  @override
  Future<List<WeightRecord>> getWeightRecords() async => _weightRecords;

  @override
  Future<List<MatingRecord>> getMatingRecords() async => _matingRecords;

  @override
  Future<List<PregnancyCheck>> getPregnancyChecks() async => _pregnancyChecks;

  @override
  Future<List<KiddingEvent>> getKiddingEvents() async => _kiddingEvents;

  @override
  Future<List<DailyMilkRecord>> getMilkRecords() async => _milkRecords;

  @override
  Future<List<ShearingRecord>> getShearingRecords() async => _shearingRecords;

  @override
  Future<List<GoatHealthEvent>> getHealthEvents() async => _healthEvents;

  @override
  Future<List<GoatMedicationLog>> getMedicationLogs() async => _medicationLogs;

  @override
  Future<List<GoatVaccination>> getVaccinations() async => _vaccinations;

  @override
  Future<List<GoatSaleRecord>> getSaleRecords() async => _saleRecords;

  @override
  Future<List<GoatFeedRecord>> getFeedRecords() async => _feedRecords;

  @override
  Future<List<PastureRecord>> getPastureRecords() async => _pastureRecords;

  @override
  Future<List<FamachaRecord>> getFamachaRecords() async => _famachaRecords;

  @override
  Future<List<BodyConditionRecord>> getBodyConditionRecords() async =>
      _bcsRecords;

  // ── POST / PUT / PATCH / DELETE ───────────────────────────────────────────
  // Mock implementations return the supplied value and perform no side-effects.
  // Riverpod Notifiers (in goat_providers.dart) own the in-session mutable state.

  @override
  Future<GoatAnimal> createAnimal(GoatAnimal animal) async => animal;

  @override
  Future<GoatAnimal> updateAnimal(GoatAnimal animal) async => animal;

  @override
  Future<void> deleteAnimal(String id) async {}

  @override
  Future<WeightRecord> createWeightRecord(WeightRecord record) async => record;

  @override
  Future<void> deleteWeightRecord(String id) async {}

  @override
  Future<MatingRecord> createMatingRecord(MatingRecord record) async => record;

  @override
  Future<MatingRecord> updateMatingRecord(MatingRecord record) async => record;

  @override
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async =>
      check;

  @override
  Future<KiddingEvent> createKiddingEvent(KiddingEvent event) async => event;

  @override
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async =>
      record;

  @override
  Future<void> deleteMilkRecord(String id) async {}

  @override
  Future<ShearingRecord> createShearingRecord(ShearingRecord record) async =>
      record;

  @override
  Future<GoatHealthEvent> createHealthEvent(GoatHealthEvent event) async =>
      event;

  @override
  Future<GoatHealthEvent> updateHealthEvent(GoatHealthEvent event) async =>
      event;

  @override
  Future<GoatMedicationLog> createMedicationLog(
          GoatMedicationLog log) async =>
      log;

  @override
  Future<GoatVaccination> createVaccination(
          GoatVaccination vaccination) async =>
      vaccination;

  @override
  Future<GoatVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  }) async {
    final vac = _vaccinations.firstWhere((v) => v.id == id,
        orElse: () => throw StateError('Vaccination $id not found'));
    return GoatVaccination(
      id: vac.id,
      animalId: vac.animalId,
      vaccineName: vac.vaccineName,
      dueDate: vac.dueDate,
      givenDate: givenDate,
      batchNumber: batchNumber ?? vac.batchNumber,
      nextDueDate: vac.nextDueDate,
      administeredBy: vac.administeredBy,
    );
  }

  @override
  Future<GoatSaleRecord> createSaleRecord(GoatSaleRecord record) async =>
      record;

  @override
  Future<GoatSaleRecord> updateSaleRecord(GoatSaleRecord record) async =>
      record;

  @override
  Future<void> deleteSaleRecord(String id) async {}

  @override
  Future<GoatFeedRecord> createFeedRecord(GoatFeedRecord record) async =>
      record;

  @override
  Future<void> deleteFeedRecord(String id) async {}

  @override
  Future<PastureRecord> createPastureRecord(PastureRecord record) async =>
      record;

  @override
  Future<PastureRecord> exitPasture(String id, String exitDate) async {
    final rec = _pastureRecords.firstWhere((r) => r.id == id,
        orElse: () => throw StateError('PastureRecord $id not found'));
    return PastureRecord(
      id: rec.id,
      herdId: rec.herdId,
      campId: rec.campId,
      entryDate: rec.entryDate,
      exitDate: exitDate,
      estimatedHa: rec.estimatedHa,
      veldCondition: rec.veldCondition,
      notes: rec.notes,
    );
  }

  @override
  Future<FamachaRecord> createFamachaRecord(FamachaRecord record) async =>
      record;

  @override
  Future<BodyConditionRecord> createBodyConditionRecord(
          BodyConditionRecord record) async =>
      record;
}
