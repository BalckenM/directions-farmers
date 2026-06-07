import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Horizontal step indicator for multi-step payroll forms.
/// Supports up to 6 steps with completed/active/future states.
///
/// Example:
/// ```dart
/// PrWizardStepper(
///   steps: ['Select Period', 'Review Employees', 'Pay Components', 'Confirm'],
///   currentStep: 1,
///   completedSteps: {0},
///   onStepTap: (i) => setState(() => _step = i),
/// )
/// ```
class PrWizardStepper extends StatelessWidget {
  const PrWizardStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.completedSteps = const {},
    this.onStepTap,
    this.compact = false,
  });

  final List<String> steps;
  final int currentStep;
  final Set<int> completedSteps;
  final void Function(int index)? onStepTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PayrollTokens.cardBg,
      padding: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: 12,
      ),
      child: compact
          ? _buildCompact()
          : Row(
              children: steps.asMap().entries.expand((e) {
                final index = e.key;
                final label = e.value;
                final isFirst = index == 0;
                final isLast = index == steps.length - 1;
                final isDone = completedSteps.contains(index);
                final isCurrent = index == currentStep;
                final isFuture = !isDone && !isCurrent;

                return [
                  if (!isFirst)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isDone
                            ? PayrollTokens.brand
                            : PayrollTokens.border,
                      ),
                    ),
                  _StepBubble(
                    index: index,
                    label: label,
                    isDone: isDone,
                    isCurrent: isCurrent,
                    isFuture: isFuture,
                    compact: false,
                    onTap: onStepTap != null ? () => onStepTap!(index) : null,
                  ),
                  if (isLast) const SizedBox.shrink(),
                ];
              }).toList(),
            ),
    );
  }

  Widget _buildCompact() {
    return Row(
      children: [
        Text(
          'Step ${currentStep + 1} of ${steps.length}',
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: PayrollTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: PayrollTokens.radiusFull,
            child: LinearProgressIndicator(
              value: (currentStep + 1) / steps.length,
              backgroundColor: PayrollTokens.border,
              valueColor: AlwaysStoppedAnimation(PayrollTokens.brand),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          steps[currentStep],
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: PayrollTokens.brand,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StepBubble extends StatelessWidget {
  const _StepBubble({
    required this.index,
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isFuture,
    required this.compact,
    this.onTap,
  });

  final int index;
  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isFuture;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = isDone
        ? PayrollTokens.brand
        : isCurrent
        ? PayrollTokens.brand
        : PayrollTokens.surfaceContainerHigh;

    final Color bubbleFg = isDone || isCurrent
        ? Colors.white
        : PayrollTokens.textMuted;

    final Color labelColor = isCurrent
        ? PayrollTokens.brand
        : isFuture
        ? PayrollTokens.textMuted
        : PayrollTokens.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(14),
              border: isCurrent
                  ? Border.all(color: PayrollTokens.brand, width: 2)
                  : null,
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check_rounded, size: 14, color: bubbleFg)
                  : Text(
                      '${index + 1}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: bubbleFg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
