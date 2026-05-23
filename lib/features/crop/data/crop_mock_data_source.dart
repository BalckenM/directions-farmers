import 'crop_data_source.dart';
import '../models/advisory_content.dart';
import '../models/calendar_event.dart';
import '../models/crop.dart';
import '../models/crop_category.dart';
import '../models/crop_expense.dart';
import '../models/crop_field.dart';
import '../models/crop_sale.dart';
import '../models/crop_season.dart';
import '../models/crop_task.dart';
import '../models/harvest_record.dart';
import '../models/pest_observation.dart';
import '../models/planting_plan.dart';
import '../models/spray_record.dart';
import '../models/weather_alert.dart';

class CropMockDataSource implements CropDataSource {
  static const _farmId = 'FARM-001';
  static const _fieldId1 = 'FIELD-001';
  static const _fieldId2 = 'FIELD-002';
  static const _seasonId = 'SEASON-001';
  static const _planId1 = 'PLAN-001';
  static const _planId2 = 'PLAN-002';
  static const _fieldId3 = 'FIELD-003';
  static const _fieldId4 = 'FIELD-004';
  static const _fieldId5 = 'FIELD-005';
  static const _seasonId2 = 'SEASON-002';
  static const _planId3 = 'PLAN-003';
  static const _planId4 = 'PLAN-004';
  static const _planId5 = 'PLAN-005';
  static const _planId6 = 'PLAN-006';
  // Category IDs
  static const _catIdCereals = 'CAT-CEREALS';
  static const _catIdLegumes = 'CAT-LEGUMES';
  static const _catIdVegetables = 'CAT-VEGETABLES';
  static const _catIdRoots = 'CAT-ROOTS';
  static const _catIdOilseeds = 'CAT-OILSEEDS';
  // Crop IDs — Cereals
  static const _cropIdMaize = 'CROP-MAIZE';
  static const _cropIdWheat = 'CROP-WHEAT';
  static const _cropIdSorghum = 'CROP-SORGHUM';
  static const _cropIdBarley = 'CROP-BARLEY';
  static const _cropIdMillet = 'CROP-MILLET';
  // Crop IDs — Legumes
  static const _cropIdSoya = 'CROP-SOYA';
  static const _cropIdGroundnut = 'CROP-GROUNDNUT';
  static const _cropIdDryBean = 'CROP-DRYBEAN';
  static const _cropIdCowpea = 'CROP-COWPEA';
  // Crop IDs — Vegetables
  static const _cropIdTomato = 'CROP-TOMATO';
  static const _cropIdOnion = 'CROP-ONION';
  static const _cropIdCabbage = 'CROP-CABBAGE';
  static const _cropIdSpinach = 'CROP-SPINACH';
  // Crop IDs — Root Crops
  static const _cropIdPotato = 'CROP-POTATO';
  static const _cropIdSweetPotato = 'CROP-SWEETPOTATO';
  // Crop IDs — Oil Seeds
  static const _cropIdSunflower = 'CROP-SUNFLOWER';
  static const _cropIdCanola = 'CROP-CANOLA';

  // ── Categories ────────────────────────────────────────────────────────────
  static const _categories = <CropCategory>[
    CropCategory(
      id: _catIdCereals,
      name: 'Cereals',
      icon: '🌽',
      color: '#F5A623',
      cropCount: 5,
      description: 'Grain crops including maize, wheat and sorghum',
    ),
    CropCategory(
      id: _catIdLegumes,
      name: 'Legumes',
      icon: '🫘',
      color: '#4CAF50',
      cropCount: 4,
      description: 'Nitrogen-fixing crops including soya and groundnuts',
    ),
    CropCategory(
      id: _catIdVegetables,
      name: 'Vegetables',
      icon: '🥦',
      color: '#66BB6A',
      cropCount: 4,
      description: 'Fresh vegetables for local market and household consumption',
    ),
    CropCategory(
      id: _catIdRoots,
      name: 'Root Crops',
      icon: '🥔',
      color: '#8D6E63',
      cropCount: 2,
      description: 'Underground storage crops including potato and sweet potato',
    ),
    CropCategory(
      id: _catIdOilseeds,
      name: 'Oil Seeds',
      icon: '🌻',
      color: '#FDD835',
      cropCount: 2,
      description: 'Crops grown for oil extraction including sunflower and canola',
    ),
  ];

