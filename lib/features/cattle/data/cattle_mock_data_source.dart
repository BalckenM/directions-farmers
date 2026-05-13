import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import 'cattle_data_source.dart';

/// In-memory mock implementation of [CattleDataSource].
///
/// Returns representative South African herd data:
/// Nguni ×6, Bonsmara ×4, Holstein ×5, Jersey ×3 (18 animals total).
class CattleMockDataSource implements CattleDataSource {
  // ── Animals ───────────────────────────────────────────────────────────────

  static final List<CattleAnimal> _animals = [
    // ── Nguni ×6 ─────────────────────────────────────────────────────────────
    CattleAnimal(
      id: 'CA001',
      farmId: 'farm-001',
      tagNumber: 'CA001',
      name: 'Thandi',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2020-03-14',
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedCalvingDate: '2026-08-15',
      lastCalvingDate: '2025-08-20',
      totalCalvesRaised: 2,
      isLactating: false,
      brucellaTested: true,
      brucellaTestDate: '2025-04-10',
      fmdZone: 'free',
      beefSpecific: const BeefSpecific(averageDailyGainKg: 0.58),
    ),
    CattleAnimal(
      id: 'CA002',
      farmId: 'farm-001',
      tagNumber: 'CA002',
      name: 'Sbu',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'bull',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2019-06-02',
      currentWeightKg: 620,
      bodyConditionScore: 4.0,
      isPregnant: false,
      isLactating: false,
      fmdZone: 'zone1',
      registrationNumber: 'NGU-2019-002',
      brandNumber: 'SB22',
      brandPosition: 'left rib',
    ),
    CattleAnimal(
      id: 'CA003',
      farmId: 'farm-001',
      tagNumber: 'CA003',
      name: 'Langa',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'heifer',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2023-09-11',
      currentWeightKg: 280,
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: false,
      brucellaTested: true,
      brucellaTestDate: '2026-01-15',
      fmdZone: 'free',
    ),
    CattleAnimal(
      id: 'CA004',
      farmId: 'farm-001',
      tagNumber: 'CA004',
      name: 'Nandi',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2021-01-28',
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedCalvingDate: '2026-09-02',
      lastCalvingDate: '2025-09-05',
      totalCalvesRaised: 1,
      isLactating: false,
      fmdZone: 'free',
    ),
    CattleAnimal(
      id: 'CA005',
      farmId: 'farm-001',
      tagNumber: 'CA005',
      name: 'Mfan',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'steer',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2023-04-17',
      currentWeightKg: 310,
      targetWeightKg: 420,
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: false,
      fmdZone: 'free',
      beefSpecific: const BeefSpecific(averageDailyGainKg: 0.62),
    ),
    CattleAnimal(
      id: 'CA006',
      farmId: 'farm-001',
      tagNumber: 'CA006',
      name: 'Busi',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'calf_female',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2026-02-10',
      damId: 'CA001',
      currentWeightKg: 78,
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: false,
      fmdZone: 'free',
    ),

    // ── Bonsmara ×4 ───────────────────────────────────────────────────────────
    CattleAnimal(
      id: 'CA007',
      farmId: 'farm-001',
      tagNumber: 'CA007',
      name: 'Koos',
      breed: 'Bonsmara',
      productionType: 'beef',
      sex: 'bull',
      status: 'active',
      herdId: 'herd-bonsmara',
      dateOfBirth: '2018-11-05',
      currentWeightKg: 780,
      bodyConditionScore: 4.5,
      isPregnant: false,
      isLactating: false,
      registrationNumber: 'BNS-2018-007',
      brandNumber: 'KV07',
      brandPosition: 'right hip',
      fmdZone: 'free',
      beefSpecific: const BeefSpecific(
        averageDailyGainKg: 0.81,
        feedConversionRatio: 6.2,
      ),
    ),
    CattleAnimal(
      id: 'CA008',
      farmId: 'farm-001',
      tagNumber: 'CA008',
      name: 'Petra',
      breed: 'Bonsmara',
      productionType: 'beef',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-bonsmara',
      dateOfBirth: '2019-07-22',
      currentWeightKg: 490,
      bodyConditionScore: 3.5,
      isPregnant: false,
      lastCalvingDate: '2025-06-12',
      totalCalvesRaised: 3,
      isLactating: false,
      brucellaTested: true,
      brucellaTestDate: '2025-04-10',
      fmdZone: 'free',
    ),
    CattleAnimal(
      id: 'CA009',
      farmId: 'farm-001',
      tagNumber: 'CA009',
      name: 'Steyn',
      breed: 'Bonsmara',
      productionType: 'beef',
      sex: 'steer',
      status: 'active',
      herdId: 'herd-bonsmara',
      dateOfBirth: '2023-02-14',
      currentWeightKg: 375,
      targetWeightKg: 480,
      bodyConditionScore: 4.0,
      isPregnant: false,
      isLactating: false,
      fmdZone: 'free',
      beefSpecific: const BeefSpecific(
        averageDailyGainKg: 0.78,
        feedlotPenId: 'B1',
      ),
    ),
    CattleAnimal(
      id: 'CA010',
      farmId: 'farm-001',
      tagNumber: 'CA010',
      name: 'Riaan',
      breed: 'Bonsmara',
      productionType: 'beef',
      sex: 'heifer',
      status: 'active',
      herdId: 'herd-bonsmara',
      dateOfBirth: '2023-05-30',
      currentWeightKg: 305,
      targetWeightKg: 380,
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: false,
      fmdZone: 'free',
    ),

    // ── Holstein ×5 ───────────────────────────────────────────────────────────
    CattleAnimal(
      id: 'CA011',
      farmId: 'farm-001',
      tagNumber: 'CA011',
      name: 'Daisy',
      breed: 'Holstein',
      productionType: 'dairy',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2020-05-18',
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: true,
      currentMilkLitrePd: 28.0,
      lactationNumber: 3,
      brucellaTested: true,
      brucellaTestDate: '2026-01-20',
      fmdZone: 'free',
      dairySpecific: const DairySpecific(
        somaticCellCount: 180000,
        butterfatPct: 3.8,
        proteinPct: 3.2,
        milkingSchedule: 'twice',
        totalMilkThisLactation: 4200,
        peakMilkLitrePd: 34.0,
      ),
    ),
    CattleAnimal(
      id: 'CA012',
      farmId: 'farm-001',
      tagNumber: 'CA012',
      name: 'Flora',
      breed: 'Holstein',
      productionType: 'dairy',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2018-08-03',
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: true,
      currentMilkLitrePd: 32.0,
      lactationNumber: 5,
      brucellaTested: true,
      brucellaTestDate: '2026-01-20',
      fmdZone: 'free',
      dairySpecific: const DairySpecific(
        somaticCellCount: 95000,
        butterfatPct: 3.9,
        proteinPct: 3.3,
        milkingSchedule: 'twice',
        totalMilkThisLactation: 5800,
        peakMilkLitrePd: 38.0,
      ),
    ),
    CattleAnimal(
      id: 'CA013',
      farmId: 'farm-001',
      tagNumber: 'CA013',
      name: 'Bella',
      breed: 'Holstein',
      productionType: 'dairy',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2021-12-09',
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedCalvingDate: '2026-10-20',
      isLactating: false,
      lactationNumber: 2,
      brucellaTested: true,
      brucellaTestDate: '2025-11-05',
      fmdZone: 'free',
    ),
    CattleAnimal(
      id: 'CA014',
      farmId: 'farm-001',
      tagNumber: 'CA014',
      name: 'Hanna',
      breed: 'Holstein',
      productionType: 'dairy',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2019-04-25',
      bodyConditionScore: 2.5,
      isPregnant: false,
      isLactating: true,
      currentMilkLitrePd: 25.0,
      lactationNumber: 4,
      fmdZone: 'free',
      notes: 'Elevated SCC — monitor closely',
      dairySpecific: const DairySpecific(
        somaticCellCount: 250000,
        butterfatPct: 3.6,
        proteinPct: 3.1,
        milkingSchedule: 'twice',
        totalMilkThisLactation: 3100,
        peakMilkLitrePd: 30.0,
      ),
    ),
    CattleAnimal(
      id: 'CA015',
      farmId: 'farm-001',
      tagNumber: 'CA015',
      name: 'Tops',
      breed: 'Holstein',
      productionType: 'dairy',
      sex: 'bull',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2021-02-01',
      currentWeightKg: 850,
      bodyConditionScore: 4.0,
      isPregnant: false,
      isLactating: false,
      fmdZone: 'free',
      registrationNumber: 'HOL-2021-015',
    ),

    // ── Jersey ×3 ─────────────────────────────────────────────────────────────
    CattleAnimal(
      id: 'CA016',
      farmId: 'farm-001',
      tagNumber: 'CA016',
      name: 'Suzie',
      breed: 'Jersey',
      productionType: 'dairy',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2020-10-14',
      bodyConditionScore: 3.5,
      isPregnant: false,
      isLactating: true,
      currentMilkLitrePd: 18.0,
      lactationNumber: 3,
      brucellaTested: true,
      brucellaTestDate: '2026-01-20',
      fmdZone: 'free',
      dairySpecific: const DairySpecific(
        somaticCellCount: 120000,
        butterfatPct: 5.1,
        proteinPct: 3.8,
        milkingSchedule: 'twice',
        totalMilkThisLactation: 2800,
        peakMilkLitrePd: 22.0,
      ),
    ),
    CattleAnimal(
      id: 'CA017',
      farmId: 'farm-001',
      tagNumber: 'CA017',
      name: 'Marla',
      breed: 'Jersey',
      productionType: 'dairy',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2021-07-08',
      bodyConditionScore: 3.5,
      isPregnant: true,
      expectedCalvingDate: '2026-09-28',
      isLactating: false,
      lactationNumber: 2,
      brucellaTested: true,
      brucellaTestDate: '2025-11-05',
      fmdZone: 'free',
    ),
    CattleAnimal(
      id: 'CA018',
      farmId: 'farm-001',
      tagNumber: 'CA018',
      name: 'Ginger',
      breed: 'Jersey',
      productionType: 'dairy',
      sex: 'heifer',
      status: 'active',
      herdId: 'herd-dairy',
      dateOfBirth: '2024-01-22',
      bodyConditionScore: 3.0,
      isPregnant: false,
      isLactating: false,
      lactationNumber: 0,
      brucellaTested: false,
      fmdZone: 'free',
    ),
  ];

