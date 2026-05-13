// ignore_for_file: avoid_dynamic_calls
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/poultry_repository.dart';
import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';

// ── Flocks ────────────────────────────────────────────────────────────────────

/// Raw flock list from mock JSON. Not autoDisposed (cache persists).
final _mockFlocksProvider = FutureProvider<List<PoultryFlock>>((ref) {
  return ref.read(poultryRepositoryProvider).getFlocks();
});

/// Holds flocks created in-session via AddFlockScreen (not persisted to JSON).
class AddedFlocksNotifier extends Notifier<List<PoultryFlock>> {
  @override
  List<PoultryFlock> build() => [];

  /// Prepend newly created flock so it appears at the top of the list.
  void addFlock(PoultryFlock flock) => state = [flock, ...state];
}

final addedFlocksProvider =
    NotifierProvider<AddedFlocksNotifier, List<PoultryFlock>>(
  AddedFlocksNotifier.new,
);

/// Flock list exposed to screens (mock + newly added, status overrides applied).
final flocksProvider =
    Provider.autoDispose<AsyncValue<List<PoultryFlock>>>((ref) {
  final overrides = ref.watch(flockStatusOverrideProvider);
  final edits = ref.watch(flockEditProvider);
  final added = ref.watch(addedFlocksProvider);
  return ref.watch(_mockFlocksProvider).whenData((mockFlocks) {
    final allFlocks = [...added, ...mockFlocks];
    return allFlocks.map((f) {
      var result = f;
      final fieldEdit = edits[f.id];
      if (fieldEdit != null) result = _applyFieldEdits(result, fieldEdit);
      final ov = overrides[f.id];
      if (ov != null) result = _applyStatusOverride(result, ov);
      return result;
    }).toList();
  });
});

/// Single flock by id (status + field overrides applied, includes added flocks).
final flockDetailProvider =
    Provider.autoDispose.family<AsyncValue<PoultryFlock?>, String>(
        (ref, flockId) {
  final overrides = ref.watch(flockStatusOverrideProvider);
  final edits = ref.watch(flockEditProvider);
  final added = ref.watch(addedFlocksProvider);
  return ref.watch(_mockFlocksProvider).whenData((mockFlocks) {
    final allFlocks = [...added, ...mockFlocks];
    try {
      var f = allFlocks.firstWhere((f) => f.id == flockId);
      final fieldEdit = edits[flockId];
      if (fieldEdit != null) f = _applyFieldEdits(f, fieldEdit);
      final ov = overrides[flockId];
      return ov != null ? _applyStatusOverride(f, ov) : f;
    } catch (_) {
      return null;
    }
  });
});

PoultryFlock _applyFieldEdits(PoultryFlock f, Map<String, dynamic> edits) =>
    PoultryFlock(
      id: f.id,
      farmId: f.farmId,
      batchName: (edits['batchName'] as String?) ?? f.batchName,
      species: f.species,
      productionType: f.productionType,
      strain: (edits['strain'] as String?) ?? f.strain,
      houseId: (edits['houseId'] as String?) ?? f.houseId,
      status: f.status,
      placementDate: (edits['placementDate'] as String?) ?? f.placementDate,
      placementCount: f.placementCount,
      currentCount: f.currentCount,
      mortalityTotal: f.mortalityTotal,
      mortalityPct: f.mortalityPct,
      dayOfAge: f.dayOfAge,
      livabilityPct: f.livabilityPct,
      currentAvgWeightG: f.currentAvgWeightG,
      feedConsumedTotalKg: f.feedConsumedTotalKg,
      fcrToDate: f.fcrToDate,
      projectedSlaughterDate:
          (edits['projectedSlaughterDate'] as String?) ?? f.projectedSlaughterDate,
      targetSlaughterWeightG:
          (edits['targetSlaughterWeightG'] as int?) ?? f.targetSlaughterWeightG,
      weekOfAge: f.weekOfAge,
      currentStage: f.currentStage,
      unitCostPerChick: f.unitCostPerChick,
      broilerSpecific: f.broilerSpecific,
      layerSpecific: f.layerSpecific,
      duckSpecific: f.duckSpecific,
      breederSpecific: f.breederSpecific,
      turkeySpecific: f.turkeySpecific,
      quailSpecific: f.quailSpecific,
      createdAt: f.createdAt,
      updatedAt: f.updatedAt,
    );

PoultryFlock _applyStatusOverride(PoultryFlock f, String status) =>
    PoultryFlock(
      id: f.id,
      farmId: f.farmId,
      batchName: f.batchName,
      species: f.species,
      productionType: f.productionType,
      strain: f.strain,
      houseId: f.houseId,
      status: status,
      placementDate: f.placementDate,
      placementCount: f.placementCount,
      currentCount: f.currentCount,
      mortalityTotal: f.mortalityTotal,
      mortalityPct: f.mortalityPct,
      dayOfAge: f.dayOfAge,
      livabilityPct: f.livabilityPct,
      currentAvgWeightG: f.currentAvgWeightG,
      feedConsumedTotalKg: f.feedConsumedTotalKg,
      fcrToDate: f.fcrToDate,
      projectedSlaughterDate: f.projectedSlaughterDate,
      targetSlaughterWeightG: f.targetSlaughterWeightG,
      weekOfAge: f.weekOfAge,
      currentStage: f.currentStage,
      unitCostPerChick: f.unitCostPerChick,
      broilerSpecific: f.broilerSpecific,
      layerSpecific: f.layerSpecific,
      duckSpecific: f.duckSpecific,
      breederSpecific: f.breederSpecific,
      turkeySpecific: f.turkeySpecific,
      quailSpecific: f.quailSpecific,
      createdAt: f.createdAt,
      updatedAt: f.updatedAt,
    );

