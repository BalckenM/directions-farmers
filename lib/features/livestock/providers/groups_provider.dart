import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/livestock_repository.dart';
import '../models/group.dart';

// ── Groups from repository ────────────────────────────────────────────────────

final groupsProvider = FutureProvider.autoDispose<List<Group>>((ref) {
  return ref.watch(livestockRepositoryProvider).getGroups();
});

// ── Local group store ─────────────────────────────────────────────────────────

class LocalGroupStore extends Notifier<Map<String, Group>> {
  @override
  Map<String, Group> build() => const {};

  void addGroup(Group group) {
    state = {...state, group.id: group};
  }

  void updateGroup(Group group) {
    state = {...state, group.id: group};
  }

  void removeGroup(String id) {
    final updated = Map<String, Group>.from(state);
    updated.remove(id);
    state = updated;
  }
}

final localGroupStoreProvider =
    NotifierProvider<LocalGroupStore, Map<String, Group>>(LocalGroupStore.new);
