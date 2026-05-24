import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/goat_data_source.dart';
import '../data/goat_mock_data_source.dart';
import '../data/goat_repository.dart';
import '../models/goat_animal.dart';
import '../models/goat_records.dart';

// ── DI providers ──────────────────────────────────────────────────────────────

final goatDataSourceProvider = Provider<GoatDataSource>(
  (ref) => GoatMockDataSource(),
);

final goatRepositoryProvider = Provider<GoatRepository>(
  (ref) => GoatRepository(ref.watch(goatDataSourceProvider)),
);

// ── Raw data providers (mock layer) ──────────────────────────────────────────

final _mockAnimalsProvider = FutureProvider<List<GoatAnimal>>((ref) {
  return ref.watch(goatRepositoryProvider).getAnimals();
});

final _mockWeightRecordsProvider = FutureProvider<List<WeightRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getWeightRecords();
});

final _mockMatingRecordsProvider = FutureProvider<List<MatingRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getMatingRecords();
});

final _mockPregnancyChecksProvider =
    FutureProvider<List<PregnancyCheck>>((ref) {
  return ref.watch(goatRepositoryProvider).getPregnancyChecks();
});

final _mockKiddingEventsProvider = FutureProvider<List<KiddingEvent>>((ref) {
  return ref.watch(goatRepositoryProvider).getKiddingEvents();
});

final _mockMilkRecordsProvider = FutureProvider<List<DailyMilkRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getMilkRecords();
});

final _mockShearingRecordsProvider =
    FutureProvider<List<ShearingRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getShearingRecords();
});

final _mockHealthEventsProvider = FutureProvider<List<GoatHealthEvent>>((ref) {
  return ref.watch(goatRepositoryProvider).getHealthEvents();
});

final _mockMedicationLogsProvider =
    FutureProvider<List<GoatMedicationLog>>((ref) {
  return ref.watch(goatRepositoryProvider).getMedicationLogs();
});

final _mockVaccinationsProvider =
    FutureProvider<List<GoatVaccination>>((ref) {
  return ref.watch(goatRepositoryProvider).getVaccinations();
});

final _mockSaleRecordsProvider = FutureProvider<List<GoatSaleRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getSaleRecords();
});

final _mockFeedRecordsProvider = FutureProvider<List<GoatFeedRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getFeedRecords();
});

final _mockPastureRecordsProvider =
    FutureProvider<List<PastureRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getPastureRecords();
});

final _mockFamachaRecordsProvider =
    FutureProvider<List<FamachaRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getFamachaRecords();
});

final _mockBodyConditionRecordsProvider =
    FutureProvider<List<BodyConditionRecord>>((ref) {
  return ref.watch(goatRepositoryProvider).getBodyConditionRecords();
});

// ── In-session write state ────────────────────────────────────────────────────

/// Animals added in-session (not yet persisted).
class AddedAnimalsNotifier extends Notifier<List<GoatAnimal>> {
  @override
  List<GoatAnimal> build() => [];

  void addAnimal(GoatAnimal animal) => state = [animal, ...state];
}

final addedAnimalsProvider =
    NotifierProvider<AddedAnimalsNotifier, List<GoatAnimal>>(
  AddedAnimalsNotifier.new,
);

/// Per-animal status overrides keyed by animalId.
class AnimalStatusOverrideNotifier
    extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void setStatus(String animalId, String status) =>
      state = {...state, animalId: status};
}

final animalStatusOverrideProvider =
    NotifierProvider<AnimalStatusOverrideNotifier, Map<String, String>>(
  AnimalStatusOverrideNotifier.new,
);

/// Per-animal field edits keyed by animalId.
class AnimalEditNotifier
    extends Notifier<Map<String, Map<String, dynamic>>> {
  @override
  Map<String, Map<String, dynamic>> build() => {};

  void applyEdit(String animalId, Map<String, dynamic> edits) =>
      state = {...state, animalId: {...(state[animalId] ?? {}), ...edits}};
}

final animalEditProvider =
    NotifierProvider<AnimalEditNotifier, Map<String, Map<String, dynamic>>>(
  AnimalEditNotifier.new,
);

