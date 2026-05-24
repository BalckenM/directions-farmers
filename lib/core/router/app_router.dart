import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/payroll/screens/attendance/attendance_log_screen.dart';
import 'package:mobile_app/features/payroll/screens/communications/compose_message_screen.dart';
import 'package:mobile_app/features/payroll/screens/leave/leave_request_screen.dart';

import '../../features/apiculture/screens/apiculture_screen.dart';
import '../../features/apiculture/screens/hive_detail_screen.dart';
import '../../features/aquaculture/screens/aquaculture_screen.dart';
import '../../features/aquaculture/screens/aquaculture_unit_detail_screen.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/intro_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/mfa_challenge_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/registration_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/cattle/screens/add_calf_screen.dart';
import '../../features/cattle/screens/add_cattle_screen.dart';
import '../../features/cattle/screens/add_medication_screen.dart'
    as cattle_medication;
import '../../features/cattle/screens/body_condition_screen.dart' as cattle_bcs;
import '../../features/cattle/screens/breeding_screen.dart';
import '../../features/cattle/screens/calving_screen.dart';
import '../../features/cattle/screens/cattle_breed_screen.dart';
import '../../features/cattle/screens/cattle_detail_screen.dart';
import '../../features/cattle/screens/cattle_financials_screen.dart';
import '../../features/cattle/screens/cattle_reports_screen.dart';
import '../../features/cattle/screens/cattle_screen.dart';
import '../../features/cattle/screens/cross_herd_comparison_screen.dart'
    as cattle_comparison;
import '../../features/cattle/screens/dipping_screen.dart' as cattle_dipping;
import '../../features/cattle/screens/edit_cattle_screen.dart';
import '../../features/cattle/screens/health_events_screen.dart'
    as cattle_health;
import '../../features/cattle/screens/inventory_screen.dart'
    show CattleInventoryScreen;
import '../../features/cattle/screens/milk_records_screen.dart' as cattle_milk;
import '../../features/cattle/screens/pasture_screen.dart' as cattle_pasture;
import '../../features/cattle/screens/pregnancy_check_screen.dart'
    as cattle_pregnancy;
import '../../features/cattle/screens/sales_screen.dart' show CattleSalesScreen;
import '../../features/cattle/screens/vaccination_screen.dart'
    as cattle_vaccination;
import '../../features/cattle/screens/weight_records_screen.dart'
    as cattle_weight;
