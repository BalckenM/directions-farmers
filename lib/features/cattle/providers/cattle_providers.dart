import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cattle_repository.dart';
import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';

// ── Raw data providers (mock layer) ──────────────────────────────────────────

final _mockCattleAnimalsProvider = FutureProvider<List<CattleAnimal>>((ref) {
  return ref.read(cattleRepositoryProvider).getAnimals();
});

final _mockCattleWeightRecordsProvider =
    FutureProvider<List<WeightRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getWeightRecords();
});

final _mockCattleBreedingRecordsProvider =
    FutureProvider<List<BreedingRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getBreedingRecords();
});

final _mockCattlePregnancyChecksProvider =
    FutureProvider<List<PregnancyCheck>>((ref) {
  return ref.read(cattleRepositoryProvider).getPregnancyChecks();
});

final _mockCalvingEventsProvider =
    FutureProvider<List<CalvingEvent>>((ref) {
  return ref.read(cattleRepositoryProvider).getCalvingEvents();
});

final _mockCattleMilkRecordsProvider =
    FutureProvider<List<DailyMilkRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getMilkRecords();
});

final _mockCattleHealthEventsProvider =
    FutureProvider<List<CattleHealthEvent>>((ref) {
  return ref.read(cattleRepositoryProvider).getHealthEvents();
});

final _mockCattleMedicationLogsProvider =
    FutureProvider<List<CattleMedicationLog>>((ref) {
  return ref.read(cattleRepositoryProvider).getMedicationLogs();
});

final _mockCattleVaccinationsProvider =
    FutureProvider<List<CattleVaccination>>((ref) {
  return ref.read(cattleRepositoryProvider).getVaccinations();
});

final _mockCattleSaleRecordsProvider =
    FutureProvider<List<CattleSaleRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getSaleRecords();
});

final _mockCattleFeedRecordsProvider =
    FutureProvider<List<CattleFeedRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getFeedRecords();
});

final _mockCattlePastureRecordsProvider =
    FutureProvider<List<PastureRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getPastureRecords();
});

final _mockCattleBodyConditionRecordsProvider =
    FutureProvider<List<BodyConditionRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getBodyConditionRecords();
});

final _mockCattleDippingRecordsProvider =
    FutureProvider<List<DippingRecord>>((ref) {
  return ref.read(cattleRepositoryProvider).getDippingRecords();
});

// ── In-session write state ────────────────────────────────────────────────────

/// Animals added in-session (not yet persisted).
class AddedCattleNotifier extends Notifier<List<CattleAnimal>> {
  @override
  List<CattleAnimal> build() => [];

  void addAnimal(CattleAnimal animal) => state = [animal, ...state];
}

final addedCattleProvider =
    NotifierProvider<AddedCattleNotifier, List<CattleAnimal>>(
  AddedCattleNotifier.new,
);

/// Per-animal status overrides keyed by animalId.
class CattleStatusOverrideNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void setStatus(String animalId, String status) =>
      state = {...state, animalId: status};
}

final cattleStatusOverrideProvider =
    NotifierProvider<CattleStatusOverrideNotifier, Map<String, String>>(
  CattleStatusOverrideNotifier.new,
);

/// Per-animal field edits keyed by animalId.
class CattleEditNotifier
    extends Notifier<Map<String, Map<String, dynamic>>> {
  @override
  Map<String, Map<String, dynamic>> build() => {};

  void applyEdit(String animalId, Map<String, dynamic> edits) =>
      state = {
        ...state,
        animalId: {...(state[animalId] ?? {}), ...edits}
      };
}

final cattleEditProvider =
    NotifierProvider<CattleEditNotifier, Map<String, Map<String, dynamic>>>(
  CattleEditNotifier.new,
);

