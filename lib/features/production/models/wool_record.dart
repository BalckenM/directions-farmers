/// Colour grade classification per Cape Wools SA / SABS standard.
enum WoolColorGrade { aa, a, b, c }

/// SA wool/mohair buyers.
enum WoolBuyer {
  bkb,
  capeWoolsSa,
  agriBest,
  nedwool,
  capeMohairAuction,
  samcra,
  other,
}

/// A shearing (wool or mohair) production record.
/// Covers SA Merino wool, Dohne Merino, Angora mohair, and other fleece species.
class WoolRecord {
  const WoolRecord({
    required this.id,
    required this.farmId,
    required this.shearingDate,
    required this.greasyFleeceWeightKg,
    this.animalId,
    this.animalType,
    this.groupId,
    this.animalCount,
    this.skirtedWeightKg,
    this.woolMicron,
    this.stapleLengthMm,
    this.stapleStrengthNktex,
    this.vegetableMatterPct,
    this.yieldPct,
    this.colorGrade,
    this.woolBuyer,
    this.woolBuyerOther,
    this.pricePerKgZar,
    this.baleNumber,
    this.teamCertRef,
    this.isMohair = false,
    this.notes,
  });

  final String id;
  final String farmId;

  /// Individual animal (for single-animal records)
  final String? animalId;

  /// Species / animal type — matches LivestockConstants keys (e.g. 'sheep', 'goats')
  final String? animalType;

  /// Group / mob ID (for mob-shearing records)
  final String? groupId;

  /// Number of animals shorn in this batch (mob record)
  final int? animalCount;

  final String shearingDate;

  /// Total raw (greasy) fleece weight in kg
  final double greasyFleeceWeightKg;

  /// Weight after skirting belly/dag wool (kg)
  final double? skirtedWeightKg;

  /// Average fibre diameter (microns) — prime quality metric
  final double? woolMicron;

  /// Staple length in mm (Merino target 70–100mm)
  final double? stapleLengthMm;

  /// Staple break strength in N/ktex (> 35 = strong)
  final double? stapleStrengthNktex;

  /// Vegetable matter content % (major quality discount above 2%)
  final double? vegetableMatterPct;

  /// Clean yield % after scouring (target > 65%)
  final double? yieldPct;

  final WoolColorGrade? colorGrade;
  final WoolBuyer? woolBuyer;

  /// Buyer name when [woolBuyer] == WoolBuyer.other
  final String? woolBuyerOther;

  /// Realised clean price per kg (ZAR)
  final double? pricePerKgZar;

  /// Auction or bale tracking number
  final String? baleNumber;

  /// Cape Wools SA TEAM certification reference
  final String? teamCertRef;

  /// True if this is a mohair record (Angora), false for wool
  final bool isMohair;

  final String? notes;

  /// Calculated total sale value (greasy weight × price/kg)
  double? get estimatedValueZar {
    if (pricePerKgZar == null) return null;
    return greasyFleeceWeightKg * pricePerKgZar!;
  }

  /// Display label for micron (e.g., "19.5 µm")
  String get displayMicron =>
      woolMicron != null ? '${woolMicron!.toStringAsFixed(1)} µm' : '—';

  /// Display label for colour grade
  String get displayColorGrade => switch (colorGrade) {
    WoolColorGrade.aa => 'AA',
    WoolColorGrade.a => 'A',
    WoolColorGrade.b => 'B',
    WoolColorGrade.c => 'C',
    null => '—',
  };

  /// Display label for buyer
  String get displayBuyer => switch (woolBuyer) {
    WoolBuyer.bkb => 'BKB',
    WoolBuyer.capeWoolsSa => 'Cape Wools SA',
    WoolBuyer.agriBest => 'Agri-Best',
    WoolBuyer.nedwool => 'Nedwool',
    WoolBuyer.capeMohairAuction => 'Cape Mohair Auction',
    WoolBuyer.samcra => 'SAMCRA',
    WoolBuyer.other => woolBuyerOther ?? 'Other',
    null => '—',
  };

  factory WoolRecord.fromJson(Map<String, dynamic> json) {
    WoolColorGrade? grade;
    final gradeStr = (json['color_grade'] as String?)?.toLowerCase();
    if (gradeStr != null) {
      grade = switch (gradeStr) {
        'aa' => WoolColorGrade.aa,
        'a' => WoolColorGrade.a,
        'b' => WoolColorGrade.b,
        'c' => WoolColorGrade.c,
        _ => null,
      };
    }

    WoolBuyer? buyer;
    final buyerStr = json['wool_buyer'] as String?;
    if (buyerStr != null) {
      buyer = switch (buyerStr) {
        'bkb' => WoolBuyer.bkb,
        'cape_wools_sa' => WoolBuyer.capeWoolsSa,
        'agri_best' => WoolBuyer.agriBest,
        'nedwool' => WoolBuyer.nedwool,
        'cape_mohair_auction' => WoolBuyer.capeMohairAuction,
        'samcra' => WoolBuyer.samcra,
        _ => WoolBuyer.other,
      };
    }

    return WoolRecord(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      animalId: json['animal_id'] as String?,
      animalType: json['animal_type'] as String?,
      groupId: json['group_id'] as String?,
      animalCount: json['animal_count'] as int?,
      shearingDate: json['shearing_date'] as String? ?? '',
      greasyFleeceWeightKg:
          (json['greasy_fleece_weight_kg'] as num?)?.toDouble() ?? 0,
      skirtedWeightKg: (json['skirted_weight_kg'] as num?)?.toDouble(),
      woolMicron: (json['wool_micron'] as num?)?.toDouble(),
      stapleLengthMm: (json['staple_length_mm'] as num?)?.toDouble(),
      stapleStrengthNktex:
          (json['staple_strength_nktex'] as num?)?.toDouble(),
      vegetableMatterPct: (json['vegetable_matter_pct'] as num?)?.toDouble(),
      yieldPct: (json['yield_pct'] as num?)?.toDouble(),
      colorGrade: grade,
      woolBuyer: buyer,
      woolBuyerOther: json['wool_buyer_other'] as String?,
      pricePerKgZar: (json['price_per_kg_zar'] as num?)?.toDouble(),
      baleNumber: json['bale_number'] as String?,
      teamCertRef: json['team_cert_ref'] as String?,
      isMohair: json['is_mohair'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}
