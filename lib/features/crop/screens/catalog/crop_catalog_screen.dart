import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../models/crop.dart';
import '../../providers/crop_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CropCatalogScreen extends ConsumerStatefulWidget {
  const CropCatalogScreen({super.key});

  @override
  ConsumerState<CropCatalogScreen> createState() => _CropCatalogScreenState();
}

class _CropCatalogScreenState extends ConsumerState<CropCatalogScreen> {
  String _search = '';
  String? _selectedCategoryId; // null = "All"

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(cropCategoriesProvider);
    final cropsAsync = ref.watch(cropsProvider(_selectedCategoryId));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Crop Catalog',
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search crops…',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.button,
                  borderSide: BorderSide(color: cs.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── Category filter chips ────────────────────────────────────────
          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (categories) {
                final allCategories = [
                  null,
                  ...categories,
                ];
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: allCategories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (_, i) {
                    final cat = allCategories[i];
                    final isSelected = cat == null
                        ? _selectedCategoryId == null
                        : _selectedCategoryId == cat.id;
                    return FilterChip(
                      label: Text(
                        cat == null ? 'All' : cat.name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? cs.primary
                                  : cs.onSurface,
                            ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(
                        () => _selectedCategoryId =
                            cat?.id,
                      ),
                      selectedColor: cs.primary.withAlpha(25),
                      checkmarkColor: cs.primary,
                      side: BorderSide(
                        color: isSelected
                            ? cs.primary
                            : cs.outlineVariant,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Crop list ────────────────────────────────────────────────────
          Expanded(
            child: cropsAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: LoadingShimmer.list(count: 6, itemHeight: 96),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Unable to load crops',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
              data: (crops) {
                final filtered = _applySearch(crops);
                if (filtered.isEmpty) {
                  return _EmptyState(
                    search: _search,
                    categoryName: _selectedCategoryId,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _CropListTile(crop: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Crop> _applySearch(List<Crop> crops) {
    if (_search.isEmpty) return crops;
    final q = _search.toLowerCase();
    return crops.where((c) {
      return c.name.toLowerCase().contains(q) ||
          (c.scientificName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}

// ── Crop list tile ────────────────────────────────────────────────────────────

class _CropListTile extends StatelessWidget {
  const _CropListTile({required this.crop});
  final Crop crop;

  Color _waterColor(String req) {
    switch (req.toLowerCase()) {
      case 'high':
        return AppColors.tertiary;
      case 'low':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final wColor = _waterColor(crop.waterRequirement);

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.cropDetailPath(crop.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      crop.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
                ],
              ),
              if (crop.scientificName != null) ...[
                const SizedBox(height: 2),
                Text(
                  crop.scientificName!,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),

              // Chips: water + maturity
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _SmallChip(
                    icon: Icons.water_drop_outlined,
                    label: '${crop.waterRequirement} water',
                    color: wColor,
                  ),
                  _SmallChip(
                    icon: Icons.schedule_rounded,
                    label: crop.maturityRange,
                    color: cs.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // Suitable provinces
              if (crop.suitableProvinces.isNotEmpty)
                Text(
                  _provinceLabel(crop.suitableProvinces),
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _provinceLabel(List<String> provinces) {
    if (provinces.length <= 2) return 'Suitable: ${provinces.join(', ')}';
    return 'Suitable: ${provinces.take(2).join(', ')} +${provinces.length - 2} more';
  }
}

// ── Small chip ────────────────────────────────────────────────────────────────

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.search, required this.categoryName});
  final String search;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final msg = search.isNotEmpty
        ? 'No crops match "$search"'
        : 'No crops in this category';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: AppSpacing.iconXl,
            color: cs.onSurfaceVariant.withAlpha(80),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(msg, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
