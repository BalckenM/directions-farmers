import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// RFID / QR scan button for animal identification fields.
///
/// Designed as an [InputDecoration.suffixIcon] in a [TextField] or
/// [FarmTextField]. When tapped, shows a "coming soon" snackbar until
/// mobile_scanner is fully integrated.
///
/// Usage:
/// ```dart
/// FarmTextField(
///   label: 'RFID Number',
///   suffixIcon: RfidScanButton(onScanned: (code) => controller.text = code),
/// )
/// ```
class RfidScanButton extends StatelessWidget {
  const RfidScanButton({
    super.key,
    this.onScanned,
    this.tooltip = 'Scan RFID / QR code',
    this.enabled = true,
  });

  /// Callback with the scanned code string.
  /// If null, the button is display-only.
  final ValueChanged<String>? onScanned;
  final String tooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: const Icon(Icons.qr_code_scanner_outlined),
        color: enabled ? AppColors.primary : AppColors.outline,
        onPressed: enabled
            ? () => _handleScan(context)
            : null,
      ),
    );
  }

  void _handleScan(BuildContext context) {
    // TODO: integrate mobile_scanner when package is wired up.
    // For now, show an info dialog explaining the feature is coming.
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_outlined),
            SizedBox(width: AppSpacing.sm),
            Text('RFID / QR Scanner'),
          ],
        ),
        content: const Text(
          'RFID and QR code scanning will be available in the next '
          'app update.\n\nFor now, enter the tag number manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// A standalone scan card — larger CTA for screens where inline scan
/// is the primary action (e.g. animal look-up from RMIS).
class RfidScanCard extends StatelessWidget {
  const RfidScanCard({
    super.key,
    this.onScanned,
    this.hint = 'Tap to scan RFID tag or QR code',
  });

  final ValueChanged<String>? onScanned;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => RfidScanButton(onScanned: onScanned)._handleScan(context),
      borderRadius: AppRadius.card,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: AppRadius.card,
          color: AppColors.primaryContainer.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