// ── Daily Record Deletes ──────────────────────────────────────────────────────

/// Tracks deleted daily record IDs in-session (no real DB yet).
class DailyRecordDeleteNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void delete(String recordId) {
    state = {...state, recordId};
  }
}

final dailyRecordDeleteProvider =
    NotifierProvider<DailyRecordDeleteNotifier, Set<String>>(
  DailyRecordDeleteNotifier.new,
);

// Holds DailyRecords submitted in the current session, keyed by flockId.
class NewDailyRecordNotifier
    extends Notifier<Map<String, List<DailyRecord>>> {
  @override
  Map<String, List<DailyRecord>> build() => {};

  void add(DailyRecord record) {
    final current = List<DailyRecord>.from(state[record.flockId] ?? []);
    current.insert(0, record);
    state = {...state, record.flockId: current};
  }
}

final newDailyRecordProvider = NotifierProvider<NewDailyRecordNotifier,
    Map<String, List<DailyRecord>>>(NewDailyRecordNotifier.new);


// ── Daily Records ─────────────────────────────────────────────────────────────

final _mockDailyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) {
  return ref.read(poultryRepositoryProvider).getDailyRecords();
});

/// Daily records for a specific flock, sorted newest-first.
/// Merges in-session submitted records with mock data; excludes deleted IDs.
final flockDailyRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<DailyRecord>>, String>(
        (ref, flockId) {
  final deleted = ref.watch(dailyRecordDeleteProvider);
  final inSession = ref.watch(newDailyRecordProvider)[flockId] ?? [];
  return ref.watch(_mockDailyRecordsProvider).whenData((records) {
    final fromMock = records
        .where((r) => r.flockId == flockId && !deleted.contains(r.id))
        .toList();
    final merged = [...inSession, ...fromMock];
    merged.sort((a, b) => b.date.compareTo(a.date));
    return merged;
  });
});

// ── Vaccination Schedules ─────────────────────────────────────────────────────

final _mockVaccinationSchedulesProvider =
    FutureProvider<List<VaccinationSchedule>>((ref) {
  return ref.read(poultryRepositoryProvider).getVaccinationSchedules();
});

// ── Vaccination Administration Overrides ─────────────────────────────────────

/// Stores administered vaccine overrides: flockId → { targetDay → VaccineItem }.
/// Applied on top of mock data so marking a vaccine as given persists in-session.
class VaccinationAdministrationNotifier
    extends Notifier<Map<String, Map<int, VaccineItem>>> {
  @override
  Map<String, Map<int, VaccineItem>> build() => {};

  void markGiven({
    required String flockId,
    required int targetDay,
    required String vaccine,
    required String method,
    String? product,
    String? batchNo,
    String? administeredBy,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final updated = VaccineItem(
      vaccine: vaccine,
      targetDay: targetDay,
      method: method,
      status: 'completed',
      completedDate: dateStr,
      product: product,
      batchNo: batchNo,
      administeredBy: administeredBy,
    );
    final flockOverrides = Map<int, VaccineItem>.from(state[flockId] ?? {});
    flockOverrides[targetDay] = updated;
    state = {...state, flockId: flockOverrides};
  }
}

final vaccinationAdministrationProvider = NotifierProvider<
    VaccinationAdministrationNotifier,
    Map<String, Map<int, VaccineItem>>>(VaccinationAdministrationNotifier.new);

/// Vaccination schedule for a specific flock, with administered overrides applied.
final flockVaccinationProvider =
    Provider.autoDispose.family<AsyncValue<VaccinationSchedule?>, String>(
        (ref, flockId) {
  final overrides = ref.watch(vaccinationAdministrationProvider)[flockId] ?? {};
  return ref.watch(_mockVaccinationSchedulesProvider).whenData((schedules) {
    try {
      final base = schedules.firstWhere((s) => s.flockId == flockId);
      if (overrides.isEmpty) return base;
      final updatedSchedule = base.schedule.map((v) {
        final ov = overrides[v.targetDay];
        return ov ?? v;
      }).toList();
      return VaccinationSchedule(
        id: base.id,
        flockId: base.flockId,
        productionType: base.productionType,
        strain: base.strain,
        placementDate: base.placementDate,
        schedule: updatedSchedule,
      );
    } catch (_) {
      return null;
    }
  });
});

// ── Feed Phases ───────────────────────────────────────────────────────────────

final _mockFeedPhasesProvider = FutureProvider<List<FeedPhase>>((ref) {
  return ref.read(poultryRepositoryProvider).getFeedPhases();
});

/// Feed phases for a specific flock, sorted by day_start.
final flockFeedPhasesProvider =
    Provider.autoDispose.family<AsyncValue<List<FeedPhase>>, String>(
        (ref, flockId) {
  return ref.watch(_mockFeedPhasesProvider).whenData((phases) {
    return phases
        .where((p) => p.flockId == flockId)
        .toList()
      ..sort((a, b) => a.dayStart.compareTo(b.dayStart));
  });
});

// ── Harvest Records ───────────────────────────────────────────────────────────

final _mockHarvestRecordsProvider = FutureProvider<List<HarvestRecord>>((ref) {
  return ref.read(poultryRepositoryProvider).getHarvestRecords();
});

/// Harvest records for a specific flock.
final flockHarvestRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<HarvestRecord>>, String>(
        (ref, flockId) {
  return ref.watch(_mockHarvestRecordsProvider).whenData((records) {
    return records
        .where((r) => r.flockId == flockId)
        .toList()
      ..sort((a, b) => b.harvestDate.compareTo(a.harvestDate));
  });
});

// ── Medication Logs ───────────────────────────────────────────────────────────

final _mockMedicationLogsProvider = FutureProvider<List<MedicationLog>>((ref) {
  return ref.read(poultryRepositoryProvider).getMedicationLogs();
});

class MedicationDeleteNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void delete(String logId) => state = {...state, logId};
}

