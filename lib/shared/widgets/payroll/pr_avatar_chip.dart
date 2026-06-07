import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';
import 'package:mobile_app/shared/widgets/avatar_widget.dart';

/// A circular avatar with profile image (or initials fallback) + employee name chip.
/// Used in tables, pay run rows, payslips, and assignments.
///
/// Example:
/// ```dart
/// PrAvatarChip(name: 'John Doe', employeeCode: 'EMP-001', imageUrl: emp.profileImageUrl)
/// PrAvatarChip(name: 'Sarah Khumalo', avatarColor: PayrollTokens.brand, subtitle: 'Supervisor')
/// ```
class PrAvatarChip extends StatelessWidget {
  const PrAvatarChip({
    super.key,
    required this.name,
    this.employeeCode,
    this.subtitle,
    this.avatarColor,
    this.imageUrl,
    this.size = PrAvatarChipSize.medium,
    this.onTap,
    this.showCode = false,
  });

  final String name;
  final String? employeeCode;
  final String? subtitle;
  final Color? avatarColor;
  final String? imageUrl;
  final PrAvatarChipSize size;
  final VoidCallback? onTap;
  final bool showCode;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Color _colorForName(String name) {
    final colors = [
      PayrollTokens.brand,
      PayrollTokens.brandSecondary,
      const Color(0xFF0EA5E9), // sky
      const Color(0xFF14B8A6), // teal
      const Color(0xFFF97316), // orange
      const Color(0xFFEC4899), // pink
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final Color color = avatarColor ?? _colorForName(name);
    final initials = _initials(name);

    final double avatarSize = switch (size) {
      PrAvatarChipSize.small => 28,
      PrAvatarChipSize.medium => 34,
      PrAvatarChipSize.large => 42,
    };

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarWidget(
            imageUrl: imageUrl,
            initials: initials,
            radius: avatarSize / 2,
            backgroundColor: color.withValues(alpha: 0.15),
            foregroundColor: color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: PayrollTokens.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showCode && employeeCode != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        employeeCode!,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: PayrollTokens.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: PayrollTokens.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else if (!showCode && employeeCode != null)
                  Text(
                    employeeCode!,
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: PayrollTokens.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PrAvatarChipSize { small, medium, large }
