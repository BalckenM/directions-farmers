import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// A white-background scaffold with optional breadcrumbs, back button,
/// and header actions. Provides consistent page layout for all PR screens.
///
/// Example:
/// ```dart
/// PrPageScaffold(
///   title: 'Employees',
///   breadcrumbs: ['Payroll', 'Employees'],
///   actions: [
///     FilledButton.icon(icon: Icon(Icons.add), label: Text('Add Employee'), onPressed: ...),
///   ],
///   body: EmployeeListBody(),
/// )
/// ```
class PrPageScaffold extends StatelessWidget {
  const PrPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.breadcrumbs,
    this.actions,
    this.subtitle,
    this.bottomBar,
    this.floatingActionButton,
    this.showBack = true,
    this.onBack,
    this.sliverBody = false,
    this.headerPinned = true,
    this.resizeToAvoidBottomInset = true,
  });

  final String title;
  final Widget body;
  final List<String>? breadcrumbs;
  final List<Widget>? actions;
  final String? subtitle;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool showBack;
  final VoidCallback? onBack;
  final bool sliverBody;
  final bool headerPinned;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PayrollTokens.pageBg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PrPageHeader(
              title: title,
              subtitle: subtitle,
              breadcrumbs: breadcrumbs,
              actions: actions,
              showBack: showBack,
              onBack: onBack,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _PrPageHeader extends StatelessWidget {
  const _PrPageHeader({
    required this.title,
    this.subtitle,
    this.breadcrumbs,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      color: PayrollTokens.cardBg,
      padding: const EdgeInsets.fromLTRB(
        PayrollTokens.spacingMd,
        12,
        PayrollTokens.spacingMd,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _Breadcrumbs(crumbs: breadcrumbs!),
            ),
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showBack && canPop)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 22,
                      color: PayrollTokens.textPrimary,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: PayrollTokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: PayrollTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: a,
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.crumbs});
  final List<String> crumbs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: crumbs.asMap().entries.expand((e) {
        final isLast = e.key == crumbs.length - 1;
        return [
          Text(
            e.value,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: isLast ? PayrollTokens.brand : PayrollTokens.textSecondary,
              fontWeight: isLast ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: PayrollTokens.textMuted,
              ),
            ),
        ];
      }).toList(),
    );
  }
}
