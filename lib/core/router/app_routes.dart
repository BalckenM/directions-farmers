/// Named route path constants for GoRouter.
// ignore_for_file: avoid_classes_with_only_static_members
abstract final class AppRoutes {
  // ── Shell (bottom nav) ────────────────────────────────────────────────────────
  static const String dashboard = '/';
  static const String livestock = '/livestock';
  static const String events = '/events';
  static const String production = '/production';
  static const String settings = '/settings';

  // ── Livestock sub-routes ──────────────────────────────────────────────────────
  static const String livestockSpecies = '/livestock/:species';
  static const String animalDetail = '/livestock/:species/:id';
  static const String addAnimal = '/livestock/:species/add';
  static const String editAnimal = '/livestock/:species/:id/edit';
  static const String groups = '/livestock/groups';
  static const String addGroup = '/livestock/groups/add';
  static String groupDetailPath(String id) => '/livestock/groups/$id';
  static String editGroupPath(String id) => '/livestock/groups/$id/edit';

  // ── Events sub-routes ─────────────────────────────────────────────────────────
  static const String healthEvents = '/events/health';
  static const String weightRecords = '/events/weight';
  static const String breedingEvents = '/events/breeding';
  static const String addHealthEvent = '/events/health/add';
  static const String addWeightRecord = '/events/weight/add';
  static const String addBreedingEvent = '/events/breeding/add';
  static const String alerts = '/events/alerts';

  // ── Production sub-routes ─────────────────────────────────────────────────────
  static const String milkRecords = '/production/milk';
  static const String eggRecords = '/production/eggs';
  static const String addMilkRecord = '/production/milk/add';
  static const String addEggRecord = '/production/eggs/add';

  // ── Settings sub-routes ───────────────────────────────────────────────────────
  static const String settingsFarm = '/settings/farm';
  static const String settingsAccount = '/settings/account';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsTheme = '/settings/theme';

  // ── Record sub-routes (unified Events + Production) ──────────────────────────
  static const String record = '/record';
  static const String recordHealth = '/record/health';
  static const String addRecordHealth = '/record/health/add';
  static const String recordWeight = '/record/weight';
  static const String addRecordWeight = '/record/weight/add';
  static const String recordBreeding = '/record/breeding';
  static const String addRecordBreeding = '/record/breeding/add';
  static const String recordMilk = '/record/milk';
  static const String addRecordMilk = '/record/milk/add';
  static const String recordEggs = '/record/eggs';
  static const String addRecordEggs = '/record/eggs/add';
  static const String recordAlerts = '/record/alerts';
  static const String recordWool = '/record/wool';
  static const String addRecordWool = '/record/wool/add';
  static const String recordFeed = '/record/feed';
  static const String addRecordFeed = '/record/feed/add';

  // ── Traceability ──────────────────────────────────────────────────────────────
  static const String movementRecords = '/traceability/movements';
  static const String addMovementRecord = '/traceability/movements/add';

  // ── Financial records ─────────────────────────────────────────────────────────
  static const String financial = '/financial';
  static const String addFinancialRecord = '/financial/add';

  // ── Insights ──────────────────────────────────────────────────────────────────
  static const String insights = '/insights';
  static const String marketPrices = '/insights/market-prices';

  // ── Reports ────────────────────────────────────────────────────────────────────
  static const String reports = '/insights/reports';

  static const String settingsPaddocks = '/settings/paddocks';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String onboarding = '/onboarding';

