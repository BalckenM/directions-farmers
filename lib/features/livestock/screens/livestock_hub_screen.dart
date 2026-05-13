import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/livestock_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_drawer.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/section_header.dart';
import '../../livestock/models/animal.dart';
import '../../livestock/providers/livestock_providers.dart';
import '../../events/providers/alerts_provider.dart';
import '../../poultry/models/poultry_flock.dart';
import '../../poultry/providers/poultry_providers.dart';

// ── Species-level config ──────────────────────────────────────────────────────

class _SpeciesConfig {
  const _SpeciesConfig({
    required this.displayName,
    required this.icon,
    required this.primaryColor,
    required this.containerColor,
    required this.unit,
    required this.automations,
    required this.tools,
    required this.sensors,
    required this.kpis,
    this.specializedRoute,
    this.specializedLabel,
  });

  final String displayName;
  final IconData icon;
  final Color primaryColor;
  final Color containerColor;
  final String unit; // e.g. "head", "flock", "hive"
  final List<_AutomationItem> automations;
  final List<_ToolItem> tools;
  final List<_SensorReading> sensors;
  final List<_KpiItem> kpis;
  final String? specializedRoute; // if non-null, Animals tab navigates here
  final String? specializedLabel; // "View Flocks →" etc.
}

class _AutomationItem {
  const _AutomationItem({required this.label, required this.icon, required this.initialOn});
  final String label;
  final IconData icon;
  final bool initialOn;
}

