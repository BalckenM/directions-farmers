// Canonical flock model lives in poultry_flock.dart as [PoultryFlock].
// This file contains supporting record/event models used by the poultry module.

/// Feed phase/ration type constants.
class FeedPhaseType {
  static const String starter = 'starter';
  static const String grower = 'grower';
  static const String finisher = 'finisher';
  static const String pulletRearer = 'pullet_rearer';
  static const String layingMash = 'laying_mash';

  static const List<String> allValues = [
    starter,
    grower,
    finisher,
    pulletRearer,
    layingMash,
  ];

  static String label(String value) => switch (value) {
        starter => 'Starter',
        grower => 'Grower',
        finisher => 'Finisher',
        pulletRearer => 'Pullet Rearer',
        layingMash => 'Laying Mash',
        _ => value,
      };

  static List<String> forProductionType(String productionType) {
    if (productionType == 'layer' || productionType == 'breeder') {
      return [starter, pulletRearer, layingMash];
    }
    return [starter, grower, finisher];
  }
}

/// Mortality cause code constants for daily records.
class MortalityCause {
  static const String sds = 'sds';
  static const String ascites = 'ascites';
  static const String suffocation = 'suffocation';
  static const String cull = 'cull';
  static const String disease = 'disease';
  static const String unknown = 'unknown';
  static const String other = 'other';

  static const List<String> allValues = [
    sds, ascites, suffocation, cull, disease, unknown, other,
  ];

  static String label(String value) => switch (value) {
        sds => 'Sudden Death Syndrome',
        ascites => 'Ascites / Roundheart',
        suffocation => 'Suffocation / Smothering',
        cull => 'Culled — Poor Doer',
        disease => 'Disease-Related',
        unknown => 'Unknown',
        other => 'Other',
        _ => value,
      };
}

/// A single daily record entry for a flock.
class DailyRecord {
  const DailyRecord({
    required this.id,
    required this.flockId,
    required this.date,
    this.dayOfAge,
    this.mortalityCount,
    this.mortalityCause,
    this.culls,
    this.feedConsumedKg,
    this.waterConsumedLitres,
    this.feedType,
    this.avgHouseTempC,
    this.avgBodyWeightG,
    // Layer-specific
    this.eggsCollectedAm,
    this.eggsCollectedPm,
    this.brokenEggs,
    this.floorEggs,
    this.avgEggWeightG,
    this.hdpPct,
    // Egg grade breakdown (layer)
    this.eggsJumbo,
    this.eggsExtraLarge,
    this.eggsLarge,
    this.eggsMedium,
    this.eggsSmall,
    this.eggsPeewee,
    this.notes,
    this.recordedBy,
  });

  final String id;
  final String flockId;
  final String date;
  final int? dayOfAge;
  final int? mortalityCount;
  final String? mortalityCause;
  final int? culls;
  final double? feedConsumedKg;
  final double? waterConsumedLitres;
  final String? feedType;
  final double? avgHouseTempC;
  final int? avgBodyWeightG;
  final int? eggsCollectedAm;
  final int? eggsCollectedPm;
  final int? brokenEggs;
  final int? floorEggs;
  final double? avgEggWeightG;
  final double? hdpPct;
  final int? eggsJumbo;
  final int? eggsExtraLarge;
  final int? eggsLarge;
  final int? eggsMedium;
  final int? eggsSmall;
  final int? eggsPeewee;
  final String? notes;
  final String? recordedBy;

