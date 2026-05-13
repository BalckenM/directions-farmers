import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Farm staff roles used for RBAC checks throughout the app.
enum UserRole { superAdmin, farmManager, farmWorker, veterinarian }

extension UserRoleX on UserRole {
  String get displayName => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.farmManager => 'Farm Manager',
        UserRole.farmWorker => 'Farm Worker',
        UserRole.veterinarian => 'Veterinarian',
      };

  /// Can register or archive flock batches.
  bool get canAddFlock =>
      this == UserRole.superAdmin || this == UserRole.farmManager;

  /// Can record batch status transitions (Harvested / Depleted / Sold).
  bool get canChangeBatchStatus =>
      this == UserRole.superAdmin || this == UserRole.farmManager;

  /// Can create, edit, or delete financial transactions.
  bool get canEditFinancials =>
      this == UserRole.superAdmin || this == UserRole.farmManager;

  /// Can prescribe or administer medication / vaccinations.
  bool get canAdministerMedication =>
      this == UserRole.superAdmin ||
      this == UserRole.farmManager ||
      this == UserRole.veterinarian;

  /// Can view reports and analytics screens.
  bool get canViewReports => this != UserRole.farmWorker;

  /// Can manage farm settings and paddocks.
  bool get canManageSettings => this == UserRole.superAdmin;
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Notifier for the current authenticated user's role.
class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.farmManager;

  /// Updates the active role (used in demo/testing mode).
  void setRole(UserRole role) => state = role;
}

/// Exposes the current authenticated user's role.
/// Defaults to [UserRole.farmManager] for the demo build.
final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole>(
  UserRoleNotifier.new,
);