import '../../features/crop/models/crop_expense.dart';
import '../../features/crop/models/crop_sale.dart';
import '../../features/crop/models/crop_season.dart';
import '../../features/crop/models/harvest_record.dart';
import '../../features/crop/models/pest_observation.dart';
import '../../features/crop/models/planting_plan.dart';
import '../../features/crop/models/spray_record.dart';
import '../../features/crop/models/advisor_models.dart';
import '../../features/crop/models/disease_detection.dart';
import '../../features/crop/screens/advisor/advisor_chat_screen.dart';
import '../../features/crop/screens/advisor/crop_advisor_screen.dart';
import '../../features/crop/screens/advisory/advisory_detail_screen.dart';
import '../../features/crop/screens/advisory/advisory_hub_screen.dart';
import '../../features/crop/screens/calendar/planting_calendar_screen.dart';
import '../../features/crop/screens/disease/crop_scanner_screen.dart';
import '../../features/crop/screens/disease/disease_result_screen.dart';
import '../../features/crop/screens/catalog/crop_catalog_screen.dart';
import '../../features/crop/screens/catalog/crop_detail_screen.dart';
import '../../features/crop/screens/crop_hub_screen.dart';
import '../../features/crop/screens/expenses/add_expense_screen.dart';
import '../../features/crop/screens/expenses/edit_expense_screen.dart';
import '../../features/crop/screens/expenses/expense_tracker_screen.dart';
import '../../features/crop/screens/fields/add_edit_field_screen.dart';
import '../../features/crop/screens/fields/add_planting_plan_screen.dart';
import '../../features/crop/screens/fields/edit_planting_plan_screen.dart';
import '../../features/crop/screens/fields/field_detail_screen.dart';
import '../../features/crop/screens/fields/field_list_screen.dart';
import '../../features/crop/screens/fields/planted_crop_detail_screen.dart';
import '../../features/crop/screens/harvest/add_harvest_screen.dart';
import '../../features/crop/screens/harvest/edit_harvest_screen.dart';
import '../../features/crop/screens/harvest/harvest_detail_screen.dart';
import '../../features/crop/screens/harvest/harvest_log_screen.dart';
import '../../features/crop/screens/pests/add_pest_observation_screen.dart';
import '../../features/crop/screens/pests/add_spray_record_screen.dart';
import '../../features/crop/screens/pests/edit_pest_observation_screen.dart';
import '../../features/crop/screens/pests/edit_spray_record_screen.dart';
import '../../features/crop/screens/pests/pest_log_screen.dart';
import '../../features/crop/screens/pests/spray_detail_screen.dart';
import '../../features/crop/screens/pests/spray_list_screen.dart';
import '../../features/crop/screens/profitability/profitability_screen.dart';
import '../../features/crop/screens/sales/add_sale_screen.dart';
import '../../features/crop/screens/sales/edit_sale_screen.dart';
import '../../features/crop/screens/sales/sale_detail_screen.dart';
import '../../features/crop/screens/sales/sales_screen.dart';
import '../../features/crop/screens/season/add_season_screen.dart';
import '../../features/crop/screens/season/edit_season_screen.dart';
import '../../features/crop/screens/season/season_detail_screen.dart';
import '../../features/crop/screens/season/season_planner_screen.dart';
import '../../features/crop/screens/tasks/add_edit_task_screen.dart';
import '../../features/crop/screens/tasks/task_detail_screen.dart';
import '../../features/crop/screens/tasks/task_list_screen.dart';
import '../../features/crop/screens/weather/weather_dashboard_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/events/screens/add_breeding_event_screen.dart';
import '../../features/events/screens/add_health_event_screen.dart';
import '../../features/events/screens/add_weight_record_screen.dart';
import '../../features/events/screens/alerts_screen.dart';
import '../../features/events/screens/breeding_events_screen.dart';
import '../../features/events/screens/health_events_screen.dart';
import '../../features/events/screens/weight_records_screen.dart';
import '../../features/financial/screens/add_financial_transaction_screen.dart';
import '../../features/financial/screens/financial_screen.dart';
import '../../features/goat/screens/add_goat_screen.dart';
import '../../features/goat/screens/add_kid_screen.dart';
import '../../features/goat/screens/add_medication_screen.dart';
import '../../features/goat/screens/body_condition_screen.dart';
import '../../features/goat/screens/breeding_screen.dart';
import '../../features/goat/screens/cross_herd_comparison_screen.dart';
import '../../features/goat/screens/edit_goat_screen.dart';
import '../../features/goat/screens/famacha_screen.dart';
import '../../features/goat/screens/goat_breed_screen.dart';
import '../../features/goat/screens/goat_detail_screen.dart';
import '../../features/goat/screens/goat_financials_screen.dart';
import '../../features/goat/screens/goat_reports_screen.dart';
import '../../features/goat/screens/goat_screen.dart';
import '../../features/goat/screens/health_events_screen.dart';
import '../../features/goat/screens/inventory_screen.dart';
import '../../features/goat/screens/kidding_screen.dart';
import '../../features/goat/screens/milk_records_screen.dart';
import '../../features/goat/screens/pasture_screen.dart';
import '../../features/goat/screens/pregnancy_check_screen.dart';
import '../../features/goat/screens/sales_screen.dart';
import '../../features/goat/screens/shearing_screen.dart';
import '../../features/goat/screens/vaccination_screen.dart';
import '../../features/goat/screens/weight_records_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/insights/screens/market_prices_screen.dart';
import '../../features/livestock/screens/add_edit_animal_screen.dart';
import '../../features/livestock/screens/add_edit_group_screen.dart';
import '../../features/livestock/screens/animal_detail_screen.dart';
import '../../features/livestock/screens/group_detail_screen.dart';
import '../../features/livestock/screens/groups_screen.dart';
import '../../features/livestock/screens/livestock_hub_screen.dart';
import '../../features/livestock/screens/livestock_screen.dart';
import '../../features/payroll/models/shift.dart';
import '../../features/payroll/screens/attendance/attendance_exceptions_screen.dart';
import '../../features/payroll/screens/attendance/clock_in_screen.dart';
import '../../features/payroll/screens/audit/audit_log_screen.dart';
import '../../features/payroll/screens/communications/communications_screen.dart';
import '../../features/payroll/screens/compliance/coida_screen.dart';
import '../../features/payroll/screens/compliance/compliance_alert_detail_screen.dart';
import '../../features/payroll/screens/compliance/compliance_screen.dart';
import '../../features/payroll/screens/compliance/emp501_screen.dart';
import '../../features/payroll/screens/compliance/paye_screen.dart';
import '../../features/payroll/screens/compliance/sdl_screen.dart';
import '../../features/payroll/screens/compliance/uif_returns_screen.dart';
import '../../features/payroll/screens/contracts/contract_detail_screen.dart';
import '../../features/payroll/screens/contracts/contract_list_screen.dart';
import '../../features/payroll/screens/contracts/contract_sign_screen.dart';
import '../../features/payroll/screens/contracts/generate_contract_screen.dart';
import '../../features/payroll/screens/deductions/add_edit_garnishee_screen.dart';
import '../../features/payroll/screens/deductions/deductions_screen.dart';
import '../../features/payroll/screens/deductions/garnishee_orders_screen.dart';
import '../../features/payroll/screens/disbursements/disbursements_screen.dart';
import '../../features/payroll/screens/disbursements/payment_history_screen.dart';
import '../../features/payroll/screens/disbursements/transaction_detail_screen.dart';
import '../../features/payroll/screens/employees/add_edit_employee_screen.dart';
import '../../features/payroll/screens/employees/employee_detail_screen.dart';
import '../../features/payroll/screens/employees/employee_import_screen.dart';
import '../../features/payroll/screens/employees/employee_list_screen.dart';
import '../../features/payroll/screens/employees/termination_screen.dart';
import '../../features/payroll/screens/employees/worker_disputes_screen.dart';
import '../../features/payroll/screens/employees/worker_self_service_screen.dart';
import '../../features/payroll/screens/incidents/incidents_screen.dart'
    show IncidentsScreen, IncidentDetailScreen;