  // ── Weight records ─────────────────────────────────────────────────────────

  static final List<WeightRecord> _weightRecords = [
    const WeightRecord(id: 'WR001', animalId: 'CA001', date: '2026-03-01', weightKg: 410, bodyConditionScore: 3.5),
    const WeightRecord(id: 'WR002', animalId: 'CA002', date: '2026-03-01', weightKg: 620),
    const WeightRecord(id: 'WR003', animalId: 'CA005', date: '2026-03-01', weightKg: 310, bodyConditionScore: 3.5),
    const WeightRecord(id: 'WR004', animalId: 'CA009', date: '2026-03-15', weightKg: 375, bodyConditionScore: 4.0),
    const WeightRecord(id: 'WR005', animalId: 'CA010', date: '2026-03-15', weightKg: 305, bodyConditionScore: 3.5),
    const WeightRecord(id: 'WR006', animalId: 'CA005', date: '2026-01-15', weightKg: 285),
    const WeightRecord(id: 'WR007', animalId: 'CA009', date: '2026-01-20', weightKg: 340),
    const WeightRecord(id: 'WR008', animalId: 'CA007', date: '2026-02-10', weightKg: 780),
  ];

  // ── Breeding records ───────────────────────────────────────────────────────

  static final List<BreedingRecord> _breedingRecords = [
    const BreedingRecord(
      id: 'BR001', cowId: 'CA001', bullId: 'CA002',
      serviceDate: '2025-11-01', serviceMethod: 'natural',
      expectedCalvingDate: '2026-08-15', outcome: 'confirmed_pregnant',
    ),
    const BreedingRecord(
      id: 'BR002', cowId: 'CA004', bullId: 'CA002',
      serviceDate: '2025-11-18', serviceMethod: 'natural',
      expectedCalvingDate: '2026-09-02', outcome: 'confirmed_pregnant',
    ),
    const BreedingRecord(
      id: 'BR003', cowId: 'CA013', bullId: 'CA015',
      serviceDate: '2026-01-10', serviceMethod: 'ai',
      semenSource: 'Topline Genetics', technician: 'J. Botha',
      expectedCalvingDate: '2026-10-20', outcome: 'confirmed_pregnant',
    ),
    const BreedingRecord(
      id: 'BR004', cowId: 'CA017', bullId: 'CA015',
      serviceDate: '2025-12-28', serviceMethod: 'natural',
      expectedCalvingDate: '2026-09-28', outcome: 'confirmed_pregnant',
    ),
  ];

