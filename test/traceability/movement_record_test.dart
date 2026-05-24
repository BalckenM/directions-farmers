// Unit tests for MovementRecord model — fromJson, copyWith, computed getters.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/traceability/models/movement_record.dart';

void main() {
  final baseRecord = MovementRecord(
    id: 'mr1',
    farmId: 'farm1',
    movementDate: '2024-05-10',
    species: 'cattle',
    animalIds: ['a1', 'a2', 'a3'],
    movementType: MovementType.farmToFarm,
    fromLocation: 'Green Farm',
    toLocation: 'Blue Farm',
    transporterName: 'Fast Transport',
    vehicleRegNo: 'CA 123-456',
    permitNumber: 'B313-2024-001',
    rmisSubmitted: false,
  );

  group('MovementRecord.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'mr1',
        'farm_id': 'farm1',
        'movement_date': '2024-05-10',
        'species': 'cattle',
        'animal_ids': ['a1', 'a2', 'a3'],
        'movement_type': 'farm_to_farm',
        'from_location': 'Green Farm',
        'to_location': 'Blue Farm',
        'transporter_name': 'Fast Transport',
        'vehicle_reg_no': 'CA 123-456',
        'permit_number': 'B313-2024-001',
        'rmis_submitted': false,
      };
      final record = MovementRecord.fromJson(json);
      expect(record.id, 'mr1');
      expect(record.farmId, 'farm1');
      expect(record.species, 'cattle');
      expect(record.animalIds, ['a1', 'a2', 'a3']);
      expect(record.movementType, MovementType.farmToFarm);
      expect(record.fromLocation, 'Green Farm');
      expect(record.permitNumber, 'B313-2024-001');
      expect(record.rmisSubmitted, isFalse);
    });

    test('parses all MovementType enum values', () {
      final typeMappings = {
        'farm_to_farm': MovementType.farmToFarm,
        'farm_to_abattoir': MovementType.farmToAbattoir,
        'farm_to_auction': MovementType.farmToAuction,
        'auction_to_farm': MovementType.auctionToFarm,
        'import': MovementType.importFromAbroad,
        'export': MovementType.exportToAbroad,
      };
      for (final entry in typeMappings.entries) {
        final record = MovementRecord.fromJson({
          'id': 'x',
          'farm_id': 'f',
          'movement_date': '2024-01-01',
          'species': 'cattle',
          'animal_ids': <String>[],
          'movement_type': entry.key,
          'from_location': 'A',
          'to_location': 'B',
        });
        expect(
          record.movementType,
          entry.value,
          reason: 'type_str=${entry.key}',
        );
      }
    });

    test('handles missing optional fields', () {
      final record = MovementRecord.fromJson({
        'id': 'mr2',
        'farm_id': 'farm2',
        'movement_date': '2024-06-01',
        'species': 'sheep',
        'animal_ids': ['s1'],
        'movement_type': 'farm_to_farm',
        'from_location': 'Farm A',
        'to_location': 'Farm B',
      });
      expect(record.transporterName, isNull);
      expect(record.permitNumber, isNull);
      expect(record.rmisSubmitted, isFalse);
      expect(record.notes, isNull);
    });
  });

  group('MovementRecord computed getters', () {
    test('animalCount returns list length', () {
      expect(baseRecord.animalCount, 3);
    });

    test('requiresVetCert is false for farmToFarm', () {
      expect(baseRecord.requiresVetCert, isFalse);
    });

    test('requiresVetCert is true for farmToAuction', () {
      final auction = baseRecord.copyWith(
        movementType: MovementType.farmToAuction,
      );
      expect(auction.requiresVetCert, isTrue);
    });

    test('requiresVetCert is true for exportToAbroad', () {
      final export = baseRecord.copyWith(
        movementType: MovementType.exportToAbroad,
      );
      expect(export.requiresVetCert, isTrue);
    });

    test('displayMovementType returns human-readable label', () {
      expect(baseRecord.displayMovementType, 'Farm to Farm');
      final abattoir = baseRecord.copyWith(
        movementType: MovementType.farmToAbattoir,
      );
      expect(abattoir.displayMovementType, 'Farm to Abattoir');
    });
  });

  group('MovementRecord.copyWith', () {
    test('returns same values when no override', () {
      final copy = baseRecord.copyWith();
      expect(copy.id, baseRecord.id);
      expect(copy.species, baseRecord.species);
      expect(copy.animalIds, baseRecord.animalIds);
      expect(copy.movementType, baseRecord.movementType);
    });

    test('overrides rmisSubmitted and adds transaction id', () {
      final copy = baseRecord.copyWith(
        rmisSubmitted: true,
        rmisSubmitDate: '2024-05-11',
        rmisTransactionId: 'RMIS-TXN-9999',
      );
      expect(copy.rmisSubmitted, isTrue);
      expect(copy.rmisSubmitDate, '2024-05-11');
      expect(copy.rmisTransactionId, 'RMIS-TXN-9999');
      // Unchanged
      expect(copy.id, baseRecord.id);
      expect(copy.permitNumber, baseRecord.permitNumber);
    });

    test('overrides animalIds list', () {
      final copy = baseRecord.copyWith(animalIds: ['a4', 'a5']);
      expect(copy.animalIds, ['a4', 'a5']);
      expect(copy.animalCount, 2);
    });
  });
}