  // ── Crop Farming ──────────────────────────────────────────────────────────────
  static const String crop         = '/crop';
  static const String cropCatalog  = '/crop/catalog';
  static String cropDetailPath(String cropId) => '/crop/catalog/$cropId';
  static const String cropFields   = '/crop/fields';
  static String cropFieldDetailPath(String fieldId) => '/crop/fields/$fieldId';
  static const String addCropField   = '/crop/fields/add';
  static String editCropFieldPath(String fieldId) => '/crop/fields/$fieldId/edit';
  static String plantedCropDetailPath(String fieldId, String planId) =>
      '/crop/fields/$fieldId/plan/$planId';
  static const String cropSeasons    = '/crop/seasons';
  static const String addCropSeason    = '/crop/seasons/add';
  static const String cropSeasonDetail = '/crop/seasons/detail';
  static const String cropCalendar   = '/crop/calendar';
  static const String cropTasks      = '/crop/tasks';
  static String cropTaskDetailPath(String id) => '/crop/tasks/$id';
  static const String addCropTask    = '/crop/tasks/add';
  static const String cropWeather    = '/crop/weather';
  static const String cropPests      = '/crop/pests';
  static const String sprayDetail    = '/crop/pests/spray/detail';
  static const String addPestObs     = '/crop/pests/add';
  static const String addSprayRecord = '/crop/pests/spray/add';
  static const String cropExpenses   = '/crop/expenses';
  static const String addCropExpense = '/crop/expenses/add';
  static const String cropHarvest    = '/crop/harvest';
  static const String addCropHarvest = '/crop/harvest/add';
  static const String cropSales         = '/crop/sales';
  static const String addCropSale       = '/crop/sales/add';
  static const String cropProfitability = '/crop/profitability';
  static const String cropAdvisory      = '/crop/advisory';
  static String cropAdvisoryDetailPath(String id) => '/crop/advisory/$id';
  static const String addPlantingPlan   = '/crop/fields/plan/add';
  static const String editCropSeason    = '/crop/seasons/edit';
  static const String editPlantingPlan  = '/crop/fields/plan/edit';
  static const String editPestObs       = '/crop/pests/edit';
  static const String editSprayRecord   = '/crop/pests/spray/edit';
  static const String harvestDetail    = '/crop/harvest/detail';
  static const String editHarvestRecord = '/crop/harvest/edit';
  static const String saleDetail        = '/crop/sales/detail';
  static const String editCropSale      = '/crop/sales/edit';
  static const String editCropExpense   = '/crop/expenses/edit';

  // ── Utility routes ────────────────────────────────────────────────────────────
  static const String notFound = '/404';

  // ── Species management hubs (one per species, entry point) ──────────────────
  // go_router prioritises concrete paths over parameterised ones.

  // Poultry — dashboard at /livestock/poultry (flock list IS the landing page)
  static const String poultryHub = '/livestock/poultry';
  static const String poultryFlocks = '/livestock/poultry/flocks';
  static const String addFlock = '/livestock/poultry/new';
  static String flockDetailPath(String flockId) =>
      '/livestock/poultry/$flockId';
  static String addPoultryDailyRecord(String flockId) =>
      '/livestock/poultry/$flockId/daily/add';
  static String harvestRecord(String flockId) =>
      '/livestock/poultry/$flockId/harvest';
  static String feedPhases(String flockId) =>
      '/livestock/poultry/$flockId/feed-phases';
  static String addMedication(String flockId) =>
      '/livestock/poultry/$flockId/medications/new';
  static String financialScreen(String flockId) =>
      '/livestock/poultry/$flockId/financial';
  static String addFeedPhase(String flockId) =>
      '/livestock/poultry/$flockId/feed-phases/new';
  static String addDiseaseEvent(String flockId) =>
      '/livestock/poultry/$flockId/health/new';
  static String addEggSale(String flockId) =>
      '/livestock/poultry/$flockId/egg-sales/new';
  static String addChickSale(String flockId) =>
      '/livestock/poultry/$flockId/chick-sales/new';
  static const String inventory = '/livestock/poultry/inventory';
  static const String addDelivery =
      '/livestock/poultry/inventory/delivery/new';
  static const String invoiceGenerator = '/livestock/poultry/invoice';
  static const String poultryHouses = '/livestock/poultry/houses';
  static String invoiceForFlock(String flockId) =>
      '/livestock/poultry/invoice?flockId=$flockId';
  static const String poultryVaccinations  = '/livestock/poultry/vaccinations';
  static const String poultryDailyRecords  = '/livestock/poultry/daily-records';
  static const String poultryFeedPhasesHub = '/livestock/poultry/feed-phases-hub';
  static const String poultryHealthEvents  = '/livestock/poultry/health-events';
  static const String poultryFinancialsHub = '/livestock/poultry/financials-hub';
  static const String poultryReports       = '/livestock/poultry/reports';

  // Aquaculture — hub at /livestock/aquaculture, units board nested
  static const String aquacultureHub = '/livestock/aquaculture';
  static const String aquacultureUnits = '/livestock/aquaculture/units';
  static String aquaUnitDetailPath(String unitId) =>
      '/livestock/aquaculture/units/$unitId';

  // Apiculture / Bees — hub at /livestock/bees, hive board nested
  static const String apicultureHub = '/livestock/bees';
  static const String apiculture = '/livestock/bees/hives';
  static String hiveDetailPath(String hiveId) =>
      '/livestock/bees/hives/$hiveId';