  // ── Pregnancy checks ───────────────────────────────────────────────────────

  static final List<PregnancyCheck> _pregnancyChecks = [
    const PregnancyCheck(
      id: 'PC001', animalId: 'CA001', date: '2025-12-10',
      method: 'rectal', result: 'pregnant',
      expectedCalvingDate: '2026-08-15', daysPregnant: 40,
      checkedBy: 'Dr. Mokoena',
    ),
    const PregnancyCheck(
      id: 'PC002', animalId: 'CA004', date: '2025-12-15',
      method: 'ultrasound', result: 'pregnant',
      expectedCalvingDate: '2026-09-02', daysPregnant: 28,
      checkedBy: 'Dr. Mokoena',
    ),
    const PregnancyCheck(
      id: 'PC003', animalId: 'CA013', date: '2026-02-05',
      method: 'ultrasound', result: 'pregnant',
      expectedCalvingDate: '2026-10-20', daysPregnant: 26,
      checkedBy: 'Dr. Van Rooyen',
    ),
    const PregnancyCheck(
      id: 'PC004', animalId: 'CA017', date: '2026-01-25',
      method: 'rectal', result: 'pregnant',
      expectedCalvingDate: '2026-09-28', daysPregnant: 29,
      checkedBy: 'Dr. Van Rooyen',
    ),
  ];

