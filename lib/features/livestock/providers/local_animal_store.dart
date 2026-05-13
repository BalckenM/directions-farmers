import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/animal.dart';

/// In-memory store for animals added/edited locally before Drift persistence
/// is wired up.  Keyed by species code → list of [Animal] records.
class LocalAnimalStore extends Notifier<Map<String, List<Animal>>> {
  @override
  Map<String, List<Animal>> build() => const {};

  /// Appends [animal] to the list for its species.
  void add(Animal animal) {
    final current = state[animal.species] ?? const [];
    state = Map.of(state)..[animal.species] = [...current, animal];
  }

  /// Replaces the record with the same [Animal.id] inside the species bucket.
  void update(Animal updated) {
    final current = state[updated.species] ?? const [];
    state = Map.of(state)
      ..[updated.species] =
          current.map((a) => a.id == updated.id ? updated : a).toList();
  }

  /// Removes the record matching [animalId] from [species].
  void remove(String species, String animalId) {
    final current = state[species] ?? const [];
    state = Map.of(state)
      ..[species] = current.where((a) => a.id != animalId).toList();
  }
}

/// Global provider – NOT autoDisposed so local records survive navigation.
final localAnimalStoreProvider =
    NotifierProvider<LocalAnimalStore, Map<String, List<Animal>>>(
  LocalAnimalStore.new,
);