/// In-session weight records keyed by animalId.
class NewCattleWeightRecordNotifier
    extends Notifier<Map<String, List<WeightRecord>>> {
  @override
  Map<String, List<WeightRecord>> build() => {};

  void addRecord(String animalId, WeightRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newCattleWeightRecordProvider = NotifierProvider<
    NewCattleWeightRecordNotifier, Map<String, List<WeightRecord>>>(
  NewCattleWeightRecordNotifier.new,
);

/// In-session milk records keyed by animalId.
class NewCattleMilkRecordNotifier
    extends Notifier<Map<String, List<DailyMilkRecord>>> {
  @override
  Map<String, List<DailyMilkRecord>> build() => {};

  void addRecord(String animalId, DailyMilkRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newCattleMilkRecordProvider = NotifierProvider<
    NewCattleMilkRecordNotifier, Map<String, List<DailyMilkRecord>>>(
  NewCattleMilkRecordNotifier.new,
);

/// In-session calving events keyed by damId.
class NewCalvingEventNotifier
    extends Notifier<Map<String, List<CalvingEvent>>> {
  @override
  Map<String, List<CalvingEvent>> build() => {};

  void addEvent(String damId, CalvingEvent event) {
    final existing = state[damId] ?? [];
    state = {...state, damId: [...existing, event]};
  }
}

final newCalvingEventProvider =
    NotifierProvider<NewCalvingEventNotifier, Map<String, List<CalvingEvent>>>(
  NewCalvingEventNotifier.new,
);

/// In-session breeding records keyed by cowId.
class NewCattleBreedingRecordNotifier
    extends Notifier<Map<String, List<BreedingRecord>>> {
  @override
  Map<String, List<BreedingRecord>> build() => {};

  void addRecord(String cowId, BreedingRecord record) {
    final existing = state[cowId] ?? [];
    state = {...state, cowId: [...existing, record]};
  }
}

final newCattleBreedingRecordProvider = NotifierProvider<
    NewCattleBreedingRecordNotifier, Map<String, List<BreedingRecord>>>(
  NewCattleBreedingRecordNotifier.new,
);

/// In-session pregnancy checks keyed by animalId.
class NewCattlePregnancyCheckNotifier
    extends Notifier<Map<String, List<PregnancyCheck>>> {
  @override
  Map<String, List<PregnancyCheck>> build() => {};

  void addCheck(String animalId, PregnancyCheck check) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, check]};
  }
}

final newCattlePregnancyCheckProvider = NotifierProvider<
    NewCattlePregnancyCheckNotifier, Map<String, List<PregnancyCheck>>>(
  NewCattlePregnancyCheckNotifier.new,
);

/// In-session health events keyed by animalId.
class NewCattleHealthEventNotifier
    extends Notifier<Map<String, List<CattleHealthEvent>>> {
  @override
  Map<String, List<CattleHealthEvent>> build() => {};

  void addEvent(String animalId, CattleHealthEvent event) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, event]};
  }
}

final newCattleHealthEventProvider = NotifierProvider<
    NewCattleHealthEventNotifier, Map<String, List<CattleHealthEvent>>>(
  NewCattleHealthEventNotifier.new,
);

/// In-session medication logs keyed by animalId.
class NewCattleMedicationLogNotifier
    extends Notifier<Map<String, List<CattleMedicationLog>>> {
  @override
  Map<String, List<CattleMedicationLog>> build() => {};

  void addLog(String animalId, CattleMedicationLog log) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, log]};
  }
}

final newCattleMedicationLogProvider = NotifierProvider<
    NewCattleMedicationLogNotifier, Map<String, List<CattleMedicationLog>>>(
  NewCattleMedicationLogNotifier.new,
);

/// In-session vaccinations keyed by animalId.
class NewCattleVaccinationNotifier
    extends Notifier<Map<String, List<CattleVaccination>>> {
  @override
  Map<String, List<CattleVaccination>> build() => {};

  void addVaccination(String animalId, CattleVaccination vac) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, vac]};
  }
}

final newCattleVaccinationProvider = NotifierProvider<
    NewCattleVaccinationNotifier, Map<String, List<CattleVaccination>>>(
  NewCattleVaccinationNotifier.new,
);