final medicationDeleteProvider =
    NotifierProvider<MedicationDeleteNotifier, Set<String>>(
  MedicationDeleteNotifier.new,
);

/// Medication logs for a specific flock, newest-first.
final flockMedicationLogsProvider =
    Provider.autoDispose.family<AsyncValue<List<MedicationLog>>, String>(
        (ref, flockId) {
  final deleted = ref.watch(medicationDeleteProvider);
  return ref.watch(_mockMedicationLogsProvider).whenData((logs) {
    return logs
        .where((l) => l.flockId == flockId && !deleted.contains(l.id))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  });
});

// ── Disease Events ────────────────────────────────────────────────────────────

final _mockDiseaseEventsProvider = FutureProvider<List<DiseaseEvent>>((ref) {
  return ref.read(poultryRepositoryProvider).getDiseaseEvents();
});

/// Disease events for a specific flock, newest-first.
final flockDiseaseEventsProvider =
    Provider.autoDispose.family<AsyncValue<List<DiseaseEvent>>, String>(
        (ref, flockId) {
  return ref.watch(_mockDiseaseEventsProvider).whenData((events) {
    return events
        .where((e) => e.flockId == flockId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  });
});

// ── Environment Readings ──────────────────────────────────────────────────────

final _mockEnvironmentReadingsProvider =
    FutureProvider<List<EnvironmentReading>>((ref) {
  return ref.read(poultryRepositoryProvider).getEnvironmentReadings();
});

/// Latest environment readings for a specific flock (newest-first by timestamp).
final flockEnvironmentReadingsProvider =
    Provider.autoDispose.family<AsyncValue<List<EnvironmentReading>>, String>(
        (ref, flockId) {
  return ref.watch(_mockEnvironmentReadingsProvider).whenData((readings) {
    return readings
        .where((r) => r.flockId == flockId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  });
});

// ── Flock Status Overrides ────────────────────────────────────────────────────

/// In-memory map of flockId → status string applied on top of mock data.
/// Allows batch status changes (Depleted / Sold) without mutating JSON.
class FlockStatusNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void setStatus(String flockId, String newStatus) {
    state = {...state, flockId: newStatus};
  }
}

final flockStatusOverrideProvider =
    NotifierProvider<FlockStatusNotifier, Map<String, String>>(
  FlockStatusNotifier.new,
);

/// Vaccination schedules exposed for farm-wide queries (e.g. hub screen).
final allVaccinationSchedulesProvider =
    Provider.autoDispose<AsyncValue<List<VaccinationSchedule>>>((ref) {
  return ref.watch(_mockVaccinationSchedulesProvider);
});

// ── Inventory ─────────────────────────────────────────────────────────────────

final _mockInventoryProvider = FutureProvider<List<InventoryItem>>((ref) {
  return ref.read(poultryRepositoryProvider).getInventoryItems();
});

final inventoryProvider =
    Provider.autoDispose<AsyncValue<List<InventoryItem>>>((ref) {
  return ref.watch(_mockInventoryProvider);
});

// ── IoT Live Environment Stream ───────────────────────────────────────────────

/// Emits a simulated live sensor reading every 30 seconds.
// ── Broiler Weight Samples ────────────────────────────────────────────────────

/// A single in-session weight sample logged by the user.
class WeightSampleEntry {
  const WeightSampleEntry({
    required this.flockId,
    required this.dayOfAge,
    required this.avgBodyWeightG,
    required this.sampleSize,
    required this.date,
    this.notes,
  });

  final String flockId;
  final int dayOfAge;
  final double avgBodyWeightG;
  final int sampleSize;
  final String date;
  final String? notes;
}

/// Stores in-session weight samples per flock.
class WeightSampleNotifier
    extends Notifier<Map<String, List<WeightSampleEntry>>> {
  @override
  Map<String, List<WeightSampleEntry>> build() => {};

  void addSample(WeightSampleEntry entry) {
    final current = List<WeightSampleEntry>.from(state[entry.flockId] ?? []);
    current.add(entry);
    state = {...state, entry.flockId: current};
  }
}

final weightSampleProvider = NotifierProvider<WeightSampleNotifier,
    Map<String, List<WeightSampleEntry>>>(
  WeightSampleNotifier.new,
);

/// FlSpots combining mock daily records + user-logged weight samples for a flock.
final flockWeightSpotsProvider =
    Provider.autoDispose.family<AsyncValue<List<FlSpot>>, String>(
        (ref, flockId) {
  final dailyAsync = ref.watch(flockDailyRecordsProvider(flockId));
  final userSamples = ref.watch(weightSampleProvider)[flockId] ?? [];
  return dailyAsync.whenData((records) {
    final spots = <FlSpot>[];
    for (final r in records) {
      if (r.dayOfAge != null && r.avgBodyWeightG != null) {
        spots.add(FlSpot(r.dayOfAge!.toDouble(), r.avgBodyWeightG!.toDouble()));
      }
    }
    for (final s in userSamples) {
      spots.add(FlSpot(s.dayOfAge.toDouble(), s.avgBodyWeightG));
    }
    spots.sort((a, b) => a.x.compareTo(b.x));
    // Deduplicate by day (user sample wins over mock)
    final seen = <double>{};
    final deduped = <FlSpot>[];
    for (final sp in spots.reversed) {
      if (seen.add(sp.x)) deduped.add(sp);
    }
    return deduped.reversed.toList();
  });
});

// ── IoT Environment Stream ────────────────────────────────────────────────────

/// Uses [ref.read] for the repository to avoid autoDispose dependency issues.
final iotEnvironmentStreamProvider =
    StreamProvider.autoDispose.family<EnvironmentReading, String>(
        (ref, flockId) {
  final r = Random();
  EnvironmentReading make() => EnvironmentReading(
        id: 'iot-live',
        flockId: flockId,
        timestamp: DateTime.now().toIso8601String(),
        tempC: 28.0 + (r.nextDouble() * 6 - 3),
        humidityPct: 65.0 + (r.nextDouble() * 20 - 10),
        ammoniaPpm: 12.0 + (r.nextDouble() * 16),
        co2Ppm: 1800.0 + (r.nextDouble() * 400),
        sensorZone: 'house-a',
      );

  return Stream<EnvironmentReading>.multi((controller) {
    controller.add(make());
    Stream.periodic(const Duration(seconds: 30))
        .listen((_) => controller.add(make()));
  });
});
// ── Flock Field Edits ─────────────────────────────────────────────────────────

/// Stores in-session field edits per flock (keyed by flockId).
class FlockEditNotifier extends Notifier<Map<String, Map<String, dynamic>>> {
  @override
  Map<String, Map<String, dynamic>> build() => {};

  void update(String flockId, Map<String, dynamic> fields) {
    final current = Map<String, dynamic>.from(state[flockId] ?? {});
    current.addAll(fields);
    state = {...state, flockId: current};
  }
}

final flockEditProvider =
    NotifierProvider<FlockEditNotifier, Map<String, Map<String, dynamic>>>(
  FlockEditNotifier.new,
);

// ── Biosecurity Log ───────────────────────────────────────────────────────────

class BiosecurityLog {
  const BiosecurityLog({
    required this.id,
    required this.flockId,
    required this.date,
    required this.eventType,
    required this.personnel,
    this.productsUsed,
    this.notes,
  });

  final String id;
  final String flockId;
  final String date;
  final String eventType;
  final String personnel;
  final String? productsUsed;
  final String? notes;

  static const List<String> eventTypes = [
    'disinfection',
    'pest_control',
    'fumigation',
    'visitor_log',
    'downtime',
    'cleaning',
    'other',
  ];

  static String label(String type) => switch (type) {
        'disinfection' => 'Disinfection',
        'pest_control' => 'Pest Control',
        'fumigation' => 'Fumigation',
        'visitor_log' => 'Visitor Log',
        'downtime' => 'Downtime / Rest',
        'cleaning' => 'Cleaning',
        _ => 'Other',
      };
}

class BiosecurityLogNotifier
    extends Notifier<Map<String, List<BiosecurityLog>>> {
  @override
  Map<String, List<BiosecurityLog>> build() => {};

  void add(BiosecurityLog log) {
    final current = List<BiosecurityLog>.from(state[log.flockId] ?? []);
    current.add(log);
    state = {...state, log.flockId: current};
  }

  void delete(String flockId, String id) {
    final current =
        (state[flockId] ?? []).where((l) => l.id != id).toList();
    state = {...state, flockId: current};
  }
}

final biosecurityLogProvider = NotifierProvider<BiosecurityLogNotifier,
    Map<String, List<BiosecurityLog>>>(
  BiosecurityLogNotifier.new,
);

// ── Litter Management ─────────────────────────────────────────────────────────

class LitterRecord {
  const LitterRecord({
    required this.id,
    required this.flockId,
    required this.date,
    required this.eventType,
    required this.condition,
    this.depthCm,
    this.material,
    this.actionTaken,
    this.notes,
  });

  final String id;
  final String flockId;
  final String date;
  final String eventType;
  final String condition;
  final double? depthCm;
  final String? material;
  final String? actionTaken;
  final String? notes;

  static const List<String> eventTypes = [
    'inspection',
    'top_dressing',
    'removal',
    'replacement',
    'treatment',
    'other',
  ];

  static const List<String> conditions = ['good', 'fair', 'poor'];

  static String conditionLabel(String c) => switch (c) {
        'good' => 'Good',
        'fair' => 'Fair',
        'poor' => 'Poor',
        _ => c,
      };
}

class LitterRecordNotifier extends Notifier<Map<String, List<LitterRecord>>> {
  @override
  Map<String, List<LitterRecord>> build() => {};

  void add(LitterRecord record) {
    final current = List<LitterRecord>.from(state[record.flockId] ?? []);
    current.add(record);
    state = {...state, record.flockId: current};
  }

  void delete(String flockId, String id) {
    final current =
        (state[flockId] ?? []).where((r) => r.id != id).toList();
    state = {...state, flockId: current};
  }
}

final litterRecordProvider =
    NotifierProvider<LitterRecordNotifier, Map<String, List<LitterRecord>>>(
  LitterRecordNotifier.new,
);

// ── Molt Management ───────────────────────────────────────────────────────────

class MoltEvent {
  const MoltEvent({
    required this.id,
    required this.flockId,
    required this.moltStartDate,
    required this.moltType,
    required this.feedRestrictionDays,
    required this.expectedDurationWeeks,
    this.returnToLayDate,
    this.notes,
  });

  final String id;
  final String flockId;
  final String moltStartDate;
  final String moltType;
  final int feedRestrictionDays;
  final int expectedDurationWeeks;
  final String? returnToLayDate;
  final String? notes;
}

class MoltEventNotifier extends Notifier<Map<String, List<MoltEvent>>> {
  @override
  Map<String, List<MoltEvent>> build() => {};

  void add(MoltEvent event) {
    final current = List<MoltEvent>.from(state[event.flockId] ?? []);
    current.add(event);
    state = {...state, event.flockId: current};
  }

  void delete(String flockId, String id) {
    final current =
        (state[flockId] ?? []).where((e) => e.id != id).toList();
    state = {...state, flockId: current};
  }
}

final moltEventProvider =
    NotifierProvider<MoltEventNotifier, Map<String, List<MoltEvent>>>(
  MoltEventNotifier.new,
);

// ── Breeder Records ───────────────────────────────────────────────────────────

class BreederRecord {
  const BreederRecord({
    required this.id,
    required this.flockId,
    required this.date,
    required this.weekOfAge,
    required this.eggsSet,
    this.eggsCandles,
    this.eggsFertile,
    this.eggsHatched,
    this.avgChickWeightG,
    this.notes,
  });

  final String id;
  final String flockId;
  final String date;
  final int weekOfAge;
  final int eggsSet;
  final int? eggsCandles;
  final int? eggsFertile;
  final int? eggsHatched;
  final double? avgChickWeightG;
  final String? notes;

  double? get fertilityPct =>
      eggsFertile != null ? eggsFertile! / eggsSet * 100 : null;
  double? get hatchRatePct =>
      eggsHatched != null ? eggsHatched! / eggsSet * 100 : null;
}

class BreederRecordNotifier
    extends AsyncNotifier<Map<String, List<BreederRecord>>> {
  @override
  Future<Map<String, List<BreederRecord>>> build() async {
    return {};
  }

  void add(BreederRecord record) {
    final current = state.value ?? {};
    final list = List<BreederRecord>.from(current[record.flockId] ?? []);
    list.add(record);
    state = AsyncData({...current, record.flockId: list});
  }

  void delete(String flockId, String id) {
    final current = state.value ?? {};
    final list = (current[flockId] ?? []).where((r) => r.id != id).toList();
    state = AsyncData({...current, flockId: list});
  }
}

final breederRecordProvider =
    AsyncNotifierProvider<BreederRecordNotifier, Map<String, List<BreederRecord>>>(
  BreederRecordNotifier.new,
);

// ── Feed Phase Delete ─────────────────────────────────────────────────────────

/// Tracks deleted feed phase IDs in-session.
class FeedPhaseDeleteNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void delete(String id) => state = {...state, id};
}

