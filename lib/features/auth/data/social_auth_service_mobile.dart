import 'dart:io' show Platform;

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Result of a social sign-in attempt — contains the provider name and ID token.
class SocialAuthResult {
  const SocialAuthResult({required this.provider, required this.idToken});

  final String provider; // 'google' | 'apple' | 'facebook'
  final String idToken;
}

/// Handles native social SDK calls and returns ID tokens for backend verification.
class SocialAuthService {
  SocialAuthService();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
  }

  /// Sign in with Google and return the ID token.
  Future<SocialAuthResult?> signInWithGoogle() async {
    await _ensureInitialized();

    final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate(scopeHint: ['email', 'profile']);

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to obtain Google ID token');
    }

    return SocialAuthResult(provider: 'google', idToken: idToken);
  }

  /// Sign in with Apple and return the identity token.
  Future<SocialAuthResult?> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to obtain Apple identity token');
    }

    return SocialAuthResult(provider: 'apple', idToken: idToken);
  }

  /// Sign in with Facebook and return the access token.
  Future<SocialAuthResult?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.cancelled) return null;
    if (result.status != LoginStatus.success) {
      throw Exception(result.message ?? 'Facebook login failed');
    }

    final token = result.accessToken?.tokenString;
    if (token == null || token.isEmpty) {
      throw Exception('Failed to obtain Facebook access token');
    }

    return SocialAuthResult(provider: 'facebook', idToken: token);
  }

  /// Check if Apple Sign In is available on this platform.
  bool get isAppleSignInAvailable => Platform.isIOS || Platform.isMacOS;
}