class _ToolItem {
  const _ToolItem({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}

class _SensorReading {
  const _SensorReading({required this.label, required this.value, required this.unit, required this.icon, this.status = _SensorStatus.normal});
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final _SensorStatus status;
}

enum _SensorStatus { normal, warning, critical }

class _KpiItem {
  const _KpiItem({required this.label, required this.value, required this.sub});
  final String label;
  final String value;
  final String sub;
}

// ── Species configurations ────────────────────────────────────────────────────

final Map<String, _SpeciesConfig> _speciesConfigs = {
  'poultry': _SpeciesConfig(
    displayName: 'Poultry',
    icon: Icons.egg_alt_rounded,
    primaryColor: AppColors.poultryColor,
    containerColor: AppColors.poultryColorContainer,
    unit: 'flocks',
    specializedRoute: AppRoutes.poultryFlocks,
    specializedLabel: 'Open Flock Manager',
    kpis: [
      _KpiItem(label: 'Total Birds', value: '4 820', sub: 'across all flocks'),
      _KpiItem(label: 'FCR (24 h)', value: '1.82', sub: 'feed conversion ratio'),
      _KpiItem(label: 'Mortality', value: '0.4%', sub: 'last 7 days'),
      _KpiItem(label: 'Prod. cost/bird', value: 'R 42.10', sub: 'batch avg'),
    ],
    sensors: [
      _SensorReading(label: 'House Temp', value: '22', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '68', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'CO₂', value: '1 840', unit: 'ppm', icon: Icons.air_rounded, status: _SensorStatus.warning),
      _SensorReading(label: 'NH₃', value: '14', unit: 'ppm', icon: Icons.science_outlined),
    ],
    automations: [
      _AutomationItem(label: 'Ventilation', icon: Icons.air_rounded, initialOn: true),
      _AutomationItem(label: 'Auto-feeder', icon: Icons.restaurant_rounded, initialOn: true),
      _AutomationItem(label: 'Lights (14 h)', icon: Icons.light_mode_rounded, initialOn: true),
      _AutomationItem(label: 'Drinkers', icon: Icons.water_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Flock Manager',  icon: Icons.format_list_bulleted_rounded,   route: AppRoutes.poultryFlocks),
      _ToolItem(label: 'Add Flock',      icon: Icons.add_circle_outline_rounded,     route: AppRoutes.addFlock),
      _ToolItem(label: 'Inventory',      icon: Icons.inventory_2_rounded,             route: AppRoutes.inventory),
      _ToolItem(label: 'Houses',         icon: Icons.home_work_rounded,               route: AppRoutes.poultryHouses),
      _ToolItem(label: 'New Delivery',   icon: Icons.local_shipping_rounded,          route: AppRoutes.addDelivery),
      _ToolItem(label: 'Invoice',        icon: Icons.receipt_long_rounded,            route: AppRoutes.invoiceGenerator),
      _ToolItem(label: 'Vaccination',    icon: Icons.vaccines_rounded,                route: AppRoutes.poultryVaccinations),
      _ToolItem(label: 'Daily Records',  icon: Icons.edit_note_rounded,               route: AppRoutes.poultryDailyRecords),
      _ToolItem(label: 'Feed Phases',    icon: Icons.restaurant_menu_rounded,         route: AppRoutes.poultryFeedPhasesHub),
      _ToolItem(label: 'Health Events',  icon: Icons.monitor_heart_rounded,           route: AppRoutes.poultryHealthEvents),
      _ToolItem(label: 'Financials',     icon: Icons.account_balance_wallet_rounded,  route: AppRoutes.poultryFinancialsHub),
      _ToolItem(label: 'Reports',        icon: Icons.description_rounded,             route: AppRoutes.poultryReports),
    ],
  ),
  'pigs': _SpeciesConfig(
    displayName: 'Pigs',
    icon: Icons.ramen_dining_rounded,
    primaryColor: AppColors.pigColor,
    containerColor: AppColors.pigColorContainer,
    unit: 'sows',
    specializedRoute: AppRoutes.pigsBoard,
    specializedLabel: 'Open Sow Board',
    kpis: [
      _KpiItem(label: 'Total Pigs', value: '284', sub: 'all groups'),
      _KpiItem(label: 'Born Alive', value: '11.4', sub: 'avg per litter'),
      _KpiItem(label: 'Weaning Age', value: '21 days', sub: 'target: 21 d'),
      _KpiItem(label: 'Feed Phase', value: 'Grower', sub: 'barn A · 3/4 groups'),
    ],
    sensors: [
      _SensorReading(label: 'Barn Temp', value: '20', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '72', unit: '%', icon: Icons.water_drop_outlined, status: _SensorStatus.warning),
      _SensorReading(label: 'Mist System', value: 'OFF', unit: '', icon: Icons.shower_outlined),
      _SensorReading(label: 'Pit Temp', value: '19', unit: '°C', icon: Icons.thermostat_auto_rounded),
    ],
    automations: [
      _AutomationItem(label: 'Misting/Drip', icon: Icons.shower_rounded, initialOn: false),
      _AutomationItem(label: 'Auto-feeder', icon: Icons.restaurant_rounded, initialOn: true),
      _AutomationItem(label: 'Heat Lamps', icon: Icons.wb_sunny_rounded, initialOn: true),
      _AutomationItem(label: 'Ventilation', icon: Icons.air_rounded, initialOn: true),
    ],
    tools: [
      _ToolItem(label: 'Farrowing', icon: Icons.child_friendly_rounded, route: AppRoutes.pigsBoard),
      _ToolItem(label: 'Feed Phases', icon: Icons.restaurant_menu_rounded, route: AppRoutes.recordFeed),
      _ToolItem(label: 'Health Events', icon: Icons.monitor_heart_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Weight Records', icon: Icons.monitor_weight_rounded, route: AppRoutes.recordWeight),
      _ToolItem(label: 'Mortality Log', icon: Icons.crisis_alert_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
  'aquaculture': _SpeciesConfig(
    displayName: 'Aquaculture',
    icon: Icons.set_meal_rounded,
    primaryColor: AppColors.aquacultureColor,
    containerColor: AppColors.aquacultureColorContainer,
    unit: 'ponds/tanks',
    specializedRoute: AppRoutes.aquacultureUnits,
    specializedLabel: 'Open Pond Manager',
    kpis: [
      _KpiItem(label: 'Total Stock', value: '12 400', sub: 'fish across 6 units'),
      _KpiItem(label: 'Avg Weight', value: '480 g', sub: 'target: 500 g'),
      _KpiItem(label: 'Survival Rate', value: '96.2%', sub: 'this cycle'),
      _KpiItem(label: 'FCR', value: '1.6', sub: 'feed conversion'),
    ],
    sensors: [
      _SensorReading(label: 'Water Temp', value: '24', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'DO Level', value: '6.8', unit: 'mg/L', icon: Icons.bubble_chart_outlined),
      _SensorReading(label: 'pH', value: '7.2', unit: '', icon: Icons.science_outlined),
      _SensorReading(label: 'Ammonia', value: '0.04', unit: 'ppm', icon: Icons.air_rounded, status: _SensorStatus.warning),
    ],
    automations: [
      _AutomationItem(label: 'Aerators', icon: Icons.bubble_chart_rounded, initialOn: true),
      _AutomationItem(label: 'Auto-feeder', icon: Icons.restaurant_rounded, initialOn: true),
      _AutomationItem(label: 'Pump A', icon: Icons.water_rounded, initialOn: true),
      _AutomationItem(label: 'UV Filter', icon: Icons.filter_alt_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Water Quality', icon: Icons.water_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Feed Log', icon: Icons.restaurant_menu_rounded, route: AppRoutes.recordFeed),
      _ToolItem(label: 'Sampling', icon: Icons.science_rounded, route: AppRoutes.recordWeight),
      _ToolItem(label: 'Harvest Plan', icon: Icons.agriculture_rounded, route: AppRoutes.reports),
      _ToolItem(label: 'Health Events', icon: Icons.monitor_heart_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
  'bees': _SpeciesConfig(
    displayName: 'Apiculture',
    icon: Icons.hive_rounded,
    primaryColor: AppColors.beesColor,
    containerColor: AppColors.beesColorContainer,
    unit: 'hives',
    specializedRoute: AppRoutes.apiculture,
    specializedLabel: 'Open Hive Manager',
    kpis: [
      _KpiItem(label: 'Total Hives', value: '36', sub: '3 apiaries'),
      _KpiItem(label: 'Honey Est.', value: '142 kg', sub: 'next harvest'),
      _KpiItem(label: 'Colony Strength', value: '82%', sub: 'avg all hives'),
      _KpiItem(label: 'Varroa Load', value: '1.8%', sub: 'below 2% threshold'),
    ],
    sensors: [
      _SensorReading(label: 'Hive Weight', value: '+0.4', unit: 'kg/d', icon: Icons.monitor_weight_outlined),
      _SensorReading(label: 'Hive Temp', value: '35', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '56', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'Activity', value: 'High', unit: '', icon: Icons.bolt_rounded),
    ],
    automations: [
      _AutomationItem(label: 'Smart Scale', icon: Icons.monitor_weight_rounded, initialOn: true),
      _AutomationItem(label: 'Temp Alert', icon: Icons.notifications_rounded, initialOn: true),
      _AutomationItem(label: 'Swarm Alert', icon: Icons.warning_rounded, initialOn: true),
      _AutomationItem(label: 'Feed Syrup', icon: Icons.local_drink_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Inspections', icon: Icons.search_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Varroa Counts', icon: Icons.bug_report_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Honey Harvest', icon: Icons.emoji_nature_rounded, route: AppRoutes.reports),
      _ToolItem(label: 'Queen Status', icon: Icons.star_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Movements', icon: Icons.swap_horiz_rounded, route: AppRoutes.movementRecords),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
  'cattle': _SpeciesConfig(
    displayName: 'Cattle',
    icon: Icons.local_offer_rounded,
    primaryColor: AppColors.cattleColor,
    containerColor: AppColors.cattleColorContainer,
    unit: 'head',
    kpis: [
      _KpiItem(label: 'Total Head', value: '–', sub: 'loading...'),
      _KpiItem(label: 'ADG', value: '0.95 kg', sub: 'avg daily gain'),
      _KpiItem(label: 'Pregnant', value: '–', sub: '% of cows'),
      _KpiItem(label: 'BCS Avg', value: '3.2', sub: 'body condition score'),
    ],
    sensors: [
      _SensorReading(label: 'Pasture Temp', value: '18', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Water Trough', value: 'Full', unit: '', icon: Icons.water_rounded),
      _SensorReading(label: 'Humidity', value: '61', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'Wind', value: '12', unit: 'km/h', icon: Icons.air_rounded),
    ],
    automations: [
      _AutomationItem(label: 'Water Pump', icon: Icons.water_rounded, initialOn: true),
      _AutomationItem(label: 'Gate Alert', icon: Icons.sensor_door_rounded, initialOn: true),
      _AutomationItem(label: 'Geofence', icon: Icons.location_on_rounded, initialOn: false),
      _AutomationItem(label: 'Feed Mixer', icon: Icons.restaurant_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Reproduction', icon: Icons.favorite_rounded, route: AppRoutes.recordBreeding),
      _ToolItem(label: 'BCS Scores', icon: Icons.monitor_weight_rounded, route: AppRoutes.recordWeight),
      _ToolItem(label: 'Health Events', icon: Icons.monitor_heart_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'LITS Export', icon: Icons.upload_rounded, route: AppRoutes.movementRecords),
      _ToolItem(label: 'Movements', icon: Icons.swap_horiz_rounded, route: AppRoutes.movementRecords),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
  'sheep': _SpeciesConfig(
    displayName: 'Sheep',
    icon: Icons.grass_rounded,
    primaryColor: AppColors.sheepColor,
    containerColor: AppColors.sheepColorContainer,
    unit: 'head',
    kpis: [
      _KpiItem(label: 'Total Head', value: '–', sub: 'loading...'),
      _KpiItem(label: 'Lambing %', value: '142%', sub: 'ewes lambed'),
      _KpiItem(label: 'Wool Avg', value: '4.8 kg', sub: 'per animal · last clip'),
      _KpiItem(label: 'FAMACHA', value: '76% grade 1', sub: 'last inspection'),
    ],
    sensors: [
      _SensorReading(label: 'Pasture Temp', value: '17', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '58', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'Water Level', value: 'OK', unit: '', icon: Icons.water_rounded),
      _SensorReading(label: 'Wind Speed', value: '8', unit: 'km/h', icon: Icons.air_rounded),
    ],
    automations: [
      _AutomationItem(label: 'Water Pump', icon: Icons.water_rounded, initialOn: true),
      _AutomationItem(label: 'Gate Alert', icon: Icons.sensor_door_rounded, initialOn: true),
      _AutomationItem(label: 'Predator Alert', icon: Icons.warning_rounded, initialOn: true),
      _AutomationItem(label: 'Geofence', icon: Icons.location_on_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'FAMACHA Scores', icon: Icons.visibility_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Wool Records', icon: Icons.cut_rounded, route: AppRoutes.recordWool),
      _ToolItem(label: 'Reproduction', icon: Icons.favorite_rounded, route: AppRoutes.recordBreeding),
      _ToolItem(label: 'LITS Export', icon: Icons.upload_rounded, route: AppRoutes.movementRecords),
      _ToolItem(label: 'Health Events', icon: Icons.monitor_heart_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
  'goats': _SpeciesConfig(
    displayName: 'Goats',
    icon: Icons.eco_rounded,
    primaryColor: AppColors.goatColor,
    containerColor: AppColors.goatColorContainer,
    unit: 'head',
    specializedRoute: AppRoutes.goatList,
    specializedLabel: 'Open Goat Herd',
    kpis: [
      _KpiItem(label: 'Total Head', value: '–', sub: 'loading...'),
      _KpiItem(label: 'Kidding %', value: '148%', sub: 'does kidded'),
      _KpiItem(label: 'Milk Yield', value: '2.1 L/d', sub: 'avg per milking doe'),
      _KpiItem(label: 'FAMACHA', value: '68% grade 1', sub: 'last inspection'),
    ],
    sensors: [
      _SensorReading(label: 'Pasture Temp', value: '21', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '62', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'Water Level', value: 'Low', unit: '', icon: Icons.water_rounded, status: _SensorStatus.warning),
      _SensorReading(label: 'Wind', value: '6', unit: 'km/h', icon: Icons.air_rounded),
    ],
    automations: [
      _AutomationItem(label: 'Water Pump', icon: Icons.water_rounded, initialOn: true),
      _AutomationItem(label: 'Gate Alert', icon: Icons.sensor_door_rounded, initialOn: true),
      _AutomationItem(label: 'Milking Reminder', icon: Icons.alarm_rounded, initialOn: true),
      _AutomationItem(label: 'Predator Alert', icon: Icons.warning_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Herd Manager',    icon: Icons.format_list_bulleted_rounded,   route: AppRoutes.goatList),
      _ToolItem(label: 'Pregnancy Check', icon: Icons.favorite_rounded,               route: AppRoutes.goatPregnancyCheck),
      _ToolItem(label: 'Vaccinations',    icon: Icons.vaccines_rounded,               route: AppRoutes.goatVaccinations),
      _ToolItem(label: 'Body Condition',  icon: Icons.visibility_rounded,             route: AppRoutes.goatBodyCondition),
      _ToolItem(label: 'Sales & Finance', icon: Icons.account_balance_wallet_rounded, route: AppRoutes.goatSales),
      _ToolItem(label: 'FAMACHA',         icon: Icons.visibility_outlined,            route: AppRoutes.goatFamacha),
      _ToolItem(label: 'Reports',         icon: Icons.description_rounded,            route: AppRoutes.goatReports),
    ],
  ),
  'horses': _SpeciesConfig(
    displayName: 'Horses',
    icon: Icons.directions_run_rounded,
    primaryColor: AppColors.horseColor,
    containerColor: AppColors.horseColorContainer,
    unit: 'head',
    kpis: [
      _KpiItem(label: 'Total Head', value: '–', sub: 'loading...'),
      _KpiItem(label: 'Training Days', value: '18', sub: 'this month'),
      _KpiItem(label: 'Next Farrier', value: '12 days', sub: 'routine trim'),
      _KpiItem(label: 'BCS Avg', value: '5.2', sub: 'Henneke scale'),
    ],
    sensors: [
      _SensorReading(label: 'Stable Temp', value: '16', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '54', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'Water Trough', value: 'Full', unit: '', icon: Icons.water_rounded),
      _SensorReading(label: 'Paddock Gate', value: 'Closed', unit: '', icon: Icons.sensor_door_outlined),
    ],
    automations: [
      _AutomationItem(label: 'Water Auto-fill', icon: Icons.water_rounded, initialOn: true),
      _AutomationItem(label: 'Stable Lights', icon: Icons.light_mode_rounded, initialOn: false),
      _AutomationItem(label: 'Gate Sensors', icon: Icons.sensor_door_rounded, initialOn: true),
      _AutomationItem(label: 'Hay Dispenser', icon: Icons.grass_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Health Events', icon: Icons.monitor_heart_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Weight Records', icon: Icons.monitor_weight_rounded, route: AppRoutes.recordWeight),
      _ToolItem(label: 'Reproduction', icon: Icons.favorite_rounded, route: AppRoutes.recordBreeding),
      _ToolItem(label: 'Movements', icon: Icons.swap_horiz_rounded, route: AppRoutes.movementRecords),
      _ToolItem(label: 'Farrier Log', icon: Icons.build_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
  'rabbits': _SpeciesConfig(
    displayName: 'Rabbits',
    icon: Icons.cruelty_free_rounded,
    primaryColor: AppColors.rabbitColor,
    containerColor: AppColors.rabbitColorContainer,
    unit: 'head',
    kpis: [
      _KpiItem(label: 'Total Head', value: '–', sub: 'loading...'),
      _KpiItem(label: 'Litter Size', value: '7.8', sub: 'avg per doe'),
      _KpiItem(label: 'ADG', value: '38 g/d', sub: 'avg daily gain'),
      _KpiItem(label: 'FCR', value: '3.2', sub: 'feed conversion'),
    ],
    sensors: [
      _SensorReading(label: 'Hutch Temp', value: '19', unit: '°C', icon: Icons.thermostat_rounded),
      _SensorReading(label: 'Humidity', value: '60', unit: '%', icon: Icons.water_drop_outlined),
      _SensorReading(label: 'Ventilation', value: 'ON', unit: '', icon: Icons.air_rounded),
      _SensorReading(label: 'Water Level', value: 'OK', unit: '', icon: Icons.water_rounded),
    ],
    automations: [
      _AutomationItem(label: 'Auto-waterer', icon: Icons.water_rounded, initialOn: true),
      _AutomationItem(label: 'Auto-feeder', icon: Icons.restaurant_rounded, initialOn: true),
      _AutomationItem(label: 'Ventilation', icon: Icons.air_rounded, initialOn: true),
      _AutomationItem(label: 'Lights', icon: Icons.light_mode_rounded, initialOn: false),
    ],
    tools: [
      _ToolItem(label: 'Reproduction', icon: Icons.favorite_rounded, route: AppRoutes.recordBreeding),
      _ToolItem(label: 'Health Events', icon: Icons.monitor_heart_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Weight Records', icon: Icons.monitor_weight_rounded, route: AppRoutes.recordWeight),
      _ToolItem(label: 'Feed Log', icon: Icons.restaurant_menu_rounded, route: AppRoutes.recordFeed),
      _ToolItem(label: 'Mortality Log', icon: Icons.crisis_alert_rounded, route: AppRoutes.recordHealth),
      _ToolItem(label: 'Reports', icon: Icons.description_rounded, route: AppRoutes.reports),
    ],
  ),
};

_SpeciesConfig _configFor(String species) =>
    _speciesConfigs[species] ??
    _SpeciesConfig(
      displayName: LivestockConstants.displayName(species),
      icon: Icons.pets_rounded,
      primaryColor: AppColors.primary,
      containerColor: AppColors.primaryContainer,
      unit: 'head',
      kpis: [],
      sensors: [],
      automations: [],
      tools: [],
    );

// ── Screen ─────────────────────────────────────────────────────────────────────

class LivestockHubScreen extends StatefulWidget {
  const LivestockHubScreen({super.key, required this.species});
  final String species;

  @override
  State<LivestockHubScreen> createState() => _LivestockHubScreenState();
}

class _LivestockHubScreenState extends State<LivestockHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final List<bool> _autoStates;
  late final _SpeciesConfig _cfg;

  @override
  void initState() {
    super.initState();
    _cfg = _configFor(widget.species);
    _tabs = TabController(length: 2, vsync: this);
    _autoStates = _cfg.automations.map((a) => a.initialOn).toList();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      drawer: const FarmDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _cfg.displayName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
            Text(
              'Management Hub',
              style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (ctx, ref, _) {
              final alertCount = ref.watch(alertsProvider).length;
              return Badge(
                isLabelVisible: alertCount > 0,
                label: Text('$alertCount'),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(AppRoutes.recordAlerts),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabs,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              dividerColor: Colors.grey.shade200,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'Hub'),
                Tab(text: 'Flock Manager'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // Tab 0: Hub
          _HubTab(cfg: _cfg, autoStates: _autoStates, onAutoToggle: _toggle, species: widget.species),
          // Tab 1: Flock Manager
          _AnimalsTab(cfg: _cfg, species: widget.species),
        ],
      ),
    );
  }

  void _toggle(int i, bool v) => setState(() => _autoStates[i] = v);
}

// ── Hub Tab ────────────────────────────────────────────────────────────────────

class _HubTab extends StatelessWidget {
  const _HubTab({
    required this.cfg,
    required this.autoStates,
    required this.onAutoToggle,
    required this.species,
  });

  final _SpeciesConfig cfg;
  final List<bool> autoStates;
  final void Function(int, bool) onAutoToggle;
  final String species;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero banner with stats
        SliverToBoxAdapter(child: _HeroBanner(cfg: cfg, species: species)),

        // Poultry-specific: active flock summary + performance analytics
        if (species == 'poultry') ...[
          SliverToBoxAdapter(child: SectionHeader(title: 'Active Flocks')),
          SliverToBoxAdapter(child: _PoultryFlockSummary()),
          SliverToBoxAdapter(child: SectionHeader(title: 'Performance Analytics')),
          SliverToBoxAdapter(child: _PoultryBatchCharts()),
        ],

        // Sensor readings
        if (cfg.sensors.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Live Sensor Readings'),
          ),
          SliverToBoxAdapter(child: _SensorRow(sensors: cfg.sensors)),
        ],

        // Automation controls
        if (cfg.automations.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Automation Controls'),
          ),
          SliverToBoxAdapter(
            child: _AutomationGrid(
              automations: cfg.automations,
              states: autoStates,
              color: AppColors.primary,
              onToggle: onAutoToggle,
            ),
          ),
        ],

        // Management tools
        if (cfg.tools.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Management Tools'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingHorizontal,
                0,
                AppSpacing.pagePaddingHorizontal,
                AppSpacing.md),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.1,
              ),
              itemCount: cfg.tools.length,
              itemBuilder: (ctx, i) =>
                  _ToolCard(tool: cfg.tools[i], color: cfg.primaryColor, species: species),
            ),
          ),
        ],

        // SA-specific quick links
        SliverToBoxAdapter(
          child: SectionHeader(title: 'South Africa Tools'),
        ),
        SliverToBoxAdapter(
          child: _SAToolsPanel(species: species, cfg: cfg),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
      ],
    );
  }
}

// ── Hero banner ────────────────────────────────────────────────────────────────

String _fmtBirds(int n) {
  if (n == 0) return '0';
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u202f');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _HeroBanner extends ConsumerWidget {
  const _HeroBanner({required this.cfg, required this.species});
  final _SpeciesConfig cfg;
  final String species;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

    // For poultry: compute live KPIs from real flock data.
    final List<_KpiItem> kpis;
    if (species == 'poultry') {
      final flocksAsync = ref.watch(flocksProvider);
      kpis = flocksAsync.when(
        data: (flocks) {
          final active = flocks.where((f) => f.isActive).toList();
          final totalBirds = active.fold<int>(0, (s, f) => s + f.currentCount);
          final totalPlaced = active.fold<int>(0, (s, f) => s + f.placementCount);
          final totalMort = active.fold<int>(0, (s, f) => s + f.mortalityTotal);
          // Weighted FCR by current bird count.
          int fcrBirds = 0;
          double weightedFcr = 0;
          for (final f in active) {
            if (f.fcrToDate != null) {
              weightedFcr += f.fcrToDate! * f.currentCount;
              fcrBirds += f.currentCount;
            }
          }
          final avgFcr = fcrBirds > 0 ? weightedFcr / fcrBirds : 0.0;
          final mortPct = totalPlaced > 0 ? totalMort / totalPlaced * 100 : 0.0;
          final closed = flocks.length - active.length;
          return [
            _KpiItem(
              label: 'Active Birds',
              value: _fmtBirds(totalBirds),
              sub: '${active.length} flock${active.length == 1 ? '' : 's'} active',
            ),
            _KpiItem(
              label: 'FCR',
              value: fcrBirds > 0 ? avgFcr.toStringAsFixed(2) : '–',
              sub: 'feed conversion ratio',
            ),
            _KpiItem(
              label: 'Mortality',
              value: '${mortPct.toStringAsFixed(1)}%',
              sub: 'active flocks overall',
            ),
            _KpiItem(
              label: 'Total Flocks',
              value: '${flocks.length}',
              sub: '$closed closed · ${active.length} active',
            ),
          ];
        },
        loading: () => cfg.kpis,
        error: (_, _) => cfg.kpis,
      );
    } else {
      kpis = cfg.kpis;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI row
          if (kpis.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kpis.map((k) => _KpiChip(kpi: k)).toList(),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          // Last updated + status
          Row(
            children: [
              Icon(Icons.circle, color: Colors.white.withAlpha(200), size: 8),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Live · Updated just now',
                style: tt.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(180),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.kpi});
  final _KpiItem kpi;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi.value,
            style: tt.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            kpi.label,
            style: tt.labelSmall?.copyWith(
              color: Colors.white.withAlpha(230),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          Text(
            kpi.sub,
            style: tt.labelSmall?.copyWith(
              color: Colors.white.withAlpha(160),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sensor row ────────────────────────────────────────────────────────────────

class _SensorRow extends StatelessWidget {
  const _SensorRow({required this.sensors});
  final List<_SensorReading> sensors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal),
        scrollDirection: Axis.horizontal,
        itemCount: sensors.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (ctx, i) => _SensorCard(reading: sensors[i]),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.reading});
  final _SensorReading reading;

  Color get _statusColor {
    switch (reading.status) {
      case _SensorStatus.warning:
        return AppColors.warning;
      case _SensorStatus.critical:
        return AppColors.error;
      case _SensorStatus.normal:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 104,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(reading.icon, size: 14, color: _statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  reading.label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                reading.value,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
                  fontSize: 22,
                ),
              ),
              if (reading.unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    reading.unit,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          if (reading.status == _SensorStatus.warning)
            Text(
              'Review needed',
              style: tt.labelSmall?.copyWith(
                  color: AppColors.warning, fontSize: 8),
            ),
        ],
      ),
    );
  }
}

// ── Automation grid ───────────────────────────────────────────────────────────

class _AutomationGrid extends StatelessWidget {
  const _AutomationGrid({
    required this.automations,
    required this.states,
    required this.color,
    required this.onToggle,
  });

  final List<_AutomationItem> automations;
  final List<bool> states;
  final Color color;
  final void Function(int, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: List.generate(automations.length, (i) {
          final item = automations[i];
          final isOn = states[i];

          return InkWell(
            borderRadius: AppRadius.card,
            onTap: () => onToggle(i, !isOn),
            child: Container(
              width: (MediaQuery.of(context).size.width -
                      AppSpacing.pagePaddingHorizontal * 2 -
                      AppSpacing.sm) /
                  2,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: isOn ? color.withAlpha(15) : cs.surfaceContainerLow,
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: isOn ? color.withAlpha(80) : cs.outlineVariant,
                  width: isOn ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isOn ? color : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                      style: tt.bodySmall?.copyWith(
                        fontWeight:
                            isOn ? FontWeight.w700 : FontWeight.w500,
                        color: isOn ? color : cs.onSurface,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: isOn,
                    onChanged: (v) => onToggle(i, v),
                    activeThumbColor: color,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Tool card ─────────────────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.color, required this.species});
  final _ToolItem tool;
  final Color color;
  final String species;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push('${tool.route}?species=$species'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tool.icon, color: color, size: 18),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tool.label,
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SA Tools panel ────────────────────────────────────────────────────────────

class _SAToolsPanel extends StatelessWidget {
  const _SAToolsPanel({required this.species, required this.cfg});
  final String species;
  final _SpeciesConfig cfg;

  static const _allTools = [
    ('LITS Traceability', Icons.qr_code_rounded, ['cattle', 'sheep', 'goats']),
    ('FAMACHA Scoring', Icons.visibility_rounded, ['sheep', 'goats']),
    ('BCS Assessment', Icons.monitor_weight_rounded, ['cattle', 'sheep']),
    ('FMD Zone Status', Icons.location_on_rounded, ['cattle', 'sheep', 'goats', 'pigs']),
    ('Market Prices (ZAR)', Icons.storefront_rounded, ['cattle', 'sheep', 'goats', 'pigs', 'poultry']),
    ('Emergency Contacts', Icons.phone_rounded, ['cattle', 'sheep', 'goats', 'pigs', 'poultry', 'aquaculture', 'horses', 'rabbits', 'bees']),
    ('Biosecurity Checklist', Icons.security_rounded, ['cattle', 'sheep', 'goats', 'pigs', 'poultry', 'aquaculture', 'horses', 'rabbits', 'bees']),
    ('Withdrawal Periods', Icons.hourglass_empty_rounded, ['cattle', 'sheep', 'goats', 'pigs', 'poultry']),
  ];

  @override
  Widget build(BuildContext context) {
    final relevantTools = _allTools.where((t) => t.$3.contains(species)).toList();
    if (relevantTools.isEmpty) {
      return const SizedBox(height: AppSpacing.md);
    }
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          0,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: relevantTools.map((tool) {
          return ActionChip(
            avatar: Icon(tool.$2, size: 16, color: AppColors.primary),
            label: Text(
              tool.$1,
              style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            backgroundColor: cs.surfaceContainerLow,
            side: BorderSide(color: cs.outlineVariant),
            onPressed: () {
              // Navigate based on tool
              switch (tool.$1) {
                case 'Market Prices (ZAR)':
                  context.push(AppRoutes.marketPrices);
                  break;
                case 'Emergency Contacts':
                  context.push(AppRoutes.settings);
                  break;
                default:
                  context.push(AppRoutes.recordHealth);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

// ── Poultry Hub: Active Flocks ─────────────────────────────────────────────────

class _PoultryFlockSummary extends ConsumerWidget {
  const _PoultryFlockSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final flocksAsync = ref.watch(flocksProvider);

    return flocksAsync.when(
      loading: () => const SizedBox(
        height: 190,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (flocks) {
        final active = flocks.where((f) => f.isActive).toList();
        if (active.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingHorizontal,
                0,
                AppSpacing.pagePaddingHorizontal,
                AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: AppRadius.card,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.egg_alt_rounded,
                      size: 40,
                      color: cs.onSurfaceVariant.withAlpha(80)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No active flocks',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.addFlock),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add First Flock'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.poultryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePaddingHorizontal),
            scrollDirection: Axis.horizontal,
            itemCount: active.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, i) => _PoultryFlockCard(flock: active[i]),
          ),
        );
      },
    );
  }
}

class _PoultryFlockCard extends StatelessWidget {
  const _PoultryFlockCard({required this.flock});
  final PoultryFlock flock;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mortPct = flock.placementCount > 0
        ? flock.mortalityTotal / flock.placementCount * 100
        : 0.0;
    final mortColor = mortPct > 5.0 ? AppColors.error : AppColors.success;
    final prodLabel = flock.productionType.replaceAll('_', ' ');

    return GestureDetector(
      onTap: () => context.push(AppRoutes.flockDetailPath(flock.id)),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: status dot + batch name + day badge
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    flock.batchName,
                    style: tt.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.poultryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Day ${flock.dayOfAge}',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.poultryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${_cap(prodLabel)} · ${flock.strain}',
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
            Divider(height: AppSpacing.md, color: cs.outlineVariant),
            // Metrics
            _FRow(
              icon: Icons.egg_alt_rounded,
              label: 'Birds',
              value: _fmtBirds(flock.currentCount),
              color: AppColors.poultryColor,
            ),
            const SizedBox(height: AppSpacing.xs),
            _FRow(
              icon: Icons.trending_up_rounded,
              label: 'FCR',
              value: flock.fcrToDate != null
                  ? flock.fcrToDate!.toStringAsFixed(2)
                  : '–',
              color: AppColors.info,
            ),
            const SizedBox(height: AppSpacing.xs),
            _FRow(
              icon: Icons.crisis_alert_rounded,
              label: 'Mort.',
              value: '${mortPct.toStringAsFixed(1)}%',
              color: mortColor,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Details',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _FRow extends StatelessWidget {
  const _FRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: tt.labelSmall
              ?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
        ),
        Text(
          value,
          style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w700, fontSize: 10, color: color),
        ),
      ],
    );
  }
}

// ── Poultry Hub: Performance Analytics ───────────────────────────────────────

class _PoultryBatchCharts extends ConsumerWidget {
  const _PoultryBatchCharts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flocksAsync = ref.watch(flocksProvider);
    return flocksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (flocks) {
        final active = flocks.where((f) => f.isActive).toList();
        if (active.isEmpty) return const SizedBox.shrink();
        final flocksWithFcr =
            active.where((f) => f.fcrToDate != null).take(6).toList();
        if (flocksWithFcr.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.sm,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── FCR bar chart ──────────────────────────────────────────
              Expanded(
                flex: 3,
                child: _HubChartCard(
                  title: 'FCR by Batch',
                  child: SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        maxY: (flocksWithFcr
                                    .map((f) => f.fcrToDate!)
                                    .reduce((a, b) => a > b ? a : b) *
                                1.3)
                            .ceilToDouble(),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) =>
                                    BarTooltipItem(
                              '${flocksWithFcr[groupIndex].batchName.split(' ').first}\n'
                              'FCR: ${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (v, _) => Text(
                                v.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx < 0 ||
                                    idx >= flocksWithFcr.length) {
                                  return const SizedBox.shrink();
                                }
                                final name = flocksWithFcr[idx]
                                    .batchName
                                    .split(' ')
                                    .first;
                                return Text(
                                  name.length > 6
                                      ? '${name.substring(0, 5)}…'
                                      : name,
                                  style: const TextStyle(
                                      fontSize: 8, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: Colors.grey.withAlpha(26),
                            strokeWidth: 1,
                          ),
                        ),
                        barGroups:
                            List.generate(flocksWithFcr.length, (i) {
                          final fcr = flocksWithFcr[i].fcrToDate!;
                          final isHigh = fcr > 1.9;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: fcr,
                                color: isHigh
                                    ? AppColors.warning
                                    : AppColors.poultryColor,
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // ── Mortality gauge ────────────────────────────────────────
              Expanded(
                flex: 2,
                child: _HubChartCard(
                  title: 'Avg Mortality',
                  child: SizedBox(
                    height: 120,
                    child: _HubMortGauge(flocks: active),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HubChartCard extends StatelessWidget {
  const _HubChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.card,
        border:
            Border.all(color: AppColors.poultryColor.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.poultryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _HubMortGauge extends StatelessWidget {
  const _HubMortGauge({required this.flocks});
  final List<PoultryFlock> flocks;

  @override
  Widget build(BuildContext context) {
    final avgMort = flocks.isEmpty
        ? 0.0
        : flocks
                .map((f) => f.mortalityPct)
                .reduce((a, b) => a + b) /
            flocks.length;
    final fraction = (avgMort / 10).clamp(0.0, 1.0);
    final color = avgMort < 3
        ? AppColors.success
        : avgMort < 5
            ? AppColors.warning
            : AppColors.error;
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: fraction,
                strokeWidth: 10,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${avgMort.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const Text(
                  'avg mort',
                  style: TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}



// ── Animals Tab ────────────────────────────────────────────────────────────────

class _AnimalsTab extends ConsumerStatefulWidget {
  const _AnimalsTab({required this.cfg, required this.species});
  final _SpeciesConfig cfg;
  final String species;

  @override
  ConsumerState<_AnimalsTab> createState() => _AnimalsTabState();
}

class _AnimalsTabState extends ConsumerState<_AnimalsTab> {
  String _search = '';
  String _filterStatus = 'All';

  static const _statusFilters = ['All', 'Active', 'Sick', 'Pregnant', 'Flagged'];

  @override
  Widget build(BuildContext context) {
    final cfg = widget.cfg;
    final species = widget.species;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // If this species has a specialized screen, show a navigation card
    if (cfg.specializedRoute != null) {
      return _SpecializedAnimalView(cfg: cfg, species: species);
    }

    // Generic animal list
    final animalsAsync = ref.watch(animalsProvider(species));

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by name, tag or breed...',
              prefixIcon: Icon(Icons.search_rounded,
                  size: 20, color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: AppRadius.button,
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.button,
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: _statusFilters.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.xs),
            itemBuilder: (_, i) {
              final filter = _statusFilters[i];
              final selected = _filterStatus == filter;
              return FilterChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _filterStatus = filter),
                selectedColor: AppColors.primary.withAlpha(30),
                checkmarkColor: AppColors.primary,
                labelStyle: tt.labelSmall?.copyWith(
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : cs.onSurface,
                ),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : cs.outlineVariant,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Animal list
        Expanded(
          child: animalsAsync.when(
            loading: () => LoadingShimmer.list(count: 6),
            error: (e, _) => Center(
              child: Text('Unable to load animals',
                  style: tt.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ),
            data: (animals) {
              final filtered = _applyFilter(animals);
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets_rounded,
                          size: 48,
                          color: cs.onSurfaceVariant.withAlpha(100)),
                      const SizedBox(height: AppSpacing.sm),
                      Text('No animals found',
                          style: tt.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
                itemCount: filtered.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) => _AnimalRow(
                  animal: filtered[i],
                  cfg: cfg,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Animal> _applyFilter(List<Animal> animals) {
    List<Animal> result = animals;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((a) {
        return a.name.toLowerCase().contains(q) ||
            (a.tagNumber.toLowerCase().contains(q)) ||
            a.breed.toLowerCase().contains(q);
      }).toList();
    }
    if (_filterStatus != 'All') {
      result = result.where((a) {
        switch (_filterStatus) {
          case 'Active':
            return a.status == 'active';
          case 'Sick':
            return a.status == 'sick';
          case 'Pregnant':
            return a.status == 'pregnant';
          case 'Flagged':
            return a.status == 'flagged';
          default:
            return true;
        }
      }).toList();
    }
    return result;
  }
}

// ── Animal row tile ───────────────────────────────────────────────────────────

class _AnimalRow extends StatelessWidget {
  const _AnimalRow({required this.animal, required this.cfg});
  final Animal animal;
  final _SpeciesConfig cfg;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final statusColor = _statusColor(animal.status);

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(
            AppRoutes.animalDetailPath(animal.species, animal.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cfg.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          animal.name,
                          style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700),
                        ),
                        if (animal.tagNumber.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '· ${animal.tagNumber}',
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        animal.breed,
                        animal.sex == 'male' ? '♂' : '♀',
                      ].join(' · '),
                      style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  animal.status.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sick':
      case 'critical':
        return AppColors.error;
      case 'pregnant':
        return AppColors.pigColor;
      case 'flagged':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}

// ── Specialized animal view (for poultry, pigs, aquaculture, bees) ─────────────

class _SpecializedAnimalView extends StatelessWidget {
  const _SpecializedAnimalView({required this.cfg, required this.species});
  final _SpeciesConfig cfg;
  final String species;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Navigation card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: AppRadius.card,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: AppRadius.card,
              child: InkWell(
                borderRadius: AppRadius.card,
                onTap: () => context.push(cfg.specializedRoute!),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(cfg.icon,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cfg.specializedLabel ?? 'Open Manager',
                              style: tt.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Specialized ${cfg.displayName.toLowerCase()} management board',
                              style: tt.bodySmall?.copyWith(
                                color: Colors.white.withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white.withAlpha(200)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Info cards about the specialized view
          Text(
            'What\'s in the ${cfg.displayName} Manager?',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...(_featureList()).map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(f, style: tt.bodySmall),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Quick add button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            onPressed: () => context.push(cfg.specializedRoute!),
            icon: Icon(cfg.icon, size: 18),
            label: Text(
              cfg.specializedLabel ?? 'Open Manager',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _featureList() {
    switch (species) {
      case 'poultry':
        return [
          'Flock board with batch & mortality tracking',
          'Feed Conversion Ratio (FCR) calculator',
          'Ventilation & climate dashboard',
          'Vaccination countdown schedule',
          'Batch profitability (cost per bird)',
        ];
      case 'pigs':
        return [
          'Sow board with farrowing records',
          'Phase-feeding calculator (creep → finisher)',
          'Barn climate & misting automation',
          '21-day weaning countdown per sow',
          'Born alive / stillborn statistics',
        ];
      case 'aquaculture':
        return [
          'Pond / tank management with stock levels',
          'Water quality parameter tracking',
          'Daily feed and survival records',
          'Harvest planning and scheduling',
          'FCR & growth performance analytics',
        ];
      case 'bees':
        return [
          'Hive board with colony strength ratings',
          'Inspection records and queen status',
          'Varroa mite count tracking',
          'Honey harvest estimation & logging',
          'Hive-level IoT weight & temperature',
        ];
      default:
        return [];
    }
  }
}