import '../../features/payroll/screens/leave/leave_approval_screen.dart';
import '../../features/payroll/screens/leave/leave_balance_screen.dart';
import '../../features/payroll/screens/leave/leave_dashboard_screen.dart';
import '../../features/payroll/screens/pay_groups/add_edit_pay_group_screen.dart';
import '../../features/payroll/screens/pay_groups/pay_groups_screen.dart';
import '../../features/payroll/screens/pay_runs/pay_run_detail_screen.dart';
import '../../features/payroll/screens/pay_runs/pay_run_list_screen.dart';
import '../../features/payroll/screens/pay_runs/payroll_approval_screen.dart';
import '../../features/payroll/screens/pay_runs/retroactive_pay_screen.dart';
import '../../features/payroll/screens/pay_runs/run_payroll_screen.dart';
import '../../features/payroll/screens/pay_structures/add_edit_pay_structure_screen.dart';
import '../../features/payroll/screens/pay_structures/pay_structures_screen.dart';
import '../../features/payroll/screens/payroll_hub_screen.dart';
import '../../features/payroll/screens/payslips/payslip_detail_screen.dart';
import '../../features/payroll/screens/payslips/payslip_list_screen.dart';
import '../../features/payroll/screens/reports/payroll_reports_screen.dart';
import '../../features/payroll/screens/roster/add_piecework_log_screen.dart';
import '../../features/payroll/screens/roster/add_shift_screen.dart';
import '../../features/payroll/screens/roster/roster_board_screen.dart';
import '../../features/payroll/screens/roster/task_sheet_screen.dart';
import '../../features/payroll/screens/settings/employer_config_screen.dart';
import '../../features/pigs/screens/pigs_screen.dart';
import '../../features/pigs/screens/sow_detail_screen.dart';
import '../../features/poultry/screens/add_chick_sale_screen.dart';
import '../../features/poultry/screens/add_daily_record_screen.dart';
import '../../features/poultry/screens/add_delivery_screen.dart';
import '../../features/poultry/screens/add_disease_event_screen.dart';
import '../../features/poultry/screens/add_egg_sale_screen.dart';
import '../../features/poultry/screens/add_feed_phase_screen.dart';
import '../../features/poultry/screens/add_flock_screen.dart';
import '../../features/poultry/screens/add_medication_screen.dart';
import '../../features/poultry/screens/biosecurity_log_screen.dart';
import '../../features/poultry/screens/breeder_records_screen.dart';
import '../../features/poultry/screens/cross_batch_comparison_screen.dart';
import '../../features/poultry/screens/edit_flock_screen.dart';
import '../../features/poultry/screens/feed_phases_screen.dart';
import '../../features/poultry/screens/flock_detail_screen.dart';
import '../../features/poultry/screens/flock_financial_screen.dart';
import '../../features/poultry/screens/harvest_record_screen.dart';
import '../../features/poultry/screens/health_events_hub_screen.dart';
import '../../features/poultry/screens/house_allocation_screen.dart';
import '../../features/poultry/screens/inventory_screen.dart';
import '../../features/poultry/screens/invoice_screen.dart';
import '../../features/poultry/screens/litter_management_screen.dart';
import '../../features/poultry/screens/molt_management_screen.dart';
import '../../features/poultry/screens/poultry_flock_picker_screen.dart';
import '../../features/poultry/screens/poultry_reports_screen.dart';
import '../../features/poultry/screens/poultry_screen.dart';
import '../../features/poultry/screens/vaccination_hub_screen.dart';
import '../../features/production/screens/add_egg_record_screen.dart';
import '../../features/production/screens/add_milk_record_screen.dart';
import '../../features/production/screens/add_wool_record_screen.dart';
import '../../features/production/screens/egg_records_screen.dart';
import '../../features/production/screens/milk_records_screen.dart';
import '../../features/production/screens/wool_records_screen.dart';
import '../../features/record/screens/add_feed_log_screen.dart';
import '../../features/record/screens/feed_log_screen.dart';
import '../../features/record/screens/record_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/settings/screens/account_settings_screen.dart';
import '../../features/settings/screens/activity_log_screen.dart';
import '../../features/settings/screens/breed_registry_screen.dart';
import '../../features/settings/screens/export_data_screen.dart';
import '../../features/settings/screens/farm_settings_screen.dart';
import '../../features/settings/screens/help_support_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/paddocks_screen.dart';
import '../../features/settings/screens/regulatory_reports_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/sync_backup_screen.dart';
import '../../features/settings/screens/theme_settings_screen.dart';
import '../../features/settings/screens/units_settings_screen.dart';
import '../../features/settings/screens/users_roles_screen.dart';
import '../../features/traceability/screens/add_movement_record_screen.dart';
import '../../features/traceability/screens/movement_records_screen.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';

