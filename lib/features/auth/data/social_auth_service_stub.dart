/// Web / unsupported platform stub — social sign-in is not available.
/// The real implementation lives in social_auth_service_mobile.dart.
library;

class SocialAuthResult {
  const SocialAuthResult({required this.provider, required this.idToken});

  final String provider;
  final String idToken;
}

class SocialAuthService {
  SocialAuthService();

  Future<SocialAuthResult?> signInWithGoogle() async {
    throw UnsupportedError('Google Sign-In is not supported on this platform.');
  }

  Future<SocialAuthResult?> signInWithApple() async {
    throw UnsupportedError('Apple Sign-In is not supported on this platform.');
  }

  Future<SocialAuthResult?> signInWithFacebook() async {
    throw UnsupportedError(
      'Facebook Sign-In is not supported on this platform.',
    );
  }

  bool get isAppleSignInAvailable => false;
}