final feedPhaseDeleteProvider =
    NotifierProvider<FeedPhaseDeleteNotifier, Set<String>>(
  FeedPhaseDeleteNotifier.new,
);

// ── Inventory Edits & Deletes ─────────────────────────────────────────────────

/// Tracks in-session quantity overrides per item id.
class InventoryEditNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() => {};

  void update(String itemId, double qty) =>
      state = {...state, itemId: qty};
}

final inventoryEditProvider =
    NotifierProvider<InventoryEditNotifier, Map<String, double>>(
  InventoryEditNotifier.new,
);

/// Tracks deleted inventory item IDs in-session.
class InventoryDeleteNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void delete(String id) => state = {...state, id};
}

final inventoryDeleteProvider =
    NotifierProvider<InventoryDeleteNotifier, Set<String>>(
  InventoryDeleteNotifier.new,
);
// ── Vaccination Due-Soon (farm-wide) ──────────────────────────────────────────

/// Returns vaccines due within the next 3 days across all active flocks.
/// Each entry has the flock name, vaccine name, and due date.
final dueSoonVaccinationsProvider = Provider.autoDispose<
    AsyncValue<List<({String flockId, String flockName, String vaccine, DateTime dueDate})>>>(
  (ref) {
    final schedulesAsync = ref.watch(allVaccinationSchedulesProvider);
    final flocksAsync = ref.watch(flocksProvider);
    return schedulesAsync.whenData((schedules) {
      final flocks = flocksAsync.value ?? [];
      final now = DateTime.now();
      final result = <({String flockId, String flockName, String vaccine, DateTime dueDate})>[];
      for (final sched in schedules) {
        final flock = flocks.cast<PoultryFlock?>().firstWhere(
              (f) => f?.id == sched.flockId,
              orElse: () => null,
            );
        if (flock == null || !flock.isActive) continue;
        for (final v in sched.schedule) {
          if (v.isCompleted) continue;
          if (v.dueDate == null) continue;
          final due = DateTime.tryParse(v.dueDate!);
          if (due == null) continue;
          final diff = due.difference(now).inDays;
          if (diff >= 0 && diff <= 3) {
            result.add((
              flockId: sched.flockId,
              flockName: flock.batchName,
              vaccine: v.vaccine,
              dueDate: due,
            ));
          }
        }
      }
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return result;
    });
  },
);