  // ── Calving events ─────────────────────────────────────────────────────────

  static final List<CalvingEvent> _calvingEvents = [
    const CalvingEvent(
      id: 'CE001', damId: 'CA001', calvingDate: '2025-08-20',
      calvingEase: 'easy', calfAlive: true,
      calfId: 'CA006', calfSex: 'calf_female', calfWeightKg: 28.5,
    ),
    const CalvingEvent(
      id: 'CE002', damId: 'CA008', calvingDate: '2025-06-12',
      calvingEase: 'easy', calfAlive: true,
      calfSex: 'calf_male', calfWeightKg: 32.0,
    ),
    const CalvingEvent(
      id: 'CE003', damId: 'CA004', calvingDate: '2025-09-05',
      calvingEase: 'assisted', calfAlive: true,
      calfSex: 'calf_female', calfWeightKg: 26.0,
      complications: 'Dystocia — manual correction required',
    ),
  ];

  // ── Milk records ───────────────────────────────────────────────────────────

  static final List<DailyMilkRecord> _milkRecords = [
    const DailyMilkRecord(id: 'MR001', animalId: 'CA011', date: '2026-03-15', morningLitres: 14.5, eveningLitres: 13.5, lactationDay: 180),
    const DailyMilkRecord(id: 'MR002', animalId: 'CA012', date: '2026-03-15', morningLitres: 16.5, eveningLitres: 15.5, lactationDay: 155),
    const DailyMilkRecord(id: 'MR003', animalId: 'CA014', date: '2026-03-15', morningLitres: 12.5, eveningLitres: 12.5, lactationDay: 200, qualityFlag: 'elevated_scc'),
    const DailyMilkRecord(id: 'MR004', animalId: 'CA016', date: '2026-03-15', morningLitres: 9.5, eveningLitres: 8.5, lactationDay: 165),
    const DailyMilkRecord(id: 'MR005', animalId: 'CA011', date: '2026-03-14', morningLitres: 14.0, eveningLitres: 14.0, lactationDay: 179),
    const DailyMilkRecord(id: 'MR006', animalId: 'CA012', date: '2026-03-14', morningLitres: 16.0, eveningLitres: 16.0, lactationDay: 154),
    const DailyMilkRecord(id: 'MR007', animalId: 'CA016', date: '2026-03-14', morningLitres: 9.0, eveningLitres: 9.0, lactationDay: 164),
  ];

