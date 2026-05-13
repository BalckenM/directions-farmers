import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/events/screens/add_breeding_event_screen.dart';
import '../../features/events/screens/add_weight_record_screen.dart';
import '../../features/events/screens/breeding_events_screen.dart';
import '../../features/events/screens/add_health_event_screen.dart';
import '../../features/events/screens/health_events_screen.dart';
import '../../features/events/screens/weight_records_screen.dart';
import '../../features/livestock/screens/livestock_hub_screen.dart';
import '../../features/livestock/screens/add_edit_animal_screen.dart';
import '../../features/livestock/screens/animal_detail_screen.dart';
import '../../features/livestock/screens/livestock_screen.dart';
import '../../features/production/screens/egg_records_screen.dart';
import '../../features/production/screens/milk_records_screen.dart';
import '../../features/livestock/screens/groups_screen.dart';
import '../../features/livestock/screens/group_detail_screen.dart';
import '../../features/livestock/screens/add_edit_group_screen.dart';
import '../../features/production/screens/add_milk_record_screen.dart';
import '../../features/production/screens/add_egg_record_screen.dart';
import '../../features/production/screens/wool_records_screen.dart';
import '../../features/production/screens/add_wool_record_screen.dart';
import '../../features/traceability/screens/movement_records_screen.dart';
import '../../features/traceability/screens/add_movement_record_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/farm_settings_screen.dart';
import '../../features/settings/screens/account_settings_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/theme_settings_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/events/screens/alerts_screen.dart';
import '../../features/financial/screens/financial_screen.dart';
import '../../features/financial/screens/add_financial_transaction_screen.dart';
import '../../features/record/screens/record_screen.dart';
import '../../features/poultry/screens/poultry_screen.dart';
import '../../features/poultry/screens/flock_detail_screen.dart';
import '../../features/poultry/screens/add_flock_screen.dart';
import '../../features/poultry/screens/add_daily_record_screen.dart';
import '../../features/poultry/screens/feed_phases_screen.dart';
import '../../features/poultry/screens/harvest_record_screen.dart';
import '../../features/poultry/screens/add_medication_screen.dart';
import '../../features/poultry/screens/flock_financial_screen.dart';
import '../../features/poultry/screens/add_feed_phase_screen.dart';
import '../../features/poultry/screens/add_disease_event_screen.dart';
import '../../features/poultry/screens/add_egg_sale_screen.dart';
import '../../features/poultry/screens/inventory_screen.dart';
import '../../features/poultry/screens/add_delivery_screen.dart';
import '../../features/poultry/screens/invoice_screen.dart';
import '../../features/poultry/screens/house_allocation_screen.dart';
import '../../features/poultry/screens/biosecurity_log_screen.dart';
import '../../features/poultry/screens/litter_management_screen.dart';
import '../../features/poultry/screens/molt_management_screen.dart';
import '../../features/poultry/screens/add_chick_sale_screen.dart';
import '../../features/poultry/screens/breeder_records_screen.dart';
import '../../features/poultry/screens/edit_flock_screen.dart';
import '../../features/poultry/screens/cross_batch_comparison_screen.dart';
import '../../features/poultry/screens/vaccination_hub_screen.dart';
import '../../features/poultry/screens/poultry_flock_picker_screen.dart';
import '../../features/poultry/screens/health_events_hub_screen.dart';
import '../../features/poultry/screens/poultry_reports_screen.dart';
import '../../features/aquaculture/screens/aquaculture_screen.dart';
import '../../features/aquaculture/screens/aquaculture_unit_detail_screen.dart';
import '../../features/apiculture/screens/apiculture_screen.dart';
import '../../features/apiculture/screens/hive_detail_screen.dart';
import '../../features/goat/screens/goat_screen.dart';
import '../../features/goat/screens/goat_breed_screen.dart';
import '../../features/goat/screens/goat_detail_screen.dart';
import '../../features/goat/screens/add_goat_screen.dart';
import '../../features/goat/screens/edit_goat_screen.dart';
import '../../features/goat/screens/add_kid_screen.dart';
import '../../features/goat/screens/kidding_screen.dart';
import '../../features/goat/screens/breeding_screen.dart';
import '../../features/goat/screens/pregnancy_check_screen.dart';
import '../../features/goat/screens/milk_records_screen.dart';
import '../../features/goat/screens/shearing_screen.dart';
import '../../features/goat/screens/weight_records_screen.dart';
import '../../features/goat/screens/health_events_screen.dart';
import '../../features/goat/screens/vaccination_screen.dart';
import '../../features/goat/screens/body_condition_screen.dart';
import '../../features/goat/screens/add_medication_screen.dart';
import '../../features/goat/screens/goat_financials_screen.dart';
import '../../features/goat/screens/goat_reports_screen.dart';
import '../../features/goat/screens/sales_screen.dart';
import '../../features/goat/screens/inventory_screen.dart';
import '../../features/goat/screens/pasture_screen.dart';
import '../../features/goat/screens/cross_herd_comparison_screen.dart';
import '../../features/goat/screens/famacha_screen.dart';
import '../../features/pigs/screens/pigs_screen.dart';
import '../../features/pigs/screens/sow_detail_screen.dart';
import '../../features/record/screens/feed_log_screen.dart';
import '../../features/record/screens/add_feed_log_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/insights/screens/market_prices_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/paddocks_screen.dart';
import '../../features/crop/screens/crop_hub_screen.dart';
import '../../features/crop/screens/catalog/crop_catalog_screen.dart';
import '../../features/crop/screens/catalog/crop_detail_screen.dart';
import '../../features/crop/screens/fields/field_list_screen.dart';
import '../../features/crop/screens/fields/field_detail_screen.dart';
import '../../features/crop/screens/fields/add_edit_field_screen.dart';
import '../../features/crop/screens/fields/planted_crop_detail_screen.dart';
import '../../features/crop/screens/season/season_planner_screen.dart';
import '../../features/crop/screens/season/add_season_screen.dart';
import '../../features/crop/screens/calendar/planting_calendar_screen.dart';
import '../../features/crop/screens/tasks/task_list_screen.dart';
import '../../features/crop/screens/tasks/task_detail_screen.dart';
import '../../features/crop/screens/tasks/add_edit_task_screen.dart';
import '../../features/crop/screens/weather/weather_dashboard_screen.dart';
import '../../features/crop/screens/pests/pest_log_screen.dart';
import '../../features/crop/screens/pests/add_pest_observation_screen.dart';
import '../../features/crop/screens/pests/add_spray_record_screen.dart';
import '../../features/crop/screens/sales/sales_screen.dart';
import '../../features/crop/screens/sales/add_sale_screen.dart';
import '../../features/crop/screens/fields/add_planting_plan_screen.dart';
import '../../features/crop/screens/expenses/expense_tracker_screen.dart';
import '../../features/crop/screens/expenses/add_expense_screen.dart';
import '../../features/crop/screens/harvest/harvest_log_screen.dart';
import '../../features/crop/screens/harvest/add_harvest_screen.dart';
import '../../features/crop/screens/profitability/profitability_screen.dart';
import '../../features/crop/screens/advisory/advisory_hub_screen.dart';
import '../../features/crop/screens/advisory/advisory_detail_screen.dart';
import '../../features/crop/screens/season/edit_season_screen.dart';
import '../../features/crop/screens/fields/edit_planting_plan_screen.dart';
import '../../features/crop/screens/pests/edit_pest_observation_screen.dart';
import '../../features/crop/screens/pests/edit_spray_record_screen.dart';
import '../../features/crop/screens/harvest/edit_harvest_screen.dart';
import '../../features/crop/screens/sales/edit_sale_screen.dart';
import '../../features/crop/models/crop_season.dart';
import '../../features/crop/models/planting_plan.dart';
import '../../features/crop/models/pest_observation.dart';
import '../../features/crop/models/spray_record.dart';
import '../../features/crop/models/harvest_record.dart';
import '../../features/crop/models/crop_sale.dart';
import 'app_routes.dart';