  // Goat module
  static const String goatsHub = '/livestock/goats';
  static const String goatList = '/livestock/goats/herd';
  static const String addGoat = '/livestock/goats/new';
  static String goatDetailPath(String id) => '/livestock/goats/$id';
  static String editGoatPath(String id) => '/livestock/goats/$id/edit';
  static String goatHealthPath(String id) => '/livestock/goats/$id/health';
  static String goatBreedingPath(String id) => '/livestock/goats/$id/breeding';
  static String goatKiddingPath(String id) => '/livestock/goats/$id/kidding';
  static String addKidPath(String damId) => '/livestock/goats/$damId/add-kid';
  static String goatMilkPath(String id) => '/livestock/goats/$id/milk';
  static String goatShearingPath(String id) => '/livestock/goats/$id/shearing';
  static String goatWeightsPath(String id) => '/livestock/goats/$id/weights';
  static String goatFinancialsPath(String id) =>
      '/livestock/goats/$id/financials';
  static String addGoatMedicationPath(String id) =>
      '/livestock/goats/$id/add-medication';
  static const String goatReports = '/livestock/goats/reports';
  static const String goatInventory = '/livestock/goats/inventory';
  static const String goatPasture = '/livestock/goats/pasture';
  static const String crossHerdComparison = '/livestock/goats/compare';
  static const String goatPregnancyCheck = '/livestock/goats/pregnancy-check';
  static const String goatBodyCondition = '/livestock/goats/bcs';
  static const String goatVaccinations = '/livestock/goats/vaccinations';
  static const String goatSales = '/livestock/goats/sales';
  static const String goatFamacha = '/livestock/goats/famacha';
  static String goatBreedPath(String breed) =>
      '/livestock/goats/breed/${Uri.encodeComponent(breed)}';

  // Cattle module
  static const String cattleHub = '/livestock/cattle';
  static const String cattleList = '/livestock/cattle/herd';
  static const String addCattle = '/livestock/cattle/new';
  static String cattleDetailPath(String id) => '/livestock/cattle/$id';
  static String editCattlePath(String id) => '/livestock/cattle/$id/edit';
  static String cattleHealthPath(String id) => '/livestock/cattle/$id/health';
  static String cattleBreedingPath(String id) =>
      '/livestock/cattle/$id/breeding';
  static String cattleCalvingPath(String id) =>
      '/livestock/cattle/$id/calving';
  static String addCalfPath(String damId) =>
      '/livestock/cattle/$damId/add-calf';
  static String cattleMilkPath(String id) => '/livestock/cattle/$id/milk';
  static String cattleWeightsPath(String id) => '/livestock/cattle/$id/weights';
  static String cattleFinancialsPath(String id) =>
      '/livestock/cattle/$id/financials';
  static String addCattleMedicationPath(String id) =>
      '/livestock/cattle/$id/add-medication';
  static const String cattleReports = '/livestock/cattle/reports';
  static const String cattleInventory = '/livestock/cattle/inventory';
  static const String cattlePasture = '/livestock/cattle/pasture';
  static const String cattleCrossHerd = '/livestock/cattle/compare';
  static const String cattlePregnancyCheck = '/livestock/cattle/pregnancy-check';
  static const String cattleBodyCondition = '/livestock/cattle/bcs';
  static const String cattleVaccinations = '/livestock/cattle/vaccinations';
  static const String cattleSales = '/livestock/cattle/sales';
  static const String cattleDipping = '/livestock/cattle/dipping';
  static const String cattleFeedSupplement = '/livestock/cattle/feed-supplement';
  static String cattleBreedPath(String breed) =>
      '/livestock/cattle/breed/${Uri.encodeComponent(breed)}';

  // Pigs — hub at /livestock/pigs, sow board nested
  static const String pigsHub = '/livestock/pigs';
  static const String pigsBoard = '/livestock/pigs/board';
  static String sowDetailPath(String sowId) => '/livestock/pigs/board/$sowId';

  // ── Helper to build parameterised paths ───────────────────────────────────────
  static String livestockSpeciesPath(String species) =>
      '/livestock/$species';

  static String animalDetailPath(String species, String id) =>
      '/livestock/$species/$id';

  static String addAnimalPath(String species) =>
      '/livestock/$species/add';

  static String editAnimalPath(String species, String id) =>
      '/livestock/$species/$id/edit';
}
