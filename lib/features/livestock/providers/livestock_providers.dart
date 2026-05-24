import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/livestock_data_source.dart';
import '../data/livestock_mock_data_source.dart';
import '../data/livestock_repository.dart';
import '../models/animal.dart';
import 'local_animal_store.dart';

final livestockDataSourceProvider = Provider<LivestockDataSource>(
  (ref) => LivestockMockDataSource(),
);

final livestockRepositoryProvider = Provider<LivestockRepository>(
  (ref) => LivestockRepository(ref.watch(livestockDataSourceProvider)),
);

// ── Raw mock data ─────────────────────────────────────────────────────────────

/// Internal provider: fetches mock animals from JSON for [species].
/// Not autoDisposed so the cache persists while the app is alive.
final _mockAnimalsProvider =
    FutureProvider.family<List<Animal>, String>((ref, species) {
  return ref.watch(livestockRepositoryProvider).getAnimals(species);
});

// ── Merged provider (mock + local) ───────────────────────────────────────────

/// Merged list: mock JSON records + any locally added animals.
///
/// Returns [AsyncValue<List<Animal>>] — call `.when()` as usual.
/// Recomputes automatically whenever [localAnimalStoreProvider] changes.
final animalsProvider =
    Provider.family<AsyncValue<List<Animal>>, String>((ref, species) {
  final mockAsync = ref.watch(_mockAnimalsProvider(species));
  final local = ref.watch(localAnimalStoreProvider)[species] ?? const [];
  return mockAsync.whenData((mock) => [...mock, ...local]);
});

// ── Single-animal detail ──────────────────────────────────────────────────────

/// Looks up an animal by id across both mock + local stores.
final animalDetailProvider = Provider.autoDispose
    .family<AsyncValue<Animal?>, (String species, String id)>((ref, args) {
  final (species, id) = args;
  final allAsync = ref.watch(animalsProvider(species));
  return allAsync.whenData((animals) {
    try {
      return animals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  });
});
