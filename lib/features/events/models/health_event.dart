/// SA notifiable diseases requiring mandatory DAFF reporting.
enum NotifiableDisease {
  footAndMouth,
  africanSwineFever,
  highlyPathogenicAvianInfluenza,
  contagiousBovineVirus,
  lumpySkinDisease,
  eastCoastFever,
  brucellosis,
  africanHorseSickness,
  newcastleDisease,
  rabies,
}

/// A single health event record.
class HealthEvent {
  const HealthEvent({
    required this.id,
    required this.animalId,
    required this.animalType,
    required this.eventType,
    required this.eventDate,
    this.description,
    this.diagnosis,
    this.treatment,
    this.productName,
    this.nextDueDate,
    this.costZar,
    this.notes,
    // SA-specific fields
    this.withdrawalDays,
    this.withdrawalEndDate,
    this.famachaScore,
    this.dagScore,
    this.isNotifiable = false,
    this.notifiableDisease,
    this.daffReportRef,
  });

  final String id;
  final String animalId;
  final String animalType;
  final String eventType;
  final String eventDate;
  final String? description;
  final String? diagnosis;
  final String? treatment;
  final String? productName;
  final String? nextDueDate;
  final double? costZar;
  final String? notes;

  // ── SA-specific fields ────────────────────────────────────────────────────────
  /// Medication withdrawal period in days (meat/milk/egg withholding)
  final int? withdrawalDays;

  /// Calculated end date of withdrawal period (ISO date string)
  final String? withdrawalEndDate;

  /// FAMACHA conjunctiva score 1–5 (sheep/goats only)
  final int? famachaScore;

  /// Dag (breech soiling) score 0–5 (sheep only)
  final int? dagScore;

  /// Whether this event involves a SA notifiable disease
  final bool isNotifiable;

  /// The specific notifiable disease (if applicable)
  final NotifiableDisease? notifiableDisease;

  /// DAFF incident report reference number
  final String? daffReportRef;

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    NotifiableDisease? disease;
    final diseaseStr = json['notifiable_disease'] as String?;
    if (diseaseStr != null) {
      disease = switch (diseaseStr) {
        'fmd' => NotifiableDisease.footAndMouth,
        'asf' => NotifiableDisease.africanSwineFever,
        'hpai' => NotifiableDisease.highlyPathogenicAvianInfluenza,
        'cbpp' => NotifiableDisease.contagiousBovineVirus,
        'lsd' => NotifiableDisease.lumpySkinDisease,
        'ecf' => NotifiableDisease.eastCoastFever,
        'brucellosis' => NotifiableDisease.brucellosis,
        'ahs' => NotifiableDisease.africanHorseSickness,
        'newcastle' => NotifiableDisease.newcastleDisease,
        'rabies' => NotifiableDisease.rabies,
        _ => null,
      };
    }

    return HealthEvent(
      id: json['id'] as String? ?? '',
      animalId: json['animal_id'] as String? ?? '',
      animalType: json['animal_type'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      description: json['description'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      productName: json['product_name'] as String?,
      nextDueDate: json['next_due_date'] as String?,
      costZar: (json['cost_zar'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      withdrawalDays: json['withdrawal_days'] as int?,
      withdrawalEndDate: json['withdrawal_end_date'] as String?,
      famachaScore: json['famacha_score'] as int?,
      dagScore: json['dag_score'] as int?,
      isNotifiable: json['is_notifiable'] as bool? ?? false,
      notifiableDisease: disease,
      daffReportRef: json['daff_report_ref'] as String?,
    );
  }

  String get displayType => eventType.replaceAll('_', ' ').toUpperCase();

  /// Whether the withdrawal period is still active (today is before withdrawal end)
  bool get isWithdrawalActive {
    if (withdrawalEndDate == null) return false;
    try {
      final end = DateTime.parse(withdrawalEndDate!);
      return DateTime.now().isBefore(end);
    } catch (_) {
      return false;
    }
  }

  /// Days remaining on withdrawal period (0 if expired or not set)
  int get withdrawalDaysRemaining {
    if (withdrawalEndDate == null) return 0;
    try {
      final end = DateTime.parse(withdrawalEndDate!);
      final diff = end.difference(DateTime.now()).inDays;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Human-readable display for FAMACHA score
  String get displayFamachaScore {
    return switch (famachaScore) {
      1 => 'FAMACHA 1 — Red (Healthy)',
      2 => 'FAMACHA 2 — Red-Pink',
      3 => 'FAMACHA 3 — Pink',
      4 => 'FAMACHA 4 — Pink-White (Treat)',
      5 => 'FAMACHA 5 — White (Critical)',
      _ => '—',
    };
  }
}
