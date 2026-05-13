class EggRecord {
  const EggRecord({
    required this.id,
    required this.flockId,
    required this.collectionDate,
    required this.collectionSession,
    required this.eggsCollected,
    this.eggsBroken,
    this.eggsGraded,
  });

  final String id;
  final String flockId;
  final String collectionDate;
  final String collectionSession;
  final int eggsCollected;
  final int? eggsBroken;
  final int? eggsGraded;

  factory EggRecord.fromJson(Map<String, dynamic> json) {
    return EggRecord(
      id: json['id'] as String? ?? '',
      flockId: json['flock_id'] as String? ?? '',
      collectionDate: json['collection_date'] as String? ?? '',
      collectionSession: json['collection_session'] as String? ?? '',
      eggsCollected: json['eggs_collected'] as int? ?? 0,
      eggsBroken: json['eggs_broken'] as int?,
      eggsGraded: json['eggs_graded'] as int?,
    );
  }

  double get breakageRate {
    final broken = eggsBroken ?? 0;
    if (eggsCollected == 0) return 0;
    return broken / eggsCollected * 100;
  }
}
