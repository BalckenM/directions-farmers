import 'auth_user.dart';

/// Sealed auth state hierarchy.
/// The router and UI pattern-match on this to decide what to show.
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => false;
  AuthUser? get user => null;
  String? get accessToken => null;
}

/// Initial state while restoring session from secure storage.
final class AuthInitializing extends AuthState {
  const AuthInitializing();
}

/// User is fully signed in.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user, required this.accessToken});

  @override
  final AuthUser user;

  @override
  final String accessToken;

  @override
  bool get isAuthenticated => true;
}

/// No session — user must sign in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Sign-in in progress (loading indicator shown in UI).
final class AuthSigningIn extends AuthState {
  const AuthSigningIn();
}

/// Backend returned mfa_required = true.
final class AuthMfaRequired extends AuthState {
  const AuthMfaRequired({required this.challengeToken, required this.email});

  final String challengeToken;
  final String email;
}

/// Sign-in failed with a human-readable message.
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