// ── Placeholder screens ───────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    ),
  );
}

// ── Shell scaffold with bottom navigation ─────────────────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
  const _FloatingNavBar({required this.selectedIndex, required this.onTap});
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad > 0 ? bottomPad : 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surface.withValues(alpha: 0.90)
                  : cs.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : cs.outlineVariant.withValues(alpha: 0.22),
                width: 0.75,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.09),
                  blurRadius: 36,
                  spreadRadius: -6,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
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
                  icon: Icons.insights_outlined,
                  filledIcon: Icons.insights_rounded,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [const Color(0xFF166534), const Color(0xFF15803D)]
                  : [const Color(0xFF22C55E), const Color(0xFF16A34A)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(
                  alpha: selected ? 0.22 : 0.42,
                ),
                blurRadius: selected ? 8 : 18,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              selected ? Icons.edit_note_rounded : Icons.add_rounded,
              key: ValueKey(selected),
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animated stadium-pill indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 16 : 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.13)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                selected ? filledIcon : icon,
                size: 22,
                color: selected
                    ? AppColors.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.70),
              ),
            ),
            // Label collapses to zero height when not selected
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: -0.1,
                          height: 1.0,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
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
      final isLoggedIn = ref.read(isAuthenticatedProvider);
      final loc = state.matchedLocation;

      // Routes that are always accessible (auth + splash)
      const openRoutes = {
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.onboarding,
        AppRoutes.intro,
        AppRoutes.welcome,
        AppRoutes.mfaChallenge,
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
    errorBuilder: (_, state) =>
        _PlaceholderScreen(title: 'Page not found: ${state.uri}'),
  );

  // Refresh router whenever auth state changes so redirect is re-evaluated.
  ref.listen(isAuthenticatedProvider, (_, _) => router.refresh());

  return router;
});