/// In-session sale records keyed by animalId.
class NewCattleSaleRecordNotifier
    extends Notifier<Map<String, List<CattleSaleRecord>>> {
  @override
  Map<String, List<CattleSaleRecord>> build() => {};

  void addRecord(String animalId, CattleSaleRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newCattleSaleRecordProvider = NotifierProvider<
    NewCattleSaleRecordNotifier, Map<String, List<CattleSaleRecord>>>(
  NewCattleSaleRecordNotifier.new,
);

/// In-session feed records keyed by herdId.
class NewCattleFeedRecordNotifier
    extends Notifier<Map<String, List<CattleFeedRecord>>> {
  @override
  Map<String, List<CattleFeedRecord>> build() => {};

  void addRecord(String herdId, CattleFeedRecord record) {
    final existing = state[herdId] ?? [];
    state = {...state, herdId: [...existing, record]};
  }
}

final newCattleFeedRecordProvider = NotifierProvider<
    NewCattleFeedRecordNotifier, Map<String, List<CattleFeedRecord>>>(
  NewCattleFeedRecordNotifier.new,
);

/// In-session pasture records keyed by herdId.
class NewCattlePastureRecordNotifier
    extends Notifier<Map<String, List<PastureRecord>>> {
  @override
  Map<String, List<PastureRecord>> build() => {};

  void addRecord(String herdId, PastureRecord record) {
    final existing = state[herdId] ?? [];
    state = {...state, herdId: [...existing, record]};
  }
}

final newCattlePastureRecordProvider = NotifierProvider<
    NewCattlePastureRecordNotifier, Map<String, List<PastureRecord>>>(
  NewCattlePastureRecordNotifier.new,
);

/// In-session BCS records keyed by animalId.
class NewCattleBcsRecordNotifier
    extends Notifier<Map<String, List<BodyConditionRecord>>> {
  @override
  Map<String, List<BodyConditionRecord>> build() => {};

  void addRecord(String animalId, BodyConditionRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newCattleBcsRecordProvider = NotifierProvider<NewCattleBcsRecordNotifier,
    Map<String, List<BodyConditionRecord>>>(
  NewCattleBcsRecordNotifier.new,
);

/// In-session dipping records keyed by animalId.
class NewCattleDippingRecordNotifier
    extends Notifier<Map<String, List<DippingRecord>>> {
  @override
  Map<String, List<DippingRecord>> build() => {};

  void addRecord(String animalId, DippingRecord record) {
    final existing = state[animalId] ?? [];
    state = {...state, animalId: [...existing, record]};
  }
}

final newCattleDippingRecordProvider = NotifierProvider<
    NewCattleDippingRecordNotifier, Map<String, List<DippingRecord>>>(
  NewCattleDippingRecordNotifier.new,
);

// ── Merged animal list provider ───────────────────────────────────────────────

CattleAnimal _applyCattleEdits(
    CattleAnimal animal, Map<String, dynamic> edits) {
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
final cattleProvider =
    Provider.autoDispose<AsyncValue<List<CattleAnimal>>>((ref) {
  final added = ref.watch(addedCattleProvider);
  final statusOverrides = ref.watch(cattleStatusOverrideProvider);
  final edits = ref.watch(cattleEditProvider);
  return ref.watch(_mockCattleAnimalsProvider).whenData((mockAnimals) {
    final all = [...added, ...mockAnimals];
    return all.map((a) {
      var result = a;
      final fieldEdit = edits[a.id];
      if (fieldEdit != null) result = _applyCattleEdits(result, fieldEdit);
      final statusOverride = statusOverrides[a.id];
      if (statusOverride != null) {
        result = result.copyWith(status: statusOverride);
      }
      return result;
    }).toList();
  });
});

/// Single cattle animal by id, with overrides applied.
final cattleDetailProvider =
    Provider.autoDispose.family<AsyncValue<CattleAnimal?>, dynamic>(
        (ref, animalId) {
  final added = ref.watch(addedCattleProvider);
  final statusOverrides = ref.watch(cattleStatusOverrideProvider);
  final edits = ref.watch(cattleEditProvider);
  return ref.watch(_mockCattleAnimalsProvider).whenData((mockAnimals) {
    final all = [...added, ...mockAnimals];
    try {
      var a = all.firstWhere((a) => a.id == animalId);
      final fieldEdit = edits[animalId as String];
      if (fieldEdit != null) a = _applyCattleEdits(a, fieldEdit);
      final statusOverride = statusOverrides[animalId];
      if (statusOverride != null) a = a.copyWith(status: statusOverride);
      return a;
    } catch (_) {
      return null;
    }
  });
});

// ── Per-animal record providers ───────────────────────────────────────────────

/// Weight records for a specific animal (mock + in-session).
final cattleWeightRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<WeightRecord>>, dynamic>(
        (ref, animalId) {
  final newRecords =
      ref.watch(newCattleWeightRecordProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleWeightRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Breeding records for a specific animal (cow or bull).
final cattleBreedingRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<BreedingRecord>>, dynamic>(
        (ref, animalId) {
  final newRecords =
      ref.watch(newCattleBreedingRecordProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleBreedingRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where(
              (r) => r.cowId == animalId || r.bullId == animalId),
        ]..sort((a, b) => b.serviceDate.compareTo(a.serviceDate)),
      );
});

/// Pregnancy checks for a specific animal.
final cattlePregnancyChecksProvider =
    Provider.autoDispose.family<AsyncValue<List<PregnancyCheck>>, dynamic>(
        (ref, animalId) {
  final newChecks =
      ref.watch(newCattlePregnancyCheckProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattlePregnancyChecksProvider).whenData(
        (all) => [
          ...newChecks,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Calving events where the given animal is the dam.
final cattleCalvingEventsProvider =
    Provider.autoDispose.family<AsyncValue<List<CalvingEvent>>, dynamic>(
        (ref, damId) {
  final newEvents =
      ref.watch(newCalvingEventProvider)[damId as String] ?? [];
  return ref.watch(_mockCalvingEventsProvider).whenData(
        (all) => [
          ...newEvents,
          ...all.where((e) => e.damId == damId),
        ]..sort((a, b) => b.calvingDate.compareTo(a.calvingDate)),
      );
});

/// Daily milk records for a specific animal (mock + in-session).
final cattleMilkRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<DailyMilkRecord>>, dynamic>(
        (ref, animalId) {
  final newRecords =
      ref.watch(newCattleMilkRecordProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleMilkRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Health events for a specific animal.
final cattleHealthEventsProvider =
    Provider.autoDispose.family<AsyncValue<List<CattleHealthEvent>>, dynamic>(
        (ref, animalId) {
  final newEvents =
      ref.watch(newCattleHealthEventProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleHealthEventsProvider).whenData(
        (all) => [
          ...newEvents,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Medication logs for a specific animal.
final cattleMedicationLogsProvider = Provider.autoDispose
    .family<AsyncValue<List<CattleMedicationLog>>, dynamic>(
        (ref, animalId) {
  final newLogs =
      ref.watch(newCattleMedicationLogProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleMedicationLogsProvider).whenData(
        (all) => [
          ...newLogs,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Vaccinations for a specific animal.
final cattleVaccinationsProvider =
    Provider.autoDispose.family<AsyncValue<List<CattleVaccination>>, dynamic>(
        (ref, animalId) {
  final newVacs =
      ref.watch(newCattleVaccinationProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleVaccinationsProvider).whenData(
        (all) => [
          ...newVacs,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
      );
});

/// Sale records for a specific animal.
final cattleSaleRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<CattleSaleRecord>>, dynamic>(
        (ref, animalId) {
  final newRecords =
      ref.watch(newCattleSaleRecordProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleSaleRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.saleDate.compareTo(a.saleDate)),
      );
});

/// BCS records for a specific animal.
final cattleBcsRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<BodyConditionRecord>>, dynamic>(
        (ref, animalId) {
  final newRecords =
      ref.watch(newCattleBcsRecordProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleBodyConditionRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Dipping records for a specific animal.
final cattleDippingRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<DippingRecord>>, dynamic>(
        (ref, animalId) {
  final newRecords =
      ref.watch(newCattleDippingRecordProvider)[animalId as String] ?? [];
  return ref.watch(_mockCattleDippingRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == animalId),
        ]..sort((a, b) => b.dippingDate.compareTo(a.dippingDate)),
      );
});

// ── Herd-level providers ──────────────────────────────────────────────────────

/// All animals belonging to a specific herd.
final cattleHerdAnimalsProvider =
    Provider.autoDispose.family<AsyncValue<List<CattleAnimal>>, dynamic>(
        (ref, herdId) {
  return ref.watch(cattleProvider).whenData(
        (all) => all.where((a) => a.herdId == herdId).toList(),
      );
});

/// Feed records for a specific herd.
final cattleHerdFeedRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<CattleFeedRecord>>, dynamic>(
        (ref, herdId) {
  final newRecords =
      ref.watch(newCattleFeedRecordProvider)[herdId as String] ?? [];
  return ref.watch(_mockCattleFeedRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.animalId == herdId),
        ]..sort((a, b) => b.date.compareTo(a.date)),
      );
});

/// Pasture records for a specific herd.
final cattleHerdPastureRecordsProvider =
    Provider.autoDispose.family<AsyncValue<List<PastureRecord>>, dynamic>(
        (ref, herdId) {
  final newRecords =
      ref.watch(newCattlePastureRecordProvider)[herdId as String] ?? [];
  return ref.watch(_mockCattlePastureRecordsProvider).whenData(
        (all) => [
          ...newRecords,
          ...all.where((r) => r.herdId == herdId),
        ]..sort((a, b) => b.entryDate.compareTo(a.entryDate)),
      );
});

// ── Breed-group providers ─────────────────────────────────────────────────────

/// Animals grouped by breed (only alive animals).
final cattleByBreedProvider =
    Provider.autoDispose<AsyncValue<Map<String, List<CattleAnimal>>>>((ref) {
  return ref.watch(cattleProvider).whenData((animals) {
    final alive = animals.where((a) => a.isAlive).toList();
    final Map<String, List<CattleAnimal>> grouped = {};
    for (final a in alive) {
      grouped.putIfAbsent(a.breed, () => []).add(a);
    }
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
final cattleBreedAnimalsProvider =
    Provider.autoDispose.family<AsyncValue<List<CattleAnimal>>, dynamic>(
        (ref, breed) {
  return ref.watch(cattleProvider).whenData(
        (animals) => animals
            .where((a) => a.breed == breed && a.isAlive)
            .toList()
          ..sort((a, b) => a.tagNumber.compareTo(b.tagNumber)),
      );
});

// ── Module-level aggregate providers ─────────────────────────────────────────

/// All cattle sale records (mock + in-session).
final allCattleSaleRecordsProvider =
    Provider.autoDispose<AsyncValue<List<CattleSaleRecord>>>((ref) {
  final inSession = ref.watch(newCattleSaleRecordProvider);
  return ref.watch(_mockCattleSaleRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All cattle vaccinations (mock + in-session).
final allCattleVaccinationsProvider =
    Provider.autoDispose<AsyncValue<List<CattleVaccination>>>((ref) {
  final inSession = ref.watch(newCattleVaccinationProvider);
  return ref.watch(_mockCattleVaccinationsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All cattle feed records (mock + in-session).
final allCattleFeedRecordsProvider =
    Provider.autoDispose<AsyncValue<List<CattleFeedRecord>>>((ref) {
  final inSession = ref.watch(newCattleFeedRecordProvider);
  return ref.watch(_mockCattleFeedRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All cattle pasture records (mock + in-session).
final allCattlePastureRecordsProvider =
    Provider.autoDispose<AsyncValue<List<PastureRecord>>>((ref) {
  final inSession = ref.watch(newCattlePastureRecordProvider);
  return ref.watch(_mockCattlePastureRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All pregnancy checks (mock + in-session).
final allCattlePregnancyChecksProvider =
    Provider.autoDispose<AsyncValue<List<PregnancyCheck>>>((ref) {
  final inSession = ref.watch(newCattlePregnancyCheckProvider);
  return ref.watch(_mockCattlePregnancyChecksProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All BCS records (mock + in-session).
final allCattleBcsRecordsProvider =
    Provider.autoDispose<AsyncValue<List<BodyConditionRecord>>>((ref) {
  final inSession = ref.watch(newCattleBcsRecordProvider);
  return ref.watch(_mockCattleBodyConditionRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All calving events (mock + in-session).
final allCalvingEventsProvider =
    Provider.autoDispose<AsyncValue<List<CalvingEvent>>>((ref) {
  final newEvents = ref.watch(newCalvingEventProvider);
  return ref.watch(_mockCalvingEventsProvider).whenData((mock) {
    final allNew = newEvents.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All cattle health events (mock + in-session).
final allCattleHealthEventsProvider =
    Provider.autoDispose<AsyncValue<List<CattleHealthEvent>>>((ref) {
  final inSession = ref.watch(newCattleHealthEventProvider);
  return ref.watch(_mockCattleHealthEventsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All weight records (mock + in-session).
final allCattleWeightRecordsProvider =
    Provider.autoDispose<AsyncValue<List<WeightRecord>>>((ref) {
  final inSession = ref.watch(newCattleWeightRecordProvider);
  return ref.watch(_mockCattleWeightRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All milk records (mock + in-session).
final allCattleMilkRecordsProvider =
    Provider.autoDispose<AsyncValue<List<DailyMilkRecord>>>((ref) {
  final inSession = ref.watch(newCattleMilkRecordProvider);
  return ref.watch(_mockCattleMilkRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

/// All dipping records (mock + in-session).
final allCattleDippingRecordsProvider =
    Provider.autoDispose<AsyncValue<List<DippingRecord>>>((ref) {
  final inSession = ref.watch(newCattleDippingRecordProvider);
  return ref.watch(_mockCattleDippingRecordsProvider).whenData((mock) {
    final allNew = inSession.values.expand((l) => l).toList();
    return [...allNew, ...mock];
  });
});

// ── Alert providers ───────────────────────────────────────────────────────────

/// Animals with expected calving date within the next 10 days.
final calvingDueSoonProvider =
    Provider.autoDispose<AsyncValue<List<CattleAnimal>>>((ref) {
  return ref.watch(cattleProvider).whenData((animals) {
    final today = DateTime.now();
    final cutoff = today.add(const Duration(days: 10));
    return animals.where((a) {
      if (!a.isPregnant || a.expectedCalvingDate == null) return false;
      try {
        final due = DateTime.parse(a.expectedCalvingDate!);
        return due.isAfter(today.subtract(const Duration(days: 1))) &&
            due.isBefore(cutoff);
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) =>
          a.expectedCalvingDate!.compareTo(b.expectedCalvingDate!));
  });
});

/// Overdue cattle vaccinations (due date passed, not yet given).
final cattleVaccinationOverdueProvider =
    Provider.autoDispose<AsyncValue<List<CattleVaccination>>>((ref) {
  return ref.watch(_mockCattleVaccinationsProvider).whenData((vaccinations) {
    return vaccinations.where((v) => v.isOverdue).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  });
});

/// Alive cattle with body condition score below 2.0.
final cattleLowBcsAlertsProvider =
    Provider.autoDispose<AsyncValue<List<CattleAnimal>>>((ref) {
  return ref.watch(cattleProvider).whenData(
        (animals) => animals
            .where(
                (a) => a.isAlive && (a.bodyConditionScore ?? 3.0) < 2.0)
            .toList(),
      );
});

/// Dairy animals whose dry-off date falls within the next 7 days.
final cattleDryOffSoonProvider =
    Provider.autoDispose<AsyncValue<List<CattleAnimal>>>((ref) {
  return ref.watch(cattleProvider).whenData((animals) {
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

/// Animals due for dipping (lastDippingDate > 14 days ago or never dipped).
final cattleDippingDueSoonProvider =
    Provider.autoDispose<AsyncValue<List<CattleAnimal>>>((ref) {
  return ref.watch(cattleProvider).whenData((animals) {
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    return animals.where((a) {
      if (!a.isAlive) return false;
      if (a.lastDippingDate == null) return true;
      try {
        return DateTime.parse(a.lastDippingDate!).isBefore(cutoff);
      } catch (_) {
        return true;
      }
    }).toList();
  });
});

// ── RBAC permission stubs ─────────────────────────────────────────────────────

/// Whether the current user can add or edit cattle records.
final canManageCattleProvider = Provider<bool>((ref) => true);

/// Whether the current user can manage cattle health and medication records.
final canManageCattleHealthProvider = Provider<bool>((ref) => true);

/// Whether the current user can view or manage cattle financial records.
final canManageCattleFinancialsProvider = Provider<bool>((ref) => true);