  // ── Health events ──────────────────────────────────────────────────────────

  static final List<CattleHealthEvent> _healthEvents = [
    const CattleHealthEvent(
      id: 'HE001', animalId: 'CA014', date: '2026-02-20',
      eventType: 'illness', diagnosis: 'Subclinical mastitis',
      severity: 'moderate', treatedBy: 'Farm manager',
      isNotifiable: false, outcome: 'Responding to treatment',
      notes: 'Right rear quarter affected. Teat dipping increased.',
    ),
    const CattleHealthEvent(
      id: 'HE002', animalId: 'CA003', date: '2026-01-05',
      eventType: 'injury', diagnosis: 'Barbed wire laceration — left shoulder',
      severity: 'mild', treatedBy: 'Farm manager',
      outcome: 'Healed',
    ),
    const CattleHealthEvent(
      id: 'HE003', animalId: 'CA009', date: '2026-03-01',
      eventType: 'observation', diagnosis: 'Suspected lumpy skin disease',
      severity: 'moderate', treatedBy: 'Dr. Mokoena',
      isNotifiable: true,
      notes: 'Notifiable disease — reported to AHT. Pending lab confirmation.',
    ),
  ];

  // ── Medication logs ────────────────────────────────────────────────────────

  static final List<CattleMedicationLog> _medicationLogs = [
    const CattleMedicationLog(
      id: 'ML001', animalId: 'CA014', date: '2026-02-20',
      medicationName: 'Penicillin G',
      route: 'injection', doseMg: 3000,
      withdrawalDaysMeat: 6, withdrawalDaysMilk: 4,
      veterinarianApproved: true, administeredBy: 'Dr. Van Rooyen',
    ),
    const CattleMedicationLog(
      id: 'ML002', animalId: 'CA003', date: '2026-01-05',
      medicationName: 'Terramycin spray',
      route: 'topical', doseMg: 50,
      veterinarianApproved: false, administeredBy: 'Farm manager',
    ),
    const CattleMedicationLog(
      id: 'ML003', animalId: 'CA009', date: '2026-03-01',
      medicationName: 'Neethling vaccine',
      route: 'injection', doseMg: 5,
      withdrawalDaysMeat: 21,
      veterinarianApproved: true, administeredBy: 'Dr. Mokoena',
    ),
  ];

  // ── Vaccinations ───────────────────────────────────────────────────────────

