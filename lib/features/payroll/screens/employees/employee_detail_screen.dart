import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/providers/payroll_action_providers.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/theme/payroll_tokens.dart';
import 'package:mobile_app/features/payroll/widgets/payroll_widgets.dart';
import 'package:mobile_app/shared/widgets/avatar_widget.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/payroll/payroll_widgets.dart' as prw;
import 'package:mobile_app/shared/widgets/progress_bar.dart';

final _dateFmt = DateFormat('d MMM y');
final _zarFmt = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _fmtDate(DateTime d) => _dateFmt.format(d);

Color _statusColor(EmploymentStatus s) => switch (s) {
  EmploymentStatus.active => AppColors.success,
  EmploymentStatus.terminated => AppColors.error,
  _ => AppColors.error,
};

String _empStatusLabel(EmploymentStatus s) => switch (s) {
  EmploymentStatus.active => 'Active',
  EmploymentStatus.inactive => 'Inactive',
  EmploymentStatus.terminated => 'Terminated',
};

// ─── Screen ───────────────────────────────────────────────────────────────────

class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeProvider(employeeId));
    if (employee == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Employee'),
        body: const EmptyState(
          icon: Icon(Icons.person_off_outlined, size: 56),
          title: 'Employee not found',
          subtitle: 'This record may have been removed.',
        ),
      );
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: employee.fullName,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit employee',
            onPressed: () =>
                context.push(AppRoutes.payrollEditEmployee(employee.id)),
          ),
          if (employee.status != EmploymentStatus.terminated)
            IconButton(
              icon: const Icon(Icons.person_remove_outlined),
              tooltip: 'Terminate employee',
              color: AppColors.error,
              onPressed: () =>
                  context.push(AppRoutes.payrollEmployeeTerminate(employee.id)),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // ── Header card ──────────────────────────────────────────────────
            _EmployeeHeader(employee: employee),

            // ── Tabs ─────────────────────────────────────────────────────────
            TabBar(
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              dividerColor: Theme.of(context).colorScheme.outlineVariant,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Contracts'),
                Tab(text: 'Leave'),
                Tab(text: 'Payslips'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ProfileTab(employee: employee),
                  _ContractTab(employeeId: employeeId),
                  _LeaveTab(employeeId: employeeId),
                  _PayslipsTab(employeeId: employeeId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _EmployeeHeader extends ConsumerWidget {
  const _EmployeeHeader({required this.employee});
  final PayrollEmployee employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initials =
        '${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}'
                '${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}'
            .toUpperCase();

    // Engagement accent drives the header palette
    final accent = _engagementAccent(employee.engagementType);
    final accentLight = accent.withValues(alpha: 0.10);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.08), cs.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Avatar with profile image – tappable to change
          GestureDetector(
            onTap: () => _pickAndUploadImage(context, ref),
            child: Stack(
              children: [
                AvatarWidget(
                  imageUrl: employee.profileImageUrl,
                  initials: initials.isNotEmpty ? initials : '?',
                  radius: 28,
                  backgroundColor: accentLight,
                  foregroundColor: accent,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 1.5),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 12,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.occupationTitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                // Engagement type chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    PayrollTokens.engagementLabel(employee.engagementType),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          prw.PrStatusPill(
            label: _empStatusLabel(employee.status),
            foreground: _statusColor(employee.status),
            background: _statusColor(employee.status).withAlpha(20),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Change Profile Photo',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library, color: AppColors.success),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;

    if (!context.mounted) return;
    // Upload the image
    final notifier = ref.read(employeeNotifierProvider.notifier);
    final url = await notifier.uploadProfileImage(employee.id, picked.path);
    if (!context.mounted) return;
    if (url != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

Color _engagementAccent(EngagementType t) => switch (t) {
  EngagementType.permanent => const Color(0xFF1E3A5F), // navy
  EngagementType.seasonal => const Color(0xFF0288D1), // sky
  EngagementType.casual => const Color(0xFFF57F17), // amber
  EngagementType.contractor => const Color(0xFF6A1B9A), // purple
};

// ─── Profile tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.employee});
  final PayrollEmployee employee;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        PrSectionCard(
          title: 'Personal Information',
          icon: Icons.person_outline_rounded,
          iconColor: AppColors.primary,
          children: [
            PrInfoRow(
              label: 'ID / Passport',
              value: employee.idOrPassportNumber,
            ),
            PrInfoRow(label: 'Phone', value: employee.phone ?? '—'),
            PrInfoRow(label: 'Email', value: employee.email ?? '—'),
            PrInfoRow(label: 'Address', value: employee.address),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrSectionCard(
          title: 'Employment',
          icon: Icons.work_outline_rounded,
          iconColor: AppColors.success,
          children: [
            PrInfoRow(label: 'Occupation', value: employee.occupationTitle),
            PrInfoRow(
              label: 'Type',
              value: PayrollTokens.engagementLabel(employee.engagementType),
            ),
            PrInfoRow(label: 'Start Date', value: _fmtDate(employee.startDate)),
            PrInfoRow(
              label: 'Status',
              value: _empStatusLabel(employee.status),
              valueColor: _statusColor(employee.status),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrSectionCard(
          title: 'Next of Kin',
          icon: Icons.family_restroom_rounded,
          iconColor: AppColors.secondary,
          children: [
            PrInfoRow(label: 'Name', value: employee.nextOfKinName),
            PrInfoRow(label: 'Phone', value: employee.nextOfKinPhone),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrSectionCard(
          title: 'Pay & Benefits',
          icon: Icons.payments_outlined,
          iconColor: AppColors.warning,
          children: [
            PrInfoRow(
              label: 'Payment Method',
              value: PayrollTokens.disbursementLabel(
                employee.disbursementMethod,
              ),
            ),
            if (employee.bankName != null)
              PrInfoRow(label: 'Bank', value: employee.bankName!),
            if (employee.bankAccountNumber != null)
              PrInfoRow(
                label: 'Account No.',
                value: employee.bankAccountNumber!,
              ),
            PrInfoRow(
              label: 'Housing Benefit',
              value: employee.hasHousingBenefit ? 'Yes' : 'No',
              valueColor: employee.hasHousingBenefit ? AppColors.success : null,
            ),
            PrInfoRow(
              label: 'Food Benefit',
              value: employee.hasFoodBenefit ? 'Yes' : 'No',
              valueColor: employee.hasFoodBenefit ? AppColors.success : null,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.account_balance_outlined, size: 18),
              label: const Text('Manage Benefit Contributions'),
              onPressed: () => context.push(
                AppRoutes.payrollBenefitContributionsByEmployee(employee.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ─── Contracts tab ────────────────────────────────────────────────────────────

class _ContractTab extends ConsumerWidget {
  const _ContractTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider(employeeId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (contracts.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.description_outlined, size: 56),
        title: 'No contracts on file',
        subtitle: 'Contracts added for this employee will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: contracts.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final c = contracts[i];
        final statusColor = PayrollTokens.contractStatusColor(c.status);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.jobDescription,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${PayrollTokens.contractTypeLabel(c.type)} · From ${_fmtDate(c.startDate)}',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              prw.PrStatusPill(
                label: PayrollTokens.contractStatusLabel(c.status),
                foreground: statusColor,
                background: statusColor.withAlpha(20),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Leave tab ────────────────────────────────────────────────────────────────

class _LeaveTab extends ConsumerWidget {
  const _LeaveTab({required this.employeeId});
  final String employeeId;

  // Semantic color per leave type name (heuristic on name, not ID)
  static Color _leaveTypeColor(String typeName) {
    final lower = typeName.toLowerCase();
    if (lower.contains('annual')) {
      return AppColors.success;
    }
    if (lower.contains('sick')) {
      return AppColors.error;
    }
    if (lower.contains('maternity') || lower.contains('paternity')) {
      return AppColors.secondary;
    }
    if (lower.contains('family')) {
      return AppColors.warning;
    }
    if (lower.contains('unpaid')) {
      return const Color(0xFF757575);
    }
    if (lower.contains('study')) {
      return AppColors.primary;
    }
    return PayrollTokens.sky;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(leaveBalancesProvider(employeeId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (balances.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.event_available_outlined, size: 56),
        title: 'No leave balances',
        subtitle: 'Leave entitlements will appear here once configured.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: balances.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final b = balances[i];
        final typeColor = _leaveTypeColor(b.leaveTypeName);
        final fraction = b.totalEntitled > 0
            ? (b.taken / b.totalEntitled).clamp(0.0, 1.0)
            : 0.0;
        final isLow = b.remaining < 2;
        final barColor = isLow ? AppColors.error : typeColor;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLow
                  ? AppColors.error.withValues(alpha: 0.4)
                  : cs.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      b.leaveTypeName,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${b.remaining.toStringAsFixed(1)} days left',
                    style: tt.bodySmall?.copyWith(
                      color: isLow ? AppColors.error : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ProgressBar(value: fraction, color: barColor, height: 6),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Taken ${b.taken.toStringAsFixed(1)} of ${b.totalEntitled.toStringAsFixed(1)} days',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Payslips tab ─────────────────────────────────────────────────────────────

class _PayslipsTab extends ConsumerWidget {
  const _PayslipsTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payslips = ref.watch(
      payslipsProvider(PayslipFilter(employeeId: employeeId)),
    );
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (payslips.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.receipt_long_outlined, size: 56),
        title: 'No payslips yet',
        subtitle: 'Payslips will appear here after each completed pay run.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: payslips.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final p = payslips[i];
        final period = DateFormat('MMM y').format(p.periodStart);
        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(AppRoutes.payrollPayslipDetail(p.id)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gross ${_zarFmt.format(p.grossPay)}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _zarFmt.format(p.netPay),
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
