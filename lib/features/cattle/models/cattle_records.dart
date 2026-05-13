/// All record types for the cattle module.
///
/// 13 types: WeightRecord, BreedingRecord, PregnancyCheck, CalvingEvent,
/// DailyMilkRecord, CattleHealthEvent, CattleMedicationLog, CattleVaccination,
/// CattleSaleRecord, CattleFeedRecord, PastureRecord, BodyConditionRecord,
/// DippingRecord.

// ── Weight record ─────────────────────────────────────────────────────────────

class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.weightKg,
    this.bodyConditionScore,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;
  final double weightKg;
  final double? bodyConditionScore;
  final String? notes;

  factory WeightRecord.fromJson(Map<String, dynamic> j) => WeightRecord(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        weightKg: (j['weightKg'] as num).toDouble(),
        bodyConditionScore: (j['bodyConditionScore'] as num?)?.toDouble(),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'weightKg': weightKg,
        if (bodyConditionScore != null) 'bodyConditionScore': bodyConditionScore,
        if (notes != null) 'notes': notes,
      };
}

// ── Breeding record ───────────────────────────────────────────────────────────

class BreedingRecord {
  const BreedingRecord({
    required this.id,
    required this.cowId,
    required this.bullId,
    required this.serviceDate,
    required this.serviceMethod,
    this.semenSource,
    this.technician,
    this.expectedCalvingDate,
    this.outcome,
    this.notes,
  });

  final String id;
  final String cowId;
  final String bullId;

  /// ISO 8601 date string.
  final String serviceDate;

  /// One of: natural / ai (artificial insemination)
  final String serviceMethod;

  /// Semen supplier or stud name (for AI).
  final String? semenSource;

  /// AI technician name (for AI).
  final String? technician;

  final String? expectedCalvingDate;

  /// One of: confirmed_pregnant / empty / pending
  final String? outcome;
  final String? notes;

