import 'package:flutter/material.dart';

/// Livestock species identifiers and domain constants.
abstract final class LivestockConstants {
  // ── Species codes ─────────────────────────────────────────────────────────────
  static const String cattle = 'cattle';
  static const String goats = 'goats';
  static const String sheep = 'sheep';
  static const String pigs = 'pigs';
  static const String poultry = 'poultry';
  static const String horses = 'horses';
  static const String rabbits = 'rabbits';
  static const String aquaculture = 'aquaculture';
  static const String bees = 'bees';

  static const List<String> allSpecies = [
    cattle, goats, sheep, pigs, poultry, horses, rabbits, aquaculture, bees,
  ];

  /// Species backed by the standard [Animal] model (excludes bees and
  /// aquaculture, which use Map-structured JSON via dedicated repositories).
  static const List<String> animalSpecies = [
    cattle, goats, sheep, pigs, poultry, horses, rabbits,
  ];

  // ── Species display names ─────────────────────────────────────────────────────
  static const Map<String, String> speciesDisplayNames = {
    cattle: 'Cattle',
    goats: 'Goats',
    sheep: 'Sheep',
    pigs: 'Pigs',
    poultry: 'Poultry',
    horses: 'Horses',
    rabbits: 'Rabbits',
    aquaculture: 'Aquaculture',
    bees: 'Bees',
  };

  static String displayName(String species) =>
      speciesDisplayNames[species] ?? species;

  // ── SVG icon asset paths ──────────────────────────────────────────────────────
  static const Map<String, String> speciesIconPaths = {
    cattle: 'assets/icons/livestock/cattle.svg',
    goats: 'assets/icons/livestock/goat.svg',
    sheep: 'assets/icons/livestock/sheep.svg',
    pigs: 'assets/icons/livestock/pig.svg',
    poultry: 'assets/icons/livestock/poultry.svg',
    horses: 'assets/icons/livestock/horse.svg',
    rabbits: 'assets/icons/livestock/rabbit.svg',
    aquaculture: 'assets/icons/livestock/fish.svg',
    bees: 'assets/icons/livestock/bee.svg',
  };

  static String iconPath(String species) =>
      speciesIconPaths[species] ?? 'assets/icons/livestock/cattle.svg';

  // ── Body Condition Score (BCS) scales ─────────────────────────────────────────

