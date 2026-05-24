import '../models/auth_user.dart';

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
  AuthUser? restoreSession();
  Future<void> clearSession();
}