// ── Placeholder screens ───────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
            child:
                Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      );
}

// ── Shell scaffold with bottom navigation ─────────────────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── Floating nav bar with center FAB ─────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
  });
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: cs.outlineVariant.withAlpha(60),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1E000000),
                blurRadius: 24,
                spreadRadius: -2,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                filledIcon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.pets_outlined,
                filledIcon: Icons.pets_rounded,
                label: 'Herd',
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _CenterFabButton(
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                filledIcon: Icons.bar_chart_rounded,
                label: 'Insights',
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.storefront_outlined,
                filledIcon: Icons.storefront_rounded,
                label: 'Farm',
                selected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterFabButton extends StatelessWidget {
  const _CenterFabButton({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF1A5E20) : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: selected ? AppShadows.level2 : AppShadows.level3,
            ),
            child: Icon(
              selected ? Icons.edit_note_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Record',
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color:
                  selected ? AppColors.primary : cs.onSurfaceVariant,
              letterSpacing: 0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withAlpha(22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                selected ? filledIcon : icon,
                size: 22,
                color: selected ? AppColors.primary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : cs.onSurfaceVariant,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Router provider ───────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  // Build router once, then listen to auth state changes and refresh.
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider);
      final loc = state.matchedLocation;

      // Routes that are always accessible (auth + splash)
      const openRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.onboarding,
      };
      final isOpen = openRoutes.contains(loc);

      // Not logged in and trying to reach protected content → login
      if (!isLoggedIn && !isOpen) return AppRoutes.login;

      // Logged in and still on auth screens → dashboard
      if (isLoggedIn && isOpen && loc != AppRoutes.splash) {
        return AppRoutes.dashboard;
      }

      return null; // no redirect
    },
    routes: _buildRoutes(),
    errorBuilder: (_, state) => _PlaceholderScreen(
      title: 'Page not found: ${state.uri}',
    ),
  );

  // Refresh router whenever auth state changes so redirect is re-evaluated.
  ref.listen(authProvider, (_, _) => router.refresh());

  return router;
});