/// In-session weight records keyed by animalId.
class NewWeightRecordNotifier
    extends Notifier<Map<String, List<WeightRecord>>> {
  @override
  Map<String, List<WeightRecord>> build() => {};

  void addRecord(String animalId, WeightRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newWeightRecordProvider =
    NotifierProvider<NewWeightRecordNotifier, Map<String, List<WeightRecord>>>(
  NewWeightRecordNotifier.new,
);

/// In-session milk records keyed by animalId.
class NewMilkRecordNotifier
    extends Notifier<Map<String, List<DailyMilkRecord>>> {
  @override
  Map<String, List<DailyMilkRecord>> build() => {};

  void addRecord(String animalId, DailyMilkRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newMilkRecordProvider = NotifierProvider<NewMilkRecordNotifier,
    Map<String, List<DailyMilkRecord>>>(
  NewMilkRecordNotifier.new,
);

/// In-session kidding events keyed by damId.
class NewKiddingEventNotifier
    extends Notifier<Map<String, List<KiddingEvent>>> {
  @override
  Map<String, List<KiddingEvent>> build() => {};

  void addEvent(String damId, KiddingEvent event) {
    final existing = state[damId] ?? [];
    state = {...state, damId: [...existing, event]};
  }
}

final newKiddingEventProvider =
    NotifierProvider<NewKiddingEventNotifier, Map<String, List<KiddingEvent>>>(
  NewKiddingEventNotifier.new,
);

// ── Merged animal list provider ───────────────────────────────────────────────

GoatAnimal _applyAnimalEdits(
    GoatAnimal animal, Map<String, dynamic> edits) {
  return animal.copyWith(
    name: edits['name'] as String?,
    breed: edits['breed'] as String?,
    tagNumber: edits['tagNumber'] as String?,
    herdId: edits['herdId'] as String?,
    bodyConditionScore: edits['bodyConditionScore'] as double?,
    currentWeightKg: edits['currentWeightKg'] as double?,
    notes: edits['notes'] as String?,
  );
}

/// Full animal list: in-session additions + mock data, with overrides applied.
final animalsProvider =
    Provider.autoDispose<AsyncValue<List<GoatAnimal>>>((ref) {
  final added = ref.watch(addedAnimalsProvider);
  final statusOverrides = ref.watch(animalStatusOverrideProvider);
  final edits = ref.watch(animalEditProvider);
  return ref.watch(_mockAnimalsProvider).whenData((mockAnimals) {
    final all = [...added, ...mockAnimals];
    return all.map((a) {
      var result = a;
      final fieldEdit = edits[a.id];
      if (fieldEdit != null) result = _applyAnimalEdits(result, fieldEdit);
      final statusOverride = statusOverrides[a.id];
      if (statusOverride != null) result = result.copyWith(status: statusOverride);
      return result;
    }).toList();
  });
});

/// Single animal by id, with overrides applied.
final animalDetailProvider =
    Provider.autoDispose.family<AsyncValue<GoatAnimal?>, String>(
        (ref, animalId) {
  final added = ref.watch(addedAnimalsProvider);
  final statusOverrides = ref.watch(animalStatusOverrideProvider);
  final edits = ref.watch(animalEditProvider);
  return ref.watch(_mockAnimalsProvider).whenData((mockAnimals) {
    final all = [...added, ...mockAnimals];
    try {
      var a = all.firstWhere((a) => a.id == animalId);
      final fieldEdit = edits[animalId];
      if (fieldEdit != null) a = _applyAnimalEdits(a, fieldEdit);
      final statusOverride = statusOverrides[animalId];
      if (statusOverride != null) a = a.copyWith(status: statusOverride);
      return a;
    } catch (_) {
      return null;
    }
  });
});

// ── Per-animal record providers ───────────────────────────────────────────────

/// Weight records for a specific animal (mock + in-session new records).
final animalWeightRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<WeightRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newWeightRecordProvider)[animalId] ?? [];
  return ref.watch(_mockWeightRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Mating records for a specific animal.
final animalMatingRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<MatingRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newMatingRecordProvider)[animalId] ?? [];
  return ref.watch(_mockMatingRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.doeId == animalId || r.buckId == animalId),
        ]..sort((a, b) => b.serviceDate.compareTo(a.serviceDate)),
      );
});

