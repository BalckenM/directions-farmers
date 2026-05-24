import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/advisor_models.dart';
import '../../providers/crop_providers.dart';

// Accepts either an AdvisorQuery (topic selection) or an AdvisorResponse
// (pre-fetched briefing card tap). Handles both via AsyncNotifierProvider.

class AdvisorChatScreen extends ConsumerStatefulWidget {
  const AdvisorChatScreen({super.key, required this.payload});

  /// Either an [AdvisorQuery] or a pre-fetched [AdvisorResponse].
  final Object payload;

  @override
  ConsumerState<AdvisorChatScreen> createState() =>
      _AdvisorChatScreenState();
}

class _AdvisorChatScreenState
    extends ConsumerState<AdvisorChatScreen> {
  AdvisorResponse? _response;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResponse();
  }

  Future<void> _loadResponse() async {
    final payload = widget.payload;
    if (payload is AdvisorResponse) {
      setState(() {
        _response = payload;
        _loading = false;
      });
      return;
    }
    if (payload is AdvisorQuery) {
      try {
        final res = await ref
            .read(advisorRepositoryProvider)
            .getAdvice(payload);
        if (mounted) setState(() { _response = res; _loading = false; });
      } catch (e) {
        if (mounted) setState(() { _error = e.toString(); _loading = false; });
      }
      return;
    }
    setState(() { _error = 'Invalid payload type'; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: FarmAppBar(
        title: _response?.topic.label ?? 'Crop Advisor',
        subtitle: '4Directions AI Advisor',
      ),
      body: _loading
          ? const _ThinkingState()
          : _error != null
              ? _ErrorState(message: _error!)
              : _ResponseView(response: _response!),
    );
  }
}

// ── Loading / thinking state ──────────────────────────────────────────────────

class _ThinkingState extends StatefulWidget {
  const _ThinkingState();

  @override
  State<_ThinkingState> createState() => _ThinkingStateState();
}

class _ThinkingStateState extends State<_ThinkingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _anim,
            child: const Icon(
              Icons.agriculture_rounded,
              size: 64,
              color: AppColors.cropGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Analysing your farm data...',
            style: tt.titleSmall?.copyWith(
              color: AppColors.cropGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Checking weather, pests, and crop conditions',
            style: tt.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load advice',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full response view ────────────────────────────────────────────────────────

class _ResponseView extends StatelessWidget {
  const _ResponseView({required this.response});

  final AdvisorResponse response;

  Color get _confidenceColor => switch (response.confidence) {
        AdvisorConfidence.high => AppColors.success,
        AdvisorConfidence.medium => AppColors.warning,
        AdvisorConfidence.low => AppColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // ── Advisor "message" bubble ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Advisor avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cropGreen.withAlpha(20),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.cropGreen.withAlpha(80)),
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    color: AppColors.cropGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '4D Crop Advisor',
                            style: tt.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.cropGreen,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs + 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _confidenceColor.withAlpha(20),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              response.confidence.label,
                              style: TextStyle(
                                color: _confidenceColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Message bubble
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.cropGreen.withAlpha(12),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border.all(
                            color: AppColors.cropGreen.withAlpha(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              response.headline,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.cropGreen,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              response.explanation,
                              style: tt.bodyMedium
                                  ?.copyWith(color: cs.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Recommendations ──────────────────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final rec = response.recommendations[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _RecommendationCard(rec: rec, index: i + 1),
              );
            },
            childCount: response.recommendations.length,
          ),
        ),

        // ── Disclaimer ───────────────────────────────────────────────────────
        if (response.disclaimer != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(15),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                      color: AppColors.warning.withAlpha(50)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        response.disclaimer!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                                color: AppColors.warning, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Ask another topic ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Ask Another Topic'),
              onPressed: () => context.go(AppRoutes.cropAiAdvisor),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Recommendation card ───────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec, required this.index});

  final AdvisorRecommendation rec;
  final int index;

  Color get _priorityColor => switch (rec.priority) {
        AdvisorPriority.immediate => AppColors.error,
        AdvisorPriority.soon => AppColors.warning,
        AdvisorPriority.planned => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _priorityColor;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    rec.title,
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    rec.priority.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.action,
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: AppRadius.card,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          size: 14,
                          color: AppColors.secondary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          rec.rationale,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (rec.timing != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        rec.timing!,
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