  factory BreedingRecord.fromJson(Map<String, dynamic> j) => BreedingRecord(
        id: j['id'] as String,
        cowId: j['cowId'] as String,
        bullId: j['bullId'] as String,
        serviceDate: j['serviceDate'] as String,
        serviceMethod: j['serviceMethod'] as String,
        semenSource: j['semenSource'] as String?,
        technician: j['technician'] as String?,
        expectedCalvingDate: j['expectedCalvingDate'] as String?,
        outcome: j['outcome'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cowId': cowId,
        'bullId': bullId,
        'serviceDate': serviceDate,
        'serviceMethod': serviceMethod,
        if (semenSource != null) 'semenSource': semenSource,
        if (technician != null) 'technician': technician,
        if (expectedCalvingDate != null) 'expectedCalvingDate': expectedCalvingDate,
        if (outcome != null) 'outcome': outcome,
        if (notes != null) 'notes': notes,
      };
}

// ── Pregnancy check ───────────────────────────────────────────────────────────

class PregnancyCheck {
  const PregnancyCheck({
    required this.id,
    required this.animalId,
    required this.date,
    required this.method,
    required this.result,
    this.expectedCalvingDate,
    this.daysPregnant,
    this.checkedBy,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;

  /// One of: rectal / ultrasound / blood_test
  final String method;

  /// One of: pregnant / empty / uncertain
  final String result;

  final String? expectedCalvingDate;
  final int? daysPregnant;
  final String? checkedBy;
  final String? notes;

  factory PregnancyCheck.fromJson(Map<String, dynamic> j) => PregnancyCheck(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        method: j['method'] as String,
        result: j['result'] as String,
        expectedCalvingDate: j['expectedCalvingDate'] as String?,
        daysPregnant: j['daysPregnant'] as int?,
        checkedBy: j['checkedBy'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'method': method,
        'result': result,
        if (expectedCalvingDate != null) 'expectedCalvingDate': expectedCalvingDate,
        if (daysPregnant != null) 'daysPregnant': daysPregnant,
        if (checkedBy != null) 'checkedBy': checkedBy,
        if (notes != null) 'notes': notes,
      };
}

// ── Calving event ─────────────────────────────────────────────────────────────

class CalvingEvent {
  const CalvingEvent({
    required this.id,
    required this.damId,
    required this.calvingDate,
    required this.calvingEase,
    required this.calfAlive,
    this.calfId,
    this.calfSex,
    this.calfWeightKg,
    this.complications,
    this.notes,
  });

  final String id;
  final String damId;

  /// ISO 8601 date string.
  final String calvingDate;

  /// One of: easy / assisted / vet
  final String calvingEase;

  final bool calfAlive;
  final String? calfId;

  /// One of: calf_male / calf_female
  final String? calfSex;

  final double? calfWeightKg;
  final String? complications;
  final String? notes;

  factory CalvingEvent.fromJson(Map<String, dynamic> j) => CalvingEvent(
        id: j['id'] as String,
        damId: j['damId'] as String,
        calvingDate: j['calvingDate'] as String,
        calvingEase: j['calvingEase'] as String,
        calfAlive: j['calfAlive'] as bool? ?? true,
        calfId: j['calfId'] as String?,
        calfSex: j['calfSex'] as String?,
        calfWeightKg: (j['calfWeightKg'] as num?)?.toDouble(),
        complications: j['complications'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'damId': damId,
        'calvingDate': calvingDate,
        'calvingEase': calvingEase,
        'calfAlive': calfAlive,
        if (calfId != null) 'calfId': calfId,
        if (calfSex != null) 'calfSex': calfSex,
        if (calfWeightKg != null) 'calfWeightKg': calfWeightKg,
        if (complications != null) 'complications': complications,
        if (notes != null) 'notes': notes,
      };
}

// ── Daily milk record ─────────────────────────────────────────────────────────

class DailyMilkRecord {
  const DailyMilkRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.morningLitres,
    this.eveningLitres,
    required this.lactationDay,
    this.qualityFlag,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;
  final double morningLitres;
  final double? eveningLitres;
  final int lactationDay;

  /// Optional quality flag, e.g. 'elevated_scc' / 'mastitis_suspect'
  final String? qualityFlag;
  final String? notes;

  double get totalLitres => morningLitres + (eveningLitres ?? 0);

  factory DailyMilkRecord.fromJson(Map<String, dynamic> j) => DailyMilkRecord(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        morningLitres: (j['morningLitres'] as num).toDouble(),
        eveningLitres: (j['eveningLitres'] as num?)?.toDouble(),
        lactationDay: j['lactationDay'] as int,
        qualityFlag: j['qualityFlag'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'morningLitres': morningLitres,
        if (eveningLitres != null) 'eveningLitres': eveningLitres,
        'lactationDay': lactationDay,
        if (qualityFlag != null) 'qualityFlag': qualityFlag,
        if (notes != null) 'notes': notes,
      };
}

// ── Health event ──────────────────────────────────────────────────────────────

class CattleHealthEvent {
  const CattleHealthEvent({
    required this.id,
    required this.animalId,
    required this.date,
    required this.eventType,
    required this.diagnosis,
    required this.severity,
    this.treatedBy,
    this.isNotifiable = false,
    this.outcome,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;

  /// e.g. 'illness' / 'injury' / 'observation'
  final String eventType;

  final String diagnosis;

  /// One of: mild / moderate / severe
  final String severity;

  final String? treatedBy;

  /// True for legally notifiable diseases (FMD, brucellosis, etc.)
  final bool isNotifiable;

  final String? outcome;
  final String? notes;

  factory CattleHealthEvent.fromJson(Map<String, dynamic> j) =>
      CattleHealthEvent(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        eventType: j['eventType'] as String,
        diagnosis: j['diagnosis'] as String,
        severity: j['severity'] as String,
        treatedBy: j['treatedBy'] as String?,
        isNotifiable: j['isNotifiable'] as bool? ?? false,
        outcome: j['outcome'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'eventType': eventType,
        'diagnosis': diagnosis,
        'severity': severity,
        if (treatedBy != null) 'treatedBy': treatedBy,
        'isNotifiable': isNotifiable,
        if (outcome != null) 'outcome': outcome,
        if (notes != null) 'notes': notes,
      };
}

// ── Medication log ────────────────────────────────────────────────────────────

class CattleMedicationLog {
  const CattleMedicationLog({
    required this.id,
    required this.animalId,
    required this.date,
    required this.medicationName,
    required this.route,
    required this.doseMg,
    this.withdrawalDaysMeat,
    this.withdrawalDaysMilk,
    this.veterinarianApproved = false,
    this.administeredBy,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;
  final String medicationName;

  /// One of: oral / injection / topical / pour_on / bolus
  final String route;

  /// Dose in milligrams.
  final double doseMg;

  final int? withdrawalDaysMeat;
  final int? withdrawalDaysMilk;
  final bool veterinarianApproved;
  final String? administeredBy;
  final String? notes;

  /// ISO date of the last withdrawal day for meat, or null.
  String? get withdrawalExpiryDateMeat {
    if (withdrawalDaysMeat == null || withdrawalDaysMeat == 0) return null;
    try {
      final start = DateTime.parse(date);
      return start
          .add(Duration(days: withdrawalDaysMeat!))
          .toIso8601String()
          .substring(0, 10);
    } catch (_) {
      return null;
    }
  }

  /// ISO date of the last withdrawal day for milk, or null.
  String? get withdrawalExpiryDateMilk {
    if (withdrawalDaysMilk == null || withdrawalDaysMilk == 0) return null;
    try {
      final start = DateTime.parse(date);
      return start
          .add(Duration(days: withdrawalDaysMilk!))
          .toIso8601String()
          .substring(0, 10);
    } catch (_) {
      return null;
    }
  }

  factory CattleMedicationLog.fromJson(Map<String, dynamic> j) =>
      CattleMedicationLog(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        medicationName: j['medicationName'] as String,
        route: j['route'] as String,
        doseMg: (j['doseMg'] as num).toDouble(),
        withdrawalDaysMeat: j['withdrawalDaysMeat'] as int?,
        withdrawalDaysMilk: j['withdrawalDaysMilk'] as int?,
        veterinarianApproved: j['veterinarianApproved'] as bool? ?? false,
        administeredBy: j['administeredBy'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'medicationName': medicationName,
        'route': route,
        'doseMg': doseMg,
        if (withdrawalDaysMeat != null) 'withdrawalDaysMeat': withdrawalDaysMeat,
        if (withdrawalDaysMilk != null) 'withdrawalDaysMilk': withdrawalDaysMilk,
        'veterinarianApproved': veterinarianApproved,
        if (administeredBy != null) 'administeredBy': administeredBy,
        if (notes != null) 'notes': notes,
      };
}

// ── Vaccination ───────────────────────────────────────────────────────────────

class CattleVaccination {
  const CattleVaccination({
    required this.id,
    required this.animalId,
    required this.vaccineName,
    required this.dueDate,
    this.givenDate,
    this.batchNumber,
    this.nextDueDate,
    this.route,
    this.siteOnBody,
    this.administeredBy,
  });

  final String id;
  final String animalId;
  final String vaccineName;
  final String dueDate;
  final String? givenDate;
  final String? batchNumber;
  final String? nextDueDate;
  final String? route;
  final String? siteOnBody;
  final String? administeredBy;

  bool get isOverdue {
    if (givenDate != null) return false;
    try {
      return DateTime.parse(dueDate).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool get isGiven => givenDate != null;

  factory CattleVaccination.fromJson(Map<String, dynamic> j) =>
      CattleVaccination(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        vaccineName: j['vaccineName'] as String,
        dueDate: j['dueDate'] as String,
        givenDate: j['givenDate'] as String?,
        batchNumber: j['batchNumber'] as String?,
        nextDueDate: j['nextDueDate'] as String?,
        route: j['route'] as String?,
        siteOnBody: j['siteOnBody'] as String?,
        administeredBy: j['administeredBy'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'vaccineName': vaccineName,
        'dueDate': dueDate,
        if (givenDate != null) 'givenDate': givenDate,
        if (batchNumber != null) 'batchNumber': batchNumber,
        if (nextDueDate != null) 'nextDueDate': nextDueDate,
        if (route != null) 'route': route,
        if (siteOnBody != null) 'siteOnBody': siteOnBody,
        if (administeredBy != null) 'administeredBy': administeredBy,
      };
}

// ── Sale record ───────────────────────────────────────────────────────────────

class CattleSaleRecord {
  const CattleSaleRecord({
    required this.id,
    required this.animalId,
    required this.saleDate,
    required this.buyerName,
    this.saleWeightKg,
    this.pricePerKg,
    this.totalAmount,
    this.transportCost,
    this.permitNumber,
    this.invoiceRef,
    this.notes,
  });

  final String id;
  final String animalId;
  final String saleDate;
  final String buyerName;
  final double? saleWeightKg;
  final double? pricePerKg;
  final double? totalAmount;
  final double? transportCost;

  /// Movement permit number required under LITS/NIIS.
  final String? permitNumber;
  final String? invoiceRef;
  final String? notes;

  double? get netRevenue {
    if (totalAmount == null) return null;
    return totalAmount! - (transportCost ?? 0);
  }

  factory CattleSaleRecord.fromJson(Map<String, dynamic> j) =>
      CattleSaleRecord(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        saleDate: j['saleDate'] as String,
        buyerName: j['buyerName'] as String,
        saleWeightKg: (j['saleWeightKg'] as num?)?.toDouble(),
        pricePerKg: (j['pricePerKg'] as num?)?.toDouble(),
        totalAmount: (j['totalAmount'] as num?)?.toDouble(),
        transportCost: (j['transportCost'] as num?)?.toDouble(),
        permitNumber: j['permitNumber'] as String?,
        invoiceRef: j['invoiceRef'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'saleDate': saleDate,
        'buyerName': buyerName,
        if (saleWeightKg != null) 'saleWeightKg': saleWeightKg,
        if (pricePerKg != null) 'pricePerKg': pricePerKg,
        if (totalAmount != null) 'totalAmount': totalAmount,
        if (transportCost != null) 'transportCost': transportCost,
        if (permitNumber != null) 'permitNumber': permitNumber,
        if (invoiceRef != null) 'invoiceRef': invoiceRef,
        if (notes != null) 'notes': notes,
      };
}

// ── Feed / supplement record ──────────────────────────────────────────────────

class CattleFeedRecord {
  const CattleFeedRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.feedType,
    required this.quantityKg,
    this.costPerKg,
    this.feedlotPenId,
    this.rationName,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;
  final String feedType;
  final double quantityKg;
  final double? costPerKg;
  final String? feedlotPenId;
  final String? rationName;
  final String? notes;

  double? get totalCost =>
      costPerKg != null ? quantityKg * costPerKg! : null;

  factory CattleFeedRecord.fromJson(Map<String, dynamic> j) =>
      CattleFeedRecord(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        feedType: j['feedType'] as String,
        quantityKg: (j['quantityKg'] as num).toDouble(),
        costPerKg: (j['costPerKg'] as num?)?.toDouble(),
        feedlotPenId: j['feedlotPenId'] as String?,
        rationName: j['rationName'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'feedType': feedType,
        'quantityKg': quantityKg,
        if (costPerKg != null) 'costPerKg': costPerKg,
        if (feedlotPenId != null) 'feedlotPenId': feedlotPenId,
        if (rationName != null) 'rationName': rationName,
        if (notes != null) 'notes': notes,
      };
}

// ── Pasture / camp rotation ───────────────────────────────────────────────────

class PastureRecord {
  const PastureRecord({
    required this.id,
    required this.herdId,
    required this.campId,
    required this.entryDate,
    this.exitDate,
    this.estimatedHa,
    this.veldCondition,
    this.notes,
  });

  final String id;
  final String herdId;
  final String campId;
  final String entryDate;
  final String? exitDate;
  final double? estimatedHa;
  final String? veldCondition;
  final String? notes;

  factory PastureRecord.fromJson(Map<String, dynamic> j) => PastureRecord(
        id: j['id'] as String,
        herdId: j['herdId'] as String,
        campId: j['campId'] as String,
        entryDate: j['entryDate'] as String,
        exitDate: j['exitDate'] as String?,
        estimatedHa: (j['estimatedHa'] as num?)?.toDouble(),
        veldCondition: j['veldCondition'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'herdId': herdId,
        'campId': campId,
        'entryDate': entryDate,
        if (exitDate != null) 'exitDate': exitDate,
        if (estimatedHa != null) 'estimatedHa': estimatedHa,
        if (veldCondition != null) 'veldCondition': veldCondition,
        if (notes != null) 'notes': notes,
      };
}

// ── Body condition record ─────────────────────────────────────────────────────

class BodyConditionRecord {
  const BodyConditionRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.score,
    this.assessedBy,
    this.notes,
  });

  final String id;
  final String animalId;
  final String date;

  /// BCS on a 1.0–5.0 scale (0.5 increments).
  final double score;
  final String? assessedBy;
  final String? notes;

  factory BodyConditionRecord.fromJson(Map<String, dynamic> j) =>
      BodyConditionRecord(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        date: j['date'] as String,
        score: (j['score'] as num).toDouble(),
        assessedBy: j['assessedBy'] as String?,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'date': date,
        'score': score,
        if (assessedBy != null) 'assessedBy': assessedBy,
        if (notes != null) 'notes': notes,
      };
}

// ── Dipping record (cattle-specific) ─────────────────────────────────────────

class DippingRecord {
  const DippingRecord({
    required this.id,
    required this.animalId,
    required this.dippingDate,
    required this.productUsed,
    required this.concentration,
    required this.method,
    required this.nextDueDays,
    this.veterinarianApproved = false,
    this.notes,
  });

  final String id;
  final String animalId;
  final String dippingDate;
  final String productUsed;

  /// Concentration as a percentage string, e.g. '0.05%'
  final String concentration;

  /// One of: plunge / spray / pour_on
  final String method;

  /// Days until next dipping is due.
  final int nextDueDays;

  final bool veterinarianApproved;
  final String? notes;

  /// Computed next due date (ISO 8601).
  String get nextDueDate {
    try {
      final start = DateTime.parse(dippingDate);
      return start
          .add(Duration(days: nextDueDays))
          .toIso8601String()
          .substring(0, 10);
    } catch (_) {
      return dippingDate;
    }
  }

  factory DippingRecord.fromJson(Map<String, dynamic> j) => DippingRecord(
        id: j['id'] as String,
        animalId: j['animalId'] as String,
        dippingDate: j['dippingDate'] as String,
        productUsed: j['productUsed'] as String,
        concentration: j['concentration'] as String,
        method: j['method'] as String,
        nextDueDays: j['nextDueDays'] as int,
        veterinarianApproved: j['veterinarianApproved'] as bool? ?? false,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'dippingDate': dippingDate,
        'productUsed': productUsed,
        'concentration': concentration,
        'method': method,
        'nextDueDays': nextDueDays,
        'veterinarianApproved': veterinarianApproved,
        if (notes != null) 'notes': notes,
      };
}
