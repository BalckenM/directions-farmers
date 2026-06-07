import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/shared/widgets/avatar_widget.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/farm_text_field.dart';
import 'package:mobile_app/shared/widgets/loading_shimmer.dart';
import 'package:mobile_app/shared/widgets/payroll/payroll_widgets.dart';

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

  // Group employees by engagement type (only used when no active search/filter)
  Map<EngagementType, List<PayrollEmployee>> _groupByEngagement(
    List<PayrollEmployee> employees,
  ) {
    final order = [
      EngagementType.permanent,
      EngagementType.seasonal,
      EngagementType.casual,
      EngagementType.contractor,
    ];
    final groups = <EngagementType, List<PayrollEmployee>>{};
    for (final type in order) {
      final list = employees.where((e) => e.engagementType == type).toList();
      if (list.isNotEmpty) groups[type] = list;
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final allEmployees = ref.watch(employeesProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (!_initialLoadDone &&
        allEmployees.isEmpty &&
        _search.isEmpty &&
        _filter == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Employees'),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 6, itemHeight: 80),
        ),
      );
    }
    _initialLoadDone = true;

    final filtered = allEmployees.where((e) {
      final matchesSearch =
          _search.isEmpty ||
          e.fullName.toLowerCase().contains(_search.toLowerCase()) ||
          (e.phone?.contains(_search) ?? false) ||
          e.occupationTitle.toLowerCase().contains(_search.toLowerCase());
      final matchesFilter = _filter == null || e.engagementType == _filter;
      return matchesSearch && matchesFilter;
    }).toList();

    // Use grouped view only when no active search or filter
    final useGrouped = _search.isEmpty && _filter == null;
    final groups = useGrouped ? _groupByEngagement(filtered) : null;

    // Build sliver list for grouped view
    Widget buildGroupedList() {
      final slivers = <Widget>[
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
      ];
      groups!.forEach((type, employees) {
        final color = _engagementAccentColor(type);
        // Section header (non-pinned to avoid Flutter Web mouse-tracker assert)
        slivers.add(
          SliverToBoxAdapter(
            child: _GroupHeader(
              label: _engagementLabel(type),
              count: employees.length,
              color: color,
            ),
          ),
        );
        // Employee list for this group
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _EmployeeTile(employee: employees[i]),
                ),
                childCount: employees.length,
              ),
            ),
          ),
        );
      });
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 100)));
      return CustomScrollView(slivers: slivers);
    }

    Widget buildFlatList() {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          100,
        ),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          return _EmployeeTile(employee: filtered[i]);
        },
      );
    }

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Employees'),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.payrollAddEmployee),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Employee'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Context strip ──────────────────────────────────────────────────
          _EmployeeContextStrip(employees: allEmployees),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: FarmTextField(
              controller: _searchCtrl,
              hint: 'Search by name, role or phone…',
              label: 'Search employees',
              prefixIcon: const Icon(Icons.search_rounded),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _EngagementFilterChip(
                  label: 'All',
                  selected: _filter == null,
                  color: AppColors.primary,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final t in EngagementType.values) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _EngagementFilterChip(
                    label: _engagementLabel(t),
                    selected: _filter == t,
                    color: _engagementAccentColor(t),
                    onTap: () => setState(() => _filter = t),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Result count ──────────────────────────────────────────────────
          if (filtered.isNotEmpty && !useGrouped)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: const Icon(
                      Icons.people_outline_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    title: _search.isNotEmpty
                        ? 'No results for "$_search"'
                        : 'No employees yet',
                    subtitle: _search.isNotEmpty
                        ? 'Try a different name or role'
                        : 'Tap "+ Add Employee" to add your first worker.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(employeesProvider),
                    child: useGrouped ? buildGroupedList() : buildFlatList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _engagementLabel(EngagementType t) => switch (t) {
  EngagementType.permanent => 'Permanent',
  EngagementType.seasonal => 'Seasonal',
  EngagementType.casual => 'Casual',
  EngagementType.contractor => 'Contractor',
};

Color _statusColor(EmploymentStatus s) => switch (s) {
  EmploymentStatus.active => AppColors.success,
  _ => AppColors.error,
};

Color _engagementAccentColor(EngagementType t) => switch (t) {
  EngagementType.permanent => AppColors.primary,
  EngagementType.seasonal => AppColors.secondary,
  EngagementType.casual => AppColors.warning,
  EngagementType.contractor => AppColors.success,
};

// ─── Group header ─────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: tt.labelMedium?.copyWith(
              color: color,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$count',
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$count employee${count == 1 ? '' : 's'}',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chip ─────────────────────────────────────────────────────────────

class _EngagementFilterChip extends StatelessWidget {
  const _EngagementFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

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
            color: selected ? color : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: selected ? color : cs.outlineVariant),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : cs.onSurface,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
    final initials =
        '${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}'
            .toUpperCase();

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(AppRoutes.payrollEmployeeDetail(employee.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Row(
            children: [
              // Avatar with profile image
              AvatarWidget(
                imageUrl: employee.profileImageUrl,
                initials: initials,
                radius: 20,
              ),
              const SizedBox(width: 12),
              // Name + role
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      employee.fullName,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (employee.occupationTitle.isNotEmpty)
                      Text(
                        employee.occupationTitle,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status pill
              PrStatusPill(
                label: employee.status == EmploymentStatus.active
                    ? 'Active'
                    : employee.status.name,
                foreground: _statusColor(employee.status),
                background: _statusColor(employee.status).withAlpha(20),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: cs.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Context strip ────────────────────────────────────────────────────────────

class _EmployeeContextStrip extends StatelessWidget {
  const _EmployeeContextStrip({required this.employees});
  final List<PayrollEmployee> employees;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) return const SizedBox.shrink();
    final active = employees
        .where((e) => e.status == EmploymentStatus.active)
        .length;
    final permanent = employees
        .where((e) => e.engagementType == EngagementType.permanent)
        .length;
    final seasonal = employees
        .where((e) => e.engagementType == EngagementType.seasonal)
        .length;
    final casual = employees
        .where((e) => e.engagementType == EngagementType.casual)
        .length;

    return Container(
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StripStat(
              label: 'Total',
              value: '${employees.length}',
              color: AppColors.primary,
            ),
            _StripDivider(),
            _StripStat(
              label: 'Active',
              value: '$active',
              color: AppColors.success,
            ),
            _StripDivider(),
            _StripStat(
              label: 'Permanent',
              value: '$permanent',
              color: AppColors.primary,
            ),
            _StripDivider(),
            _StripStat(
              label: 'Seasonal',
              value: '$seasonal',
              color: AppColors.secondary,
            ),
            _StripDivider(),
            _StripStat(
              label: 'Casual',
              value: '$casual',
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _StripStat extends StatelessWidget {
  const _StripStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: tt.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StripDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 12,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    color: Theme.of(context).colorScheme.outlineVariant,
  );
}