// ── Mortality Spike Detection ─────────────────────────────────────────────────

/// Returns true if the most recent daily record for [flockId] has mortality
/// more than 3× the rolling 7-day batch average.
final mortalitySpikeProvider =
    Provider.autoDispose.family<bool, String>((ref, flockId) {
  final records = ref.watch(flockDailyRecordsProvider(flockId)).value ?? [];
  if (records.length < 2) return false;
  final todayCount = records.first.mortalityCount ?? 0;
  final previous = records.skip(1).take(7);
  final total =
      previous.fold<int>(0, (sum, r) => sum + (r.mortalityCount ?? 0));
  final avg = total / previous.length;
  return avg > 0 && todayCount > avg * 3;
});

// ── Active Withdrawal Period Detection ────────────────────────────────────────

/// Returns medication logs for [flockId] that still have an active withdrawal
/// period (clearance date is after today).
final activeWithdrawalProvider =
    Provider.autoDispose.family<AsyncValue<List<MedicationLog>>, String>(
        (ref, flockId) {
  return ref.watch(flockMedicationLogsProvider(flockId)).whenData((logs) {
    final today = DateTime.now();
    return logs.where((l) {
      if (l.withdrawalDays <= 0) return false;
      try {
        final clearance =
            DateTime.parse(l.date).add(Duration(days: l.withdrawalDays));
        return clearance.isAfter(today);
      } catch (_) {
        return false;
      }
    }).toList();
  });
});