  /// BCS 1–5 scale (used for: cattle, sheep, pigs, horses)
  static const List<double> bcsScale5 = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];

  /// BCS 1–9 scale (used for: cattle — extended US system)
  static const List<int> bcsScale9 = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  static const Map<String, String> bcs5Labels = {
    '1': 'Emaciated',
    '2': 'Thin',
    '3': 'Ideal',
    '4': 'Fat',
    '5': 'Obese',
  };

  // ── Gender options ────────────────────────────────────────────────────────────
  static const Map<String, List<String>> genderBySpecies = {
    cattle: ['Bull', 'Cow', 'Heifer', 'Steer', 'Calf'],
    goats: ['Buck', 'Doe', 'Kid', 'Wether'],
    sheep: ['Ram', 'Ewe', 'Lamb', 'Wether'],
    pigs: ['Boar', 'Sow', 'Gilt', 'Piglet', 'Barrow'],
    poultry: ['Rooster', 'Hen', 'Chick', 'Pullet', 'Cockerel'],
    horses: ['Stallion', 'Mare', 'Gelding', 'Foal', 'Colt', 'Filly'],
    rabbits: ['Buck', 'Doe', 'Kit'],
    aquaculture: ['Male', 'Female', 'Unknown'],
    bees: ['Queen', 'Worker', 'Drone'],
  };

  // ── Health status labels ──────────────────────────────────────────────────────
  static const String healthHealthy = 'healthy';
  static const String healthSick = 'sick';
  static const String healthRecovering = 'recovering';
  static const String healthQuarantine = 'quarantine';
  static const String healthDeceased = 'deceased';

  static const Map<String, String> healthStatusLabels = {
    healthHealthy: 'Healthy',
    healthSick: 'Sick',
    healthRecovering: 'Recovering',
    healthQuarantine: 'Quarantine',
    healthDeceased: 'Deceased',
  };

  static const Map<String, Color> healthStatusColors = {
    healthHealthy: Color(0xFF388E3C),
    healthSick: Color(0xFFB71C1C),
    healthRecovering: Color(0xFFF57F17),
    healthQuarantine: Color(0xFF0277BD),
    healthDeceased: Color(0xFF616161),
  };

  // ── Production types ──────────────────────────────────────────────────────────
  static const String productionMilk = 'milk';
  static const String productionEggs = 'eggs';
  static const String productionWool = 'wool';
  static const String productionHoney = 'honey';
  static const String productionFish = 'fish';
  static const String productionMeat = 'meat';

  /// Species → production types mapping
  static const Map<String, List<String>> productionBySpecies = {
    cattle: [productionMilk, productionMeat],
    goats: [productionMilk, productionMeat],
    sheep: [productionWool, productionMilk, productionMeat],
    pigs: [productionMeat],
    poultry: [productionEggs, productionMeat],
    horses: [productionMeat],
    rabbits: [productionMeat],
    aquaculture: [productionFish],
    bees: [productionHoney],
  };

  // ── Breeding status ───────────────────────────────────────────────────────────
  static const String breedingOpen = 'open';
  static const String breedingBred = 'bred';
  static const String breedingConfirmedPregnant = 'confirmed_pregnant';
  static const String breedingLactating = 'lactating';
  static const String breedingDry = 'dry';

  // ── Weight units ──────────────────────────────────────────────────────────────
  static const String weightKg = 'kg';
  static const String weightLb = 'lb';
  static const String weightG = 'g';

  // ── Volume units (production) ─────────────────────────────────────────────────
  static const String volumeLitre = 'L';
  static const String volumeMl = 'mL';

  // ── Identification types ──────────────────────────────────────────────────────
  static const String idTagEarTag = 'ear_tag';
  static const String idTagRfid = 'rfid';
  static const String idTagTattoo = 'tattoo';
  static const String idTagBrand = 'brand';
  static const String idTagMicrochip = 'microchip';

  // ── Breed lists per species ───────────────────────────────────────────────────
  static const Map<String, List<String>> breedsBySpecies = {
    cattle: [
      'Angus', 'Hereford', 'Holstein-Friesian', 'Jersey', 'Brahman',
      'Simmental', 'Charolais', 'Limousin', 'Shorthorn', 'Nguni',
      'Boran', 'Afrikaner', 'Bonsmara', 'Other',
    ],
    goats: [
      'Boer', 'Saanen', 'Nubian', 'Alpine', 'Angora',
      'Kalahari Red', 'Toggenburg', 'La Mancha', 'Indigenous/Crossbreed', 'Other',
    ],
    sheep: [
      'Merino', 'Dorper', 'White Dorper', 'Suffolk', 'Corriedale',
      'Romney', 'Rambouillet', 'Damara', 'Van Rooy', 'Dohne Merino',
      'Awassi', 'Blackface', 'Other',
    ],
    pigs: [
      'Large White', 'Landrace', 'Duroc', 'Berkshire', 'Hampshire',
      'Pietrain', 'Kolbroek', 'Windsnyer', 'Crossbreed', 'Other',
    ],
    poultry: [
      'Ross 308 (Broiler)', 'Cobb 500 (Broiler)', 'Lohmann Brown (Layer)',
      'Isa Brown (Layer)', 'Black Australorp', 'Rhode Island Red',
      'Potchefstroom Koekoek', 'Naked Neck', 'Other',
    ],
    horses: [
      'Thoroughbred', 'Quarter Horse', 'Arabian', 'Warmblood',
      'Clydesdale', 'Appaloosa', 'Boerperd', 'Friesian', 'Other',
    ],
    rabbits: [
      'New Zealand White', 'Californian', 'Rex', 'Flemish Giant',
      'Angora', 'Dutch', 'Other',
    ],
    aquaculture: [
      'Tilapia (Nile)', 'Catfish (Sharptooth)', 'Rainbow Trout',
      'Common Carp', 'Catla', 'Pangasius', 'Other',
    ],
    bees: [
      'Italian (A. m. ligustica)', 'Carniolan', 'Buckfast',
      'Cape Bee (A. m. capensis)', 'African Bee', 'Other',
    ],
  };

  /// Returns breed options for [species], falling back to a generic list.
  static List<String> breedsFor(String species) =>
      breedsBySpecies[species] ?? ['Crossbreed', 'Indigenous', 'Other'];

  // ── Animal image URLs ─────────────────────────────────────────────────────────

  /// Per-species curated Unsplash photo IDs (livestock photos).
  static const Map<String, List<String>> _speciesPhotoIds = {
    cattle: [
      'photo-1500595046743-cd271d694d30', // cows in field
      'photo-1570042225831-d98fa7577f1e', // grazing cattle
      'photo-1545468230-68d54f5f6e38',    // herd of cattle
      'photo-1551950376-f77b6ec78f1e',    // dairy cows
    ],
    goats: [
      'photo-1524024973431-2ad916746881', // white goats
      'photo-1542889601-399c4f3a8402',    // goat close-up
      'photo-1535268647677-300dbf3d78d1', // goats grazing
    ],
    sheep: [
      'photo-1484557985045-edf25e08da73', // sheep in field
      'photo-1518020382113-a7e8fc38eac9', // white sheep
      'photo-1583337130417-3346a1be7dee', // sheep flock
    ],
    pigs: [
      'photo-1516467508483-a7212febe31a', // pigs in pen
      'photo-1597843786272-f5e2e69ee7ac', // pink pig
    ],
    poultry: [
      'photo-1548550023-2bdb3c5beed7',    // chickens
      'photo-1518492104633-130d0cc84637', // hens
      'photo-1612170153139-6f881ff067e0', // rooster
    ],
    horses: [
      'photo-1553284965-83fd3e82fa5a',    // horse in field
      'photo-1534773728080-33d31da27ae5', // horse portrait
      'photo-1452378174528-3090a4bba7b2', // horses running
    ],
    rabbits: [
      'photo-1585110396000-c9ffd4e4b308', // rabbit
      'photo-1518717758536-85ae29035b6d', // white rabbit
    ],
    aquaculture: [
      'photo-1559827260-dc66d52bef19', // fish
      'photo-1519708227418-c8fd9a32b7a2', // aquaculture
    ],
    bees: [
      'photo-1587049352846-4a222e784d38', // bees on hive
      'photo-1558642084-fd07fae5282e',    // honeybee
    ],
  };

  /// Returns a deterministic Unsplash image URL for an animal.
  /// [width] and [height] control the returned image dimensions.
  static String animalImageUrl(
    String species,
    String animalId, {
    int width = 400,
    int height = 300,
  }) {
    final ids = _speciesPhotoIds[species] ??
        _speciesPhotoIds[cattle]!;
    final idx = animalId.hashCode.abs() % ids.length;
    return 'https://images.unsplash.com/${ids[idx]}?w=$width&h=$height&fit=crop&auto=format';
  }

  // ── SA Compliance ─────────────────────────────────────────────────────────────

  /// DAFF (Dept. of Agriculture, Forestry and Fisheries) emergency hotline.
  static const String daffEmergencyNumber = '012 319 7000';

  /// SA notifiable disease names for display (keys match [NotifiableDisease] enum).
  static const Map<String, String> notifiableDiseaseLabels = {
    'fmd': 'Foot and Mouth Disease (FMD)',
    'asf': 'African Swine Fever (ASF)',
    'hpai': 'Highly Pathogenic Avian Influenza (HPAI)',
    'cbpp': 'Contagious Bovine Pleuropneumonia (CBPP)',
    'lsd': 'Lumpy Skin Disease',
    'ecf': 'East Coast Fever',
    'brucellosis': 'Brucellosis',
    'ahs': 'African Horse Sickness (AHS)',
    'newcastle': 'Newcastle Disease',
    'rabies': 'Rabies',
  };

  /// Species → notifiable diseases applicable to that species.
  static const Map<String, List<String>> notifiableDiseasesBySpecies = {
    cattle: ['fmd', 'lsd', 'cbpp', 'ecf', 'brucellosis', 'rabies'],
    goats: ['fmd', 'lsd', 'brucellosis', 'rabies'],
    sheep: ['fmd', 'lsd', 'brucellosis', 'rabies'],
    pigs: ['fmd', 'asf', 'rabies'],
    poultry: ['hpai', 'newcastle'],
    horses: ['fmd', 'ahs', 'rabies'],
    rabbits: ['rabies'],
    aquaculture: [],
    bees: [],
  };

  /// Required response actions per notifiable disease (shown in prompt).
  static const Map<String, String> notifiableDiseaseActions = {
    'fmd': 'QUARANTINE herd immediately. Do not move animals. '
        'Contact DAFF $daffEmergencyNumber and your state vet.',
    'asf': 'QUARANTINE all pigs immediately. No pork movement. '
        'Contact DAFF $daffEmergencyNumber urgently.',
    'hpai': 'ISOLATE affected flock. Implement biosecurity. '
        'Report to DAFF $daffEmergencyNumber and state vet.',
    'cbpp': 'RESTRICT movement. Contact state vet for testing. '
        'Report to DAFF $daffEmergencyNumber.',
    'lsd': 'VACCINATE susceptible animals. Restrict movement. '
        'Notify state vet. Focus: KZN, Eastern Cape.',
    'ecf': 'Notifiable disease — contact state vet immediately. '
        'Report to DAFF $daffEmergencyNumber.',
    'brucellosis': 'Statutory testing required for herd sales. '
        'Contact state vet for B-free certification.',
    'ahs': 'Horses must be in AHS-free zone. Vaccinate with AHS vaccine. '
        'Contact state vet for zone verification.',
    'newcastle': 'ISOLATE flock. Report to DAFF $daffEmergencyNumber. '
        'Implement biosecurity protocol.',
    'rabies': 'Do not handle without PPE. Report to state vet immediately. '
        'Contact DAFF $daffEmergencyNumber.',
  };

  // ── SA Vaccination Templates ─────────────────────────────────────────────────

  /// Pre-loaded SA vaccination protocol templates per species.
  /// Each entry: {name, frequency, notes, speciesApplicable}
  static const Map<String, List<Map<String, String>>> vaccinationTemplates = {
    cattle: [
      {
        'name': 'Clostridial 7-in-1',
        'frequency': 'Annual + booster at weaning',
        'notes': 'Covers blackleg, pulpy kidney, tetanus etc.',
      },
      {
        'name': 'Foot and Mouth Disease (FMD)',
        'frequency': 'Bi-annual',
        'notes': 'Compulsory in FMD zones (Limpopo, Mpumalanga)',
      },
      {
        'name': 'Lumpy Skin Disease',
        'frequency': 'Annual',
        'notes': 'Priority KZN, Eastern Cape, Limpopo',
      },
      {
        'name': 'Brucellosis RB51/S19',
        'frequency': 'Once (heifers 4–8 months)',
        'notes': 'State-certified procedure only',
      },
      {
        'name': 'BVD / IBR',
        'frequency': 'Annual',
        'notes': 'Priority breeding herds',
      },
      {
        'name': 'Tick Vaccine',
        'frequency': 'Per protocol',
        'notes': 'ECF endemic areas (Limpopo, Mpumalanga, KZN)',
      },
    ],
    sheep: [
      {
        'name': 'Pasteurellosis (Ovine Pneumonia)',
        'frequency': 'Annual',
        'notes': 'Pneumonia prevention esp. winter rainfall areas',
      },
      {
        'name': 'Clostridial 4-in-1',
        'frequency': 'Annual + ewe pre-lambing booster',
        'notes': 'Pulpy kidney, tetanus, blackleg, braxy',
      },
      {
        'name': 'Bluetongue',
        'frequency': 'Annual (Apr–May)',
        'notes': 'Summer rainfall regions; multiple serotypes',
      },
      {
        'name': 'Orf (Contagious Pustular Dermatitis)',
        'frequency': 'Annual',
        'notes': 'Especially where orf is endemic',
      },
    ],
    goats: [
      {
        'name': 'Clostridial 4-in-1',
        'frequency': 'Annual',
        'notes': 'Pulpy kidney, tetanus, blackleg, braxy',
      },
      {
        'name': 'Pasteurellosis',
        'frequency': 'Annual',
        'notes': 'Pneumonia prevention',
      },
      {
        'name': 'Bluetongue',
        'frequency': 'Annual',
        'notes': 'Annual vaccination recommended',
      },
    ],
    pigs: [
      {
        'name': 'Porcine Circovirus (PCV2)',
        'frequency': 'Once (3 weeks of age)',
        'notes': 'Core vaccine for all production pigs',
      },
      {
        'name': 'PRRSV',
        'frequency': 'Annual',
        'notes': 'Where PRRS is present',
      },
      {
        'name': 'E. coli (K88/K99)',
        'frequency': 'Sow pre-farrowing',
        'notes': 'Neonatal scour prevention',
      },
    ],
    poultry: [
      {
        'name': 'Newcastle Disease (ND)',
        'frequency': 'Every 6 weeks (broilers); annual (layers)',
        'notes': 'Core vaccination — live + killed combination',
      },
      {
        'name': 'Infectious Bronchitis (IB)',
        'frequency': 'Per programme',
        'notes': 'Respiratory protection',
      },
      {
        'name': 'Marek\'s Disease',
        'frequency': 'Day-old chick',
        'notes': 'In-hatchery administration',
      },
      {
        'name': 'Infectious Bursal Disease (IBD/Gumboro)',
        'frequency': 'Day 14 and 21',
        'notes': 'Immuno-suppressant disease prevention',
      },
    ],
    horses: [
      {
        'name': 'African Horse Sickness (AHS)',
        'frequency': 'Annual (Mar–Apr)',
        'notes': 'Compulsory in AHS-controlled zones',
      },
      {
        'name': 'Equine Influenza',
        'frequency': 'Annual',
        'notes': 'Required for racing/competition',
      },
      {
        'name': 'Equine Herpesvirus (EHV-1/4)',
        'frequency': 'Every 6 months',
        'notes': 'Breeding mares every 3 months',
      },
      {
        'name': 'Tetanus',
        'frequency': 'Annual',
        'notes': 'Core vaccine',
      },
      {
        'name': 'Rabies',
        'frequency': 'Annual',
        'notes': 'High-risk areas',
      },
    ],
    rabbits: [],
    aquaculture: [],
    bees: [],
  };

  // ── SA Weight Benchmarks ──────────────────────────────────────────────────────

  /// Live weight benchmarks (kg) per SA breed at key production stages.
  /// Stages: birth, weaning, 6months, slaughter, matureFemale, matureMale
  static const Map<String, Map<String, double>> weightBenchmarksByBreed = {
    // Cattle
    'Bonsmara': {
      'birth': 33,
      'weaning': 210,
      '6months': 230,
      'slaughter': 480,
      'matureFemale': 500,
      'matureMale': 750,
    },
    'Nguni': {
      'birth': 22,
      'weaning': 160,
      '6months': 180,
      'slaughter': 360,
      'matureFemale': 380,
      'matureMale': 540,
    },
    'Afrikaner': {
      'birth': 28,
      'weaning': 175,
      '6months': 200,
      'slaughter': 420,
      'matureFemale': 450,
      'matureMale': 680,
    },
    // Sheep
    'Dorper': {
      'birth': 4.0,
      'weaning': 24,
      '6months': 38,
      'slaughter': 45,
      'matureFemale': 75,
      'matureMale': 110,
    },
    'Merino': {
      'birth': 4.5,
      'weaning': 26,
      '6months': 40,
      'slaughter': 50,
      'matureFemale': 65,
      'matureMale': 95,
    },
    'Dohne Merino': {
      'birth': 4.5,
      'weaning': 27,
      '6months': 42,
      'slaughter': 52,
      'matureFemale': 68,
      'matureMale': 100,
    },
    // Goats
    'Boer Goat': {
      'birth': 4.5,
      'weaning': 25,
      '6months': 42,
      'slaughter': 50,
      'matureFemale': 80,
      'matureMale': 125,
    },
    'Angora': {
      'birth': 3.5,
      'weaning': 18,
      '6months': 28,
      'slaughter': 35,
      'matureFemale': 45,
      'matureMale': 65,
    },
  };

  // ── SA Market Reference Prices (2025/2026) ────────────────────────────────────

  /// Reference market prices — for benchmark display only; not live data.
  static const Map<String, String> marketPriceReferences = {
    'A3 Beef Carcass': 'R67–72/kg',
    'Dorper Wether (live)': 'R1,800–2,400/head',
    'Boer Goat (auction)': 'R1,500–3,500/head',
    'Merino Wool (21µm clean)': 'R120–145/kg',
    'Mohair — Kid (<26µm)': 'R320–380/kg',
    'Mohair — Adult': 'R180–240/kg',
    'Raw Milk (factory gate)': 'R5.80–7.20/litre',
    'Free Range Eggs': 'R42–55/dozen',
  };

  // ── FAMACHA Reference ─────────────────────────────────────────────────────────

  /// FAMACHA score descriptions and actions (1=healthy, 5=severely anaemic).
  static const List<Map<String, String>> famachaReference = [
    {
      'score': '1',
      'label': 'Red',
      'description': 'Healthy — red conjunctiva',
      'action': 'No treatment needed',
      'alertLevel': 'none',
    },
    {
      'score': '2',
      'label': 'Red-Pink',
      'description': 'Acceptable — slight pallor',
      'action': 'Monitor closely',
      'alertLevel': 'none',
    },
    {
      'score': '3',
      'label': 'Pink',
      'description': 'Borderline — moderately pale',
      'action': 'Treat if concurrent risk factors (low BCS, dag, nasal discharge)',
      'alertLevel': 'warning',
    },
    {
      'score': '4',
      'label': 'Pink-White',
      'description': 'Anaemic — pale conjunctiva',
      'action': 'TREAT immediately with anthelmintic',
      'alertLevel': 'alert',
    },
    {
      'score': '5',
      'label': 'White',
      'description': 'Severely anaemic — white conjunctiva',
      'action': 'URGENT treatment; consider iron dextran + B12; vet consult',
      'alertLevel': 'critical',
    },
  ];

  /// Drench active ingredient classes for rotation tracking.
  static const List<String> drenchClasses = [
    'BZ (Benzimidazole)',
    'LEV (Levamisole)',
    'ML (Macrocyclic Lactone)',
    'Combination (BZ+LEV)',
    'Monepantel (Zolvix)',
    'Derquantel+Abamectin',
  ];

  /// Short key for drench class (for storage/rotation comparison).
  static const Map<String, String> drenchClassKeys = {
    'BZ (Benzimidazole)': 'BZ',
    'LEV (Levamisole)': 'LEV',
    'ML (Macrocyclic Lactone)': 'ML',
    'Combination (BZ+LEV)': 'COMBO',
    'Monepantel (Zolvix)': 'MONO',
    'Derquantel+Abamectin': 'DERQ',
  };
}
