// This file is a placeholder until you run `flutterfire configure`.
//
// To generate the real firebase_options.dart:
//   1. Install FlutterFire CLI:  dart pub global activate flutterfire_cli
//   2. Run:                      flutterfire configure
//   3. Commit the generated file and remove this placeholder.
//
// Until then, Firebase is disabled at runtime (FIREBASE_ENABLED=false by default).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase has not been configured for this project yet.\n'
      'Run `flutterfire configure` to generate firebase_options.dart.',
    );
  }
}
