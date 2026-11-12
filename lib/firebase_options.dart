// PLACEHOLDER. Replace this file by running, from the project folder:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command connects the app to your Firebase project and overwrites this
// file with the real settings. Until then the app runs in demo mode on
// sample data. See README.md for the full setup steps.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured yet. Run "flutterfire configure".',
    );
  }
}
