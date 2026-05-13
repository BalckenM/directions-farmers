import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/traceability/models/movement_record.dart';

/// A card showing a B313 Movement Permit summary with share and print actions.
///
/// Renders a styled preview of the permit details and provides action buttons
/// to share (e.g. via WhatsApp) or print the permit once PDF generation
/// is implemented (Sprint 4).
class MovementPermitCard extends StatelessWidget {
  const MovementPermitCard({
    super.key,
    required this.record,
    this.onShare,
    this.onPrint,
    this.compact = false,
  });

  /// The movement record to display as a B313 permit.
  final MovementRecord record;

  /// Called when the user taps "Share". If null the button is disabled.
  final VoidCallback? onShare;

  /// Called when the user taps "Print". If null the button is disabled.
  final VoidCallback? onPrint;

  /// When true, renders a condensed single-row version suitable for lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactPermitCard(record: record) : _FullPermitCard(
      record: record,
      onShare: onShare,
      onPrint: onPrint,
    );
  }
}

// ── Full card ─────────────────────────────────────────────────────────────────

class _FullPermitCard extends StatelessWidget {
  const _FullPermitCard({
    required this.record,
    this.onShare,
    this.onPrint,
  });

  final MovementRecord record;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.description_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'B313 Movement Permit',
                        style: tt.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (record.permitNumber != null)
                        Text(
                          'Permit No: ${record.permitNumber}',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.primary.withAlpha(180),
                          ),
                        ),
                    ],
                  ),
                ),
                // RMIS status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: record.rmisSubmitted
                        ? AppColors.successContainer
                        : AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    record.rmisSubmitted ? 'RMIS ✓' : 'RMIS Pending',
                    style: tt.labelSmall?.copyWith(
                      color: record.rmisSubmitted
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PermitRow(
                  icon: Icons.today_rounded,
                  label: 'Movement Date',
                  value: record.movementDate,
                ),
                _PermitRow(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Movement Type',
                  value: record.displayMovementType,
                ),
                _PermitRow(
                  icon: Icons.location_on_outlined,
                  label: 'From',
                  value: record.fromLocation,
                ),
                if (record.fromFarmRegistrationNo != null)
                  _PermitRow(
                    icon: Icons.numbers_rounded,
                    label: 'Farm Reg No.',
                    value: record.fromFarmRegistrationNo!,
                    indent: true,
                  ),
                _PermitRow(
                  icon: Icons.location_on_rounded,
                  label: 'To',
                  value: record.toLocation,
                ),
                if (record.toFarmRegistrationNo != null)
                  _PermitRow(
                    icon: Icons.numbers_rounded,
                    label: 'Dest. Reg No.',
                    value: record.toFarmRegistrationNo!,
                    indent: true,
                  ),
                _PermitRow(
                  icon: Icons.pets_rounded,
                  label: 'Species',
                  value: record.species[0].toUpperCase() +
                      record.species.substring(1),
                ),
                _PermitRow(
                  icon: Icons.tag_rounded,
                  label: 'Animals',
                  value: '${record.animalIds.length} head',
                ),
                if (record.transporterName != null)
                  _PermitRow(
                    icon: Icons.local_shipping_rounded,
                    label: 'Transporter',
                    value: record.transporterName!,
                  ),
                if (record.vehicleRegNo != null)
                  _PermitRow(
                    icon: Icons.directions_car_rounded,
                    label: 'Vehicle Reg',
                    value: record.vehicleRegNo!,
                  ),
                if (record.veterinaryHealthCertRef != null)
                  _PermitRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Vet Cert Ref',
                    value: record.veterinaryHealthCertRef!,
                    valueColor: AppColors.success,
                  ),
                if (record.rmisTransactionId != null)
                  _PermitRow(
                    icon: Icons.cloud_done_rounded,
                    label: 'RMIS Tx ID',
                    value: record.rmisTransactionId!,
                    valueColor: AppColors.success,
                  ),
              ],
            ),
          ),
          // ── Actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Print PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurfaceVariant,
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact card (list view) ──────────────────────────────────────────────────

class _CompactPermitCard extends StatelessWidget {
  const _CompactPermitCard({required this.record});
  final MovementRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(60),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.permitNumber != null
                      ? 'B313 — ${record.permitNumber}'
                      : 'B313 Permit',
                  style: tt.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${record.fromLocation} → ${record.toLocation}',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
            decoration: BoxDecoration(
              color: record.rmisSubmitted
                  ? AppColors.successContainer
                  : AppColors.warningContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              record.rmisSubmitted ? 'RMIS ✓' : 'Pending',
              style: tt.labelSmall?.copyWith(
                color: record.rmisSubmitted
                    ? AppColors.success
                    : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row helper ────────────────────────────────────────────────────────────────

class _PermitRow extends StatelessWidget {
  const _PermitRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.indent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.xs,
        left: indent ? AppSpacing.lg : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