  // ── Crops ─────────────────────────────────────────────────────────────────
  static const _crops = <Crop>[
    // ── Cereals (5) ──────────────────────────────────────────────────────
    Crop(
      id: _cropIdMaize,
      categoryId: _catIdCereals,
      name: 'Maize',
      scientificName: 'Zea mays',
      localNames: {'zu': 'Umbila', 'st': 'Poone'},
      maturityDaysMin: 90,
      maturityDaysMax: 130,
      plantingMonths: [10, 11, 12],
      harvestMonths: [3, 4, 5],
      waterRequirement: 'medium',
      rainfallMmMin: 450,
      rainfallMmMax: 800,
      suitableProvinces: ['Limpopo', 'Mpumalanga', 'North West'],
      soilTypes: ['loam', 'sandy_loam', 'clay_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 10.0,
      temperatureMaxC: 35.0,
      expectedYieldDrylandTHa: 3.5,
      expectedYieldIrrigatedTHa: 8.0,
      marketUse: ['food', 'feed', 'processing'],
      commonPests: ['stalk_borer', 'aphid', 'armyworm'],
      commonDiseases: ['grey_leaf_spot', 'northern_corn_leaf_blight'],
      fertilizerNKgHa: 120.0,
      fertilizerPKgHa: 30.0,
      fertilizerKKgHa: 30.0,
    ),
    Crop(
      id: _cropIdWheat,
      categoryId: _catIdCereals,
      name: 'Wheat',
      scientificName: 'Triticum aestivum',
      localNames: {'af': 'Koring', 'st': 'Korone'},
      maturityDaysMin: 110,
      maturityDaysMax: 150,
      plantingMonths: [5, 6, 7],
      harvestMonths: [10, 11, 12],
      waterRequirement: 'medium',
      rainfallMmMin: 350,
      rainfallMmMax: 700,
      suitableProvinces: ['Free State', 'Western Cape', 'Northern Cape'],
      soilTypes: ['loam', 'clay_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 5.0,
      temperatureMaxC: 28.0,
      expectedYieldDrylandTHa: 2.5,
      expectedYieldIrrigatedTHa: 5.5,
      marketUse: ['food', 'flour', 'export'],
      commonPests: ['russian_wheat_aphid', 'hessian_fly'],
      commonDiseases: ['stripe_rust', 'stem_rust', 'septoria'],
      fertilizerNKgHa: 90.0,
      fertilizerPKgHa: 25.0,
      fertilizerKKgHa: 20.0,
    ),
    Crop(
      id: _cropIdSorghum,
      categoryId: _catIdCereals,
      name: 'Sorghum',
      scientificName: 'Sorghum bicolor',
      localNames: {'zu': 'Amabele', 'st': 'Mabele'},
      maturityDaysMin: 100,
      maturityDaysMax: 140,
      plantingMonths: [10, 11, 12],
      harvestMonths: [3, 4, 5],
      waterRequirement: 'low',
      rainfallMmMin: 300,
      rainfallMmMax: 650,
      suitableProvinces: ['Limpopo', 'North West', 'KwaZulu-Natal'],
      soilTypes: ['loam', 'sandy_loam', 'clay'],
      farmType: ['dryland'],
      temperatureMinC: 15.0,
      temperatureMaxC: 38.0,
      expectedYieldDrylandTHa: 2.5,
      expectedYieldIrrigatedTHa: 5.0,
      marketUse: ['food', 'feed', 'brewing'],
      commonPests: ['stalk_borer', 'shoot_fly'],
      commonDiseases: ['head_smut', 'covered_kernel_smut'],
      fertilizerNKgHa: 80.0,
      fertilizerPKgHa: 20.0,
      fertilizerKKgHa: 20.0,
    ),
    Crop(
      id: _cropIdBarley,
      categoryId: _catIdCereals,
      name: 'Barley',
      scientificName: 'Hordeum vulgare',
      localNames: {'af': 'Gars'},
      maturityDaysMin: 90,
      maturityDaysMax: 120,
      plantingMonths: [5, 6],
      harvestMonths: [10, 11],
      waterRequirement: 'medium',
      rainfallMmMin: 300,
      rainfallMmMax: 600,
      suitableProvinces: ['Western Cape', 'Northern Cape', 'Free State'],
      soilTypes: ['loam', 'sandy_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 5.0,
      temperatureMaxC: 28.0,
      expectedYieldDrylandTHa: 2.0,
      expectedYieldIrrigatedTHa: 4.5,
      marketUse: ['malting', 'feed', 'brewing'],
      commonPests: ['aphid', 'thrips'],
      commonDiseases: ['powdery_mildew', 'net_blotch'],
      fertilizerNKgHa: 70.0,
      fertilizerPKgHa: 20.0,
      fertilizerKKgHa: 15.0,
    ),
    Crop(
      id: _cropIdMillet,
      categoryId: _catIdCereals,
      name: 'Pearl Millet',
      scientificName: 'Pennisetum glaucum',
      localNames: {'zu': 'Imfe', 'ts': 'Nyaluthi'},
      maturityDaysMin: 75,
      maturityDaysMax: 100,
      plantingMonths: [11, 12, 1],
      harvestMonths: [3, 4],
      waterRequirement: 'low',
      rainfallMmMin: 250,
      rainfallMmMax: 600,
      suitableProvinces: ['Limpopo', 'North West', 'KwaZulu-Natal'],
      soilTypes: ['sandy', 'sandy_loam', 'loam'],
      farmType: ['dryland'],
      temperatureMinC: 20.0,
      temperatureMaxC: 40.0,
      expectedYieldDrylandTHa: 1.8,
      marketUse: ['food', 'feed', 'beer'],
      commonPests: ['stalk_borer', 'midge'],
      commonDiseases: ['downy_mildew', 'ergot'],
      fertilizerNKgHa: 60.0,
      fertilizerPKgHa: 15.0,
      fertilizerKKgHa: 15.0,
    ),
    // ── Legumes (4) ──────────────────────────────────────────────────────
    Crop(
      id: _cropIdSoya,
      categoryId: _catIdLegumes,
      name: 'Soybean',
      scientificName: 'Glycine max',
      localNames: {'zu': 'Isoya'},
      maturityDaysMin: 100,
      maturityDaysMax: 140,
      plantingMonths: [11, 12],
      harvestMonths: [4, 5],
      waterRequirement: 'medium',
      rainfallMmMin: 500,
      rainfallMmMax: 900,
      suitableProvinces: ['Mpumalanga', 'KwaZulu-Natal', 'Free State'],
      soilTypes: ['loam', 'clay_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 15.0,
      temperatureMaxC: 30.0,
      expectedYieldDrylandTHa: 2.0,
      expectedYieldIrrigatedTHa: 3.5,
      marketUse: ['oil', 'feed', 'export'],
      commonPests: ['red_spider_mite', 'stink_bug'],
      commonDiseases: ['sudden_death_syndrome', 'rust'],
      fertilizerNKgHa: 20.0,
      fertilizerPKgHa: 30.0,
      fertilizerKKgHa: 30.0,
    ),
    Crop(
      id: _cropIdGroundnut,
      categoryId: _catIdLegumes,
      name: 'Groundnuts',
      scientificName: 'Arachis hypogaea',
      localNames: {'zu': 'Izindlubu', 'st': 'Ditloo'},
      maturityDaysMin: 90,
      maturityDaysMax: 130,
      plantingMonths: [10, 11, 12],
      harvestMonths: [3, 4],
      waterRequirement: 'medium',
      rainfallMmMin: 400,
      rainfallMmMax: 800,
      suitableProvinces: ['Limpopo', 'North West', 'KwaZulu-Natal'],
      soilTypes: ['sandy', 'sandy_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 20.0,
      temperatureMaxC: 35.0,
      expectedYieldDrylandTHa: 1.5,
      expectedYieldIrrigatedTHa: 3.0,
      marketUse: ['oil', 'food', 'export'],
      commonPests: ['aphid', 'thrips', 'leaf_miner'],
      commonDiseases: ['early_leaf_spot', 'late_leaf_spot', 'aflatoxin'],
      fertilizerNKgHa: 20.0,
      fertilizerPKgHa: 30.0,
      fertilizerKKgHa: 25.0,
    ),
    Crop(
      id: _cropIdDryBean,
      categoryId: _catIdLegumes,
      name: 'Dry Beans',
      scientificName: 'Phaseolus vulgaris',
      localNames: {'zu': 'Ubhontshisi', 'st': 'Phasola'},
      maturityDaysMin: 80,
      maturityDaysMax: 110,
      plantingMonths: [10, 11],
      harvestMonths: [2, 3],
      waterRequirement: 'medium',
      rainfallMmMin: 350,
      rainfallMmMax: 650,
      suitableProvinces: ['Mpumalanga', 'Free State', 'North West'],
      soilTypes: ['loam', 'sandy_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 12.0,
      temperatureMaxC: 32.0,
      expectedYieldDrylandTHa: 1.2,
      expectedYieldIrrigatedTHa: 2.5,
      marketUse: ['food', 'export'],
      commonPests: ['bean_beetle', 'aphid'],
      commonDiseases: ['common_mosaic', 'angular_leaf_spot'],
      fertilizerNKgHa: 20.0,
      fertilizerPKgHa: 25.0,
      fertilizerKKgHa: 20.0,
    ),
    Crop(
      id: _cropIdCowpea,
      categoryId: _catIdLegumes,
      name: 'Cowpeas',
      scientificName: 'Vigna unguiculata',
      localNames: {'zu': 'Indumba', 'ts': 'Nyawa'},
      maturityDaysMin: 60,
      maturityDaysMax: 90,
      plantingMonths: [10, 11, 12],
      harvestMonths: [1, 2, 3],
      waterRequirement: 'low',
      rainfallMmMin: 250,
      rainfallMmMax: 600,
      suitableProvinces: ['Limpopo', 'KwaZulu-Natal', 'Mpumalanga'],
      soilTypes: ['sandy', 'sandy_loam', 'loam'],
      farmType: ['dryland'],
      temperatureMinC: 20.0,
      temperatureMaxC: 37.0,
      expectedYieldDrylandTHa: 0.8,
      expectedYieldIrrigatedTHa: 1.8,
      marketUse: ['food', 'livestock_feed'],
      commonPests: ['aphid', 'thrips', 'pod_borer'],
      commonDiseases: ['cowpea_mosaic', 'cercospora_leaf_spot'],
      fertilizerNKgHa: 15.0,
      fertilizerPKgHa: 20.0,
      fertilizerKKgHa: 20.0,
    ),
    // ── Vegetables (4) ───────────────────────────────────────────────────
    Crop(
      id: _cropIdTomato,
      categoryId: _catIdVegetables,
      name: 'Tomato',
      scientificName: 'Solanum lycopersicum',
      localNames: {'zu': 'Ithomathi', 'st': 'Tamati'},
      maturityDaysMin: 70,
      maturityDaysMax: 100,
      plantingMonths: [8, 9, 10],
      harvestMonths: [11, 12, 1, 2],
      waterRequirement: 'high',
      rainfallMmMin: 600,
      rainfallMmMax: 1200,
      suitableProvinces: ['Limpopo', 'Mpumalanga', 'Western Cape'],
      soilTypes: ['loam', 'sandy_loam'],
      farmType: ['irrigated'],
      temperatureMinC: 15.0,
      temperatureMaxC: 32.0,
      expectedYieldIrrigatedTHa: 45.0,
      marketUse: ['fresh_market', 'processing', 'export'],
      commonPests: ['whitefly', 'red_spider_mite', 'thrips'],
      commonDiseases: ['early_blight', 'late_blight', 'fusarium_wilt'],
      fertilizerNKgHa: 150.0,
      fertilizerPKgHa: 80.0,
      fertilizerKKgHa: 200.0,
    ),
    Crop(
      id: _cropIdOnion,
      categoryId: _catIdVegetables,
      name: 'Onion',
      scientificName: 'Allium cepa',
      localNames: {'af': 'Ui', 'zu': 'Uyanyanisi'},
      maturityDaysMin: 100,
      maturityDaysMax: 150,
      plantingMonths: [5, 6, 7],
      harvestMonths: [10, 11, 12],
      waterRequirement: 'medium',
      rainfallMmMin: 350,
      rainfallMmMax: 700,
      suitableProvinces: ['Northern Cape', 'Western Cape', 'Free State'],
      soilTypes: ['loam', 'sandy_loam'],
      farmType: ['irrigated', 'dryland'],
      temperatureMinC: 10.0,
      temperatureMaxC: 30.0,
      expectedYieldIrrigatedTHa: 40.0,
      marketUse: ['fresh_market', 'export', 'processing'],
      commonPests: ['thrips', 'onion_fly'],
      commonDiseases: ['purple_blotch', 'downy_mildew', 'botrytis'],
      fertilizerNKgHa: 100.0,
      fertilizerPKgHa: 60.0,
      fertilizerKKgHa: 120.0,
    ),
    Crop(
      id: _cropIdCabbage,
      categoryId: _catIdVegetables,
      name: 'Cabbage',
      scientificName: 'Brassica oleracea var. capitata',
      localNames: {'zu': 'Ikhaphisi', 'st': 'Khabetjhe'},
      maturityDaysMin: 70,
      maturityDaysMax: 120,
      plantingMonths: [7, 8, 9],
      harvestMonths: [10, 11, 12, 1],
      waterRequirement: 'medium',
      rainfallMmMin: 380,
      rainfallMmMax: 750,
      suitableProvinces: ['KwaZulu-Natal', 'Eastern Cape', 'Free State'],
      soilTypes: ['loam', 'clay_loam'],
      farmType: ['irrigated', 'dryland'],
      temperatureMinC: 10.0,
      temperatureMaxC: 28.0,
      expectedYieldIrrigatedTHa: 50.0,
      marketUse: ['fresh_market', 'processing'],
      commonPests: ['diamondback_moth', 'aphid', 'cutworm'],
      commonDiseases: ['black_rot', 'clubroot', 'alternaria'],
      fertilizerNKgHa: 120.0,
      fertilizerPKgHa: 50.0,
      fertilizerKKgHa: 100.0,
    ),
    Crop(
      id: _cropIdSpinach,
      categoryId: _catIdVegetables,
      name: 'Spinach',
      scientificName: 'Spinacia oleracea',
      localNames: {'zu': 'Ispinitshi', 'st': 'Sipinashi'},
      maturityDaysMin: 40,
      maturityDaysMax: 60,
      plantingMonths: [2, 3, 4, 8, 9],
      harvestMonths: [4, 5, 6, 10, 11],
      waterRequirement: 'medium',
      rainfallMmMin: 300,
      rainfallMmMax: 650,
      suitableProvinces: ['Gauteng', 'Western Cape', 'KwaZulu-Natal'],
      soilTypes: ['loam', 'sandy_loam'],
      farmType: ['irrigated'],
      temperatureMinC: 8.0,
      temperatureMaxC: 25.0,
      expectedYieldIrrigatedTHa: 12.0,
      marketUse: ['fresh_market', 'processing'],
      commonPests: ['aphid', 'leaf_miner'],
      commonDiseases: ['downy_mildew', 'anthracnose'],
      fertilizerNKgHa: 80.0,
      fertilizerPKgHa: 30.0,
      fertilizerKKgHa: 60.0,
    ),
    // ── Root Crops (2) ───────────────────────────────────────────────────
    Crop(
      id: _cropIdPotato,
      categoryId: _catIdRoots,
      name: 'Potato',
      scientificName: 'Solanum tuberosum',
      localNames: {'af': 'Aartappel', 'zu': 'Amazambane'},
      maturityDaysMin: 90,
      maturityDaysMax: 130,
      plantingMonths: [7, 8, 9],
      harvestMonths: [11, 12, 1],
      waterRequirement: 'high',
      rainfallMmMin: 500,
      rainfallMmMax: 900,
      suitableProvinces: ['Limpopo', 'Free State', 'Western Cape'],
      soilTypes: ['sandy_loam', 'loam'],
      farmType: ['irrigated'],
      temperatureMinC: 8.0,
      temperatureMaxC: 25.0,
      expectedYieldIrrigatedTHa: 35.0,
      marketUse: ['fresh_market', 'processing', 'chips'],
      commonPests: ['potato_tuber_moth', 'aphid', 'cutworm'],
      commonDiseases: ['late_blight', 'early_blight', 'common_scab'],
      fertilizerNKgHa: 150.0,
      fertilizerPKgHa: 100.0,
      fertilizerKKgHa: 180.0,
    ),
    Crop(
      id: _cropIdSweetPotato,
      categoryId: _catIdRoots,
      name: 'Sweet Potato',
      scientificName: 'Ipomoea batatas',
      localNames: {'zu': 'Ubhatata', 'st': 'Patata'},
      maturityDaysMin: 100,
      maturityDaysMax: 140,
      plantingMonths: [10, 11, 12],
      harvestMonths: [3, 4, 5],
      waterRequirement: 'medium',
      rainfallMmMin: 400,
      rainfallMmMax: 800,
      suitableProvinces: ['KwaZulu-Natal', 'Limpopo', 'Eastern Cape'],
      soilTypes: ['sandy', 'sandy_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 18.0,
      temperatureMaxC: 35.0,
      expectedYieldDrylandTHa: 10.0,
      expectedYieldIrrigatedTHa: 20.0,
      marketUse: ['food', 'fresh_market', 'processing'],
      commonPests: ['sweet_potato_weevil', 'aphid'],
      commonDiseases: ['fusarium_wilt', 'black_rot'],
      fertilizerNKgHa: 60.0,
      fertilizerPKgHa: 40.0,
      fertilizerKKgHa: 80.0,
    ),
    // ── Oil Seeds (2) ─────────────────────────────────────────────────────
    Crop(
      id: _cropIdSunflower,
      categoryId: _catIdOilseeds,
      name: 'Sunflower',
      scientificName: 'Helianthus annuus',
      localNames: {'af': 'Sonneblom', 'zu': 'Ifulawa'},
      maturityDaysMin: 100,
      maturityDaysMax: 130,
      plantingMonths: [11, 12],
      harvestMonths: [4, 5],
      waterRequirement: 'low',
      rainfallMmMin: 300,
      rainfallMmMax: 650,
      suitableProvinces: ['Free State', 'North West', 'Limpopo'],
      soilTypes: ['loam', 'sandy_loam', 'clay_loam'],
      farmType: ['dryland'],
      temperatureMinC: 15.0,
      temperatureMaxC: 35.0,
      expectedYieldDrylandTHa: 1.5,
      expectedYieldIrrigatedTHa: 2.5,
      marketUse: ['oil', 'feed', 'export'],
      commonPests: ['sunflower_beetle', 'aphid', 'bollworm'],
      commonDiseases: ['sclerotinia', 'alternaria_blight', 'downy_mildew'],
      fertilizerNKgHa: 60.0,
      fertilizerPKgHa: 25.0,
      fertilizerKKgHa: 25.0,
    ),
    Crop(
      id: _cropIdCanola,
      categoryId: _catIdOilseeds,
      name: 'Canola',
      scientificName: 'Brassica napus',
      localNames: {'af': 'Kanola'},
      maturityDaysMin: 120,
      maturityDaysMax: 160,
      plantingMonths: [5, 6],
      harvestMonths: [10, 11],
      waterRequirement: 'medium',
      rainfallMmMin: 350,
      rainfallMmMax: 700,
      suitableProvinces: ['Western Cape', 'Northern Cape'],
      soilTypes: ['loam', 'clay_loam'],
      farmType: ['dryland', 'irrigated'],
      temperatureMinC: 5.0,
      temperatureMaxC: 27.0,
      expectedYieldDrylandTHa: 1.4,
      expectedYieldIrrigatedTHa: 2.8,
      marketUse: ['oil', 'biofuel', 'animal_feed'],
      commonPests: ['aphid', 'diamond_back_moth', 'bagrada_bug'],
      commonDiseases: ['sclerotinia', 'blackleg', 'alternaria'],
      fertilizerNKgHa: 100.0,
      fertilizerPKgHa: 30.0,
      fertilizerKKgHa: 25.0,
    ),
  ];

  // ── Fields ────────────────────────────────────────────────────────────────
  static const _fields = <CropField>[
    CropField(
      id: _fieldId1,
      farmId: _farmId,
      name: 'North Block',
      sizeHectares: 15.5,
      soilType: 'loam',
      irrigationType: 'dryland',
      priorCropId: _cropIdSoya,
      gpsCenter: CropFieldGps(lat: -25.1540, lng: 29.4320),
    ),
    CropField(
      id: _fieldId2,
      farmId: _farmId,
      name: 'South Block',
      sizeHectares: 10.0,
      soilType: 'sandy_loam',
      irrigationType: 'irrigated',
      priorCropId: _cropIdMaize,
      gpsCenter: CropFieldGps(lat: -25.1620, lng: 29.4350),
    ),
    CropField(
      id: _fieldId3,
      farmId: _farmId,
      name: 'East Block',
      sizeHectares: 8.0,
      soilType: 'clay_loam',
      irrigationType: 'dryland',
      priorCropId: _cropIdSorghum,
      notes: 'Prone to waterlogging — avoid heavy clay areas near fence line',
    ),
    CropField(
      id: _fieldId4,
      farmId: _farmId,
      name: 'West Block',
      sizeHectares: 12.0,
      soilType: 'sandy_loam',
      irrigationType: 'irrigated',
      priorCropId: _cropIdWheat,
      gpsCenter: CropFieldGps(lat: -25.1480, lng: 29.4260),
    ),
    CropField(
      id: _fieldId5,
      farmId: _farmId,
      name: 'Garden Plot',
      sizeHectares: 2.5,
      soilType: 'loam',
      irrigationType: 'irrigated',
      notes: 'Smallholder vegetable production — shared with workers',
    ),
  ];

  // ── Seasons ───────────────────────────────────────────────────────────────
  static final _seasons = <CropSeason>[
    CropSeason(
      id: _seasonId,
      farmId: _farmId,
      name: '2024/25 Summer',
      seasonType: 'summer',
      startDate: DateTime(2024, 10, 1),
      endDate: DateTime(2025, 5, 31),
      status: 'active',
      notes: 'Good rainfall forecast — target dryland yield of 3.5 t/ha',
    ),
    CropSeason(
      id: _seasonId2,
      farmId: _farmId,
      name: '2023/24 Summer',
      seasonType: 'summer',
      startDate: DateTime(2023, 10, 1),
      endDate: DateTime(2024, 5, 31),
      status: 'completed',
      notes: 'Below-average season — drought in January reduced yields by 15%',
    ),
  ];

  // ── Planting Plans ────────────────────────────────────────────────────────
  static final _plans = <PlantingPlan>[
    PlantingPlan(
      id: _planId1,
      fieldId: _fieldId1,
      seasonId: _seasonId,
      cropId: _cropIdMaize,
      plannedPlantingDate: DateTime(2024, 11, 15),
      plannedHarvestDate: DateTime(2025, 4, 10),
      targetYieldTHa: 7.5,
      status: 'active',
      createdAt: DateTime(2024, 10, 10),
    ),
    PlantingPlan(
      id: _planId2,
      fieldId: _fieldId2,
      seasonId: _seasonId,
      cropId: _cropIdSoya,
      plannedPlantingDate: DateTime(2024, 11, 20),
      plannedHarvestDate: DateTime(2025, 4, 25),
      targetYieldTHa: 3.0,
      status: 'active',
      createdAt: DateTime(2024, 10, 10),
    ),
    PlantingPlan(
      id: _planId3,
      fieldId: _fieldId3,
      seasonId: _seasonId,
      cropId: _cropIdSorghum,
      plannedPlantingDate: DateTime(2024, 11, 25),
      plannedHarvestDate: DateTime(2025, 4, 20),
      targetYieldTHa: 2.5,
      status: 'active',
      createdAt: DateTime(2024, 10, 15),
    ),
    PlantingPlan(
      id: _planId4,
      fieldId: _fieldId4,
      seasonId: _seasonId2,
      cropId: _cropIdWheat,
      plannedPlantingDate: DateTime(2023, 6, 10),
      plannedHarvestDate: DateTime(2023, 11, 15),
      targetYieldTHa: 4.5,
      status: 'completed',
      createdAt: DateTime(2023, 5, 20),
    ),
    PlantingPlan(
      id: _planId5,
      fieldId: _fieldId5,
      seasonId: _seasonId,
      cropId: _cropIdCabbage,
      plannedPlantingDate: DateTime(2025, 2, 1),
      plannedHarvestDate: DateTime(2025, 5, 15),
      targetYieldTHa: 40.0,
      status: 'active',
      createdAt: DateTime(2025, 1, 20),
    ),
    PlantingPlan(
      id: _planId6,
      fieldId: _fieldId5,
      seasonId: _seasonId,
      cropId: _cropIdTomato,
      plannedPlantingDate: DateTime(2025, 1, 10),
      plannedHarvestDate: DateTime(2025, 5, 30),
      targetYieldTHa: 60.0,
      status: 'active',
      createdAt: DateTime(2025, 1, 5),
    ),
  ];

  // ── Calendar Events ───────────────────────────────────────────────────────
  static final _calendarEvents = <CalendarEvent>[
    CalendarEvent(
      id: 'CE-001',
      planId: _planId1,
      fieldId: _fieldId1,
      activityType: CalendarActivityType.planting,
      title: 'Maize Planting — North Block',
      scheduledDate: DateTime(2024, 11, 15),
      completedDate: DateTime(2024, 11, 16),
      status: 'completed',
      reminderDaysBefore: 3,
    ),
    CalendarEvent(
      id: 'CE-002',
      planId: _planId1,
      fieldId: _fieldId1,
      activityType: CalendarActivityType.fertilizerApplication,
      title: 'Top Dressing — North Block',
      scheduledDate: DateTime(2025, 1, 10),
      status: 'pending',
      reminderDaysBefore: 2,
    ),
    CalendarEvent(
      id: 'CE-003',
      planId: _planId2,
      fieldId: _fieldId2,
      activityType: CalendarActivityType.planting,
      title: 'Soya Planting — South Block',
      scheduledDate: DateTime(2024, 11, 20),
      completedDate: DateTime(2024, 11, 21),
      status: 'completed',
      reminderDaysBefore: 3,
    ),
    CalendarEvent(
      id: 'CE-004',
      planId: _planId1,
      fieldId: _fieldId1,
      activityType: CalendarActivityType.landPrep,
      title: 'Deep Rip & Lime — North Block',
      scheduledDate: DateTime(2024, 10, 20),
      completedDate: DateTime(2024, 10, 22),
      status: 'completed',
      notes: 'Applied 1.5 t/ha agricultural lime',
      reminderDaysBefore: 5,
    ),
    CalendarEvent(
      id: 'CE-005',
      planId: _planId2,
      fieldId: _fieldId2,
      activityType: CalendarActivityType.scouting,
      title: 'Red Spider Mite Scouting — South Block',
      scheduledDate: DateTime(2025, 1, 20),
      status: 'pending',
      reminderDaysBefore: 1,
    ),
    CalendarEvent(
      id: 'CE-006',
      planId: _planId1,
      fieldId: _fieldId1,
      activityType: CalendarActivityType.germinationCheck,
      title: 'Germination Count — North Block',
      scheduledDate: DateTime(2024, 11, 26),
      completedDate: DateTime(2024, 11, 26),
      status: 'completed',
      notes: '92% germination — within target range',
      reminderDaysBefore: 1,
    ),
    CalendarEvent(
      id: 'CE-007',
      planId: _planId3,
      fieldId: _fieldId3,
      activityType: CalendarActivityType.planting,
      title: 'Sorghum Planting — East Block',
      scheduledDate: DateTime(2024, 11, 25),
      completedDate: DateTime(2024, 11, 27),
      status: 'completed',
      reminderDaysBefore: 3,
    ),
    CalendarEvent(
      id: 'CE-008',
      planId: _planId1,
      fieldId: _fieldId1,
      activityType: CalendarActivityType.harvest,
      title: 'Maize Harvest — North Block',
      scheduledDate: DateTime(2025, 4, 10),
      status: 'pending',
      notes: 'Book combine harvester 2 weeks in advance',
      reminderDaysBefore: 14,
    ),
    CalendarEvent(
      id: 'CE-009',
      planId: _planId2,
      fieldId: _fieldId2,
      activityType: CalendarActivityType.irrigation,
      title: 'Irrigation Scheduling Check — South Block',
      scheduledDate: DateTime(2025, 1, 8),
      completedDate: DateTime(2025, 1, 8),
      status: 'completed',
      notes: 'Adjusted drip schedule — 30mm applied',
      reminderDaysBefore: 1,
    ),
    CalendarEvent(
      id: 'CE-010',
      planId: _planId4,
      fieldId: _fieldId4,
      activityType: CalendarActivityType.postHarvest,
      title: 'Stubble Management — West Block',
      scheduledDate: DateTime(2023, 11, 25),
      completedDate: DateTime(2023, 11, 28),
      status: 'completed',
      notes: 'Baled straw — 45 bales sold',
      reminderDaysBefore: 5,
    ),
  ];

  // ── Tasks ─────────────────────────────────────────────────────────────────
  static final _tasks = <CropTask>[
    CropTask(
      id: 'TASK-001',
      farmId: _farmId,
      fieldId: _fieldId1,
      planId: _planId1,
      title: 'Apply top dressing fertilizer',
      description: 'Apply 120 kg/ha LAN to North Block',
      dueDate: DateTime(2025, 1, 10),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      createdAt: DateTime(2024, 12, 1),
    ),
    CropTask(
      id: 'TASK-002',
      farmId: _farmId,
      fieldId: _fieldId2,
      planId: _planId2,
      title: 'Scout for red spider mite',
      dueDate: DateTime(2025, 1, 20),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdAt: DateTime(2024, 12, 15),
    ),
    CropTask(
      id: 'TASK-003',
      farmId: _farmId,
      fieldId: _fieldId2,
      planId: _planId2,
      title: 'Apply pre-emergence herbicide',
      description: 'Apply S-metolachlor 960 EC at 1.5 L/ha',
      dueDate: DateTime(2024, 11, 22),
      priority: TaskPriority.high,
      status: TaskStatus.completed,
      assignedTo: 'Sipho Nkosi',
      createdAt: DateTime(2024, 11, 18),
      completedAt: DateTime(2024, 11, 22),
    ),
    CropTask(
      id: 'TASK-004',
      farmId: _farmId,
      fieldId: _fieldId4,
      title: 'Service centre-pivot irrigation system',
      description: 'Annual service — check nozzles, seals and pressure settings',
      dueDate: DateTime(2025, 1, 15),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdAt: DateTime(2024, 12, 20),
    ),
    CropTask(
      id: 'TASK-005',
      farmId: _farmId,
      title: 'Book combine harvester — North Block',
      description: 'Contact Rautenbach Harvesting. Maize harvest estimate: 10 April 2025',
      dueDate: DateTime(2025, 2, 28),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      createdAt: DateTime(2025, 1, 2),
    ),
    CropTask(
      id: 'TASK-006',
      farmId: _farmId,
      fieldId: _fieldId1,
      planId: _planId1,
      title: 'Soil sampling — North Block',
      description: 'Collect 20 composite samples for pH and nutrient analysis',
      dueDate: DateTime(2025, 5, 30),
      priority: TaskPriority.low,
      status: TaskStatus.pending,
      assignedTo: 'James Mahlangu',
      createdAt: DateTime(2025, 1, 5),
    ),
    CropTask(
      id: 'TASK-007',
      farmId: _farmId,
      fieldId: _fieldId3,
      planId: _planId3,
      title: 'Weeding — East Block',
      description: 'Hand weed inter-row in sorghum before canopy closure',
      dueDate: DateTime(2025, 1, 5),
      priority: TaskPriority.medium,
      status: TaskStatus.overdue,
      createdAt: DateTime(2024, 12, 20),
    ),
    CropTask(
      id: 'TASK-008',
      farmId: _farmId,
      title: 'Renew crop insurance policy',
      description: 'Contact Agri SA Insurance — current policy expires 28 Feb 2025',
      dueDate: DateTime(2025, 2, 20),
      priority: TaskPriority.urgent,
      status: TaskStatus.pending,
      createdAt: DateTime(2025, 1, 10),
    ),
  ];

  // ── Weather Alerts ────────────────────────────────────────────────────────
  static final _weatherAlerts = <WeatherAlert>[
    WeatherAlert(
      id: 'WA-001',
      farmId: _farmId,
      alertType: WeatherAlertType.heatStress,
      severity: 'medium',
      title: 'Heat Stress Warning',
      message: 'Temperatures expected to exceed 35°C. Ensure adequate irrigation.',
      issuedAt: DateTime(2025, 1, 5),
      validUntil: DateTime(2025, 1, 10),
      actionRequired: true,
      cropIdsAffected: [_cropIdMaize],
    ),
    WeatherAlert(
      id: 'WA-002',
      farmId: _farmId,
      alertType: WeatherAlertType.rainForecast,
      severity: 'low',
      title: 'Rain Forecast — 35–50 mm Expected',
      message: '35–50 mm rainfall expected over the next 48 hours. Good for dryland maize at V6 stage.',
      issuedAt: DateTime(2025, 1, 12),
      validUntil: DateTime(2025, 1, 14),
      actionRequired: false,
      cropIdsAffected: [_cropIdMaize, _cropIdSorghum],
    ),
    WeatherAlert(
      id: 'WA-003',
      farmId: _farmId,
      alertType: WeatherAlertType.spraySuitable,
      severity: 'low',
      title: 'Suitable Spraying Window — Tomorrow Morning',
      message: 'Wind speed below 15 km/h forecast 06:00–10:00. Temperature 18–22°C. Ideal spraying conditions.',
      issuedAt: DateTime(2025, 1, 18),
      validUntil: DateTime(2025, 1, 19),
      actionRequired: false,
      cropIdsAffected: [_cropIdMaize, _cropIdSoya, _cropIdSorghum],
    ),
  ];

  // ── Pest Observations ─────────────────────────────────────────────────────
  static final _pests = <PestObservation>[
    PestObservation(
      id: 'PEST-001',
      planId: _planId1,
      fieldId: _fieldId1,
      observedDate: DateTime(2025, 1, 3),
      pestName: 'Stalk Borer',
      category: 'insect',
      severity: 'low',
      description: 'Early instar larvae observed on 5% of plants',
      recommendedAction: 'Monitor. Apply insecticide if threshold exceeded.',
      status: 'open',
    ),
    PestObservation(
      id: 'PEST-002',
      planId: _planId2,
      fieldId: _fieldId2,
      observedDate: DateTime(2025, 1, 8),
      pestName: 'Red Spider Mite',
      category: 'mite',
      severity: 'medium',
      description: 'Stippling on leaves, webbing under leaflets on approx 15% of plants',
      recommendedAction: 'Apply abamectin 1.8% EC at 500 ml/ha. Ensure thorough coverage of undersides.',
      followUpDate: DateTime(2025, 1, 22),
      status: 'open',
    ),
    PestObservation(
      id: 'PEST-003',
      planId: _planId1,
      fieldId: _fieldId1,
      observedDate: DateTime(2024, 12, 10),
      pestName: 'Armyworm',
      category: 'insect',
      severity: 'high',
      description: 'Defoliation on 30% of plants in south corner — mass emergence',
      recommendedAction: 'Immediate application of chlorpyrifos 480 EC at 1 L/ha',
      followUpDate: DateTime(2024, 12, 17),
      status: 'treated',
    ),
    PestObservation(
      id: 'PEST-004',
      planId: _planId3,
      fieldId: _fieldId3,
      observedDate: DateTime(2025, 1, 5),
      pestName: 'Shoot Fly',
      category: 'insect',
      severity: 'low',
      description: 'Dead heart symptoms on 3% of sorghum seedlings in north row',
      recommendedAction: 'Monitor — below economic threshold of 10%. No action required.',
      status: 'resolved',
    ),
  ];

  // ── Spray Records ─────────────────────────────────────────────────────────
  static final _sprays = <SprayRecord>[
    SprayRecord(
      id: 'SPRAY-001',
      fieldId: _fieldId2,
      sprayDate: DateTime(2024, 12, 20),
      productName: 'Glyphosate 360',
      dosagePerHa: 2.5,
      areaSprayedHa: 10.0,
      applicatorName: 'John Dlamini',
      withholdingDays: 7,
      reEntryDate: DateTime(2024, 12, 27),
      outcome: 'Effective — 95% weed control',
    ),
    SprayRecord(
      id: 'SPRAY-002',
      pestObservationId: 'PEST-003',
      fieldId: _fieldId1,
      sprayDate: DateTime(2024, 12, 11),
      productName: 'Chlorpyrifos 480 EC',
      dosagePerHa: 1.0,
      areaSprayedHa: 15.5,
      applicatorName: 'Sipho Nkosi',
      withholdingDays: 21,
      reEntryDate: DateTime(2024, 12, 14),
      outcome: 'Armyworm population eliminated — no residual pressure',
    ),
    SprayRecord(
      id: 'SPRAY-003',
      fieldId: _fieldId3,
      sprayDate: DateTime(2024, 12, 5),
      productName: 'Atrazine 500 SC',
      dosagePerHa: 3.0,
      areaSprayedHa: 8.0,
      applicatorName: 'James Mahlangu',
      withholdingDays: 60,
      reEntryDate: DateTime(2024, 12, 8),
      outcome: 'Good broadleaf weed control achieved',
    ),
  ];

  // ── Expenses ──────────────────────────────────────────────────────────────
  static final _expenses = <CropExpense>[
    CropExpense(
      id: 'EXP-001',
      farmId: _farmId,
      fieldId: _fieldId1,
      planId: _planId1,
      category: ExpenseCategory.seed,
      description: 'DKC 80-30 Maize Seed — 25 kg bags × 12',
      amountZar: 7200.0,
      date: DateTime(2024, 11, 1),
      supplier: 'Monsanto SA',
      quantity: 300.0,
      unit: 'kg',
    ),
    CropExpense(
      id: 'EXP-002',
      farmId: _farmId,
      fieldId: _fieldId1,
      planId: _planId1,
      category: ExpenseCategory.fertilizer,
      description: '5:2:2 Base fertilizer',
      amountZar: 12500.0,
      date: DateTime(2024, 11, 10),
      supplier: 'Omnia Group',
      quantity: 1860.0,
      unit: 'kg',
    ),
    CropExpense(
      id: 'EXP-003',
      farmId: _farmId,
      fieldId: _fieldId2,
      planId: _planId2,
      category: ExpenseCategory.seed,
      description: 'Roundup Ready Soya SNK 2863R',
      amountZar: 4800.0,
      date: DateTime(2024, 11, 5),
      supplier: 'Pioneer Seeds',
      quantity: 80.0,
      unit: 'kg',
    ),
    CropExpense(
      id: 'EXP-004',
      farmId: _farmId,
      fieldId: _fieldId2,
      planId: _planId2,
      category: ExpenseCategory.chemical,
      description: 'Glyphosate 360 — pre-emergence herbicide',
      amountZar: 1350.0,
      date: DateTime(2024, 12, 18),
      supplier: 'Croplife SA',
      quantity: 30.0,
      unit: 'L',
    ),
    CropExpense(
      id: 'EXP-005',
      farmId: _farmId,
      fieldId: _fieldId1,
      planId: _planId1,
      category: ExpenseCategory.fertilizer,
      description: 'LAN 28% — top dressing',
      amountZar: 9600.0,
      date: DateTime(2025, 1, 10),
      supplier: 'Omnia Agri',
      quantity: 1860.0,
      unit: 'kg',
    ),
    CropExpense(
      id: 'EXP-006',
      farmId: _farmId,
      fieldId: _fieldId1,
      planId: _planId1,
      category: ExpenseCategory.chemical,
      description: 'Chlorpyrifos 480 EC — armyworm control',
      amountZar: 2325.0,
      date: DateTime(2024, 12, 11),
      supplier: 'Croplife SA',
      quantity: 15.5,
      unit: 'L',
    ),
    CropExpense(
      id: 'EXP-007',
      farmId: _farmId,
      category: ExpenseCategory.fuel,
      description: 'Diesel — planting operations',
      amountZar: 6800.0,
      date: DateTime(2024, 11, 20),
      supplier: 'Total Energies',
      quantity: 400.0,
      unit: 'L',
    ),
    CropExpense(
      id: 'EXP-008',
      farmId: _farmId,
      category: ExpenseCategory.labor,
      description: 'Seasonal labour — planting gang × 8 workers',
      amountZar: 5600.0,
      date: DateTime(2024, 11, 15),
      quantity: 8.0,
      unit: 'days',
    ),
  ];

  // ── Harvest Records ───────────────────────────────────────────────────────
  static final _harvests = <HarvestRecord>[
    HarvestRecord(
      id: 'HARV-001',
      planId: _planId1,
      fieldId: _fieldId1,
      cropId: _cropIdMaize,
      harvestDate: DateTime(2024, 4, 10),
      actualYieldTons: 116.25,
      areaHarvestedHa: 15.5,
      yieldTHa: 7.5,
      qualityGrade: 'Grade 1',
      moisturePercent: 14.5,
      storageLocation: 'Silo A',
    ),
    HarvestRecord(
      id: 'HARV-002',
      planId: _planId2,
      fieldId: _fieldId2,
      cropId: _cropIdSoya,
      harvestDate: DateTime(2025, 4, 25),
      actualYieldTons: 28.0,
      areaHarvestedHa: 10.0,
      yieldTHa: 2.8,
      qualityGrade: 'Grade 1',
      moisturePercent: 13.0,
      storageLocation: 'Silo B',
    ),
    HarvestRecord(
      id: 'HARV-003',
      planId: _planId4,
      fieldId: _fieldId4,
      cropId: _cropIdWheat,
      harvestDate: DateTime(2023, 11, 15),
      actualYieldTons: 51.6,
      areaHarvestedHa: 12.0,
      yieldTHa: 4.3,
      qualityGrade: 'Grade 2',
      moisturePercent: 12.5,
      storageLocation: 'On-farm silo',
      notes: 'Slightly below target — heat stress in November reduced grain fill',
    ),
    HarvestRecord(
      id: 'HARV-004',
      planId: _planId3,
      fieldId: _fieldId3,
      cropId: _cropIdSorghum,
      harvestDate: DateTime(2025, 4, 20),
      actualYieldTons: 18.0,
      areaHarvestedHa: 8.0,
      yieldTHa: 2.25,
      qualityGrade: 'Grade 1',
      moisturePercent: 13.5,
      storageLocation: 'Buyer pickup',
    ),
  ];

  // ── Sales ─────────────────────────────────────────────────────────────────
  static final _sales = <CropSale>[
    CropSale(
      id: 'SALE-001',
      harvestId: 'HARV-001',
      farmId: _farmId,
      cropId: _cropIdMaize,
      saleDate: DateTime(2024, 4, 20),
      quantityTons: 100.0,
      pricePerTonZar: 3200.0,
      totalAmountZar: 320000.0,
      buyer: 'Grain SA Co-op',
      paymentStatus: 'paid',
    ),
    CropSale(
      id: 'SALE-002',
      harvestId: 'HARV-001',
      farmId: _farmId,
      cropId: _cropIdMaize,
      saleDate: DateTime(2024, 5, 15),
      quantityTons: 16.25,
      pricePerTonZar: 3100.0,
      totalAmountZar: 50375.0,
      buyer: 'Local feedlot',
      paymentStatus: 'paid',
    ),
    CropSale(
      id: 'SALE-003',
      harvestId: 'HARV-002',
      farmId: _farmId,
      cropId: _cropIdSoya,
      saleDate: DateTime(2025, 5, 5),
      quantityTons: 28.0,
      pricePerTonZar: 7200.0,
      totalAmountZar: 201600.0,
      buyer: 'NWK Agri',
      paymentStatus: 'pending',
    ),
    CropSale(
      id: 'SALE-004',
      harvestId: 'HARV-003',
      farmId: _farmId,
      cropId: _cropIdWheat,
      saleDate: DateTime(2023, 11, 20),
      quantityTons: 51.6,
      pricePerTonZar: 5400.0,
      totalAmountZar: 278640.0,
      buyer: 'Pioneer Foods Milling',
      paymentStatus: 'paid',
    ),
  ];

  // ── Advisory ──────────────────────────────────────────────────────────────
  static final _advisory = <AdvisoryContent>[
    AdvisoryContent(
      id: 'ADV-001',
      category: 'pest_guide',
      cropId: _cropIdMaize,
      province: 'Limpopo',
      title: 'Managing Stalk Borer in Maize',
      summary: 'Early scouting and threshold-based intervention reduces crop loss.',
      body: 'Scout from V3 stage. Economic threshold is 20% plant damage. '
          'Apply cyantraniliprole or chlorpyrifos at whorl stage if threshold exceeded.',
      tags: ['stalk_borer', 'maize', 'IPM'],
      language: 'en',
      publishedAt: DateTime(2024, 10, 1),
    ),
    AdvisoryContent(
      id: 'ADV-002',
      category: 'crop_tip',
      cropId: _cropIdSoya,
      title: 'Soybean Inoculation Best Practice',
      summary: 'Inoculating soybean seed with Bradyrhizobium can replace up to 200 kg N/ha.',
      body: 'Use fresh inoculant applied in cool conditions. Avoid direct sunlight '
          'on treated seed. Plant within 24 hours of treatment for best results.',
      tags: ['soybean', 'inoculation', 'nitrogen'],
      language: 'en',
      publishedAt: DateTime(2024, 9, 15),
    ),
    AdvisoryContent(
      id: 'ADV-003',
      category: 'planting_guide',
      cropId: _cropIdSorghum,
      province: 'Limpopo',
      title: 'Sorghum Production in Semi-Arid Regions',
      summary: 'Sorghum is drought-tolerant but responds well to early weed control and balanced nutrition.',
      body: 'Plant at 50 000 plants/ha. Apply 60 kg N/ha at planting. '
          'First weed control critical at 2–4 leaf stage. '
          'Scout for shoot fly and head smut regularly.',
      tags: ['sorghum', 'dryland', 'semi-arid'],
      language: 'en',
      publishedAt: DateTime(2024, 8, 20),
    ),
    AdvisoryContent(
      id: 'ADV-004',
      category: 'weather_response',
      cropId: _cropIdMaize,
      title: 'Managing Maize During Heat Stress',
      summary: 'Temperatures above 35°C at silking can reduce yield by up to 40%.',
      body: 'Ensure adequate soil moisture during silking. Avoid broadcasting urea during heat — '
          'risk of ammonia volatilisation. Consider foliar potassium application to improve stress tolerance.',
      tags: ['heat_stress', 'maize', 'silking'],
      language: 'en',
      publishedAt: DateTime(2024, 11, 15),
    ),
    AdvisoryContent(
      id: 'ADV-005',
      category: 'crop_tip',
      cropId: _cropIdWheat,
      province: 'Free State',
      title: 'Septoria Leaf Blotch Management in Wheat',
      summary: 'Septoria is the leading foliar disease in dryland wheat — early fungicide timing is critical.',
      body: 'Apply fungicide at growth stage 31–37 (first node to flag leaf). '
          'Use azoxystrobin + propiconazole at label rate. '
          'Rotate modes of action to avoid resistance.',
      tags: ['wheat', 'septoria', 'fungicide'],
      language: 'en',
      publishedAt: DateTime(2024, 7, 10),
    ),
    AdvisoryContent(
      id: 'ADV-006',
      category: 'market_update',
      cropId: _cropIdMaize,
      title: 'SAFEX Maize Price Outlook — January 2025',
      summary: 'White maize trading at R3 180/t — strong export demand supporting prices.',
      body: 'Current SAFEX white maize spot price: R3 180/t. '
          'Yellow maize: R2 950/t. '
          'Global supply tightness expected to support prices through Q1 2025. '
          'Consider forward contracts for 30–50% of expected production.',
      tags: ['maize', 'price', 'SAFEX', 'market'],
      language: 'en',
      publishedAt: DateTime(2025, 1, 8),
    ),
  ];

  // ── Simulated network latency ─────────────────────────────────────────────
  // Mirrors real API behaviour so loading states and shimmer widgets are
  // exercised during development.  Keep short enough not to slow down QA.
  static const _kReadDelay  = Duration(milliseconds: 350);
  static const _kWriteDelay = Duration(milliseconds: 200);

  @override
  Future<List<CropCategory>> getCropCategories() async {
    await Future.delayed(_kReadDelay);
    return _categories;
  }

  @override
  Future<List<Crop>> getCrops() async {
    await Future.delayed(_kReadDelay);
    return _crops;
  }

  @override
  Future<List<CropField>> getCropFields() async {
    await Future.delayed(_kReadDelay);
    return _fields;
  }

  @override
  Future<List<CropSeason>> getSeasons() async {
    await Future.delayed(_kReadDelay);
    return _seasons;
  }

  @override
  Future<List<PlantingPlan>> getPlantingPlans() async {
    await Future.delayed(_kReadDelay);
    return _plans;
  }

  @override
  Future<List<CalendarEvent>> getCalendarEvents() async {
    await Future.delayed(_kReadDelay);
    return _calendarEvents;
  }

  @override
  Future<List<CropTask>> getCropTasks() async {
    await Future.delayed(_kReadDelay);
    return _tasks;
  }

  @override
  Future<List<WeatherAlert>> getWeatherAlerts() async {
    await Future.delayed(_kReadDelay);
    return _weatherAlerts;
  }

  @override
  Future<List<PestObservation>> getPestObservations() async {
    await Future.delayed(_kReadDelay);
    return _pests;
  }

  @override
  Future<List<SprayRecord>> getSprayRecords() async {
    await Future.delayed(_kReadDelay);
    return _sprays;
  }

  @override
  Future<List<CropExpense>> getCropExpenses() async {
    await Future.delayed(_kReadDelay);
    return _expenses;
  }

  @override
  Future<List<HarvestRecord>> getCropHarvestRecords() async {
    await Future.delayed(_kReadDelay);
    return _harvests;
  }

  @override
  Future<List<CropSale>> getCropSales() async {
    await Future.delayed(_kReadDelay);
    return _sales;
  }

  @override
  Future<List<AdvisoryContent>> getAdvisoryContent() async {
    await Future.delayed(_kReadDelay);
    return _advisory;
  }

  // ── Write stubs (repository manages in-memory cache; mock persists nothing) ──

  @override Future<CropField> addField(CropField f) async { await Future.delayed(_kWriteDelay); return f; }
  @override Future<CropField> updateField(CropField f) async { await Future.delayed(_kWriteDelay); return f; }
  @override Future<void> deleteField(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<CropSeason> addSeason(CropSeason s) async { await Future.delayed(_kWriteDelay); return s; }
  @override Future<CropSeason> updateSeason(CropSeason s) async { await Future.delayed(_kWriteDelay); return s; }
  @override Future<void> deleteSeason(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<PlantingPlan> addPlantingPlan(PlantingPlan p) async { await Future.delayed(_kWriteDelay); return p; }
  @override Future<PlantingPlan> updatePlantingPlan(PlantingPlan p) async { await Future.delayed(_kWriteDelay); return p; }
  @override Future<void> deletePlantingPlan(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<CropTask> addTask(CropTask t) async { await Future.delayed(_kWriteDelay); return t; }
  @override Future<CropTask> updateTask(CropTask t) async { await Future.delayed(_kWriteDelay); return t; }
  @override Future<void> deleteTask(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<PestObservation> addPestObservation(PestObservation o) async { await Future.delayed(_kWriteDelay); return o; }
  @override Future<PestObservation> updatePestObservation(PestObservation o) async { await Future.delayed(_kWriteDelay); return o; }
  @override Future<void> deletePestObservation(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<SprayRecord> addSprayRecord(SprayRecord r) async { await Future.delayed(_kWriteDelay); return r; }
  @override Future<SprayRecord> updateSprayRecord(SprayRecord r) async { await Future.delayed(_kWriteDelay); return r; }
  @override Future<void> deleteSprayRecord(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<CropExpense> addExpense(CropExpense e) async { await Future.delayed(_kWriteDelay); return e; }
  @override Future<CropExpense> updateExpense(CropExpense e) async { await Future.delayed(_kWriteDelay); return e; }
  @override Future<void> deleteExpense(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<HarvestRecord> addHarvestRecord(HarvestRecord r) async { await Future.delayed(_kWriteDelay); return r; }
  @override Future<HarvestRecord> updateHarvestRecord(HarvestRecord r) async { await Future.delayed(_kWriteDelay); return r; }
  @override Future<void> deleteHarvestRecord(String id) async { await Future.delayed(_kWriteDelay); }

  @override Future<CropSale> addSale(CropSale s) async { await Future.delayed(_kWriteDelay); return s; }
  @override Future<CropSale> updateSale(CropSale s) async { await Future.delayed(_kWriteDelay); return s; }
  @override Future<void> deleteSale(String id) async {}
}