  static final List<CattleVaccination> _vaccinations = [
    const CattleVaccination(
      id: 'VC001', animalId: 'CA001', vaccineName: 'Brucella S19',
      dueDate: '2026-04-01', route: 'injection', administeredBy: 'Dr. Mokoena',
    ),
    const CattleVaccination(
      id: 'VC002', animalId: 'CA002', vaccineName: 'Blackleg (Clostridial)',
      dueDate: '2026-05-15',
      givenDate: '2026-05-14', batchNumber: 'CLO-2026-A',
      nextDueDate: '2027-05-14', route: 'injection',
    ),
    const CattleVaccination(
      id: 'VC003', animalId: 'CA011', vaccineName: 'BVD + IBR combo',
      dueDate: '2026-03-01',
      givenDate: '2026-03-02', batchNumber: 'BVD-2026-B',
      nextDueDate: '2027-03-02',
      route: 'injection', administeredBy: 'Dr. Van Rooyen',
    ),
    const CattleVaccination(
      id: 'VC004', animalId: 'CA009', vaccineName: 'Lumpy Skin Disease',
      dueDate: '2026-02-01',
    ),
    const CattleVaccination(
      id: 'VC005', animalId: 'CA016', vaccineName: 'Rift Valley Fever',
      dueDate: '2026-06-01', route: 'injection',
    ),
  ];

  // ── Sale records ───────────────────────────────────────────────────────────

  static final List<CattleSaleRecord> _saleRecords = [
    const CattleSaleRecord(
      id: 'SR001', animalId: 'CA005', saleDate: '2025-11-10',
      buyerName: 'Langkloof Feedlot',
      saleWeightKg: 290, pricePerKg: 38.50,
      totalAmount: 11165, transportCost: 650,
      permitNumber: 'MP-LK-2025-0441',
    ),
  ];

  // ── Feed records ───────────────────────────────────────────────────────────

  static final List<CattleFeedRecord> _feedRecords = [
    const CattleFeedRecord(
      id: 'FR001', animalId: 'CA009', date: '2026-03-15',
      feedType: 'TMR (total mixed ration)', quantityKg: 12.5,
      costPerKg: 3.20, feedlotPenId: 'B1', rationName: 'Finisher ration',
    ),
    const CattleFeedRecord(
      id: 'FR002', animalId: 'CA011', date: '2026-03-15',
      feedType: 'Dairy concentrate', quantityKg: 8.0, costPerKg: 5.80,
    ),
    const CattleFeedRecord(
      id: 'FR003', animalId: 'CA012', date: '2026-03-15',
      feedType: 'Dairy concentrate', quantityKg: 9.5, costPerKg: 5.80,
    ),
    const CattleFeedRecord(
      id: 'FR004', animalId: 'CA016', date: '2026-03-15',
      feedType: 'Dairy concentrate', quantityKg: 6.0, costPerKg: 5.80,
    ),
  ];

  // ── Pasture records ────────────────────────────────────────────────────────

  static final List<PastureRecord> _pastureRecords = [
    const PastureRecord(
      id: 'PR001', herdId: 'herd-nguni', campId: 'Camp A',
      entryDate: '2026-02-01', estimatedHa: 45.0, veldCondition: 'good',
    ),
    const PastureRecord(
      id: 'PR002', herdId: 'herd-bonsmara', campId: 'Camp C',
      entryDate: '2026-01-15', estimatedHa: 30.0, veldCondition: 'fair',
    ),
    const PastureRecord(
      id: 'PR003', herdId: 'herd-nguni', campId: 'Camp B',
      entryDate: '2025-11-01', exitDate: '2026-01-31',
      estimatedHa: 40.0, veldCondition: 'good',
    ),
  ];

  // ── Body condition records ─────────────────────────────────────────────────

  static final List<BodyConditionRecord> _bcsRecords = [
    const BodyConditionRecord(id: 'BC001', animalId: 'CA001', date: '2026-03-01', score: 3.5, assessedBy: 'Farm manager'),
    const BodyConditionRecord(id: 'BC002', animalId: 'CA011', date: '2026-03-01', score: 3.0, assessedBy: 'Farm manager'),
    const BodyConditionRecord(id: 'BC003', animalId: 'CA014', date: '2026-03-01', score: 2.5, assessedBy: 'Farm manager', notes: 'Below target — increase energy supplementation'),
    const BodyConditionRecord(id: 'BC004', animalId: 'CA016', date: '2026-03-01', score: 3.5, assessedBy: 'Farm manager'),
    const BodyConditionRecord(id: 'BC005', animalId: 'CA007', date: '2026-02-15', score: 4.5),
  ];