/// Pregnancy checks for a specific animal.
final animalPregnancyChecksProvider =
    Provider.autoDispose.family<AsyncValue<List<PregnancyCheck>>, String>(
        (ref, animalId) {
  final newChecks = ref.watch(newPregnancyCheckProvider)[animalId] ?? [];
  return ref.watch(_mockPregnancyChecksProvider).whenData(
        (all) => [
          ...newChecks,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Kidding events where the given animal is the dam.
final animalKiddingEventsProvider =
    Provider.autoDispose.family<AsyncValue<List<KiddingEvent>>, String>(
        (ref, damId) {
  final newEvents = ref.watch(newKiddingEventProvider)[damId] ?? [];
  return ref.watch(_mockKiddingEventsProvider).whenData(
        (all) => [
          ...newEvents,
          ...all.where((e) => e.damId == damId),
        ]..sort((a, b) => b.kiddingDate.compareTo(a.kiddingDate)),
      );
});

/// Daily milk records for a specific animal (mock + in-session).
final animalMilkRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<DailyMilkRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newMilkRecordProvider)[animalId] ?? [];
  return ref.watch(_mockMilkRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Shearing records for a specific animal.
final animalShearingRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<ShearingRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newShearingRecordProvider)[animalId] ?? [];
  return ref.watch(_mockShearingRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.shearingDate.compareTo(a.shearingDate)),
      );
});

