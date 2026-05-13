/// A single water-quality snapshot for a pond / tank / cage unit.
///
/// SA alert thresholds applied in [isCritical] and [isWarning]:
///   DO  < 3.0 mg/L  → critical (emergency aeration)
///   DO  < 4.0 mg/L  → warning
///   pH  outside 6.5–8.5 → warning
///   Ammonia > 1.0 mg/L  → alert
class WaterQualityLog {
  const WaterQualityLog({
    required this.id,
    required this.pondId,
    required this.recordedAt,
    required this.session,
    this.recordedBy,
    this.temperatureC,
    this.dissolvedOxygenMgL,
    this.ph,
    this.ammoniaMgL,
    this.nitriteMgL,
    this.nitrateMgL,
    this.turbidityNtu,
    this.secchiDepthCm,
    this.correctiveAction,
    this.notes,
  });

  final String id;
  final String pondId;

  /// ISO-8601 timestamp string.
  final String recordedAt;

  /// 'morning' | 'afternoon' | 'evening'
  final String session;
  final String? recordedBy;
  final double? temperatureC;
  final double? dissolvedOxygenMgL;
  final double? ph;
  final double? ammoniaMgL;
  final double? nitriteMgL;
  final double? nitrateMgL;
  final double? turbidityNtu;
  final double? secchiDepthCm;
  final String? correctiveAction;
  final String? notes;

  // ── Alert helpers ─────────────────────────────────────────────────────────────

  bool get isDoEmergency =>
      dissolvedOxygenMgL != null && dissolvedOxygenMgL! < 3.0;

  bool get isDoWarning =>
      dissolvedOxygenMgL != null &&
      dissolvedOxygenMgL! >= 3.0 &&
      dissolvedOxygenMgL! < 4.0;

  bool get isPhWarning =>
      ph != null && (ph! < 6.5 || ph! > 8.5);

  bool get isAmmoniaAlert =>
      ammoniaMgL != null && ammoniaMgL! > 1.0;

  bool get isCritical => isDoEmergency;

  bool get hasAlert => isDoEmergency || isDoWarning || isPhWarning || isAmmoniaAlert;

  // ── Factory ───────────────────────────────────────────────────────────────────

  factory WaterQualityLog.fromJson(Map<String, dynamic> json) =>
      WaterQualityLog(
        id: json['id'] as String? ?? '',
        pondId: json['pond_id'] as String? ?? '',
        recordedAt: json['recorded_at'] as String? ?? '',
        session: json['session'] as String? ?? '',
        recordedBy: json['recorded_by'] as String?,
        temperatureC: (json['temperature_c'] as num?)?.toDouble(),
        dissolvedOxygenMgL:
            (json['dissolved_oxygen_mg_l'] as num?)?.toDouble(),
        ph: (json['ph'] as num?)?.toDouble(),
        ammoniaMgL: (json['ammonia_mg_l'] as num?)?.toDouble(),
        nitriteMgL: (json['nitrite_mg_l'] as num?)?.toDouble(),
        nitrateMgL: (json['nitrate_mg_l'] as num?)?.toDouble(),
        turbidityNtu: (json['turbidity_ntu'] as num?)?.toDouble(),
        secchiDepthCm: (json['secchi_depth_cm'] as num?)?.toDouble(),
        correctiveAction: json['corrective_action'] as String?,
        notes: json['notes'] as String?,
      );
}
