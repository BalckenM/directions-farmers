import '../models/animal.dart';
import '../models/group.dart';
import 'livestock_data_source.dart';

/// In-memory mock livestock data — no JSON files, no rootBundle.
class LivestockMockDataSource implements LivestockDataSource {
  static const _farmId = 'farm-001';

  @override
  Future<List<Animal>> getAnimals(String species) async {
    return switch (species) {
      'cattle' => _cattle,
      'goats' => _goats,
      'sheep' => _sheep,
      'pigs' => _pigs,
      'poultry' => _poultry,
      'horses' => _horses,
      'rabbits' => _rabbits,
      'aquaculture' => const [],
      _ => const [],
    };
  }

  @override
  Future<List<Group>> getGroups() async => _groups;

  // ── Cattle ──────────────────────────────────────────────────────────────────
  static const _cattle = [
    Animal(
      id: 'C-001',
      farmId: _farmId,
      species: 'cattle',
      tagNumber: 'ZA-C-0001',
      name: 'Bessie',
      breed: 'Holstein',
      sex: 'female',
      status: 'active',
      productionType: 'dairy',
      ageMonths: 36,
      currentWeightKg: 550.0,
      bodyConditionScore: 3,
      locationPaddock: 'Paddock A',
      vaccinationStatus: 'up_to_date',
      brucellaTested: true,
    ),
    Animal(
      id: 'C-002',
      farmId: _farmId,
      species: 'cattle',
      tagNumber: 'ZA-C-0002',
      name: 'Duke',
      breed: 'Angus',
      sex: 'male',
      status: 'active',
      productionType: 'beef',
      ageMonths: 18,
      currentWeightKg: 420.0,
      locationPaddock: 'Paddock B',
      brucellaTested: false,
    ),
    Animal(
      id: 'C-003',
      farmId: _farmId,
      species: 'cattle',
      tagNumber: 'ZA-C-0003',
      name: 'Daisy',
      breed: 'Jersey',
      sex: 'female',
      status: 'active',
      productionType: 'dairy',
      ageMonths: 48,
      currentWeightKg: 480.0,
      bodyConditionScore: 3,
      locationPaddock: 'Paddock A',
      vaccinationStatus: 'up_to_date',
      brucellaTested: true,
    ),
  ];

  // ── Goats ────────────────────────────────────────────────────────────────────
  static const _goats = [
    Animal(
      id: 'G-001',
      farmId: _farmId,
      species: 'goats',
      tagNumber: 'ZA-G-0001',
      name: 'Nanny',
      breed: 'Boer',
      sex: 'female',
      status: 'active',
      productionType: 'meat',
      ageMonths: 24,
      currentWeightKg: 65.0,
      locationPaddock: 'Paddock C',
    ),
    Animal(
      id: 'G-002',
      farmId: _farmId,
      species: 'goats',
      tagNumber: 'ZA-G-0002',
      name: 'Billy',
      breed: 'Boer',
      sex: 'male',
      status: 'active',
      productionType: 'meat',
      ageMonths: 30,
      currentWeightKg: 90.0,
      locationPaddock: 'Paddock C',
    ),
  ];

  // ── Sheep ────────────────────────────────────────────────────────────────────
  static const _sheep = [
    Animal(
      id: 'S-001',
      farmId: _farmId,
      species: 'sheep',
      tagNumber: 'ZA-S-0001',
      name: 'Woolly',
      breed: 'Merino',
      sex: 'female',
      status: 'active',
      productionType: 'wool',
      ageMonths: 20,
      currentWeightKg: 55.0,
      bodyConditionScore: 3,
      locationPaddock: 'Paddock D',
    ),
    Animal(
      id: 'S-002',
      farmId: _farmId,
      species: 'sheep',
      tagNumber: 'ZA-S-0002',
      name: 'Ram',
      breed: 'Merino',
      sex: 'male',
      status: 'active',
      productionType: 'wool',
      ageMonths: 28,
      currentWeightKg: 75.0,
      locationPaddock: 'Paddock D',
    ),
  ];

  // ── Pigs ─────────────────────────────────────────────────────────────────────
  static const _pigs = [
    Animal(
      id: 'P-001',
      farmId: _farmId,
      species: 'pigs',
      tagNumber: 'ZA-P-0001',
      name: 'Porky',
      breed: 'Large White',
      sex: 'female',
      status: 'active',
      productionType: 'breeding',
      ageMonths: 18,
      currentWeightKg: 220.0,
    ),
  ];

  // ── Poultry ──────────────────────────────────────────────────────────────────
  static const _poultry = [
    Animal(
      id: 'PT-001',
      farmId: _farmId,
      species: 'poultry',
      tagNumber: 'FLOCK-001',
      name: 'Layer Flock A',
      breed: 'Lohmann Brown',
      sex: 'female',
      status: 'active',
      productionType: 'layer',
      ageMonths: 8,
    ),
  ];

  // ── Horses ───────────────────────────────────────────────────────────────────
  static const _horses = [
    Animal(
      id: 'H-001',
      farmId: _farmId,
      species: 'horses',
      tagNumber: 'ZA-H-0001',
      name: 'Thunder',
      breed: 'Thoroughbred',
      sex: 'male',
      status: 'active',
      productionType: 'sport',
      ageMonths: 60,
      currentWeightKg: 500.0,
    ),
  ];

  // ── Rabbits ──────────────────────────────────────────────────────────────────
  static const _rabbits = [
    Animal(
      id: 'R-001',
      farmId: _farmId,
      species: 'rabbits',
      tagNumber: 'ZA-R-0001',
      name: 'Bunny',
      breed: 'New Zealand White',
      sex: 'female',
      status: 'active',
      productionType: 'meat',
      ageMonths: 6,
      currentWeightKg: 4.5,
    ),
  ];

  // ── Groups ───────────────────────────────────────────────────────────────────
  static const _groups = [
    Group(
      id: 'GRP-001',
      farmId: _farmId,
      name: 'Dairy Herd',
      species: 'cattle',
      animalCount: 12,
      purpose: 'dairy',
      location: 'Paddock A',
    ),
    Group(
      id: 'GRP-002',
      farmId: _farmId,
      name: 'Beef Finishers',
      species: 'cattle',
      animalCount: 8,
      purpose: 'beef',
      location: 'Paddock B',
    ),
    Group(
      id: 'GRP-003',
      farmId: _farmId,
      name: 'Boer Goats',
      species: 'goats',
      animalCount: 25,
      purpose: 'meat',
      location: 'Paddock C',
    ),
  ];
}
