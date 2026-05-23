import '../models/feed_log.dart';
import 'record_data_source.dart';

class RecordMockDataSource implements RecordDataSource {
  @override
  Future<List<FeedLog>> getFeedLogs() async => _feedLogs;

  @override
  Future<void> addFeedLog(FeedLog log) async => _feedLogs.insert(0, log);

  // Mutable in-memory seed data
  final _feedLogs = <FeedLog>[
    FeedLog(
      id: 'FL-001',
      date: '2024-04-01',
      species: 'cattle',
      groupId: 'GRP-CATTLE-01',
      groupName: 'Herd A — Breeding cows',
      animalCount: 42,
      feedType: 'Lucerne hay',
      quantityKg: 420.0,
      costZar: 1512.0,
      recordedBy: 'Jan van der Berg',
    ),
    FeedLog(
      id: 'FL-002',
      date: '2024-04-01',
      species: 'sheep',
      groupId: 'GRP-SHEEP-02',
      groupName: 'Ewes — Pre-lambing',
      animalCount: 120,
      feedType: 'Ewe nut pellets (16% CP)',
      quantityKg: 180.0,
      costZar: 936.0,
      recordedBy: 'Jan van der Berg',
      notes: 'Supplementary feed — dryland pasture sparse',
    ),
    FeedLog(
      id: 'FL-003',
      date: '2024-04-02',
      species: 'cattle',
      groupId: 'GRP-CATTLE-01',
      groupName: 'Herd A — Breeding cows',
      animalCount: 42,
      feedType: 'Lucerne hay',
      quantityKg: 420.0,
      costZar: 1512.0,
      recordedBy: 'Sipho Dlamini',
    ),
    FeedLog(
      id: 'FL-004',
      date: '2024-04-03',
      species: 'goats',
      groupId: 'GRP-GOAT-01',
      groupName: 'Dairy goats — Milkers',
      animalCount: 28,
      feedType: 'Goat maintenance pellets',
      quantityKg: 84.0,
      costZar: 546.0,
      recordedBy: 'Jan van der Berg',
    ),
    FeedLog(
      id: 'FL-005',
      date: '2024-04-03',
      species: 'cattle',
      groupId: 'GRP-CATTLE-02',
      groupName: 'Feedlot steers',
      animalCount: 18,
      feedType: 'Maize silage',
      quantityKg: 900.0,
      costZar: 2250.0,
      recordedBy: 'Sipho Dlamini',
      notes: 'Phase 2 finishing ration',
    ),
  ];
}
