import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_text_field.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/payroll_employee.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';


class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  EngagementType? _filter;
  // Transitions from shimmer → real content after first frame with data or
  // after a short timer (so a truly empty list shows EmptyState, not shimmer).
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    // Allow one frame for data to load; if still empty it's a genuine empty list.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _initialLoadDone = true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allEmployees = ref.watch(employeesProvider);
    final cs = Theme.of(context).colorScheme;

    // Show shimmer only during the brief initial load window.
    if (!_initialLoadDone && allEmployees.isEmpty && _search.isEmpty && _filter == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Employees'),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 6, itemHeight: 72),
        ),
      );
    }
    _initialLoadDone = true; // mark done once we have data

    final filtered = allEmployees.where((e) {
      final matchesSearch = _search.isEmpty ||
          e.fullName.toLowerCase().contains(_search.toLowerCase()) ||
          (e.phone?.contains(_search) ?? false) ||
          e.occupationTitle.toLowerCase().contains(_search.toLowerCase());
      final matchesFilter = _filter == null || e.engagementType == _filter;
      return matchesSearch && matchesFilter;
    }).toList();

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Employees'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.payrollAddEmployee),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Employee'),
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: FarmTextField(
              controller: _searchCtrl,
              hint: 'Search by name, role…',
              label: 'Search employees',
              prefixIcon: const Icon(Icons.search_rounded),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _EngagementFilterChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final t in EngagementType.values) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _EngagementFilterChip(
                    label: _engagementLabel(t),
                    selected: _filter == t,
                    onTap: () => setState(() => _filter = t),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Count label ──────────────────────────────────────────────────────
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filtered.length} employee${filtered.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),

          // ── List ─────────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: const Icon(Icons.people_outline_rounded, size: 56),
                    title: _search.isNotEmpty
                        ? 'No results for "$_search"'
                        : 'No employees yet',
                    subtitle: _search.isNotEmpty
                        ? 'Try a different name or role'
                        : 'Tap "+ Add Employee" to add your first worker.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(employeesProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        100,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) =>
                          _EmployeeTile(employee: filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _engagementLabel(EngagementType t) => switch (t) {
      EngagementType.permanent   => 'Permanent',
      EngagementType.seasonal    => 'Seasonal',
      EngagementType.casual      => 'Casual',
      EngagementType.contractor  => 'Contractor',
    };

Color _statusColor(EmploymentStatus s) => switch (s) {
      EmploymentStatus.active => AppColors.success,
      _                       => AppColors.error,
    };

// ─── Filter chip ─────────────────────────────────────────────────────────────

class _EngagementFilterChip extends StatelessWidget {
  const _EngagementFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: selected ? PayrollTokens.navy : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(
              color: selected ? PayrollTokens.navy : cs.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : cs.onSurface,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Employee tile ────────────────────────────────────────────────────────────

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee});
  final PayrollEmployee employee;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initial = employee.firstName.isNotEmpty
        ? employee.firstName[0].toUpperCase()
        : '?';

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(AppRoutes.payrollEmployeeDetail(employee.id)),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: PayrollTokens.navy.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: PayrollTokens.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${employee.occupationTitle} · ${_engagementLabel(employee.engagementType)}',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: employee.status == EmploymentStatus.active
                    ? 'Active'
                    : employee.status.name,
                color: _statusColor(employee.status),
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