/// Health events for a specific animal.
final animalHealthEventsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatHealthEvent>>, String>(
        (ref, animalId) {
  final newEvents = ref.watch(newHealthEventProvider)[animalId] ?? [];
  return ref.watch(_mockHealthEventsProvider).whenData(
        (all) => [
          ...newEvents,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Medication logs for a specific animal.
final animalMedicationLogsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatMedicationLog>>, String>(
        (ref, animalId) {
  final newLogs = ref.watch(newMedicationLogProvider)[animalId] ?? [];
  return ref.watch(_mockMedicationLogsProvider).whenData(
        (all) => [
          ...newLogs,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Vaccinations for a specific animal.
final animalVaccinationsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatVaccination>>, String>(
        (ref, animalId) {
  final newVacs = ref.watch(newVaccinationProvider)[animalId] ?? [];
  return ref.watch(_mockVaccinationsProvider).whenData(
        (all) => [
          ...newVacs,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
      );
});

/// Sale records for a specific animal.
final animalSaleRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatSaleRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newSaleRecordProvider)[animalId] ?? [];
  return ref.watch(_mockSaleRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.saleDate.compareTo(a.saleDate)),
      );
});

/// FAMACHA records for a specific animal.
final animalFamachaRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<FamachaRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newFamachaRecordProvider)[animalId] ?? [];
  return ref.watch(_mockFamachaRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Body condition records for a specific animal.
final animalBcsRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<BodyConditionRecord>>, String>(
        (ref, animalId) {
  final newRecords = ref.watch(newBcsRecordProvider)[animalId] ?? [];
  return ref.watch(_mockBodyConditionRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

// ── Herd-level providers ──────────────────────────────────────────────────────

/// All animals belonging to a specific herd.
final herdAnimalsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatAnimal>>, String>(
        (ref, herdId) {
  return ref.watch(animalsProvider).whenData(
        (all) => all.where((a) => a.herdId == herdId).toList(),
      );
});

/// Feed records for a specific herd.
final herdFeedRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatFeedRecord>>, String>(
        (ref, herdId) {
  final newRecords = ref.watch(newFeedRecordProvider)[herdId] ?? [];
  return ref.watch(_mockFeedRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.herdId == herdId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Pasture records for a specific herd.
final herdPastureRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<PastureRecord>>, String>(
        (ref, herdId) {
  final newRecords = ref.watch(newPastureRecordProvider)[herdId] ?? [];
  return ref.watch(_mockPastureRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.herdId == herdId),
        ]..sort((a, b) => b.entryDate.compareTo(a.entryDate)),
      );
});

// ── Alert providers ───────────────────────────────────────────────────────────

/// Animals with expected kidding date within the next 10 days.
final kiddingDueSoonProvider =
    Provider.autoDispose<AsyncValue<List<GoatAnimal>>>((ref) {
  return ref.watch(animalsProvider).whenData((animals) {
    final today = DateTime.now();
    final cutoff = today.add(const Duration(days: 10));
    return animals.where((a) {
      if (!a.isPregnant || a.expectedKiddingDate == null) return false;
      try {
        final due = DateTime.parse(a.expectedKiddingDate!);
        return due.isAfter(today.subtract(const Duration(days: 1))) &&
            due.isBefore(cutoff);
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) =>
          a.expectedKiddingDate!.compareTo(b.expectedKiddingDate!));
  });
});

/// Overdue vaccinations (due date passed, not yet given).
final vaccinationOverdueProvider =
    Provider.autoDispose<AsyncValue<List<GoatVaccination>>>((ref) {
  return ref.watch(_mockVaccinationsProvider).whenData((vaccinations) {
    return vaccinations.where((v) => v.isOverdue).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  });
});

/// Animals with FAMACHA score ≥ 4 (requires immediate attention).
final famachaAlertProvider =
    Provider.autoDispose<AsyncValue<List<GoatAnimal>>>((ref) {
  return ref.watch(animalsProvider).whenData(
        (animals) => animals
            .where((a) => a.famachaScore != null && a.famachaScore! >= 4)
            .toList(),
      );
});

/// Angora/fiber animals due for shearing (last sheared > 6 months ago or never).
final shearingDueProvider =
    Provider.autoDispose<AsyncValue<List<GoatAnimal>>>((ref) {
  return ref.watch(animalsProvider).whenData((animals) {
    final cutoff =
        DateTime.now().subtract(const Duration(days: 180));
    return animals.where((a) {
      if (a.productionType != 'fiber') return false;
      if (a.lastShearingDate == null) return true;
      try {
        return DateTime.parse(a.lastShearingDate!).isBefore(cutoff);
      } catch (_) {
        return true;
      }
    }).toList();
  });
});

/// Alive animals with body condition score below 2.0 (poor condition, at-risk).
final lowBcsAlertsProvider =
    Provider.autoDispose<AsyncValue<List<GoatAnimal>>>((ref) {
  return ref.watch(animalsProvider).whenData(
        (animals) => animals
            .where((a) =>
                a.isAlive && (a.bodyConditionScore ?? 3.0) < 2.0)
            .toList(),
      );
});

/// Dairy animals whose dry-off date falls within the next 7 days.
final dryOffSoonProvider =
    Provider.autoDispose<AsyncValue<List<GoatAnimal>>>((ref) {
  return ref.watch(animalsProvider).whenData((animals) {
    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 7));
    return animals.where((a) {
      if (a.dryOffDate == null || !a.isAlive) return false;
      try {
        final d = DateTime.parse(a.dryOffDate!);
        return d.isAfter(now) && d.isBefore(cutoff);
      } catch (_) {
        return false;
      }
    }).toList();
  });
});

// ── RBAC permission stubs ─────────────────────────────────────────────────────
// These are intentionally always-true stubs. Replace with role-aware logic
// once a proper auth/role system is implemented.

/// Whether the current user can add or edit animal records.
final canManageAnimalsProvider = Provider<bool>((ref) => true);

/// Whether the current user can manage health and medication records.
final canManageHealthProvider = Provider<bool>((ref) => true);

/// Whether the current user can view or manage financial records.
final canManageFinancialsProvider = Provider<bool>((ref) => true);

// ── Module-level aggregate providers ─────────────────────────────────────────

/// All sale records (mock + in-session).
final allGoatSaleRecordsProvider =
    Provider.autoDispose<AsyncValue<List<GoatSaleRecord>>>((ref) {
  final inSession = ref.watch(newSaleRecordProvider);
  return ref.watch(_mockSaleRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All vaccinations (mock + in-session).
final allGoatVaccinationsProvider =
    Provider.autoDispose<AsyncValue<List<GoatVaccination>>>((ref) {
  final inSession = ref.watch(newVaccinationProvider);
  return ref.watch(_mockVaccinationsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All feed records (mock + in-session).
final allGoatFeedRecordsProvider =
    Provider.autoDispose<AsyncValue<List<GoatFeedRecord>>>((ref) {
  final inSession = ref.watch(newFeedRecordProvider);
  return ref.watch(_mockFeedRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All pasture records (mock + in-session).
final allGoatPastureRecordsProvider =
    Provider.autoDispose<AsyncValue<List<PastureRecord>>>((ref) {
  final inSession = ref.watch(newPastureRecordProvider);
  return ref.watch(_mockPastureRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All pregnancy checks (mock + in-session).
final allGoatPregnancyChecksProvider =
    Provider.autoDispose<AsyncValue<List<PregnancyCheck>>>((ref) {
  final inSession = ref.watch(newPregnancyCheckProvider);
  return ref.watch(_mockPregnancyChecksProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All BCS records (mock + in-session).
final allGoatBcsRecordsProvider =
    Provider.autoDispose<AsyncValue<List<BodyConditionRecord>>>((ref) {
  final inSession = ref.watch(newBcsRecordProvider);
  return ref.watch(_mockBodyConditionRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

// ── Missing aggregate providers ───────────────────────────────────────────────

/// All kidding events across herds.
final allGoatKiddingEventsProvider =
    Provider.autoDispose<AsyncValue<List<KiddingEvent>>>((ref) {
  final newEvents = ref.watch(newKiddingEventProvider);
  return ref.watch(_mockKiddingEventsProvider).whenData((mock) {
    final allNew = newEvents.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All FAMACHA records across animals.
final allGoatFamachaRecordsProvider =
    Provider.autoDispose<AsyncValue<List<FamachaRecord>>>((ref) {
  final inSession = ref.watch(newFamachaRecordProvider);
  return ref.watch(_mockFamachaRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All health events across animals.
final allGoatHealthEventsProvider =
    Provider.autoDispose<AsyncValue<List<GoatHealthEvent>>>((ref) {
  final inSession = ref.watch(newHealthEventProvider);
  return ref.watch(_mockHealthEventsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All weight records across animals.
final allGoatWeightRecordsProvider =
    Provider.autoDispose<AsyncValue<List<WeightRecord>>>((ref) {
  final inSession = ref.watch(newWeightRecordProvider);
  return ref.watch(_mockWeightRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All milk records across animals.
final allGoatMilkRecordsProvider =
    Provider.autoDispose<AsyncValue<List<DailyMilkRecord>>>((ref) {
  final inSession = ref.watch(newMilkRecordProvider);
  return ref.watch(_mockMilkRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All shearing records across animals.
final allGoatShearingRecordsProvider =
    Provider.autoDispose<AsyncValue<List<ShearingRecord>>>((ref) {
  final inSession = ref.watch(newShearingRecordProvider);
  return ref.watch(_mockShearingRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

// ── Additional write notifiers ─────────────────────────────────────────────────

/// In-session health events keyed by animalId.
class NewHealthEventNotifier
    extends Notifier<Map<String, List<GoatHealthEvent>>> {
  @override
  Map<String, List<GoatHealthEvent>> build() => {};

  void addEvent(String animalId, GoatHealthEvent event) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, event]};
  }
}

final newHealthEventProvider = NotifierProvider<NewHealthEventNotifier,
    Map<String, List<GoatHealthEvent>>>(
  NewHealthEventNotifier.new,
);

/// In-session medication logs keyed by animalId.
class NewMedicationLogNotifier
    extends Notifier<Map<String, List<GoatMedicationLog>>> {
  @override
  Map<String, List<GoatMedicationLog>> build() => {};

  void addLog(String animalId, GoatMedicationLog log) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, log]};
  }
}

final newMedicationLogProvider = NotifierProvider<NewMedicationLogNotifier,
    Map<String, List<GoatMedicationLog>>>(
  NewMedicationLogNotifier.new,
);

/// In-session vaccinations keyed by animalId.
class NewVaccinationNotifier
    extends Notifier<Map<String, List<GoatVaccination>>> {
  @override
  Map<String, List<GoatVaccination>> build() => {};

  void addVaccination(String animalId, GoatVaccination vac) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, vac]};
  }
}

final newVaccinationProvider =
    NotifierProvider<NewVaccinationNotifier, Map<String, List<GoatVaccination>>>(
  NewVaccinationNotifier.new,
);

/// In-session shearing records keyed by animalId.
class NewShearingRecordNotifier
    extends Notifier<Map<String, List<ShearingRecord>>> {
  @override
  Map<String, List<ShearingRecord>> build() => {};

  void addRecord(String animalId, ShearingRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newShearingRecordProvider = NotifierProvider<NewShearingRecordNotifier,
    Map<String, List<ShearingRecord>>>(
  NewShearingRecordNotifier.new,
);

/// In-session sale records keyed by animalId.
class NewSaleRecordNotifier
    extends Notifier<Map<String, List<GoatSaleRecord>>> {
  @override
  Map<String, List<GoatSaleRecord>> build() => {};

  void addRecord(String animalId, GoatSaleRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newSaleRecordProvider =
    NotifierProvider<NewSaleRecordNotifier, Map<String, List<GoatSaleRecord>>>(
  NewSaleRecordNotifier.new,
);

/// In-session feed records keyed by herdId.
class NewFeedRecordNotifier
    extends Notifier<Map<String, List<GoatFeedRecord>>> {
  @override
  Map<String, List<GoatFeedRecord>> build() => {};

  void addRecord(String herdId, GoatFeedRecord record) {
    final existing = state[herdId] ?? [];
    state = {...state, herdId: [...existing, record]};
  }
}

final newFeedRecordProvider =
    NotifierProvider<NewFeedRecordNotifier, Map<String, List<GoatFeedRecord>>>(
  NewFeedRecordNotifier.new,
);

/// In-session pasture records keyed by herdId.
class NewPastureRecordNotifier
    extends Notifier<Map<String, List<PastureRecord>>> {
  @override
  Map<String, List<PastureRecord>> build() => {};

  void addRecord(String herdId, PastureRecord record) {
    final existing = state[herdId] ?? [];
    state = {...state, herdId: [...existing, record]};
  }
}

final newPastureRecordProvider =
    NotifierProvider<NewPastureRecordNotifier, Map<String, List<PastureRecord>>>(
  NewPastureRecordNotifier.new,
);

/// In-session FAMACHA records keyed by animalId.
class NewFamachaRecordNotifier
    extends Notifier<Map<String, List<FamachaRecord>>> {
  @override
  Map<String, List<FamachaRecord>> build() => {};

  void addRecord(String animalId, FamachaRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newFamachaRecordProvider = NotifierProvider<NewFamachaRecordNotifier,
    Map<String, List<FamachaRecord>>>(
  NewFamachaRecordNotifier.new,
);

/// In-session BCS records keyed by animalId.
class NewBcsRecordNotifier
    extends Notifier<Map<String, List<BodyConditionRecord>>> {
  @override
  Map<String, List<BodyConditionRecord>> build() => {};

  void addRecord(String animalId, BodyConditionRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newBcsRecordProvider = NotifierProvider<NewBcsRecordNotifier,
    Map<String, List<BodyConditionRecord>>>(
  NewBcsRecordNotifier.new,
);

/// In-session mating records keyed by doeId.
class NewMatingRecordNotifier
    extends Notifier<Map<String, List<MatingRecord>>> {
  @override
  Map<String, List<MatingRecord>> build() => {};

  void addRecord(String doeId, MatingRecord record) {
    final existing = state[doeId] ?? [];
    state = {...state, doeId: [...existing, record]};
  }
}

final newMatingRecordProvider =
    NotifierProvider<NewMatingRecordNotifier, Map<String, List<MatingRecord>>>(
  NewMatingRecordNotifier.new,
);

/// In-session pregnancy checks keyed by animalId.
class NewPregnancyCheckNotifier
    extends Notifier<Map<String, List<PregnancyCheck>>> {
  @override
  Map<String, List<PregnancyCheck>> build() => {};

  void addCheck(String animalId, PregnancyCheck check) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, check]};
  }
}

final newPregnancyCheckProvider = NotifierProvider<NewPregnancyCheckNotifier,
    Map<String, List<PregnancyCheck>>>(
  NewPregnancyCheckNotifier.new,
);

// ── Breed-group providers ─────────────────────────────────────────────────────

/// Animals grouped by breed (only alive animals).
/// Returns Map<breed, List<GoatAnimal>> ordered by count descending.
final goatsByBreedProvider =
    Provider.autoDispose<AsyncValue<Map<String, List<GoatAnimal>>>>((ref) {
  return ref.watch(animalsProvider).whenData((animals) {
    final alive = animals.where((a) => a.isAlive).toList();
    final Map<String, List<GoatAnimal>> grouped = {};
    for (final a in alive) {
      grouped.putIfAbsent(a.breed, () => []).add(a);
    }
    // Sort entries by count descending, then breed name ascending.
    final sorted = Map.fromEntries(
      grouped.entries.toList()
        ..sort((x, y) {
          final cmp = y.value.length.compareTo(x.value.length);
          return cmp != 0 ? cmp : x.key.compareTo(y.key);
        }),
    );
    return sorted;
  });
});

/// Animals for a specific breed (alive, sorted by tag number).
final breedAnimalsProvider =
    Provider.autoDispose.family<AsyncValue<List<GoatAnimal>>, String>(
        (ref, breed) {
  return ref.watch(animalsProvider).whenData(
        (animals) => animals
            .where((a) => a.breed == breed && a.isAlive)
            .toList()
          ..sort((a, b) => a.tagNumber.compareTo(b.tagNumber)),
      );
});
