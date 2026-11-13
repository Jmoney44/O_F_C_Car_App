// Connection settings for the "ofccar" Firebase project.
//
// Android is connected. On platforms that are not registered yet (iOS, web)
// the app runs in demo mode on sample data. To add one, register the app in
// the Firebase console and add its options below, or run
// `flutterfire configure`, which regenerates this whole file.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is not configured for web yet.');
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      _ => throw UnsupportedError(
        'Firebase is not configured for this platform yet.',
      ),
    };
  }

  // These values identify the project; they are not secrets. Access to data
  // is controlled by firestore.rules and storage.rules.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0nX_GWvsXIApUQRfaulsxFwh8LQodCwU',
    appId: '1:1047570474841:android:c1f01b623a3c6e5352ce48',
    messagingSenderId: '1047570474841',
    projectId: 'ofccar',
    storageBucket: 'ofccar.firebasestorage.app',
  );
}
