import '../models/movement_record.dart';
import 'traceability_data_source.dart';

class TraceabilityMockDataSource implements TraceabilityDataSource {
  @override
  Future<List<MovementRecord>> getMovementRecords() async => _movementRecords;

  @override
  Future<void> addMovementRecord(MovementRecord record) async =>
      _movementRecords.insert(0, record);

  // Mutable in-memory seed data
  final _movementRecords = <MovementRecord>[
    MovementRecord(
      id: 'MV-001',
      farmId: 'FARM-001',
      movementDate: '2024-03-10',
      species: 'cattle',
      animalIds: ['C-001', 'C-002', 'C-003'],
      movementType: MovementType.farmToAuction,
      fromLocation: 'Green Valley Farm',
      toLocation: 'Midlands Livestock Auction',
      fromFarmRegistrationNo: 'DLRD-GT-12345',
      transporterName: 'SA Livestock Transport',
      vehicleRegNo: 'JHB 456 GP',
      permitNumber: 'B313-2024-0310-001',
      distanceKm: 85.0,
      rmisSubmitted: true,
      rmisSubmitDate: '2024-03-09',
      rmisTransactionId: 'RMIS-TXN-00091',
    ),
    MovementRecord(
      id: 'MV-002',
      farmId: 'FARM-001',
      movementDate: '2024-03-22',
      species: 'sheep',
      animalIds: ['S-004', 'S-005', 'S-006', 'S-007', 'S-008'],
      movementType: MovementType.farmToAbattoir,
      fromLocation: 'Green Valley Farm',
      toLocation: 'Estcourt Meat Processing',
      fromFarmRegistrationNo: 'DLRD-GT-12345',
      toFarmRegistrationNo: 'DLRD-KZN-99988',
      transporterName: 'Swift Agri Logistics',
      vehicleRegNo: 'PMB 789 KZN',
      permitNumber: 'B313-2024-0322-002',
      veterinaryHealthCertRef: 'VHC-2024-0322-55',
      distanceKm: 42.5,
      rmisSubmitted: true,
      rmisSubmitDate: '2024-03-21',
      rmisTransactionId: 'RMIS-TXN-00104',
    ),
    MovementRecord(
      id: 'MV-003',
      farmId: 'FARM-001',
      movementDate: '2024-04-05',
      species: 'cattle',
      animalIds: ['C-010', 'C-011'],
      movementType: MovementType.auctionToFarm,
      fromLocation: 'Harrismith Livestock Auction',
      toLocation: 'Green Valley Farm',
      toFarmRegistrationNo: 'DLRD-GT-12345',
      transporterName: 'Boland Vee Transport',
      vehicleRegNo: 'HRR 112 FS',
      permitNumber: 'B313-2024-0405-003',
      distanceKm: 130.0,
      rmisSubmitted: false,
      notes: 'Awaiting RMIS submission — permit received from auction house',
    ),
  ];
}