// ── Inventory Low-Stock Alert ─────────────────────────────────────────────────

/// Returns inventory items whose current stock is at or below the minimum threshold.
final lowStockItemsProvider =
    Provider.autoDispose<AsyncValue<List<InventoryItem>>>((ref) {
  return ref.watch(inventoryProvider).whenData(
        (items) => items.where((i) => i.currentStock <= i.minThreshold).toList(),
      );
});

// ── Egg Sales ─────────────────────────────────────────────────────────────────

final _mockEggSalesProvider = FutureProvider<List<EggSale>>((ref) {
  return ref.read(poultryRepositoryProvider).getEggSales();
});

/// In-session egg sales recorded this session (keyed by flockId).
class EggSaleNotifier extends Notifier<Map<String, List<EggSale>>> {
  @override
  Map<String, List<EggSale>> build() => {};

  void add(EggSale sale) {
    final current = List<EggSale>.from(state[sale.flockId] ?? []);
    current.add(sale);
    state = {...state, sale.flockId: current};
  }

  void delete(String flockId, String saleId) {
    final current =
        (state[flockId] ?? []).where((s) => s.id != saleId).toList();
    state = {...state, flockId: current};
  }
}

final eggSaleNotifierProvider =
    NotifierProvider<EggSaleNotifier, Map<String, List<EggSale>>>(
  EggSaleNotifier.new,
);

/// Egg sales for a specific flock — merges mock JSON + in-session additions.
final flockEggSalesProvider =
    Provider.autoDispose.family<AsyncValue<List<EggSale>>, String>(
        (ref, flockId) {
  final inSession = ref.watch(eggSaleNotifierProvider)[flockId] ?? [];
  return ref.watch(_mockEggSalesProvider).whenData((mockSales) {
    final combined = [
      ...mockSales.where((s) => s.flockId == flockId),
      ...inSession,
    ];
    combined.sort((a, b) => b.date.compareTo(a.date));
    return combined;
  });
});

/// Total egg sales revenue for a specific flock (sum of all transactions).
final flockEggSalesRevenueProvider =
    Provider.autoDispose.family<AsyncValue<double>, String>((ref, flockId) {
  return ref.watch(flockEggSalesProvider(flockId)).whenData(
        (sales) => sales.fold(0.0, (sum, s) => sum + s.totalRevenue),
      );
});

// ── Chick Sales ───────────────────────────────────────────────────────────────

final _mockChickSalesProvider = FutureProvider<List<ChickSale>>((ref) {
  return ref.read(poultryRepositoryProvider).getChickSales();
});

/// In-session chick sales recorded this session (keyed by flockId).
class ChickSaleNotifier extends Notifier<Map<String, List<ChickSale>>> {
  @override
  Map<String, List<ChickSale>> build() => {};

