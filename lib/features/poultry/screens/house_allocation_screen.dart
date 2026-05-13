import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/poultry_providers.dart';

// ── House data model ──────────────────────────────────────────────────────────

class _HouseInfo {
  const _HouseInfo({
    required this.id,
    required this.name,
    required this.capacity,
    this.activeFlockId,
    this.activeFlockName,
    this.lastFlockId,
    this.lastFlockName,
    this.lastFlockStatus,
  });

  final String id;
  final String name;
  final int capacity;

  /// flockId of the currently active flock occupying this house.
  final String? activeFlockId;
  final String? activeFlockName;

  /// Last historical flock that was in this house.
  final String? lastFlockId;
  final String? lastFlockName;
  final String? lastFlockStatus; // 'harvested' | 'depleted' | 'sold'

  bool get isOccupied => activeFlockId != null;
}

// ── House name helper ─────────────────────────────────────────────────────────

String _formatHouseName(String houseId) {
  // 'house-001' → 'House 001', 'house-a' → 'House A', etc.
  final suffix = houseId.replaceFirst(RegExp(r'^house[-_]?', caseSensitive: false), '');
  return 'House ${suffix.toUpperCase()}';
}

List<_HouseInfo> _buildHousesFromFlocks(List<dynamic> flocks) {
  // Group by houseId
  final Map<String, List<dynamic>> byHouse = {};
  for (final f in flocks) {
    final id = f.houseId as String;
    byHouse.putIfAbsent(id, () => []).add(f);
  }

  return byHouse.entries.map((entry) {
    final houseId = entry.key;
    final houseFlocks = entry.value;

    // Active flock = status 'active'
    final active = houseFlocks
        .where((f) => (f.status as String) == 'active')
        .toList();
    active.sort((a, b) =>
        (b.placementDate as String).compareTo(a.placementDate as String));
    final activeFlock = active.isNotEmpty ? active.first : null;

    // Last non-active flock
    final historical = houseFlocks
        .where((f) => (f.status as String) != 'active')
        .toList();
    historical.sort((a, b) =>
        (b.placementDate as String).compareTo(a.placementDate as String));
    final lastFlock = historical.isNotEmpty ? historical.first : null;

    final capacity =
        (activeFlock ?? lastFlock)?.placementCount as int? ?? 0;

    return _HouseInfo(
      id: houseId,
      name: _formatHouseName(houseId),
      capacity: capacity,
      activeFlockId: activeFlock?.id as String?,
      activeFlockName: activeFlock?.batchName as String?,
      lastFlockId: lastFlock?.id as String?,
      lastFlockName: lastFlock?.batchName as String?,
      lastFlockStatus: lastFlock?.status as String?,
    );
  }).toList()
    ..sort((a, b) => a.id.compareTo(b.id));
}

// ── Screen ────────────────────────────────────────────────────────────────────

class HouseAllocationScreen extends ConsumerWidget {
  const HouseAllocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flocksAsync = ref.watch(flocksProvider);

    final flockList = flocksAsync.value ?? [];
    final houses = _buildHousesFromFlocks(flockList);

    // Compute current occupancy pct from live data where possible
    final occupancyByFlock =
        {for (final f in flockList) f.id: f.currentCount};

    final occupied = houses.where((h) => h.isOccupied).length;
    final total = houses.length;
    final totalCapacity = houses.fold(0, (s, h) => s + h.capacity);
    final totalBirds = houses.fold<int>(
      0,
      (s, h) => s +
          (h.activeFlockId != null
              ? (occupancyByFlock[h.activeFlockId] ?? 0)
              : 0),
    );

    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(
        title: 'House Allocation',
        subtitle: 'Shed occupancy & AIAO management',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Summary strip ───────────────────────────────────────────────
          Container(
            color: AppColors.poultryColor.withAlpha(15),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryStat(
                    label: 'Houses',
                    value: '$occupied / $total occupied'),
                _SummaryStat(
                    label: 'Birds',
                    value: '$totalBirds / $totalCapacity capacity'),
                _SummaryStat(
                    label: 'Utilisation',
                    value: totalCapacity == 0
                        ? '—'
                        : '${(totalBirds / totalCapacity * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),

          // ── House cards ─────────────────────────────────────────────────
          Expanded(
            child: houses.isEmpty
                ? flocksAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('No houses found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: houses.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _HouseCard(
                      house: houses[i],
                      currentBirds: houses[i].activeFlockId != null
                          ? occupancyByFlock[houses[i].activeFlockId]
                          : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── House Card ────────────────────────────────────────────────────────────────

class _HouseCard extends StatelessWidget {
  const _HouseCard({required this.house, this.currentBirds});

  final _HouseInfo house;
  final int? currentBirds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occupied = house.isOccupied;
    final statusColor = occupied ? AppColors.poultryColor : AppColors.success;
    final statusLabel = occupied ? 'OCCUPIED' : 'AVAILABLE';
    final occupancyPct = currentBirds != null
        ? (currentBirds! / house.capacity).clamp(0.0, 1.0)
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (occupied ? AppColors.poultryColor : AppColors.success)
                            .withAlpha(31),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    occupied ? Icons.home_work_outlined : Icons.home_outlined,
                    color: occupied
                        ? AppColors.poultryColor
                        : AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(house.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                          'Capacity: ${house.capacity.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} birds',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: statusColor.withAlpha(102), width: 0.8),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ),
              ],
            ),

            // Occupancy bar
            if (occupancyPct != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: occupancyPct,
                        minHeight: 6,
                        backgroundColor:
                            AppColors.poultryColor.withAlpha(31),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.poultryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(occupancyPct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.poultryColor),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            if (occupied && house.activeFlockName != null) ...[
              // Active flock info
              _InfoRow(
                icon: Icons.settings_outlined,
                label: 'Active batch',
                value: house.activeFlockName!,
                onTap: house.activeFlockId != null
                    ? () => context.push(
                        AppRoutes.flockDetailPath(house.activeFlockId!))
                    : null,
              ),
              // AIAO compliance indicator
              _InfoRow(
                icon: Icons.sync_outlined,
                label: 'AIAO',
                value: 'All-in All-out mode active',
                valueColor: AppColors.success,
              ),
            ] else ...[
              // Empty house info
              if (house.lastFlockName != null)
                _InfoRow(
                  icon: Icons.history_outlined,
                  label: 'Last batch',
                  value:
                      '${house.lastFlockName} (${house.lastFlockStatus ?? 'ended'})',
                  valueColor: theme.colorScheme.onSurfaceVariant,
                  onTap: house.lastFlockId != null
                      ? () => context.push(
                          AppRoutes.flockDetailPath(house.lastFlockId!))
                      : null,
                ),
              _InfoRow(
                icon: Icons.cleaning_services_outlined,
                label: 'Status',
                value: 'Ready for next batch',
                valueColor: AppColors.success,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.poultryColor)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(icon,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text('$label: ',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right,
                  size: 14, color: AppColors.poultryColor),
          ],
        ),
      ),
    );
  }
}
