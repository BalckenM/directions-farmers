import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/insights_repository.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final marketPricesProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) =>
        ref.watch(insightsRepositoryProvider).getMarketPrices());

// ── Screen ────────────────────────────────────────────────────────────────────

class MarketPricesScreen extends ConsumerWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(marketPricesProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Market Prices',
        subtitle: 'SA livestock & commodity prices',
      ),
      body: asyncValue.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(marketPricesProvider),
        ),
        data: (data) => _MarketBody(data: data),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _MarketBody extends StatelessWidget {
  const _MarketBody({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final updatedAt = data['updated_at'] as String? ?? '';
    final sourceNote = data['source_note'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Header info
        _InfoBanner(updatedAt: updatedAt, sourceNote: sourceNote),

        // Cattle
        if (data['cattle'] != null)
          _CattleSection(cattle: data['cattle'] as Map<String, dynamic>),

        // Sheep
        if (data['sheep'] != null)
          _SheeSection(sheep: data['sheep'] as Map<String, dynamic>),

        // Goats
        if (data['goats'] != null)
          _SimpleAnimalSection(
            title: 'Goats',
            emoji: '🐐',
            animalData: data['goats'] as Map<String, dynamic>,
          ),

        // Poultry
        if (data['poultry'] != null)
          _PoultrySection(poultry: data['poultry'] as Map<String, dynamic>),

        // Feed inputs
        if (data['feed_inputs'] != null)
          _FeedInputsSection(
              feedInputs: data['feed_inputs'] as Map<String, dynamic>),
      ],
    );
  }
}

// ── Header banner ─────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.updatedAt, required this.sourceNote});
  final String updatedAt, sourceNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String displayDate = updatedAt;
    final parsed = DateTime.tryParse(updatedAt);
    if (parsed != null) {
      displayDate = DateFormat('d MMMM yyyy').format(parsed);
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.info_outline_rounded, size: 16, color: cs.onPrimaryContainer),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text('Updated $displayDate',
                  style: theme.textTheme.labelMedium!
                      .copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(sourceNote,
              style: theme.textTheme.bodySmall!
                  .copyWith(color: cs.onPrimaryContainer)),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.emoji, required this.title});
  final String emoji, title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppSpacing.sm),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ── Price row ─────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.unit = ''});
  final String label, value, unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 6, horizontal: AppSpacing.md),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium)),
        Text(value,
            style: theme.textTheme.bodyMedium!
                .copyWith(fontWeight: FontWeight.w600)),
        if (unit.isNotEmpty)
          Text(' $unit',
              style: theme.textTheme.bodySmall),
      ]),
    );
  }
}

// ── Auction highlight card ────────────────────────────────────────────────────

class _AuctionHighlight extends StatelessWidget {
  const _AuctionHighlight({required this.highlight});
  final Map<String, dynamic> highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R', decimalDigits: 2);

    final market = highlight['market'] as String? ?? '';
    final date = highlight['date'] as String? ?? '';
    final topPrice = (highlight['top_price_per_kg'] as num?)?.toDouble();
    final note = highlight['note'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Row(children: [
        const Icon(Icons.gavel_rounded, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(market,
                  style: theme.textTheme.bodySmall!
                      .copyWith(fontWeight: FontWeight.bold)),
              Text(note, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (topPrice != null)
              Text(fmt.format(topPrice),
                  style: theme.textTheme.bodySmall!
                      .copyWith(fontWeight: FontWeight.bold)),
            if (topPrice != null)
              Text('/kg', style: theme.textTheme.labelSmall),
            Text(date, style: theme.textTheme.labelSmall),
          ],
        ),
      ]),
    );
  }
}

// ── Cattle section ────────────────────────────────────────────────────────────

class _CattleSection extends StatelessWidget {
  const _CattleSection({required this.cattle});
  final Map<String, dynamic> cattle;

  @override
  Widget build(BuildContext context) {
    final beefOnHoof = cattle['beef_on_hoof'] as Map<String, dynamic>?;
    final milkGate = cattle['milk_farm_gate'] as Map<String, dynamic>?;
    final highlights = (cattle['auction_highlights'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(emoji: '🐄', title: 'Cattle'),
        if (beefOnHoof != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Beef on Hoof',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          _PriceRow(label: 'Grade A bulls', value: 'R ${beefOnHoof['grade_a_bulls']}', unit: '/kg lw'),
          _PriceRow(label: 'Grade A heifers', value: 'R ${beefOnHoof['grade_a_heifers']}', unit: '/kg lw'),
          _PriceRow(label: 'Grade A/B steers', value: 'R ${beefOnHoof['grade_ab_steers']}', unit: '/kg lw'),
          _PriceRow(label: 'Weaners (male)', value: 'R ${beefOnHoof['weaners_male']}', unit: '/kg lw'),
          _PriceRow(label: 'Weaners (female)', value: 'R ${beefOnHoof['weaners_female']}', unit: '/kg lw'),
          _PriceRow(label: 'Cull cows', value: 'R ${beefOnHoof['cull_cows']}', unit: '/kg lw'),
        ],
        if (milkGate != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Milk (farm gate)',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          _PriceRow(label: 'Base price (raw)', value: 'R ${milkGate['base_price_raw']}', unit: '/litre'),
          _PriceRow(label: 'With quality premium', value: 'R ${milkGate['effective_with_premium']}', unit: '/litre'),
        ],
        if (highlights != null && highlights.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Recent auction highlights',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          for (final h in highlights) _AuctionHighlight(highlight: h),
        ],
        const Divider(height: AppSpacing.xl),
      ],
    );
  }
}