  void add(ChickSale sale) {
    final current = List<ChickSale>.from(state[sale.flockId] ?? []);
    current.add(sale);
    state = {...state, sale.flockId: current};
  }

  void delete(String flockId, String saleId) {
    final current =
        (state[flockId] ?? []).where((s) => s.id != saleId).toList();
    state = {...state, flockId: current};
  }
}

final chickSaleNotifierProvider =
    NotifierProvider<ChickSaleNotifier, Map<String, List<ChickSale>>>(
  ChickSaleNotifier.new,
);

/// Chick sales for a specific flock — merges mock JSON + in-session additions.
final flockChickSalesProvider =
    Provider.autoDispose.family<AsyncValue<List<ChickSale>>, String>(
        (ref, flockId) {
  final inSession = ref.watch(chickSaleNotifierProvider)[flockId] ?? [];
  return ref.watch(_mockChickSalesProvider).whenData((mockSales) {
    final combined = [
      ...mockSales.where((s) => s.flockId == flockId),
      ...inSession,
    ];
    combined.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    return combined;
  });
});

/// Total chick sales revenue for a specific flock (sum of all transactions).
final flockChickSalesRevenueProvider =
    Provider.autoDispose.family<AsyncValue<double>, String>((ref, flockId) {
  return ref.watch(flockChickSalesProvider(flockId)).whenData(
        (sales) => sales.fold(0.0, (sum, s) => sum + s.totalAmount),
      );
});

/// Total DOC chicks sold for a specific flock.
final flockChicksSoldCountProvider =
    Provider.autoDispose.family<AsyncValue<int>, String>((ref, flockId) {
  return ref.watch(flockChickSalesProvider(flockId)).whenData(
        (sales) => sales.fold(0, (sum, s) => sum + s.chickCount),
      );
});

// ── Financial Auto-Entries ────────────────────────────────────────────────────

/// In-session auto-generated financial ledger entries (created automatically
/// when daily records or medication logs are saved).
class FinancialAutoEntryNotifier
    extends Notifier<Map<String, List<FinancialAutoEntry>>> {
  @override
  Map<String, List<FinancialAutoEntry>> build() => {};

  void add(FinancialAutoEntry entry) {
    final current =
        List<FinancialAutoEntry>.from(state[entry.flockId] ?? []);
    current.add(entry);
    state = {...state, entry.flockId: current};
  }

  void addAll(List<FinancialAutoEntry> entries) {
    if (entries.isEmpty) return;
    var next = Map<String, List<FinancialAutoEntry>>.from(state);
    for (final e in entries) {
      final current = List<FinancialAutoEntry>.from(next[e.flockId] ?? []);
      current.add(e);
      next[e.flockId] = current;
    }
    state = next;
  }
}

final financialAutoEntryProvider = NotifierProvider<FinancialAutoEntryNotifier,
    Map<String, List<FinancialAutoEntry>>>(
  FinancialAutoEntryNotifier.new,
);

/// Auto-entries for a specific flock, newest-first.
final flockAutoExpensesProvider =
    Provider.autoDispose.family<List<FinancialAutoEntry>, String>(
        (ref, flockId) {
  final all = ref.watch(financialAutoEntryProvider)[flockId] ?? [];
  return [...all]..sort((a, b) => b.date.compareTo(a.date));
});

/// Total auto-generated feed expenses from daily logs for a flock.
final flockFeedExpenseTotalProvider =
    Provider.autoDispose.family<double, String>((ref, flockId) {
  return ref
      .watch(flockAutoExpensesProvider(flockId))
      .where((e) =>
          e.category == 'feed' &&
          e.type == FinancialEntryType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);
});

/// Total auto-generated medication expenses for a flock.
final flockMedicationExpenseTotalProvider =
    Provider.autoDispose.family<double, String>((ref, flockId) {
  return ref
      .watch(flockAutoExpensesProvider(flockId))
      .where((e) =>
          e.category == 'medication' &&
          e.type == FinancialEntryType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);
});

/// Total auto-generated harvest revenue for a flock.
final flockHarvestRevenueTotalProvider =
    Provider.autoDispose.family<double, String>((ref, flockId) {
  return ref
      .watch(flockAutoExpensesProvider(flockId))
      .where((e) =>
          e.category == 'harvest' &&
          e.type == FinancialEntryType.revenue)
      .fold(0.0, (sum, e) => sum + e.amount);
});

// ── Live-Computed Performance KPIs ────────────────────────────────────────────

/// Live FCR derived from daily records: totalFeedConsumed / totalWeightGain.
/// Returns null when insufficient data.
final flockLiveFcrProvider =
    Provider.autoDispose.family<AsyncValue<double?>, String>((ref, flockId) {
  final flockAsync = ref.watch(flockDetailProvider(flockId));
  final recordsAsync = ref.watch(flockDailyRecordsProvider(flockId));
  return flockAsync.whenData((flock) {
    if (flock == null) return null;
    final records = recordsAsync.value ?? [];
    if (records.isEmpty) return null;
    final totalFeedKg = records
        .where((r) => r.feedConsumedKg != null)
        .fold(0.0, (s, r) => s + r.feedConsumedKg!);
    // Latest weight from the most recent record with a reading
    final latestWeight = records
        .where((r) => r.avgBodyWeightG != null)
        .fold<double?>(null, (_, r) => r.avgBodyWeightG!.toDouble());
    if (totalFeedKg <= 0 || latestWeight == null) return null;
    final weightGainKg =
        (latestWeight - 40.0) * flock.currentCount / 1000.0;
    if (weightGainKg <= 0) return null;
    return totalFeedKg / weightGainKg;
  });
});