  // ── Dipping records ────────────────────────────────────────────────────────

  static final List<DippingRecord> _dippingRecords = [
    const DippingRecord(
      id: 'DR001', animalId: 'CA001', dippingDate: '2026-02-15',
      productUsed: 'Triatix (Amitraz)', concentration: '0.025%',
      method: 'spray', nextDueDays: 14,
      veterinarianApproved: false,
    ),
    const DippingRecord(
      id: 'DR002', animalId: 'CA002', dippingDate: '2026-02-15',
      productUsed: 'Triatix (Amitraz)', concentration: '0.025%',
      method: 'spray', nextDueDays: 14,
    ),
    const DippingRecord(
      id: 'DR003', animalId: 'CA009', dippingDate: '2026-03-01',
      productUsed: 'Deadline (Cypermethrin)', concentration: '0.05%',
      method: 'plunge', nextDueDays: 21,
      veterinarianApproved: true,
      notes: 'Feedlot protocol — mandatory 21-day interval',
    ),
  ];

  // ── DataSource interface implementations ───────────────────────────────────

  @override
  Future<List<CattleAnimal>> getAnimals() async => List.from(_animals);

  @override
  Future<List<WeightRecord>> getWeightRecords() async =>
      List.from(_weightRecords);

  @override
  Future<List<BreedingRecord>> getBreedingRecords() async =>
      List.from(_breedingRecords);

  @override
  Future<List<PregnancyCheck>> getPregnancyChecks() async =>
      List.from(_pregnancyChecks);

  @override
  Future<List<CalvingEvent>> getCalvingEvents() async =>
      List.from(_calvingEvents);

  @override
  Future<List<DailyMilkRecord>> getMilkRecords() async =>
      List.from(_milkRecords);

  @override
  Future<List<CattleHealthEvent>> getHealthEvents() async =>
      List.from(_healthEvents);

  @override
  Future<List<CattleMedicationLog>> getMedicationLogs() async =>
      List.from(_medicationLogs);

  @override
  Future<List<CattleVaccination>> getVaccinations() async =>
      List.from(_vaccinations);

  @override
  Future<List<CattleSaleRecord>> getSaleRecords() async =>
      List.from(_saleRecords);

  @override
  Future<List<CattleFeedRecord>> getFeedRecords() async =>
      List.from(_feedRecords);

  @override
  Future<List<PastureRecord>> getPastureRecords() async =>
      List.from(_pastureRecords);

  @override
  Future<List<BodyConditionRecord>> getBodyConditionRecords() async =>
      List.from(_bcsRecords);

  @override
  Future<List<DippingRecord>> getDippingRecords() async =>
      List.from(_dippingRecords);

  // ── Mutation stubs (mock: return/store in-place) ──────────────────────────

  @override
  Future<CattleAnimal> createAnimal(CattleAnimal animal) async {
    _animals.add(animal);
    return animal;
  }

  @override
  Future<CattleAnimal> updateAnimal(CattleAnimal animal) async {
    final idx = _animals.indexWhere((a) => a.id == animal.id);
    if (idx != -1) _animals[idx] = animal;
    return animal;
  }

  @override
  Future<void> deleteAnimal(String id) async =>
      _animals.removeWhere((a) => a.id == id);

  @override
  Future<WeightRecord> createWeightRecord(WeightRecord record) async {
    _weightRecords.add(record);
    return record;
  }