  int get totalEggs => (eggsCollectedAm ?? 0) + (eggsCollectedPm ?? 0);
  int get gradedEggs =>
      (eggsJumbo ?? 0) +
      (eggsExtraLarge ?? 0) +
      (eggsLarge ?? 0) +
      (eggsMedium ?? 0) +
      (eggsSmall ?? 0) +
      (eggsPeewee ?? 0);
  bool get isLayerRecord => eggsCollectedAm != null || eggsCollectedPm != null;
  bool get hasGrading => gradedEggs > 0;

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      id: json['id'] as String? ?? '',
      flockId: json['flock_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      dayOfAge: json['day_of_age'] as int?,
      mortalityCount: json['mortality_count'] as int?,
      mortalityCause: json['mortality_cause'] as String?,
      culls: json['culls'] as int?,
      feedConsumedKg: (json['feed_consumed_kg'] as num?)?.toDouble(),
      waterConsumedLitres:
          (json['water_consumed_litres'] as num?)?.toDouble(),
      feedType: json['feed_type'] as String?,
      avgHouseTempC: (json['avg_house_temp_c'] as num?)?.toDouble(),
      avgBodyWeightG: json['avg_body_weight_g'] as int?,
      eggsCollectedAm: json['eggs_collected_am'] as int?,
      eggsCollectedPm: json['eggs_collected_pm'] as int?,
      brokenEggs: json['broken_eggs'] as int?,
      floorEggs: json['floor_eggs'] as int?,
      avgEggWeightG: (json['avg_egg_weight_g'] as num?)?.toDouble(),
      hdpPct: (json['hdp_pct'] as num?)?.toDouble(),
      eggsJumbo: json['eggs_jumbo'] as int?,
      eggsExtraLarge: json['eggs_extra_large'] as int?,
      eggsLarge: json['eggs_large'] as int?,
      eggsMedium: json['eggs_medium'] as int?,
      eggsSmall: json['eggs_small'] as int?,
      eggsPeewee: json['eggs_peewee'] as int?,
      notes: json['notes'] as String?,
      recordedBy: json['recorded_by'] as String?,
    );
  }
}

// ── Feed Phase (Ration Scheduler) ─────────────────────────────────────────────

/// A feed phase entry for a batch — defines the ration schedule by day-of-age.
class FeedPhase {
  const FeedPhase({
    required this.id,
    required this.flockId,
    required this.phaseName,
    required this.feedType,
    required this.dayStart,
    required this.dayEnd,
    this.targetIntakeGPerBirdPerDay,
    this.feedProduct,
    this.notes,
  });

  final String id;
  final String flockId;
  final String phaseName;
  final String feedType;
  final int dayStart;
  final int dayEnd;
  final double? targetIntakeGPerBirdPerDay;
  final String? feedProduct;
  final String? notes;

  bool isActiveOnDay(int dayOfAge) =>
      dayOfAge >= dayStart && dayOfAge <= dayEnd;

  factory FeedPhase.fromJson(Map<String, dynamic> json) => FeedPhase(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        phaseName: json['phase_name'] as String? ?? '',
        feedType: json['feed_type'] as String? ?? '',
        dayStart: json['day_start'] as int? ?? 0,
        dayEnd: json['day_end'] as int? ?? 0,
        targetIntakeGPerBirdPerDay:
            (json['target_intake_g_per_bird_per_day'] as num?)?.toDouble(),
        feedProduct: json['feed_product'] as String?,
        notes: json['notes'] as String?,
      );
}

// ── Harvest Record ─────────────────────────────────────────────────────────────

/// Harvest/slaughter record for a completed broiler (or duck/turkey) batch.
class HarvestRecord {
  const HarvestRecord({
    required this.id,
    required this.flockId,
    required this.harvestDate,
    required this.birdsHarvested,
    required this.totalLiveWeightKg,
    this.processorName,
    this.carcassGradeAPct,
    this.condemnationRatePct,
    this.pricePerKgZar,
    this.notes,
    this.recordedBy,
  });

  final String id;
  final String flockId;
  final String harvestDate;
  final int birdsHarvested;
  final double totalLiveWeightKg;
  final String? processorName;
  final double? carcassGradeAPct;
  final double? condemnationRatePct;
  final double? pricePerKgZar;
  final String? notes;
  final String? recordedBy;

  double get avgHarvestWeightKg =>
      birdsHarvested > 0 ? totalLiveWeightKg / birdsHarvested : 0;
  double get totalRevenueZar =>
      pricePerKgZar != null ? totalLiveWeightKg * pricePerKgZar! : 0;