// ── Sheep section ─────────────────────────────────────────────────────────────

class _SheeSection extends StatelessWidget {
  const _SheeSection({required this.sheep});
  final Map<String, dynamic> sheep;

  @override
  Widget build(BuildContext context) {
    final mutton = sheep['mutton'] as Map<String, dynamic>?;
    final wool = sheep['wool'] as Map<String, dynamic>?;
    final highlights = (sheep['auction_highlights'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(emoji: '🐑', title: 'Sheep'),
        if (mutton != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Mutton (liveweight)',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          _PriceRow(label: 'Dorper slaughter', value: 'R ${mutton['dorper_slaughter']}', unit: '/kg lw'),
          _PriceRow(label: 'Merino slaughter', value: 'R ${mutton['merino_slaughter']}', unit: '/kg lw'),
          _PriceRow(label: 'Corriedale slaughter', value: 'R ${mutton['corriedale_slaughter']}', unit: '/kg lw'),
        ],
        if (wool != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Wool', style: Theme.of(context).textTheme.labelLarge),
          ),
          _PriceRow(label: 'Fine Merino (≤19µ)', value: 'R ${wool['fine_merino_19_micron']}', unit: '/kg clean'),
          _PriceRow(label: 'Medium Merino (20-22µ)', value: 'R ${wool['medium_merino_20_22_micron']}', unit: '/kg clean'),
          _PriceRow(label: 'Broad/Crossbred', value: 'R ${wool['broad_crossbred']}', unit: '/kg greasy'),
        ],
        if (highlights != null && highlights.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Recent auction highlights',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          for (final h in highlights) _AuctionHighlight(highlight: h),
        ],
        const Divider(height: AppSpacing.xl),
      ],
    );
  }
}

// ── Generic animal section (Goats, etc.) ─────────────────────────────────────

class _SimpleAnimalSection extends StatelessWidget {
  const _SimpleAnimalSection({
    required this.title,
    required this.emoji,
    required this.animalData,
  });
  final String title, emoji;
  final Map<String, dynamic> animalData;

  @override
  Widget build(BuildContext context) {
    final meat = animalData['meat'] as Map<String, dynamic>?;
    final highlights = (animalData['auction_highlights'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(emoji: emoji, title: title),
        if (meat != null) ...[
          for (final entry in meat.entries)
            if (entry.key != 'unit')
              _PriceRow(
                label: _formatKey(entry.key),
                value: 'R ${entry.value}',
                unit: '/kg lw',
              ),
        ],
        if (highlights != null && highlights.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Recent auction highlights',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          for (final h in highlights) _AuctionHighlight(highlight: h),
        ],
        const Divider(height: AppSpacing.xl),
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

// ── Poultry section ───────────────────────────────────────────────────────────

class _PoultrySection extends StatelessWidget {
  const _PoultrySection({required this.poultry});
  final Map<String, dynamic> poultry;

  @override
  Widget build(BuildContext context) {
    final broilers = poultry['broilers_live'] as Map<String, dynamic>?;
    final eggs = poultry['eggs'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(emoji: '🐔', title: 'Poultry'),
        if (broilers != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Broilers (liveweight)',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          _PriceRow(label: 'Grade A broilers', value: 'R ${broilers['grade_a_per_kg']}', unit: '/kg lw'),
          _PriceRow(label: 'Spent hens', value: 'R ${broilers['spent_hens_per_kg']}', unit: '/kg lw'),
        ],
        if (eggs != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Eggs', style: Theme.of(context).textTheme.labelLarge),
          ),
          _PriceRow(label: 'Extra large (6s)', value: 'R ${eggs['extra_large_6_pack']}', unit: '/pack'),
          _PriceRow(label: 'Large (12s)', value: 'R ${eggs['large_12_pack']}', unit: '/pack'),
          _PriceRow(label: 'Free-range premium (%)', value: '+${eggs['free_range_premium_percent']}%', unit: ''),
        ],
        const Divider(height: AppSpacing.xl),
      ],
    );
  }
}

// ── Feed inputs section ───────────────────────────────────────────────────────

class _FeedInputsSection extends StatelessWidget {
  const _FeedInputsSection({required this.feedInputs});
  final Map<String, dynamic> feedInputs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(emoji: '🌾', title: 'Feed Inputs'),
        for (final entry in feedInputs.entries)
          if (entry.value is Map) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(_formatKey(entry.key),
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            for (final sub in (entry.value as Map).entries)
              if (sub.key != 'unit')
                _PriceRow(
                  label: _formatKey(sub.key),
                  value: 'R ${sub.value}',
                  unit: '/tonne',
                ),
            const SizedBox(height: AppSpacing.xs),
          ],
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