  @override
  Future<void> deleteWeightRecord(String id) async =>
      _weightRecords.removeWhere((r) => r.id == id);

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    _breedingRecords.add(record);
    return record;
  }

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    final idx = _breedingRecords.indexWhere((r) => r.id == record.id);
    if (idx != -1) _breedingRecords[idx] = record;
    return record;
  }

  @override
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async {
    _pregnancyChecks.add(check);
    return check;
  }

  @override
  Future<CalvingEvent> createCalvingEvent(CalvingEvent event) async {
    _calvingEvents.add(event);
    return event;
  }

  @override
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async {
    _milkRecords.add(record);
    return record;
  }

  @override
  Future<void> deleteMilkRecord(String id) async =>
      _milkRecords.removeWhere((r) => r.id == id);

  @override
  Future<CattleHealthEvent> createHealthEvent(CattleHealthEvent event) async {
    _healthEvents.add(event);
    return event;
  }

  @override
  Future<CattleHealthEvent> updateHealthEvent(CattleHealthEvent event) async {
    final idx = _healthEvents.indexWhere((e) => e.id == event.id);
    if (idx != -1) _healthEvents[idx] = event;
    return event;
  }

  @override
  Future<CattleMedicationLog> createMedicationLog(
      CattleMedicationLog log) async {
    _medicationLogs.add(log);
    return log;
  }

  @override
  Future<CattleVaccination> createVaccination(
      CattleVaccination vaccination) async {
    _vaccinations.add(vaccination);
    return vaccination;
  }

  @override
  Future<CattleVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  }) async {
    final idx = _vaccinations.indexWhere((v) => v.id == id);
    if (idx != -1) {
      final updated = CattleVaccination(
        id: _vaccinations[idx].id,
        animalId: _vaccinations[idx].animalId,
        vaccineName: _vaccinations[idx].vaccineName,
        dueDate: _vaccinations[idx].dueDate,
        givenDate: givenDate,
        batchNumber: batchNumber ?? _vaccinations[idx].batchNumber,
        nextDueDate: _vaccinations[idx].nextDueDate,
        route: _vaccinations[idx].route,
        siteOnBody: _vaccinations[idx].siteOnBody,
        administeredBy: _vaccinations[idx].administeredBy,
      );
      _vaccinations[idx] = updated;
      return updated;
    }
    throw Exception('Vaccination not found: $id');
  }

  @override
  Future<CattleSaleRecord> createSaleRecord(CattleSaleRecord record) async {
    _saleRecords.add(record);
    return record;
  }

  @override
  Future<CattleSaleRecord> updateSaleRecord(CattleSaleRecord record) async {
    final idx = _saleRecords.indexWhere((r) => r.id == record.id);
    if (idx != -1) _saleRecords[idx] = record;
    return record;
  }

  @override
  Future<void> deleteSaleRecord(String id) async =>
      _saleRecords.removeWhere((r) => r.id == id);

  @override
  Future<CattleFeedRecord> createFeedRecord(CattleFeedRecord record) async {
    _feedRecords.add(record);
    return record;
  }

  @override
  Future<void> deleteFeedRecord(String id) async =>
      _feedRecords.removeWhere((r) => r.id == id);

  @override
  Future<PastureRecord> createPastureRecord(PastureRecord record) async {
    _pastureRecords.add(record);
    return record;
  }

  @override
  Future<PastureRecord> exitPasture(String id, String exitDate) async {
    final idx = _pastureRecords.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final updated = PastureRecord(
        id: _pastureRecords[idx].id,
        herdId: _pastureRecords[idx].herdId,
        campId: _pastureRecords[idx].campId,
        entryDate: _pastureRecords[idx].entryDate,
        exitDate: exitDate,
        estimatedHa: _pastureRecords[idx].estimatedHa,
        veldCondition: _pastureRecords[idx].veldCondition,
        notes: _pastureRecords[idx].notes,
      );
      _pastureRecords[idx] = updated;
      return updated;
    }
    throw Exception('Pasture record not found: $id');
  }

  @override
  Future<BodyConditionRecord> createBodyConditionRecord(
      BodyConditionRecord record) async {
    _bcsRecords.add(record);
    return record;
  }

  @override
  Future<DippingRecord> createDippingRecord(DippingRecord record) async {
    _dippingRecords.add(record);
    return record;
  }
}
