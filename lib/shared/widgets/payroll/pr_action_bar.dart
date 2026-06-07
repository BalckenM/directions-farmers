import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Sticky bottom action bar for forms and multi-action screens.
/// Provides consistent placement of primary/secondary buttons.
///
/// Example:
/// ```dart
/// PrActionBar(
///   primaryLabel: 'Save Changes',
///   onPrimary: _handleSave,
///   secondaryLabel: 'Cancel',
///   onSecondary: () => context.pop(),
///   loading: _saving,
/// )
/// ```
class PrActionBar extends StatelessWidget {
  const PrActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tertiaryLabel,
    this.onTertiary,
    this.loading = false,
    this.primaryDestructive = false,
    this.disablePrimary = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;
  final bool loading;
  final bool primaryDestructive;
  final bool disablePrimary;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        PayrollTokens.spacingMd,
        PayrollTokens.spacingSm,
        PayrollTokens.spacingMd,
        PayrollTokens.spacingSm + mediaQuery.padding.bottom,
      ),
      decoration: BoxDecoration(
        color: PayrollTokens.cardBg,
        border: Border(top: BorderSide(color: PayrollTokens.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (tertiaryLabel != null) ...[
            TextButton(onPressed: onTertiary, child: Text(tertiaryLabel!)),
            const Spacer(),
          ],
          if (secondaryLabel != null) ...[
            if (tertiaryLabel == null) const Spacer(),
            OutlinedButton(
              onPressed: loading ? null : onSecondary,
              child: Text(secondaryLabel!),
            ),
            const SizedBox(width: 12),
          ],
          if (tertiaryLabel == null && secondaryLabel == null) const Spacer(),
          SizedBox(
            height: 44,
            child: FilledButton(
              style: primaryDestructive
                  ? FilledButton.styleFrom(
                      backgroundColor: PayrollTokens.statusError,
                      foregroundColor: Colors.white,
                    )
                  : null,
              onPressed: (loading || disablePrimary) ? null : onPrimary,
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
