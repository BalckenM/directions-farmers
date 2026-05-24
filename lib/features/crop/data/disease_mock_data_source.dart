import 'dart:math';

import '../models/disease_detection.dart';
import 'disease_data_source.dart';

// SA crop disease library — mock on-device detection.
// Real implementation would use TFLite or a cloud vision model.
class DiseaseMockDataSource implements DiseaseDataSource {
  static const _kDelay = Duration(milliseconds: 800);

  // ── Disease library ───────────────────────────────────────────────────────

  static const List<DiseaseInfo> _diseases = [
    // ── Maize diseases ────────────────────────────────────────────────────
    DiseaseInfo(
      id: 'DIS-MAIZE-GLS',
      name: 'Grey Leaf Spot',
      scientificName: 'Cercospora zeae-maydis',
      cropTypes: ['maize'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.high,
      description:
          'One of the most economically important foliar diseases of maize in '
          'South Africa. Thrives in warm, humid conditions with overnight dew.',
      visualSymptoms:
          'Rectangular grey-to-tan lesions running parallel to leaf veins. '
          'Lesions have well-defined edges and may merge under severe infection, '
          'giving the leaf a bleached, straw-coloured appearance.',
      spread:
          'Spreads via airborne spores from infected crop debris left in the '
          'field after harvest. High humidity and morning dew favour spread.',
      treatments: [
        TreatmentOption(
          name: 'Fungicide Application',
          type: TreatmentType.chemical,
          description: 'Apply a strobilurin or triazole fungicide at flag-leaf stage.',
          applicationMethod: 'Boom sprayer or knapsack at full leaf coverage',
          timing: 'At first lesion appearance or at V8–VT stage preventatively',
          saProducts: ['Amistar Top 325 SC', 'Headline EC', 'Alto 240 EC'],
          waitingDays: 14,
        ),
        TreatmentOption(
          name: 'Resistant Hybrid Selection',
          type: TreatmentType.cultural,
          description: 'Choose maize hybrids with documented GLS resistance ratings.',
          applicationMethod: 'Seed selection before planting',
          timing: 'Before the next planting season',
        ),
        TreatmentOption(
          name: 'Crop Rotation',
          type: TreatmentType.cultural,
          description: 'Rotate with non-host crops such as soybean or sunflower.',
          applicationMethod: 'Field-level crop planning',
          timing: 'Off-season planning',
        ),
      ],
      preventionTips: [
        'Plant resistant hybrids rated ≥ 6 on GLS resistance scale',
        'Destroy or incorporate infected crop residues after harvest',
        'Avoid overhead irrigation that keeps foliage wet overnight',
        'Monitor fields from V6 stage onwards, especially in high-rainfall areas',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-MAIZE-NLB',
      name: 'Northern Leaf Blight',
      scientificName: 'Exserohilum turcicum',
      cropTypes: ['maize'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.high,
      description:
          'A widespread foliar disease of maize causing significant yield losses '
          'when infection occurs before tasselling.',
      visualSymptoms:
          'Large (5–15 cm), cigar-shaped grey-green to tan lesions with '
          'wavy margins. Lesions may have dark green, water-soaked borders '
          'when actively expanding. Severe infection turns whole plant brown.',
      spread: 'Airborne conidia from infected debris. Spread accelerated by '
          'cool, moist nights (18–27°C optimal).',
      treatments: [
        TreatmentOption(
          name: 'Fungicide Spray',
          type: TreatmentType.chemical,
          description: 'Triazole-based fungicide applied at tasselling.',
          applicationMethod: 'Aerial or tractor boom at VT/R1 growth stage',
          timing: 'At tassel emergence (VT stage)',
          saProducts: ['Tilt 250 EC', 'Bumper 250 EC', 'Folicur 250 EW'],
          waitingDays: 21,
        ),
        TreatmentOption(
          name: 'Resistant Hybrids',
          type: TreatmentType.cultural,
          description: 'Select hybrids with Ht1, Ht2, or HtN resistance genes.',
          applicationMethod: 'Pre-season seed selection',
          timing: 'Before planting',
        ),
      ],
      preventionTips: [
        'Select NLB-resistant hybrids for areas with a history of the disease',
        'Plough infected residues deeply (> 15 cm) after harvest',
        'Avoid continuous maize — rotate with legumes',
        'Scout fields from V6; target the ear leaf and leaves above',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-MAIZE-MSV',
      name: 'Maize Streak Virus',
      scientificName: 'Maize streak virus (MSV)',
      cropTypes: ['maize'],
      category: DiseaseCategory.viral,
      severity: DiseaseSeverity.critical,
      description:
          'The most destructive viral disease of maize in sub-Saharan Africa, '
          'transmitted by leafhoppers. Early infection can cause complete crop loss.',
      visualSymptoms:
          'Narrow, pale yellow streaks parallel to the veins on young leaves. '
          'Infected plants are stunted and may die if infected early. '
          'Leaves may be completely yellowed in severe cases.',
      spread:
          'Transmitted exclusively by leafhopper insects (Cicadulina spp.). '
          'Leafhoppers acquire the virus in minutes and remain infective for life.',
      treatments: [
        TreatmentOption(
          name: 'Insecticide Seed Treatment',
          type: TreatmentType.chemical,
          description: 'Use imidacloprid-coated seed to kill leafhoppers at emergence.',
          applicationMethod: 'Treated seed at planting',
          timing: 'At planting',
          saProducts: ['Gaucho 600 FS', 'Cruiser 350 FS'],
          waitingDays: 0,
        ),
        TreatmentOption(
          name: 'Foliar Insecticide',
          type: TreatmentType.chemical,
          description:
              'Apply insecticide to control leafhopper populations in the crop.',
          applicationMethod: 'Knapsack or boom sprayer',
          timing: 'At first leafhopper sighting or V3–V4 stage',
          saProducts: ['Actara 25 WG', 'Confidor 200 SL'],
          waitingDays: 7,
        ),
      ],
      preventionTips: [
        'Use MSV-resistant or MSV-tolerant hybrids — essential in high-risk areas',
        'Plant early to avoid peak leafhopper populations',
        'Remove and destroy infected volunteer plants and grasses (alternate hosts)',
        'Do not plant next to old maize or grassy areas that harbour leafhoppers',
        'Rogue out severely infected plants early to prevent spread',
      ],
      requiresImmediateAction: true,
    ),
    DiseaseInfo(
      id: 'DIS-MAIZE-FAW',
      name: 'Fall Armyworm',
      scientificName: 'Spodoptera frugiperda',
      cropTypes: ['maize', 'sorghum', 'wheat'],
      category: DiseaseCategory.pest,
      severity: DiseaseSeverity.critical,
      description:
          'An invasive pest that arrived in Africa in 2016. Caterpillars feed '
          'in the whorl and on ears, causing severe yield losses if not controlled early.',
      visualSymptoms:
          'Window-pane feeding on young leaves; ragged holes in the whorl. '
          'Frass (sawdust-like droppings) inside the whorl is a diagnostic sign. '
          'Caterpillars have an inverted "Y" on their head capsule.',
      spread:
          'Adult moths migrate long distances on wind currents. Each female '
          'can lay 1 000–2 000 eggs over a two-week period.',
      treatments: [
        TreatmentOption(
          name: 'Whorl Application (Chemical)',
          type: TreatmentType.chemical,
          description:
              'Apply insecticide directly into the whorl before caterpillars '
              'burrow into the stem.',
          applicationMethod: 'Knapsack sprayer directed into the whorl',
          timing:
              'When > 20% of plants show fresh feeding damage in the whorl',
          saProducts: ['Dursban 480 EC', 'Thunder 150 EC', 'Coragen 200 SC'],
          waitingDays: 14,
        ),
        TreatmentOption(
          name: 'Biological Control — Bt',
          type: TreatmentType.biological,
          description:
              'Bacillus thuringiensis (Bt) products are effective against '
              'young larvae (< L3 instar).',
          applicationMethod: 'Knapsack into whorl at dusk when larvae feed',
          timing: 'When eggs begin to hatch (young larvae visible)',
          saProducts: ['DiPel DF', 'Thuricide HP'],
        ),
        TreatmentOption(
          name: 'Early Planting',
          type: TreatmentType.cultural,
          description:
              'Earlier planting means the crop passes the vulnerable whorl '
              'stage before peak moth populations arrive.',
          applicationMethod: 'Farm planning',
          timing: 'Before the planting season',
        ),
      ],
      preventionTips: [
        'Scout weekly from emergence — check whorls of 20 plants per ha',
        'Economic threshold: treat when > 20% of plants have fresh whorl damage',
        'Avoid planting near recently harvested maize fields',
        'Use pheromone traps to monitor adult moth flight',
        'Preserve natural enemies — avoid broad-spectrum insecticides early',
      ],
      requiresImmediateAction: true,
    ),

    // ── Soybean diseases ──────────────────────────────────────────────────
    DiseaseInfo(
      id: 'DIS-SOY-RUST',
      name: 'Soybean Rust',
      scientificName: 'Phakopsora pachyrhizi',
      cropTypes: ['soybean'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.critical,
      description:
          'The most economically significant foliar disease of soybeans worldwide. '
          'Can cause up to 80% yield loss if uncontrolled. Spreads rapidly under '
          'warm (15–28°C), humid conditions.',
      visualSymptoms:
          'Small (2–5 mm) tan to dark-brown lesions on lower leaf surface. '
          'Creamy-white to tan spore masses (uredinia) visible with hand lens. '
          'Yellowing and premature defoliation in severe cases.',
      spread:
          'Airborne urediniospores travel hundreds of kilometres on wind currents. '
          'Volunteer soybeans and kudzu are green bridges between seasons.',
      treatments: [
        TreatmentOption(
          name: 'Triazole Fungicide',
          type: TreatmentType.chemical,
          description:
              'Apply a DMI (triazole) or strobilurin+triazole mixture at first '
              'sign of infection or preventatively at R1–R3.',
          applicationMethod: 'High-volume boom sprayer ensuring lower-leaf coverage',
          timing: 'Preventative at R1 (first flower) in high-risk areas',
          saProducts: ['Bumper 250 EC', 'Opus 125 EC', 'Amistar Top 325 SC'],
          waitingDays: 14,
        ),
      ],
      preventionTips: [
        'Monitor lower leaves from R1 stage — rust starts low in the canopy',
        'Use a hand lens to check for uredinia on underside of leaf',
        'Destroy volunteer soybeans and alternative hosts (kudzu, tick trefoil)',
        'Maintain accurate records of first-detection dates for regional alerts',
        'Plant early-maturing varieties in high-pressure areas',
      ],
      requiresImmediateAction: true,
    ),

    // ── Tomato diseases ───────────────────────────────────────────────────
    DiseaseInfo(
      id: 'DIS-TOM-EB',
      name: 'Tomato Early Blight',
      scientificName: 'Alternaria solani',
      cropTypes: ['tomato', 'potato'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.moderate,
      description:
          'A very common foliar and fruit disease of tomato and potato. '
          'Mainly attacks older, stressed plants but can spread upward rapidly.',
      visualSymptoms:
          'Dark-brown to black circular lesions with concentric rings (target '
          'board pattern) on older leaves. Yellow halo around lesions. '
          'Lesions on stems are dark, sunken, and elliptical.',
      spread:
          'Spreads via airborne spores and splashing rain. Warm days (24–29°C) '
          'with cool humid nights favour infection.',
      treatments: [
        TreatmentOption(
          name: 'Protectant Fungicide',
          type: TreatmentType.chemical,
          description: 'Apply mancozeb or chlorothalonil on a 7–10-day schedule.',
          applicationMethod: 'Knapsack or boom sprayer',
          timing: 'Begin at transplanting or first symptom appearance',
          saProducts: ['Dithane M45', 'Mancozeb 800 WP', 'Bravo 500 SC'],
          waitingDays: 7,
        ),
        TreatmentOption(
          name: 'Remove Lower Leaves',
          type: TreatmentType.cultural,
          description:
              'Remove and destroy infected lower leaves to reduce spore loads.',
          applicationMethod: 'Manual removal, do not compost',
          timing: 'As soon as lesions are detected',
        ),
      ],
      preventionTips: [
        'Water at soil level; avoid wetting foliage',
        'Stake and prune plants to improve air circulation',
        'Mulch soil surface to reduce spore splash from the ground',
        'Rotate with non-solanaceous crops for at least 2 years',
        'Ensure adequate potassium — stressed plants are more susceptible',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-TOM-LB',
      name: 'Tomato Late Blight',
      scientificName: 'Phytophthora infestans',
      cropTypes: ['tomato', 'potato'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.critical,
      description:
          'The most destructive pathogen of tomato and potato. Can destroy a '
          'field in days under cool, wet conditions. Caused the Irish potato famine.',
      visualSymptoms:
          'Large (> 2 cm), irregular dark-green to purple-brown water-soaked '
          'patches on leaves, often at tips or margins. White mycelium visible '
          'on underside in humid weather. Black lesions on stems and fruit.',
      spread:
          'Sporangia are rain-splashed and airborne. Spreads explosively in '
          'cool (10–25°C), wet, overcast weather.',
      treatments: [
        TreatmentOption(
          name: 'Systemic Fungicide',
          type: TreatmentType.chemical,
          description: 'Apply a phenylamide or CAA fungicide at first infection.',
          applicationMethod: 'High-volume sprayer at 7-day intervals',
          timing: 'Immediately at first detection — do not delay',
          saProducts: ['Acrobat MZ WG', 'Revus 250 SC', 'Ridomil Gold MZ'],
          waitingDays: 7,
        ),
        TreatmentOption(
          name: 'Copper-Based Preventative',
          type: TreatmentType.chemical,
          description:
              'Copper-based fungicides offer protective activity before infection.',
          applicationMethod: 'Regular spray programme under high-risk weather',
          timing: 'Start when blight-favourable weather (cool and wet) is forecast',
          saProducts: ['Nordox 75 WG', 'Kocide 2000', 'Cuprofix Ultra 40 WG'],
          waitingDays: 7,
        ),
      ],
      preventionTips: [
        'CRITICAL: Act immediately — late blight can wipe out a crop in 4–7 days',
        'Remove and destroy (burn) infected plant material — do not compost',
        'Avoid overhead irrigation during cool, humid weather',
        'Improve drainage in fields prone to waterlogging',
        'Monitor weather forecasts; spray preventatively before expected blight weather',
      ],
      requiresImmediateAction: true,
    ),

    // ── Wheat diseases ────────────────────────────────────────────────────
    DiseaseInfo(
      id: 'DIS-WHEAT-SR',
      name: 'Wheat Stem Rust',
      scientificName: 'Puccinia graminis f. sp. tritici',
      cropTypes: ['wheat'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.critical,
      description:
          'The most feared wheat disease globally. New strains like Ug99 '
          'can overcome major resistance genes. SA has strict monitoring programmes.',
      visualSymptoms:
          'Brick-red to orange-brown, elliptical pustules on stems and leaves. '
          'Infected tissue tears open (epidermis peels back). Late-season pustules '
          'turn black (teliospore stage). Infected stems lodge easily.',
      spread:
          'Wind-dispersed urediniospores travel thousands of kilometres. '
          'Has migrated from East Africa into SA on wind currents.',
      treatments: [
        TreatmentOption(
          name: 'Emergency Fungicide',
          type: TreatmentType.chemical,
          description: 'Apply a triazole fungicide immediately at first sign.',
          applicationMethod: 'Aerial or tractor boom — full field coverage',
          timing: 'Immediately at first pustule detection',
          saProducts: ['Tilt 250 EC', 'Punch C', 'Prosaro 420 SC'],
          waitingDays: 21,
        ),
      ],
      preventionTips: [
        'Report any suspected stem rust to the SA Wheat Breeding Programme (ARC)',
        'Use ARC-recommended resistant varieties for your region',
        'Scout from jointing (GS30) — check stems and leaf sheaths',
        'Keep accurate records to aid national monitoring efforts',
      ],
      requiresImmediateAction: true,
    ),

    // ── General / multi-crop ──────────────────────────────────────────────
    DiseaseInfo(
      id: 'DIS-GEN-APHID',
      name: 'Aphid Infestation',
      scientificName: 'Various Aphididae spp.',
      cropTypes: ['any'],
      category: DiseaseCategory.pest,
      severity: DiseaseSeverity.moderate,
      description:
          'Soft-bodied sap-sucking insects that colonise stems and undersides '
          'of leaves. Can transmit viral diseases and produce honeydew that '
          'encourages sooty mould growth.',
      visualSymptoms:
          'Dense colonies of small (1–3 mm) green, black, or grey insects on '
          'undersides of young leaves and shoot tips. Distorted, curled leaves. '
          'Sticky honeydew and black sooty mould on leaf surfaces.',
      spread:
          'Winged adults colonise new plants. Spread accelerated in warm, '
          'dry conditions. Ants farming aphids protect them from predators.',
      treatments: [
        TreatmentOption(
          name: 'Contact Insecticide',
          type: TreatmentType.chemical,
          description:
              'Use a selective aphicide or pyrethroid targeting aphids.',
          applicationMethod: 'Directed spray to undersides of leaves',
          timing: 'When colonies are established or virus risk is high',
          saProducts: ['Aphox 50 WP', 'Pirimor 500 WG', 'Cypermethrin 200 EC'],
          waitingDays: 7,
        ),
        TreatmentOption(
          name: 'Biological Control',
          type: TreatmentType.biological,
          description:
              'Encourage or release natural enemies: ladybirds, parasitic wasps, '
              'hoverflies.',
          applicationMethod: 'Reduce broad-spectrum insecticide use to allow '
              'natural enemy populations to build',
          timing: 'Ongoing management strategy',
        ),
        TreatmentOption(
          name: 'Water Spray',
          type: TreatmentType.cultural,
          description: 'High-pressure water spray dislodges aphid colonies.',
          applicationMethod: 'Knapsack sprayer with water — morning treatment',
          timing: 'At first colony detection on high-value crops',
        ),
      ],
      preventionTips: [
        'Avoid over-application of nitrogen fertilizer — lush growth attracts aphids',
        'Install reflective mulch to disorient aphid landing',
        'Monitor weekly; check undersides of young leaves',
        'Control ants that protect aphid colonies from predators',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-GEN-MITE',
      name: 'Red Spider Mite',
      scientificName: 'Tetranychus urticae',
      cropTypes: ['any'],
      category: DiseaseCategory.pest,
      severity: DiseaseSeverity.moderate,
      description:
          'A common pest in hot, dry conditions. Severe infestations can '
          'defoliate plants within a week if uncontrolled.',
      visualSymptoms:
          'Stippled, bronze-yellow speckling on upper leaf surface. Fine webbing '
          'on leaves and stems visible with hand lens. Tiny (0.5 mm) red or '
          'green mites visible on underside of leaves.',
      spread:
          'Dispersed by wind, contact, and on farm equipment. Populations '
          'explode rapidly in hot (> 30°C), dry, dusty conditions.',
      treatments: [
        TreatmentOption(
          name: 'Miticide Application',
          type: TreatmentType.chemical,
          description: 'Rotate between miticide classes to prevent resistance.',
          applicationMethod: 'Thorough coverage of undersides of leaves',
          timing:
              'At threshold — 5+ mites per leaf or visible webbing on young leaves',
          saProducts: ['Envidor 240 SC', 'Agrimek 18 EC', 'Danitol 10 EC'],
          waitingDays: 7,
        ),
        TreatmentOption(
          name: 'Predatory Mite Release',
          type: TreatmentType.biological,
          description:
              'Release Phytoseiulus persimilis in high-value crops or tunnels.',
          applicationMethod: 'Release onto affected plants early in the season',
          timing: 'When spider mite populations first appear',
        ),
      ],
      preventionTips: [
        'Maintain soil moisture — dry conditions favour mite outbreaks',
        'Avoid broad-spectrum insecticides that kill natural predators',
        'Dust roads and paths near fields to reduce dusty conditions',
        'Monitor with a hand lens every 5–7 days during hot, dry spells',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-GEN-N-DEF',
      name: 'Nitrogen Deficiency',
      scientificName: null,
      cropTypes: ['any'],
      category: DiseaseCategory.nutrientDeficiency,
      severity: DiseaseSeverity.moderate,
      description:
          'Nitrogen is the nutrient most commonly limiting crop growth in SA soils. '
          'Deficiency causes significant yield reduction if not corrected early.',
      visualSymptoms:
          'Uniform yellowing starting on oldest (lower) leaves, progressing '
          'upward. In maize: "V-shape" yellowing along the midrib. Plants are '
          'stunted with pale green to yellow-green colour overall.',
      spread: 'Not infectious — caused by insufficient N in soil, leaching, '
          'waterlogging (denitrification), or lack of fertilizer.',
      treatments: [
        TreatmentOption(
          name: 'Side-Dress Nitrogen',
          type: TreatmentType.cultural,
          description: 'Apply LAN (28% N) or Urea in split applications.',
          applicationMethod: 'Side-band application at base of plants',
          timing: 'At V4–V6 in maize; at tillering in small grains',
          saProducts: ['LAN 28%', 'Urea 46% N', 'Nitrobor 27%'],
        ),
        TreatmentOption(
          name: 'Foliar Urea Spray',
          type: TreatmentType.chemical,
          description: 'Apply 0.5–1% urea solution as a foliar feed.',
          applicationMethod: 'Knapsack sprayer on leaves — avoid runoff',
          timing: 'As an emergency corrective measure only',
        ),
      ],
      preventionTips: [
        'Base fertilizer rates on soil analysis results (sample every 3 years)',
        'Split N applications to reduce leaching losses',
        'Incorporate legume cover crops to build soil N reserves',
        'Monitor pH — N uptake is impaired below pH 5.5',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-GEN-FE-DEF',
      name: 'Iron Deficiency Chlorosis',
      scientificName: null,
      cropTypes: ['any'],
      category: DiseaseCategory.nutrientDeficiency,
      severity: DiseaseSeverity.low,
      description:
          'Common in high-pH (alkaline) or waterlogged soils. Correcting '
          'soil pH is more effective than foliar treatments long-term.',
      visualSymptoms:
          'Interveinal chlorosis on youngest (upper) leaves — leaf veins remain '
          'green while tissue between veins turns yellow to white. '
          'Lower leaves remain green initially.',
      spread: 'Not infectious — caused by high soil pH (> 7.5), waterlogging, '
          'or excess phosphate fixing Fe in the soil.',
      treatments: [
        TreatmentOption(
          name: 'Foliar Iron Chelate',
          type: TreatmentType.chemical,
          description: 'Apply Fe-EDTA or Fe-DTPA chelate as a foliar spray.',
          applicationMethod: 'Knapsack sprayer on affected leaves',
          timing: 'At first sign of chlorosis on young leaves',
          saProducts: ['Sequestrene 138 Fe', 'Fetrilon Combi 1'],
        ),
        TreatmentOption(
          name: 'Soil Acidification',
          type: TreatmentType.cultural,
          description: 'Apply elemental sulphur to lower soil pH over time.',
          applicationMethod: 'Incorporated with tillage',
          timing: 'Off-season soil preparation',
        ),
      ],
      preventionTips: [
        'Test soil pH annually — target pH 5.5–6.5 for most crops',
        'Avoid over-liming soils',
        'Improve drainage to prevent waterlogging',
        'Use iron-efficient crop varieties where available',
      ],
      requiresImmediateAction: false,
    ),
    DiseaseInfo(
      id: 'DIS-GEN-PM',
      name: 'Powdery Mildew',
      scientificName: 'Various Erysiphaceae spp.',
      cropTypes: ['any'],
      category: DiseaseCategory.fungal,
      severity: DiseaseSeverity.moderate,
      description:
          'A common fungal disease that covers leaf surfaces with white powder. '
          'Thrives in warm days, cool nights, and moderate humidity.',
      visualSymptoms:
          'White, powdery fungal growth on upper leaf surface. Affected leaves '
          'may become yellow, distorted, or drop prematurely. Stems and flowers '
          'may also be affected in severe cases.',
      spread:
          'Windborne conidia spread rapidly. Unlike most fungi, does NOT require '
          'free water — thrives in dry conditions with high relative humidity.',
      treatments: [
        TreatmentOption(
          name: 'Sulphur Fungicide',
          type: TreatmentType.chemical,
          description: 'Wettable sulphur is highly effective against powdery mildew.',
          applicationMethod: 'Knapsack or boom sprayer',
          timing: 'At first sign; repeat every 10–14 days',
          saProducts: ['Thiovit Jet 80 WG', 'Sulphur 800 WP', 'Kumulus DF'],
          waitingDays: 7,
        ),
        TreatmentOption(
          name: 'Bicarbonate Spray',
          type: TreatmentType.biological,
          description:
              'Sodium or potassium bicarbonate (0.5%) disrupts spore germination.',
          applicationMethod: 'Knapsack at early infection stages',
          timing: 'Preventive or at very early infection',
        ),
      ],
      preventionTips: [
        'Improve air circulation through pruning and wider row spacing',
        'Avoid excessive nitrogen fertilizer',
        'Remove heavily infected plant material',
        'Choose mildew-resistant varieties where available',
      ],
      requiresImmediateAction: false,
    ),
    // ── Healthy ───────────────────────────────────────────────────────────
    DiseaseInfo(
      id: 'DIS-HEALTHY',
      name: 'Healthy Plant',
      scientificName: null,
      cropTypes: ['any'],
      category: DiseaseCategory.healthy,
      severity: DiseaseSeverity.low,
      description:
          'No disease or deficiency detected. The plant appears vigorous and healthy.',
      visualSymptoms:
          'Uniform, deep-green leaf colour. No lesions, discolouration, or '
          'distortion visible. Strong stem, normal leaf size.',
      spread: 'N/A',
      treatments: [],
      preventionTips: [
        'Continue current management practices',
        'Monitor weekly as a preventive routine',
        'Maintain optimal soil moisture and fertility',
      ],
      requiresImmediateAction: false,
    ),
  ];

  // ── Interface implementation ──────────────────────────────────────────────

  @override
  Future<List<DiseaseInfo>> getDiseaseLibrary() async {
    await Future.delayed(_kDelay);
    return List.unmodifiable(_diseases);
  }

  @override
  Future<DiseaseDetectionResult> detectDisease({
    required String imagePath,
    String? cropHint,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Filter candidates by crop hint if provided.
    final candidates = cropHint == null
        ? _diseases
        : _diseases
            .where((d) =>
                d.cropTypes.contains(cropHint.toLowerCase()) ||
                d.cropTypes.contains('any'))
            .toList();

    // Seed random with hash of imagePath for reproducibility per image.
    final rng = Random(imagePath.hashCode);

    // Assign confidence scores — healthy always gets a base score.
    final scored = <DiseaseMatch>[];
    for (final disease in candidates) {
      double conf;
      if (disease.id == 'DIS-HEALTHY') {
        conf = 0.35 + rng.nextDouble() * 0.35; // 0.35–0.70
      } else {
        conf = rng.nextDouble() * 0.65; // 0.00–0.65
      }
      scored.add(DiseaseMatch(disease: disease, confidence: conf));
    }

    // Sort descending by confidence.
    scored.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Boost the top result to be plausible.
    final top = scored.first;
    final boosted = [
      DiseaseMatch(
        disease: top.disease,
        confidence: (top.confidence + 0.25).clamp(0.0, 0.98),
      ),
      ...scored.skip(1).take(3),
    ];

    return DiseaseDetectionResult(
      id: 'SCAN-${DateTime.now().millisecondsSinceEpoch}',
      detectedAt: DateTime.now(),
      imagePath: imagePath,
      matches: boosted,
      cropHint: cropHint,
    );
  }
}
