import '../models/breeding_event.dart';
import '../models/health_event.dart';
import '../models/weight_record.dart';
import 'events_data_source.dart';

/// In-memory mock events data — no JSON files, no rootBundle.
class EventsMockDataSource implements EventsDataSource {
  @override
  Future<List<HealthEvent>> getHealthEvents() async => _events;

  @override
  Future<List<WeightRecord>> getWeightRecords() async => _weightRecords;

  @override
  Future<List<BreedingEvent>> getBreedingEvents() async => _breedingEvents;

  @override
  Future<void> addHealthEvent(HealthEvent event) async => _events.insert(0, event);

  @override
  Future<void> addWeightRecord(WeightRecord record) async =>
      _weightRecords.insert(0, record);

  @override
  Future<void> addBreedingEvent(BreedingEvent event) async =>
      _breedingEvents.insert(0, event);

  // Mutable in-memory seed data
  final _events = <HealthEvent>[
    HealthEvent(
      id: 'HE-001',
      animalId: 'C-001',
      animalType: 'cattle',
      eventType: 'vaccination',
      eventDate: '2024-03-15',
      description: 'Annual FMD vaccination',
      productName: 'Onderstepoort FMD Vaccine',
      costZar: 85.0,
      nextDueDate: '2025-03-15',
    ),
    HealthEvent(
      id: 'HE-002',
      animalId: 'C-002',
      animalType: 'cattle',
      eventType: 'treatment',
      eventDate: '2024-04-02',
      description: 'Tick-borne disease treatment',
      diagnosis: 'Redwater (Babesiosis)',
      treatment: 'Berenil injection',
      productName: 'Berenil',
      costZar: 120.0,
      withdrawalDays: 14,
    ),
    HealthEvent(
      id: 'HE-003',
      animalId: 'G-001',
      animalType: 'goats',
      eventType: 'deworming',
      eventDate: '2024-04-10',
      description: 'Routine deworming',
      productName: 'Closamectin',
      famachaScore: 2,
      dagScore: 1,
      costZar: 35.0,
      nextDueDate: '2024-07-10',
    ),
    HealthEvent(
      id: 'HE-004',
      animalId: 'S-001',
      animalType: 'sheep',
      eventType: 'vaccination',
      eventDate: '2024-02-20',
      description: 'Pulpy kidney & pasteurella vaccine',
      productName: 'Multivax-P Plus',
      costZar: 45.0,
      nextDueDate: '2024-08-20',
    ),
  ];

  final _weightRecords = <WeightRecord>[
    WeightRecord(
      id: 'WR-001',
      animalId: 'C-001',
      animalType: 'cattle',
      weighDate: '2024-01-15',
      weightKg: 380.0,
      bodyConditionScore: 3,
      method: 'weigh_bridge',
    ),
    WeightRecord(
      id: 'WR-002',
      animalId: 'C-001',
      animalType: 'cattle',
      weighDate: '2024-04-15',
      weightKg: 412.0,
      bodyConditionScore: 3,
      adgSinceLastKg: 0.36,
      method: 'weigh_bridge',
    ),
    WeightRecord(
      id: 'WR-003',
      animalId: 'C-002',
      animalType: 'cattle',
      weighDate: '2024-03-20',
      weightKg: 298.0,
      bodyConditionScore: 2,
      method: 'weigh_tape',
    ),
    WeightRecord(
      id: 'WR-004',
      animalId: 'G-001',
      animalType: 'goats',
      weighDate: '2024-04-01',
      weightKg: 48.5,
      bodyConditionScore: 3,
      method: 'platform_scale',
    ),
    WeightRecord(
      id: 'WR-005',
      animalId: 'S-001',
      animalType: 'sheep',
      weighDate: '2024-02-28',
      weightKg: 62.0,
      bodyConditionScore: 3,
      adgSinceLastKg: 0.18,
      method: 'platform_scale',
    ),
  ];

  final _breedingEvents = <BreedingEvent>[
    BreedingEvent(
      id: 'BE-001',
      animalId: 'C-001',
      animalType: 'cattle',
      eventType: 'mating',
      serviceDate: '2024-02-10',
      serviceMethod: 'natural',
      sireName: 'Bull-007',
      sireBreed: 'Bonsmara',
      expectedBirthDate: '2024-11-20',
      pregnancyResult: 'confirmed_pregnant',
    ),
    BreedingEvent(
      id: 'BE-002',
      animalId: 'C-002',
      animalType: 'cattle',
      eventType: 'ai',
      serviceDate: '2024-03-05',
      serviceMethod: 'ai',
      sireName: 'Stud-SA-12',
      sireBreed: 'Nguni',
      expectedBirthDate: '2024-12-15',
      pregnancyResult: 'open',
    ),
    BreedingEvent(
      id: 'BE-003',
      animalId: 'G-001',
      animalType: 'goats',
      eventType: 'mating',
      serviceDate: '2024-01-20',
      serviceMethod: 'natural',
      sireName: 'Buck-03',
      sireBreed: 'Boer',
      expectedBirthDate: '2024-06-15',
      pregnancyResult: 'birth',
      notes: 'Twin kids born healthy',
    ),
    BreedingEvent(
      id: 'BE-004',
      animalId: 'S-001',
      animalType: 'sheep',
      eventType: 'lambing',
      serviceDate: '2024-03-01',
      serviceMethod: 'natural',
      sireName: 'Ram-02',
      sireBreed: 'Merino',
      expectedBirthDate: '2024-08-01',
      pregnancyResult: 'confirmed_pregnant',
    ),
  ];
}
