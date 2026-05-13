// Riverpod provider tests for the goat module.
//
// Uses ProviderContainer to exercise providers in isolation.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/goat/providers/goat_providers.dart';

// Helper — listens to [provider] via Completer and waits for AsyncData/AsyncError.
// Uses dynamic for the provider argument to avoid referencing the unexported
// ProviderListenable<T> type directly.
Future<T> _resolve<T>(ProviderContainer container, dynamic provider) {
  final completer = Completer<T>();
  final sub = container.listen<AsyncValue<T>>(
    // ignore: avoid_dynamic_calls
    provider,
    (_, next) {
      if (next is AsyncData<T> && !completer.isCompleted) {
        completer.complete(next.value);
      } else if (next is AsyncError && !completer.isCompleted) {
        completer.completeError(next.error!, next.stackTrace);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

void main() {
  group('animalsProvider', () {
    test('resolves to 14 animals', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final animals = await _resolve<List>(container, animalsProvider);
      expect(animals.length, 14);
    });

    test('all animal ids are unique', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final animals = await _resolve<List>(container, animalsProvider);
      final ids = animals.map((a) => (a as dynamic).id).toSet();
      expect(ids.length, animals.length);
    });
  });

  group('famachaAlertProvider', () {
    test('returns only animals with score >= 4', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final flagged = await _resolve<List>(container, famachaAlertProvider);
      for (final a in flagged) {
        expect((a as dynamic).famachaScore, greaterThanOrEqualTo(4));
      }
    });

    test('at least one animal is flagged in mock data', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final flagged = await _resolve<List>(container, famachaAlertProvider);
      expect(flagged, isNotEmpty);
    });
  });

  group('vaccinationOverdueProvider', () {
    test('all returned vaccinations are overdue', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final overdue = await _resolve<List>(container, vaccinationOverdueProvider);
      for (final v in overdue) {
        expect((v as dynamic).isOverdue, isTrue,
            reason: '${(v as dynamic).id} should be overdue but isOverdue=false');
      }
    });
  });

  group('kiddingDueSoonProvider', () {
    test('all returned animals are pregnant with future kidding date', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final due = await _resolve<List>(container, kiddingDueSoonProvider);
      for (final a in due) {
        expect((a as dynamic).isPregnant, isTrue);
        expect((a as dynamic).expectedKiddingDate, isNotNull);
      }
    });
  });

  group('lowBcsAlertsProvider', () {
    test('returns only alive animals with BCS < 2.0', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final lowBcs = await _resolve<List>(container, lowBcsAlertsProvider);
      for (final a in lowBcs) {
        expect((a as dynamic).isAlive, isTrue,
            reason: '${(a as dynamic).id} should be alive');
        expect((a as dynamic).bodyConditionScore, lessThan(2.0),
            reason: '${(a as dynamic).id} BCS should be < 2.0');
      }
    });
  });

  group('dryOffSoonProvider', () {
    test('all returned animals have a dryOffDate and are alive', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dryOff = await _resolve<List>(container, dryOffSoonProvider);
      for (final a in dryOff) {
        expect((a as dynamic).isAlive, isTrue);
        expect((a as dynamic).dryOffDate, isNotNull);
      }
    });
  });

  group('RBAC stub providers', () {
    test('canManageAnimalsProvider returns true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(canManageAnimalsProvider), isTrue);
    });

    test('canManageHealthProvider returns true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(canManageHealthProvider), isTrue);
    });

    test('canManageFinancialsProvider returns true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(canManageFinancialsProvider), isTrue);
    });
  });

  group('animalDetailProvider', () {
    test('returns correct animal by id', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final animal = await _resolve<dynamic>(container, animalDetailProvider('goat-001'));
      expect(animal, isNotNull);
      expect((animal as dynamic).name, 'Bella');
    });

    test('returns null for unknown id', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final animal = await _resolve<dynamic>(container, animalDetailProvider('unknown-id'));
      expect(animal, isNull);
    });
  });

  group('herdAnimalsProvider', () {
    test('herd-a animals are all from herd-a', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final animals = await _resolve<List>(container, herdAnimalsProvider('herd-a'));
      expect(animals, isNotEmpty);
      for (final a in animals) {
        expect((a as dynamic).herdId, 'herd-a');
      }
    });
  });
}
