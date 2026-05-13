import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MilkRecord {
  const MilkRecord({
    required this.id,
    required this.animalId,
    required this.animalType,
    required this.sessionDate,
    required this.session,
    required this.yieldLitres,
    this.fatPct,
    this.proteinPct,
    this.sccCellsPerMl,
  });

  final String id;
  final String animalId;
  final String animalType;
  final String sessionDate;
  final String session;
  final double yieldLitres;
  final double? fatPct;
  final double? proteinPct;
  final int? sccCellsPerMl;

  factory MilkRecord.fromJson(Map<String, dynamic> json) {
    return MilkRecord(
      id: json['id'] as String? ?? '',
      animalId: json['animal_id'] as String? ?? '',
      animalType: json['animal_type'] as String? ?? '',
      sessionDate: json['session_date'] as String? ?? '',
      session: json['session'] as String? ?? '',
      yieldLitres: (json['yield_litres'] as num?)?.toDouble() ?? 0,
      fatPct: (json['fat_pct'] as num?)?.toDouble(),
      proteinPct: (json['protein_pct'] as num?)?.toDouble(),
      sccCellsPerMl: json['scc_cells_per_ml'] as int?,
    );
  }

  String get qualityIndicator {
    final scc = sccCellsPerMl;
    if (scc == null) return '';
    if (scc < 200000) return 'GOOD';
    if (scc < 400000) return 'FAIR';
    return 'POOR';
  }

  // ignore: avoid_returning_null_for_void
  Color get qualityColor {
    final scc = sccCellsPerMl;
    if (scc == null) return AppColors.outline;
    if (scc < 200000) return AppColors.success;
    if (scc < 400000) return AppColors.warning;
    return AppColors.error;
  }
}
