import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/livestock_data_source.dart';
import '../data/livestock_remote_data_source.dart';
import '../data/livestock_repository.dart';
import '../models/animal.dart';
import 'local_animal_store.dart';

final livestockDataSourceProvider = Provider<LivestockDataSource>(
  (ref) => LivestockRemoteDataSource(ref.read(apiDioProvider)),
);

final livestockRepositoryProvider = Provider<LivestockRepository>(
  (ref) => LivestockRepository(ref.watch(livestockDataSourceProvider)),
);

// ── Raw data providers ─────────────────────────────────────────────────────────────

/// Internal provider: fetches animals from API for [species].
/// Not autoDisposed so the cache persists while the app is alive.
final _apiAnimalsProvider =
    FutureProvider.family<List<Animal>, String>((ref, species) {
  return ref.watch(livestockRepositoryProvider).getAnimals(species);
});

// ── Merged provider (API + local) ───────────────────────────────────────────

/// Merged list: API records + any locally added animals.
///
/// Returns [AsyncValue<List<Animal>>] — call `.when()` as usual.
/// Recomputes automatically whenever [localAnimalStoreProvider] changes.
final animalsProvider =
    Provider.family<AsyncValue<List<Animal>>, String>((ref, species) {
  final apiAsync = ref.watch(_apiAnimalsProvider(species));
  final local = ref.watch(localAnimalStoreProvider)[species] ?? const [];
  return apiAsync.whenData((api) => [...api, ...local]);
});

// ── Single-animal detail ──────────────────────────────────────────────────────

/// Looks up an animal by id across both API + local stores.
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
