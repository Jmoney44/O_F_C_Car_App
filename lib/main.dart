import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/demo/demo_repositories.dart';
import 'data/firebase/firebase_repositories.dart';
import 'data/repositories.dart';
import 'firebase_options.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repositories = await _connect();
  runApp(
    ProviderScope(
      overrides: [repositoriesProvider.overrideWithValue(repositories)],
      child: const OfcApp(),
    ),
  );
}

/// Uses Firebase once `flutterfire configure` has generated the real
/// `firebase_options.dart`; until then falls back to in-memory sample data.
Future<Repositories> _connect() async {
  final FirebaseOptions options;
  try {
    options = DefaultFirebaseOptions.currentPlatform;
  } on UnsupportedError {
    debugPrint('Firebase is not configured: running in demo mode.');
    return demoRepositories();
  }
  await Firebase.initializeApp(options: options);
  return firebaseRepositories();
}