List<RouteBase> _buildRoutes() {
  return [
      // ── Crop Farming routes ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.crop,
        builder: (_, _) => const CropHubScreen(),
        routes: [
          GoRoute(
            path: 'catalog',
            builder: (_, _) => const CropCatalogScreen(),
            routes: [
              GoRoute(
                path: ':cropId',
                builder: (_, state) => CropDetailScreen(
                    cropId: state.pathParameters['cropId']!),
              ),
            ],
          ),
          GoRoute(
            path: 'fields',
            builder: (_, _) => const FieldListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddEditFieldScreen(),
              ),
              GoRoute(
                path: 'plan/add',
                builder: (_, state) => AddPlantingPlanScreen(
                    preselectedFieldId:
                        state.uri.queryParameters['fieldId']),
              ),
              GoRoute(
                path: 'plan/edit',
                builder: (_, state) =>
                    EditPlantingPlanScreen(plan: state.extra! as PlantingPlan),
              ),
              GoRoute(
                path: ':fieldId',
                builder: (_, state) => FieldDetailScreen(
                    fieldId: state.pathParameters['fieldId']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => AddEditFieldScreen(
                        fieldId: state.pathParameters['fieldId']!),
                  ),
                  GoRoute(
                    path: 'plan/:planId',
                    builder: (_, state) => PlantedCropDetailScreen(
                        planId: state.pathParameters['planId']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'seasons',
            builder: (_, _) => const SeasonPlannerScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddSeasonScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (_, state) =>
                    EditSeasonScreen(season: state.extra! as CropSeason),
              ),
            ],
          ),
          GoRoute(
            path: 'calendar',
            builder: (_, _) => const PlantingCalendarScreen(),
          ),
          GoRoute(
            path: 'tasks',
            builder: (_, _) => const TaskListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddEditTaskScreen(),
              ),
              GoRoute(
                path: ':taskId',
                builder: (_, state) => TaskDetailScreen(
                    taskId: state.pathParameters['taskId']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => AddEditTaskScreen(
                        taskId: state.pathParameters['taskId']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'weather',
            builder: (_, _) => const WeatherDashboardScreen(),
          ),
          GoRoute(
            path: 'pests',
            builder: (_, _) => const PestLogScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddPestObservationScreen(),
              ),
              GoRoute(
                path: 'spray/add',
                builder: (_, state) => AddSprayRecordScreen(
                    pestObservationId:
                        state.uri.queryParameters['obsId']),
              ),
              GoRoute(
                path: 'edit',
                builder: (_, state) => EditPestObservationScreen(
                    observation: state.extra! as PestObservation),
              ),
              GoRoute(
                path: 'spray/edit',
                builder: (_, state) =>
                    EditSprayRecordScreen(record: state.extra! as SprayRecord),
              ),
            ],
          ),
          GoRoute(
            path: 'sales',
            builder: (_, _) => const SalesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddSaleScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (_, state) =>
                    EditSaleScreen(sale: state.extra! as CropSale),
              ),
            ],
          ),
          GoRoute(
            path: 'expenses',
            builder: (_, _) => const ExpenseTrackerScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddExpenseScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'harvest',
            builder: (_, _) => const HarvestLogScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, _) => const AddHarvestScreen(),
              ),
              GoRoute(
                path: 'edit',
                builder: (_, state) =>
                    EditHarvestScreen(record: state.extra! as HarvestRecord),
              ),
            ],
          ),
          GoRoute(
            path: 'profitability',
            builder: (_, _) => const ProfitabilityScreen(),
          ),
          GoRoute(
            path: 'advisory',
            builder: (_, _) => const AdvisoryHubScreen(),
            routes: [
              GoRoute(
                path: ':articleId',
                builder: (_, state) => AdvisoryDetailScreen(
                    articleId: state.pathParameters['articleId']!),
              ),
            ],
          ),
        ],
      ),

      // ── Splash ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      // ── Auth routes ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),

      // ── Shell with bottom nav ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _AppShell(navigationShell: shell),
        branches: [
          // ── Branch 0: Command ────────────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, _) => const DashboardScreen(),
            ),
          ]),

          // ── Branch 1: Herd ───────────────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.livestock,
              builder: (_, _) => const LivestockScreen(),
              routes: [
                // ── Poultry — hub is landing page, flocks board is nested ──────────
                GoRoute(
                  path: 'poultry',
                  builder: (_, _) =>
                      const LivestockHubScreen(species: 'poultry'),
                  routes: [
                    // ── Literal routes first — prevents :flockId swallowing them ──
                    GoRoute(
                      path: 'flocks',
                      builder: (_, _) => const PoultryScreen(),
                    ),
                    GoRoute(
                      path: 'new',
                      builder: (_, _) => const AddFlockScreen(),
                    ),
                    GoRoute(
                      path: 'inventory',
                      builder: (_, _) => const InventoryScreen(),
                      routes: [
                        GoRoute(
                          path: 'delivery/new',
                          builder: (_, _) => const AddDeliveryScreen(),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'invoice',
                      builder: (_, state) {
                        final flockId =
                            state.uri.queryParameters['flockId'] ?? '';
                        return InvoiceScreen(flockId: flockId);
                      },
                    ),
                    GoRoute(
                      path: 'houses',
                      builder: (_, _) => const HouseAllocationScreen(),
                    ),
                    GoRoute(
                      path: 'vaccinations',
                      builder: (_, state) => VaccinationHubScreen(
                          flockId: state.uri.queryParameters['flockId'] ?? ''),
                    ),
                    GoRoute(
                      path: 'daily-records',
                      builder: (_, _) =>
                          const PoultryFlockPickerScreen(target: 'daily-add'),
                    ),
                    GoRoute(
                      path: 'feed-phases-hub',
                      builder: (_, _) =>
                          const PoultryFlockPickerScreen(target: 'feed-phases'),
                    ),
                    GoRoute(
                      path: 'health-events',
                      builder: (_, state) => HealthEventsHubScreen(
                          flockId: state.uri.queryParameters['flockId'] ?? ''),
                    ),
                    GoRoute(
                      path: 'financials-hub',
                      builder: (_, _) =>
                          const PoultryFlockPickerScreen(target: 'financial'),
                    ),
                    GoRoute(
                      path: 'reports',
                      builder: (_, state) => PoultryReportsScreen(
                          flockId: state.uri.queryParameters['flockId'] ?? ''),
                    ),
                    // ── Parameterised route last — catches any real flockId ────────
                    GoRoute(
                      path: ':flockId',
                      builder: (_, state) => FlockDetailScreen(
                          flockId: state.pathParameters['flockId']!),
                      routes: [
                        GoRoute(
                          path: 'daily/add',
                          builder: (_, state) => AddDailyRecordScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'harvest',
                          builder: (_, state) => HarvestRecordScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'feed-phases',
                          builder: (_, state) => FeedPhasesScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                          routes: [
                            GoRoute(
                              path: 'new',
                              builder: (_, state) => AddFeedPhaseScreen(
                                  flockId:
                                      state.pathParameters['flockId']!),
                            ),
                          ],
                        ),
                        GoRoute(
                          path: 'medications/new',
                          builder: (_, state) => AddMedicationScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'financial',
                          builder: (_, state) => FlockFinancialScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'health/new',
                          builder: (_, state) => AddDiseaseEventScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'egg-sales/new',
                          builder: (_, state) => AddEggSaleScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'chick-sales/new',
                          builder: (_, state) => AddChickSaleScreen(
                              flockId:
                                  state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'biosecurity',
                          builder: (_, state) => BiosecurityLogScreen(
                              flockId: state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'litter',
                          builder: (_, state) => LitterManagementScreen(
                              flockId: state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'molt',
                          builder: (_, state) => MoltManagementScreen(
                              flockId: state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'breeder-records',
                          builder: (_, state) => BreederRecordsScreen(
                              flockId: state.pathParameters['flockId']!),
                        ),
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => EditFlockScreen(
                              flockId: state.pathParameters['flockId']!),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Aquaculture hub → units board → unit detail ──────────────
                GoRoute(
                  path: 'cross-batch',
                  builder: (_, _) => const CrossBatchComparisonScreen(),
                ),
                GoRoute(
                  path: 'aquaculture',
                  builder: (_, _) =>
                      const LivestockHubScreen(species: 'aquaculture'),
                  routes: [
                    GoRoute(
                      path: 'units',
                      builder: (_, _) => const AquacultureScreen(),
                      routes: [
                        GoRoute(
                          path: ':unitId',
                          builder: (_, state) => AquacultureUnitDetailScreen(
                              unitId: state.pathParameters['unitId']!),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Bees hub → hive board → hive detail ─────────────────────
                GoRoute(
                  path: 'bees',
                  builder: (_, _) =>
                      const LivestockHubScreen(species: 'bees'),
                  routes: [
                    GoRoute(
                      path: 'hives',
                      builder: (_, _) => const ApicultureScreen(),
                      routes: [
                        GoRoute(
                          path: ':hiveId',
                          builder: (_, state) => HiveDetailScreen(
                              hiveId: state.pathParameters['hiveId']!),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Pigs hub → sow board → sow detail ───────────────────────
                GoRoute(
                  path: 'pigs',
                  builder: (_, _) =>
                      const LivestockHubScreen(species: 'pigs'),
                  routes: [
                    GoRoute(
                      path: 'board',
                      builder: (_, _) => const PigsScreen(),
                      routes: [
                        GoRoute(
                          path: ':sowId',
                          builder: (_, state) => SowDetailScreen(
                              sowId: state.pathParameters['sowId']!),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Goat module ──────────────────────────────────────────────
                GoRoute(
                  path: 'goats',
                  builder: (_, _) =>
                      const LivestockHubScreen(species: 'goats'),
                  routes: [
                    GoRoute(
                      path: 'herd',
                      builder: (_, _) => const GoatScreen(),
                    ),
                    GoRoute(
                      path: 'new',
                      builder: (_, _) => const AddGoatScreen(),
                    ),
                    GoRoute(
                      path: 'reports',
                      builder: (_, _) => const GoatReportsScreen(),
                    ),
                    GoRoute(
                      path: 'inventory',
                      builder: (_, _) => const GoatInventoryScreen(),
                    ),
                    GoRoute(
                      path: 'pasture',
                      builder: (_, _) => const GoatPastureScreen(),
                    ),
                    GoRoute(
                      path: 'compare',
                      builder: (_, _) => const CrossHerdComparisonScreen(),
                    ),
                    GoRoute(
                      path: 'pregnancy-check',
                      builder: (_, _) => const PregnancyCheckScreen(),
                    ),
                    GoRoute(
                      path: 'bcs',
                      builder: (_, _) => const GoatBodyConditionScreen(),
                    ),
                    GoRoute(
                      path: 'vaccinations',
                      builder: (_, _) => const GoatVaccinationScreen(),
                    ),
                    GoRoute(
                      path: 'sales',
                      builder: (_, _) => const GoatSalesScreen(),
                    ),
                    GoRoute(
                      path: 'famacha',
                      builder: (_, _) => const GoatFamachaScreen(),
                    ),
                    GoRoute(
                      path: 'breed/:breed',
                      builder: (_, state) => GoatBreedScreen(
                        breed: Uri.decodeComponent(
                            state.pathParameters['breed']!),
                      ),
                    ),
                    GoRoute(
                      path: ':goatId',
                      builder: (_, state) => GoatDetailScreen(
                          goatId: state.pathParameters['goatId']!),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => EditGoatScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'health',
                          builder: (_, state) => GoatHealthEventsScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'breeding',
                          builder: (_, state) => GoatBreedingScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'kidding',
                          builder: (_, state) => GoatKiddingScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'add-kid',
                          builder: (_, state) => AddKidScreen(
                              damId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'milk',
                          builder: (_, state) => GoatMilkRecordsScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'shearing',
                          builder: (_, state) => GoatShearingScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'weights',
                          builder: (_, state) => GoatWeightRecordsScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'financials',
                          builder: (_, state) => GoatFinancialsScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                        GoRoute(
                          path: 'add-medication',
                          builder: (_, state) => GoatAddMedicationScreen(
                              goatId: state.pathParameters['goatId']!),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Generic species hub (cattle, sheep, goats, horses, etc.) ─
                GoRoute(
                  path: ':species',
                  builder: (_, state) => LivestockHubScreen(
                      species: state.pathParameters['species']!),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, state) => AddEditAnimalScreen(
                          species: state.pathParameters['species']!),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (_, state) => AnimalDetailScreen(
                          species: state.pathParameters['species']!,
                          animalId: state.pathParameters['id']!),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => AddEditAnimalScreen(
                              species: state.pathParameters['species']!,
                              animalId: state.pathParameters['id']!),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'groups',
                  builder: (_, _) => const GroupsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddEditGroupScreen(),
                    ),
                    GoRoute(
                      path: ':groupId',
                      builder: (_, state) => GroupDetailScreen(
                          groupId: state.pathParameters['groupId']!),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => AddEditGroupScreen(
                              groupId: state.pathParameters['groupId']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ]),

          // ── Branch 2: Record (Events + Production unified) ───────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.record,
              builder: (_, _) => const RecordScreen(),
              routes: [
                GoRoute(
                  path: 'health',
                  builder: (_, _) => const HealthEventsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddHealthEventScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'weight',
                  builder: (_, _) => const WeightRecordsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddWeightRecordScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'breeding',
                  builder: (_, _) => const BreedingEventsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddBreedingEventScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'milk',
                  builder: (_, _) => const MilkRecordsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddMilkRecordScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'eggs',
                  builder: (_, _) => const EggRecordsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddEggRecordScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'wool',
                  builder: (_, _) => const WoolRecordsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddWoolRecordScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'alerts',
                  builder: (_, _) => const AlertsScreen(),
                ),
                GoRoute(
                  path: 'feed',
                  builder: (_, _) => const FeedLogScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, _) => const AddFeedLogScreen(),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.financial,
              builder: (_, _) => const FinancialScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, _) => const AddFinancialTransactionScreen(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.movementRecords,
              builder: (_, _) => const MovementRecordsScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, _) => const AddMovementRecordScreen(),
                ),
              ],
            ),
          ]),

          // ── Branch 3: Insights ───────────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.insights,
              builder: (_, _) => const InsightsScreen(),
              routes: [
                GoRoute(
                  path: 'reports',
                  builder: (_, _) => const ReportsScreen(),
                ),
                GoRoute(
                  path: 'market-prices',
                  builder: (_, _) => const MarketPricesScreen(),
                ),
              ],
            ),
          ]),

          // ── Branch 3b: Crop Farming (accessible via drawer from any branch) ──
          // Note: Crop routes are added as top-level GoRoutes outside the shell
          // so they can be pushed from any tab via context.push().

          // ── Branch 4: Farm (Settings) ────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, _) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'farm',
                  builder: (_, _) => const FarmSettingsScreen(),
                ),
                GoRoute(
                  path: 'account',
                  builder: (_, _) => const AccountSettingsScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (_, _) => const NotificationSettingsScreen(),
                ),
                GoRoute(
                  path: 'theme',
                  builder: (_, _) => const ThemeSettingsScreen(),
                ),
                GoRoute(
                  path: 'paddocks',
                  builder: (_, _) => const PaddocksScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ];
}
