import '../models/paddock.dart';
import 'settings_data_source.dart';

class SettingsMockDataSource implements SettingsDataSource {
  @override
  Future<List<Paddock>> getPaddocks() async => _paddocks;

  static const _paddocks = [
    Paddock(
      id: 'PAD-001',
      name: 'Camp 1 — Rynbos',
      areaHa: 12.5,
      campNumber: 'C1',
      status: 'occupied',
      currentAnimalCount: 32,
      forageType: 'Mixed sweet grassveld',
      waterSource: 'Earth dam',
      restPeriodDays: 45,
      species: ['cattle'],
      currentGroupId: 'GRP-CATTLE-01',
      currentGroupName: 'Herd A — Breeding cows',
      lastGrazed: '2024-02-01',
      gpsLat: -29.4512,
      gpsLng: 29.8734,
    ),
    Paddock(
      id: 'PAD-002',
      name: 'Camp 2 — Lusern land',
      areaHa: 5.8,
      campNumber: 'C2',
      status: 'resting',
      currentAnimalCount: 0,
      forageType: 'Lucerne pasture (irrigated)',
      waterSource: 'Borehole + trough',
      restPeriodDays: 30,
      species: ['cattle', 'sheep'],
      lastGrazed: '2024-03-15',
      gpsLat: -29.4489,
      gpsLng: 29.8801,
      notes: 'Resting — allow 30 days regrowth before re-entry',
    ),
    Paddock(
      id: 'PAD-003',
      name: 'Sheep kraal — lambing',
      areaHa: 2.1,
      campNumber: 'K1',
      status: 'occupied',
      currentAnimalCount: 120,
      forageType: 'Natural veldt',
      waterSource: 'Trough (reticulated)',
      restPeriodDays: 60,
      species: ['sheep'],
      currentGroupId: 'GRP-SHEEP-02',
      currentGroupName: 'Ewes — Pre-lambing',
      lastGrazed: '2024-01-20',
      gpsLat: -29.4601,
      gpsLng: 29.8650,
    ),
    Paddock(
      id: 'PAD-004',
      name: 'Back camp — fallow',
      areaHa: 18.0,
      campNumber: 'C4',
      status: 'empty',
      currentAnimalCount: 0,
      forageType: 'Dryland mixed bushveld',
      waterSource: 'Seasonal stream',
      restPeriodDays: 90,
      species: [],
      lastGrazed: '2023-11-30',
      notes: 'Awaiting spring flush — do not graze until October',
    ),
  ];
}