/// Live EPEF (European Production Efficiency Factor) for broiler flocks.
/// Formula: (livability% × avgBodyWeightKg) / (liveFcr × ageInDays) × 100
final flockLiveEpefProvider =
    Provider.autoDispose.family<AsyncValue<double?>, String>((ref, flockId) {
  final flockAsync = ref.watch(flockDetailProvider(flockId));
  final fcrAsync = ref.watch(flockLiveFcrProvider(flockId));
  return flockAsync.whenData((flock) {
    if (flock == null || !flock.isBroiler) return null;
    final livability = flock.livabilityPct ?? 0.0;
    final avgWeightKg = (flock.currentAvgWeightG ?? 0.0) / 1000.0;
    final age = flock.dayOfAge;
    final fcr = fcrAsync.value;
    if (fcr == null || fcr <= 0 || age <= 0 || avgWeightKg <= 0) return null;
    return (livability * avgWeightKg) / (fcr * age) * 100.0;
  });
});

/// Live Hen-Day Average % (HDA): latest record eggs / current count × 100.
final flockLiveHdaProvider =
    Provider.autoDispose.family<AsyncValue<double?>, String>((ref, flockId) {
  final flockAsync = ref.watch(flockDetailProvider(flockId));
  final recordsAsync = ref.watch(flockDailyRecordsProvider(flockId));
  return flockAsync.whenData((flock) {
    if (flock == null || !flock.isLayer) return null;
    final records = recordsAsync.value ?? [];
    if (records.isEmpty || flock.currentCount <= 0) return null;
    final latest = records.first;
    final eggs = latest.totalEggs;
    return eggs / flock.currentCount * 100.0;
  });
});

/// Live Hen-Housed Average % (HHA): total eggs produced / placement count × 100.
final flockLiveHhaProvider =
    Provider.autoDispose.family<AsyncValue<double?>, String>((ref, flockId) {
  final flockAsync = ref.watch(flockDetailProvider(flockId));
  final recordsAsync = ref.watch(flockDailyRecordsProvider(flockId));
  return flockAsync.whenData((flock) {
    if (flock == null || !flock.isLayer) return null;
    final records = recordsAsync.value ?? [];
    if (records.isEmpty || flock.placementCount <= 0) return null;
    final totalEggs = records.fold(0, (s, r) => s + r.totalEggs);
    return totalEggs / flock.placementCount * 100.0;
  });
});

/// Returns true when the latest daily record shows water:feed ratio > 1.2.
/// A ratio outside 1:2 – 1:3 range may indicate health or management issues.
final flockWaterToFeedAlertProvider =
    Provider.autoDispose.family<AsyncValue<bool>, String>((ref, flockId) {
  final recordsAsync = ref.watch(flockDailyRecordsProvider(flockId));
  return recordsAsync.whenData((records) {
    if (records.isEmpty) return false;
    final latest = records.first;
    final water = latest.waterConsumedLitres;
    final feed = latest.feedConsumedKg;
    if (water == null || feed == null || feed <= 0) return false;
    // Normal water:feed ratio for poultry is roughly 1.8–2.5.
    // Flag when water drops below 1.2× feed (dehydration risk).
    return (water / feed) < 1.2;
  });
});

// ── Newcastle Disease Recurring Alert ─────────────────────────────────────────

/// Returns true when the flock is an active layer with no completed ND
/// (Newcastle Disease) vaccination in the past 28 days.
final newcastleOverdueProvider =
    Provider.autoDispose.family<AsyncValue<bool>, String>((ref, flockId) {
  final flockAsync = ref.watch(flockDetailProvider(flockId));
  final vaccsAsync = ref.watch(flockVaccinationProvider(flockId));
  return flockAsync.whenData((flock) {
    if (flock == null || !flock.isActive || !flock.isLayer) return false;
    final schedule = vaccsAsync.value;
    if (schedule == null) return false;
    final ndItems = schedule.schedule.where((v) {
      final name = v.vaccine.toLowerCase();
      return name.contains('newcastle') ||
          name.contains(' nd ') ||
          name.startsWith('nd') ||
          name.contains('lasota');
    }).toList();
    if (ndItems.isEmpty) return true; // Never vaccinated
    // Find the most recent completed ND vaccination
    final completed = ndItems
        .where((v) => v.isCompleted)
        .toList()
      ..sort((a, b) {
        final aDate = a.completedDate ?? a.dueDate ?? '';
        final bDate = b.completedDate ?? b.dueDate ?? '';
        return bDate.compareTo(aDate);
      });
    if (completed.isEmpty) return true;
    final dateStr =
        completed.first.completedDate ?? completed.first.dueDate;
    if (dateStr == null) return false;
    final lastDate = DateTime.tryParse(dateStr);
    if (lastDate == null) return false;
    return DateTime.now().difference(lastDate).inDays > 28;
  });
});