List<RouteBase> _buildRoutes() {
  return [
    // ── Splash ───────────────────────────────────────────────────────────────
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    // ── Auth routes ──────────────────────────────────────────────────────────
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (_, _) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.intro,
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, _) => const RegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return WelcomeScreen(
          firstName: extra['firstName'] ?? '',
          farmName: extra['farmName'] ?? '',
        );
      },
    ),

    // ── Shell with bottom nav ────────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => _AppShell(navigationShell: shell),
      branches: [
        // ── Branch 0: Command ────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, _) => const DashboardScreen(),
            ),
          ],
        ),

        // ── Branch 1: Herd ───────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
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
                        flockId: state.uri.queryParameters['flockId'] ?? '',
                      ),
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
                        flockId: state.uri.queryParameters['flockId'] ?? '',
                      ),
                    ),
                    GoRoute(
                      path: 'financials-hub',
                      builder: (_, _) =>
                          const PoultryFlockPickerScreen(target: 'financial'),
                    ),
                    GoRoute(
                      path: 'reports',
                      builder: (_, state) => PoultryReportsScreen(
                        flockId: state.uri.queryParameters['flockId'] ?? '',
                      ),
                    ),
                    // ── Parameterised route last — catches any real flockId ────────
                    GoRoute(
                      path: ':flockId',
                      builder: (_, state) => FlockDetailScreen(
                        flockId: state.pathParameters['flockId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'daily/add',
                          builder: (_, state) => AddDailyRecordScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'harvest',
                          builder: (_, state) => HarvestRecordScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'feed-phases',
                          builder: (_, state) => FeedPhasesScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                          routes: [
                            GoRoute(
                              path: 'new',
                              builder: (_, state) => AddFeedPhaseScreen(
                                flockId: state.pathParameters['flockId']!,
                              ),
                            ),
                          ],
                        ),
                        GoRoute(
                          path: 'medications/new',
                          builder: (_, state) => AddMedicationScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'financial',
                          builder: (_, state) => FlockFinancialScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'health/new',
                          builder: (_, state) => AddDiseaseEventScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'egg-sales/new',
                          builder: (_, state) => AddEggSaleScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'chick-sales/new',
                          builder: (_, state) => AddChickSaleScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'biosecurity',
                          builder: (_, state) => BiosecurityLogScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'litter',
                          builder: (_, state) => LitterManagementScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'molt',
                          builder: (_, state) => MoltManagementScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'breeder-records',
                          builder: (_, state) => BreederRecordsScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => EditFlockScreen(
                            flockId: state.pathParameters['flockId']!,
                          ),
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
                            unitId: state.pathParameters['unitId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Bees hub → hive board → hive detail ─────────────────────
                GoRoute(
                  path: 'bees',
                  builder: (_, _) => const LivestockHubScreen(species: 'bees'),
                  routes: [
                    GoRoute(
                      path: 'hives',
                      builder: (_, _) => const ApicultureScreen(),
                      routes: [
                        GoRoute(
                          path: ':hiveId',
                          builder: (_, state) => HiveDetailScreen(
                            hiveId: state.pathParameters['hiveId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Pigs hub → sow board → sow detail ───────────────────────
                GoRoute(
                  path: 'pigs',
                  builder: (_, _) => const LivestockHubScreen(species: 'pigs'),
                  routes: [
                    GoRoute(
                      path: 'board',
                      builder: (_, _) => const PigsScreen(),
                      routes: [
                        GoRoute(
                          path: ':sowId',
                          builder: (_, state) => SowDetailScreen(
                            sowId: state.pathParameters['sowId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Cattle module ────────────────────────────────────────────
                GoRoute(
                  path: 'cattle',
                  builder: (_, _) =>
                      const LivestockHubScreen(species: 'cattle'),
                  routes: [
                    GoRoute(
                      path: 'herd',
                      builder: (_, _) => const CattleScreen(),
                    ),
                    GoRoute(
                      path: 'new',
                      builder: (_, _) => const AddCattleScreen(),
                    ),
                    GoRoute(
                      path: 'reports',
                      builder: (_, _) => const CattleReportsScreen(),
                    ),
                    GoRoute(
                      path: 'inventory',
                      builder: (_, _) => const CattleInventoryScreen(),
                    ),
                    GoRoute(
                      path: 'pasture',
                      builder: (_, _) => const cattle_pasture.PastureScreen(),
                    ),
                    GoRoute(
                      path: 'compare',
                      builder: (_, _) =>
                          const cattle_comparison.CrossHerdComparisonScreen(),
                    ),
                    GoRoute(
                      path: 'sales',
                      builder: (_, _) => const CattleSalesScreen(),
                    ),
                    GoRoute(
                      path: 'breed/:breed',
                      builder: (_, state) => CattleBreedScreen(
                        breed: Uri.decodeComponent(
                          state.pathParameters['breed']!,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: ':cattleId',
                      builder: (_, state) => CattleDetailScreen(
                        cattleId: state.pathParameters['cattleId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => EditCattleScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'health',
                          builder: (_, state) =>
                              cattle_health.HealthEventsScreen(
                                cattleId: state.pathParameters['cattleId']!,
                              ),
                        ),
                        GoRoute(
                          path: 'breeding',
                          builder: (_, state) => CattleBreedingScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'calving',
                          builder: (_, state) => CalvingScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'add-calf',
                          builder: (_, state) => AddCalfScreen(
                            damId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'milk',
                          builder: (_, state) => cattle_milk.MilkRecordsScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'weights',
                          builder: (_, state) =>
                              cattle_weight.WeightRecordsScreen(
                                cattleId: state.pathParameters['cattleId']!,
                              ),
                        ),
                        GoRoute(
                          path: 'financials',
                          builder: (_, state) => CattleFinancialsScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'add-medication',
                          builder: (_, state) =>
                              cattle_medication.AddMedicationScreen(
                                cattleId: state.pathParameters['cattleId']!,
                              ),
                        ),
                        GoRoute(
                          path: 'bcs',
                          builder: (_, state) => cattle_bcs.BodyConditionScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'vaccination',
                          builder: (_, state) =>
                              cattle_vaccination.VaccinationScreen(
                                cattleId: state.pathParameters['cattleId']!,
                              ),
                        ),
                        GoRoute(
                          path: 'dipping',
                          builder: (_, state) => cattle_dipping.DippingScreen(
                            cattleId: state.pathParameters['cattleId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'pregnancy-check',
                          builder: (_, state) =>
                              cattle_pregnancy.PregnancyCheckScreen(
                                cattleId: state.pathParameters['cattleId']!,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Goat module ──────────────────────────────────────────────
                GoRoute(
                  path: 'goats',
                  builder: (_, _) => const LivestockHubScreen(species: 'goats'),
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
                          state.pathParameters['breed']!,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: ':goatId',
                      builder: (_, state) => GoatDetailScreen(
                        goatId: state.pathParameters['goatId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => EditGoatScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'health',
                          builder: (_, state) => GoatHealthEventsScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'breeding',
                          builder: (_, state) => GoatBreedingScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'kidding',
                          builder: (_, state) => GoatKiddingScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'add-kid',
                          builder: (_, state) => AddKidScreen(
                            damId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'milk',
                          builder: (_, state) => GoatMilkRecordsScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'shearing',
                          builder: (_, state) => GoatShearingScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'weights',
                          builder: (_, state) => GoatWeightRecordsScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'financials',
                          builder: (_, state) => GoatFinancialsScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'add-medication',
                          builder: (_, state) => GoatAddMedicationScreen(
                            goatId: state.pathParameters['goatId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // ── Generic species hub (cattle, sheep, goats, horses, etc.) ─
                GoRoute(
                  path: ':species',
                  builder: (_, state) => LivestockHubScreen(
                    species: state.pathParameters['species']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, state) => AddEditAnimalScreen(
                        species: state.pathParameters['species']!,
                      ),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (_, state) => AnimalDetailScreen(
                        species: state.pathParameters['species']!,
                        animalId: state.pathParameters['id']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => AddEditAnimalScreen(
                            species: state.pathParameters['species']!,
                            animalId: state.pathParameters['id']!,
                          ),
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
                        groupId: state.pathParameters['groupId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => AddEditGroupScreen(
                            groupId: state.pathParameters['groupId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ── Branch 2: Record (Events + Production unified) ───────────────────
        StatefulShellBranch(
          routes: [
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
          ],
        ),

        // ── Branch 3: Insights ───────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
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
          ],
        ),

        // ── Branch 4: Farm (Settings) ────────────────────────────────────────
        StatefulShellBranch(
          routes: [
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
                GoRoute(
                  path: 'breed-registry',
                  builder: (_, _) => const BreedRegistryScreen(),
                ),
                GoRoute(
                  path: 'activity-log',
                  builder: (_, _) => const ActivityLogScreen(),
                ),
                GoRoute(
                  path: 'users-roles',
                  builder: (_, _) => const UsersRolesScreen(),
                ),
                GoRoute(
                  path: 'units',
                  builder: (_, _) => const UnitsSettingsScreen(),
                ),
                GoRoute(
                  path: 'sync-backup',
                  builder: (_, _) => const SyncBackupScreen(),
                ),
                GoRoute(
                  path: 'export-data',
                  builder: (_, _) => const ExportDataScreen(),
                ),
                GoRoute(
                  path: 'regulatory-reports',
                  builder: (_, _) => const RegulatoryReportsScreen(),
                ),
                GoRoute(
                  path: 'help',
                  builder: (_, _) => const HelpSupportScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Branch 5: Crop Farming (drawer-only, no bottom nav tab) ─────────
        // Placing crop inside the shell ensures the bottom nav bar and
        // FarmAppBar back-button work correctly on every crop screen.
        StatefulShellBranch(
          routes: [
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
                        cropId: state.pathParameters['cropId']!,
                      ),
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
                            state.uri.queryParameters['fieldId'],
                      ),
                    ),
                    GoRoute(
                      path: 'plan/edit',
                      builder: (_, state) => EditPlantingPlanScreen(
                        plan: state.extra! as PlantingPlan,
                      ),
                    ),
                    GoRoute(
                      path: ':fieldId',
                      builder: (_, state) => FieldDetailScreen(
                        fieldId: state.pathParameters['fieldId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => AddEditFieldScreen(
                            fieldId: state.pathParameters['fieldId']!,
                          ),
                        ),
                        GoRoute(
                          path: 'plan/:planId',
                          builder: (_, state) => PlantedCropDetailScreen(
                            planId: state.pathParameters['planId']!,
                          ),
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
                    GoRoute(
                      path: 'detail',
                      builder: (_, state) => SeasonDetailScreen(
                        season: state.extra! as CropSeason,
                      ),
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
                        taskId: state.pathParameters['taskId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (_, state) => AddEditTaskScreen(
                            taskId: state.pathParameters['taskId']!,
                          ),
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
                      path: 'sprays',
                      builder: (_, _) => const SprayListScreen(),
                    ),
                    GoRoute(
                      path: 'spray/add',
                      builder: (_, state) => AddSprayRecordScreen(
                        pestObservationId: state.uri.queryParameters['obsId'],
                      ),
                    ),
                    GoRoute(
                      path: 'spray/detail',
                      builder: (_, state) => SprayDetailScreen(
                        record: state.extra! as SprayRecord,
                      ),
                    ),
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => EditPestObservationScreen(
                        observation: state.extra! as PestObservation,
                      ),
                    ),
                    GoRoute(
                      path: 'spray/edit',
                      builder: (_, state) => EditSprayRecordScreen(
                        record: state.extra! as SprayRecord,
                      ),
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
                      path: 'detail',
                      builder: (_, state) =>
                          SaleDetailScreen(sale: state.extra! as CropSale),
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
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => EditExpenseScreen(
                        expense: state.extra! as CropExpense,
                      ),
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
                      path: 'detail',
                      builder: (_, state) => HarvestDetailScreen(
                        record: state.extra! as HarvestRecord,
                      ),
                    ),
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => EditHarvestScreen(
                        record: state.extra! as HarvestRecord,
                      ),
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
                        articleId: state.pathParameters['articleId']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'disease/scanner',
                  builder: (_, _) => const CropScannerScreen(),
                ),
                GoRoute(
                  path: 'disease/result',
                  builder: (_, state) => DiseaseResultScreen(
                    result: state.extra! as DiseaseDetectionResult,
                  ),
                ),
                GoRoute(
                  path: 'advisor',
                  builder: (_, _) => const CropAdvisorScreen(),
                  routes: [
                    GoRoute(
                      path: 'chat',
                      builder: (_, state) => AdvisorChatScreen(
                        payload: state.extra!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ── MFA challenge ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.mfaChallenge,
      builder: (_, state) {
        final mfa = state.extra as AuthMfaRequired;
        return MfaChallengeScreen(
          challengeToken: mfa.challengeToken,
          email: mfa.email,
        );
      },
    ),

    // ── Payroll module ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.payrollHub,
      builder: (_, _) => const PayrollHubScreen(),
      routes: [
        GoRoute(
          path: 'employees',
          builder: (_, _) => const EmployeeListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (_, _) => const AddEditEmployeeScreen(),
            ),
            GoRoute(
              path: 'import',
              builder: (_, _) => const EmployeeImportScreen(),
            ),
            GoRoute(
              path: 'disputes',
              builder: (_, __) => const WorkerDisputesScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  EmployeeDetailScreen(employeeId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, state) => AddEditEmployeeScreen(
                    employeeId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'terminate',
                  builder: (_, state) => TerminationScreen(
                    employeeId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'contracts',
          builder: (_, _) => const ContractListScreen(),
          routes: [
            GoRoute(
              path: 'generate',
              builder: (_, _) => const GenerateContractScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  ContractDetailScreen(contractId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'sign',
                  builder: (_, state) => ContractSignScreen(
                    contractId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'pay-structures',
          builder: (_, _) => const PayStructuresScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (_, _) => const AddEditPayStructureScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (_, state) =>
                  AddEditPayStructureScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'pay-groups',
          builder: (_, _) => const PayGroupsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (_, _) => const AddEditPayGroupScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (_, state) =>
                  AddEditPayGroupScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'attendance',
          builder: (_, _) => const AttendanceLogScreen(),
          routes: [
            GoRoute(path: 'clock-in', builder: (_, _) => const ClockInScreen()),
            GoRoute(
              path: 'exceptions',
              builder: (_, _) => const AttendanceExceptionsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'pay-runs',
          builder: (_, _) => const PayRunListScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const RunPayrollScreen()),
            GoRoute(
              path: 'retroactive',
              builder: (_, _) => const RetroactivePayScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  PayRunDetailScreen(payRunId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'approval',
                  builder: (_, state) => PayrollApprovalScreen(
                    payRunId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'payslips',
          builder: (_, _) => const PayslipListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  PayslipDetailScreen(payslipId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'leave',
          builder: (_, _) => const LeaveDashboardScreen(),
          routes: [
            GoRoute(
              path: 'request',
              builder: (_, _) => const LeaveRequestScreen(),
            ),
            GoRoute(
              path: 'approval',
              builder: (_, _) => const LeaveApprovalScreen(),
            ),
            GoRoute(
              path: 'balances',
              builder: (_, _) => const LeaveBalanceScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'deductions',
          builder: (_, _) => const DeductionsScreen(),
          routes: [
            GoRoute(
              path: 'garnishee',
              builder: (_, _) => const GarnisheeOrdersScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, _) => const AddEditGarnisheeScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => GarnisheeDetailScreen(
                    orderId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => AddEditGarnisheeScreen(
                        orderId: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'compliance',
          builder: (_, _) => const ComplianceScreen(),
          routes: [
            GoRoute(path: 'uif', builder: (_, _) => const UifReturnsScreen()),
            GoRoute(path: 'paye', builder: (_, _) => const PayeScreen()),
            GoRoute(path: 'sdl', builder: (_, _) => const SdlScreen()),
            GoRoute(path: 'emp501', builder: (_, _) => const Emp501Screen()),
            GoRoute(path: 'coida', builder: (_, _) => const CoidaScreen()),
            GoRoute(
              path: 'alerts/:id',
              builder: (_, state) => ComplianceAlertDetailScreen(
                alertId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'reports',
          builder: (_, _) => const PayrollReportsScreen(),
        ),
        GoRoute(path: 'audit', builder: (_, _) => const AuditLogScreen()),
        GoRoute(
          path: 'disbursements',
          builder: (_, _) => const DisbursementsScreen(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (_, _) => const PaymentHistoryScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => TransactionDetailScreen(
                transactionId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'incidents',
          builder: (_, _) => const IncidentsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  IncidentDetailScreen(incidentId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'communications',
          builder: (_, _) => const CommunicationsScreen(),
          routes: [
            GoRoute(
              path: 'compose',
              builder: (_, _) => const ComposeMessageScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'roster',
          builder: (_, _) => const RosterBoardScreen(),
          routes: [
            GoRoute(
              path: 'add-shift',
              builder: (_, state) => AddShiftScreen(
                preselectedDate: state.extra is DateTime
                    ? state.extra as DateTime
                    : null,
              ),
            ),
            GoRoute(
              path: 'task-sheet',
              builder: (_, state) => TaskSheetScreen(
                shiftId: state.uri.queryParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (_, state) => AddShiftScreen(
                editShift: state.extra is Shift ? state.extra as Shift : null,
              ),
            ),
            GoRoute(
              path: 'add-piecework-log',
              builder: (_, _) => const AddPieceworkLogScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'self-service',
          builder: (_, _) => const WorkerSelfServiceScreen(),
        ),
        GoRoute(
          path: 'settings',
          routes: [
            GoRoute(
              path: 'employer-config',
              builder: (_, _) => const EmployerConfigScreen(),
            ),
          ],
          redirect: (_, _) => null,
          builder: (_, _) => const EmployerConfigScreen(),
        ),
      ],
    ),
  ];
}