  factory HarvestRecord.fromJson(Map<String, dynamic> json) => HarvestRecord(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        harvestDate: json['harvest_date'] as String? ?? '',
        birdsHarvested: json['birds_harvested'] as int? ?? 0,
        totalLiveWeightKg:
            (json['total_live_weight_kg'] as num?)?.toDouble() ?? 0,
        processorName: json['processor_name'] as String?,
        carcassGradeAPct:
            (json['carcass_grade_a_pct'] as num?)?.toDouble(),
        condemnationRatePct:
            (json['condemnation_rate_pct'] as num?)?.toDouble(),
        pricePerKgZar: (json['price_per_kg_zar'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        recordedBy: json['recorded_by'] as String?,
      );
}

/// One entry in a flock vaccination schedule.
class VaccineItem {
  const VaccineItem({
    required this.vaccine,
    required this.targetDay,
    required this.method,
    required this.status,
    this.completedDate,
    this.dueDate,
    this.product,
    this.batchNo,
    this.administeredBy,
  });

  final String vaccine;
  final int targetDay;
  final String method;

  /// completed | pending | overdue
  final String status;
  final String? completedDate;
  final String? dueDate;
  final String? product;
  final String? batchNo;
  final String? administeredBy;

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  factory VaccineItem.fromJson(Map<String, dynamic> json) => VaccineItem(
        vaccine: json['vaccine'] as String? ?? '',
        targetDay: json['target_day'] as int? ?? 0,
        method: json['method'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        completedDate: json['completed_date'] as String?,
        dueDate: json['due_date'] as String?,
        product: json['product'] as String?,
        batchNo: json['batch_no'] as String?,
        administeredBy: json['administered_by'] as String?,
      );
}

/// Full vaccination schedule for a flock.
class VaccinationSchedule {
  const VaccinationSchedule({
    required this.id,
    required this.flockId,
    required this.productionType,
    required this.strain,
    required this.placementDate,
    required this.schedule,
  });

  final String id;
  final String flockId;
  final String productionType;
  final String strain;
  final String placementDate;
  final List<VaccineItem> schedule;

  int get completedCount => schedule.where((v) => v.isCompleted).length;
  int get pendingCount => schedule.where((v) => v.isPending).length;
  int get overdueCount => schedule.where((v) => v.isOverdue).length;

  factory VaccinationSchedule.fromJson(Map<String, dynamic> json) =>
      VaccinationSchedule(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        productionType: json['production_type'] as String? ?? '',
        strain: json['strain'] as String? ?? '',
        placementDate: json['placement_date'] as String? ?? '',
        schedule: (json['schedule'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
            .map(VaccineItem.fromJson)
            .toList(),
      );
}

// ── Medication Log ─────────────────────────────────────────────────────────────

/// A single medication administration event for a flock.
class MedicationLog {
  const MedicationLog({
    required this.id,
    required this.flockId,
    required this.date,
    required this.drugName,
    required this.dosage,
    required this.route,
    required this.withdrawalDays,
    this.diagnosis,
    this.prescribedBy,
    this.administeredBy,
    this.batchNo,
    this.notes,
  });

  final String id;
  final String flockId;
  final String date;
  final String drugName;
  final String dosage;
  final String route; // drinking_water | injection | feed | spray | eye_drop
  final int withdrawalDays;
  final String? diagnosis;
  final String? prescribedBy;
  final String? administeredBy;
  final String? batchNo;
  final String? notes;

  /// Date after which birds can be slaughtered (YYYY-MM-DD).
  String get clearanceDate {
    try {
      final d = DateTime.parse(date).add(Duration(days: withdrawalDays));
      return '${d.year.toString()}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  factory MedicationLog.fromJson(Map<String, dynamic> json) => MedicationLog(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        date: json['date'] as String? ?? '',
        drugName: json['drug_name'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        route: json['route'] as String? ?? '',
        withdrawalDays: json['withdrawal_days'] as int? ?? 0,
        diagnosis: json['diagnosis'] as String?,
        prescribedBy: json['prescribed_by'] as String?,
        administeredBy: json['administered_by'] as String?,
        batchNo: json['batch_no'] as String?,
        notes: json['notes'] as String?,
      );
}

// ── Disease Event ─────────────────────────────────────────────────────────────

/// A disease investigation or outbreak event logged for a flock.
class DiseaseEvent {
  const DiseaseEvent({
    required this.id,
    required this.flockId,
    required this.date,
    required this.disease,
    required this.severity,
    required this.affectedCount,
    this.symptoms,
    this.diagnosticTest,
    this.testResult,
    this.isNotifiable,
    this.reportedToAuthorities,
    this.reportedDate,
    this.outcome,
    this.loggedBy,
    this.notes,
  });

  final String id;
  final String flockId;
  final String date;
  final String disease;
  final String severity; // low | medium | high | emergency
  final int affectedCount;
  final String? symptoms;
  final String? diagnosticTest;
  final String? testResult;
  final bool? isNotifiable;
  final bool? reportedToAuthorities;
  final String? reportedDate;
  final String? outcome;
  final String? loggedBy;
  final String? notes;

  bool get isHpai =>
      disease.toLowerCase().contains('avian influenza') ||
      disease.toLowerCase().contains('hpai') ||
      disease.toLowerCase().contains('bird flu');

  bool get isEmergency => severity == 'emergency';

  factory DiseaseEvent.fromJson(Map<String, dynamic> json) => DiseaseEvent(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        date: json['date'] as String? ?? '',
        disease: json['disease'] as String? ?? '',
        severity: json['severity'] as String? ?? 'medium',
        affectedCount: json['affected_count'] as int? ?? 0,
        symptoms: json['symptoms'] as String?,
        diagnosticTest: json['diagnostic_test'] as String?,
        testResult: json['test_result'] as String?,
        isNotifiable: json['is_notifiable'] as bool?,
        reportedToAuthorities: json['reported_to_authorities'] as bool?,
        reportedDate: json['reported_date'] as String?,
        outcome: json['outcome'] as String?,
        loggedBy: json['logged_by'] as String?,
        notes: json['notes'] as String?,
      );
}

// ── Environment Reading ────────────────────────────────────────────────────────

/// A single IoT sensor reading for a house/flock environment.
class EnvironmentReading {
  const EnvironmentReading({
    required this.id,
    required this.flockId,
    required this.timestamp,
    required this.sensorZone,
    this.tempC,
    this.humidityPct,
    this.ammoniaPpm,
    this.co2Ppm,
    this.lightLux,
    this.windspeedMs,
  });

  final String id;
  final String flockId;
  final String timestamp;
  final String sensorZone; // e.g. 'north', 'south', 'inlet', 'outlet'
  final double? tempC;
  final double? humidityPct;
  final double? ammoniaPpm;
  final double? co2Ppm;
  final double? lightLux;
  final double? windspeedMs;

  bool get tempAlert => tempC != null && (tempC! > 32 || tempC! < 16);
  bool get ammoniaAlert => ammoniaPpm != null && ammoniaPpm! > 20;
  bool get humidityAlert =>
      humidityPct != null && (humidityPct! > 80 || humidityPct! < 40);

  factory EnvironmentReading.fromJson(Map<String, dynamic> json) =>
      EnvironmentReading(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
        sensorZone: json['sensor_zone'] as String? ?? '',
        tempC: (json['temp_c'] as num?)?.toDouble(),
        humidityPct: (json['humidity_pct'] as num?)?.toDouble(),
        ammoniaPpm: (json['ammonia_ppm'] as num?)?.toDouble(),
        co2Ppm: (json['co2_ppm'] as num?)?.toDouble(),
        lightLux: (json['light_lux'] as num?)?.toDouble(),
        windspeedMs: (json['windspeed_ms'] as num?)?.toDouble(),
      );
}

// ── Egg Sale ──────────────────────────────────────────────────────────────────

/// A single egg sales transaction — records grade breakdown, price, and buyer.
class EggSale {
  const EggSale({
    required this.id,
    required this.flockId,
    required this.date,
    required this.buyerName,
    required this.dozensTotal,
    required this.pricePerDozen,
    this.gradeBreakdown = const {},
    this.invoiceRef,
    this.notes,
  });

  final String id;
  final String flockId;
  final String date;
  final String buyerName;
  final double dozensTotal;
  final double pricePerDozen;
  final Map<String, int> gradeBreakdown; // 'jumbo','extra_large','large','medium','small'
  final String? invoiceRef;
  final String? notes;

  double get totalRevenue => dozensTotal * pricePerDozen;

  int get totalEggs =>
      gradeBreakdown.values.fold(0, (sum, v) => sum + v);

  factory EggSale.fromJson(Map<String, dynamic> json) => EggSale(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        date: json['date'] as String? ?? '',
        buyerName: json['buyer_name'] as String? ?? '',
        dozensTotal: (json['dozens_total'] as num?)?.toDouble() ?? 0.0,
        pricePerDozen: (json['price_per_dozen'] as num?)?.toDouble() ?? 0.0,
        gradeBreakdown: (json['grade_breakdown'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        invoiceRef: json['invoice_ref'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'flock_id': flockId,
        'date': date,
        'buyer_name': buyerName,
        'dozens_total': dozensTotal,
        'price_per_dozen': pricePerDozen,
        'grade_breakdown': gradeBreakdown,
        'invoice_ref': invoiceRef,
        'notes': notes,
      };
}

// ── Chick Sale ─────────────────────────────────────────────────────────────────

/// A day-old chick (DOC) sale record for breeder / parent-stock flocks.
class ChickSale {
  const ChickSale({
    required this.id,
    required this.flockId,
    this.batchNo,
    required this.hatchDate,
    required this.saleDate,
    required this.buyerName,
    required this.chickCount,
    required this.pricePerChick,
    required this.totalAmount,
    required this.chickSex,
    this.eggsSet,
    this.eggsHatched,
    this.fertilityPct,
    this.hatchabilityPct,
    this.avgChickWeightG,
    this.invoiceRef,
    this.notes,
  });

  final String id;
  final String flockId;
  final String? batchNo;
  final String hatchDate;
  final String saleDate;
  final String buyerName;

  /// Number of DOC chicks sold.
  final int chickCount;

  /// Price per DOC chick.
  final double pricePerChick;

  /// Total invoice amount (chickCount * pricePerChick).
  final double totalAmount;

  /// "straight_run", "male", "female", or "sexed_female".
  final String chickSex;

  final int? eggsSet;
  final int? eggsHatched;
  final double? fertilityPct;
  final double? hatchabilityPct;
  final double? avgChickWeightG;
  final String? invoiceRef;
  final String? notes;

  factory ChickSale.fromJson(Map<String, dynamic> json) => ChickSale(
        id: json['id'] as String? ?? '',
        flockId: json['flock_id'] as String? ?? '',
        batchNo: json['batch_no'] as String?,
        hatchDate: json['hatch_date'] as String? ?? '',
        saleDate: json['sale_date'] as String? ?? '',
        buyerName: json['buyer_name'] as String? ?? '',
        chickCount: json['chick_count'] as int? ?? 0,
        pricePerChick: (json['price_per_chick'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
        chickSex: json['chick_sex'] as String? ?? 'straight_run',
        eggsSet: json['eggs_set'] as int?,
        eggsHatched: json['eggs_hatched'] as int?,
        fertilityPct: (json['fertility_pct'] as num?)?.toDouble(),
        hatchabilityPct: (json['hatchability_pct'] as num?)?.toDouble(),
        avgChickWeightG: (json['avg_chick_weight_g'] as num?)?.toDouble(),
        invoiceRef: json['invoice_ref'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'flock_id': flockId,
        'batch_no': batchNo,
        'hatch_date': hatchDate,
        'sale_date': saleDate,
        'buyer_name': buyerName,
        'chick_count': chickCount,
        'price_per_chick': pricePerChick,
        'total_amount': totalAmount,
        'chick_sex': chickSex,
        'eggs_set': eggsSet,
        'eggs_hatched': eggsHatched,
        'fertility_pct': fertilityPct,
        'hatchability_pct': hatchabilityPct,
        'avg_chick_weight_g': avgChickWeightG,
        'invoice_ref': invoiceRef,
        'notes': notes,
      };
}

// ── Financial Auto-Entry ───────────────────────────────────────────────────────

/// A single auto-generated financial ledger entry for a flock.
/// Created automatically when daily records, medication logs, or harvest records are saved.
enum FinancialEntryType { expense, revenue }

class FinancialAutoEntry {
  const FinancialAutoEntry({
    required this.id,
    required this.flockId,
    required this.date,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    this.sourceId,
  });

  final String id;
  final String flockId;
  final String date;
  final FinancialEntryType type;
  final String category; // 'feed','medication','harvest','other'
  final String description;
  final double amount;
  final String? sourceId; // ID of the source record (daily record, medication log, etc.)
}
