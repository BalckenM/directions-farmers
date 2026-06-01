import 'package:mobile_app/features/auth/models/auth_user.dart';

/// Result of a social auth call — includes whether the user is new.
class SocialLoginResult {
  const SocialLoginResult({required this.user, required this.isNewUser});
  final AuthUser user;
  final bool isNewUser;
}

abstract class AuthDataSource {
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String farmName,
    required String country,
    required String province,
    required String subscriptionPlan,
    required List<String> activatedModules,
    String? phone,
  });
  Future<SocialLoginResult> socialLogin({
    required String provider,
    required String idToken,
  });
  Future<AuthUser?> restoreSession();
  Future<void> clearSession();

  /// Returns all staff accounts belonging to the given farm owner.
  List<AuthUser> getTeamMembers(String farmOwnerId);
}
