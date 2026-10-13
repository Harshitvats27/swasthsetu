import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Feature injection modules ────────────────────────────────────────────────
// Uncomment each line as the feature is implemented.
import 'package:swasthsetu/features/auth/di/auth_injection.dart';
import 'package:swasthsetu/features/profile/di/profile_injection.dart';
import 'package:swasthsetu/features/appointments/di/appointments_injection.dart';
import 'package:swasthsetu/features/doctors/di/doctors_injection.dart';
import 'package:swasthsetu/features/hospitals/di/hospitals_injection.dart';
import 'package:swasthsetu/features/hospitals_queue/di/hospitals_queue_injection.dart';
// import 'package:swasthsetu/features/pharmacy/di/pharmacy_injection.dart';
import 'package:swasthsetu/features/sos/di/sos_injection.dart';
// import 'package:swasthsetu/features/chat/di/chat_injection.dart';
// import 'package:swasthsetu/features/ai_search/di/ai_search_injection.dart';

/// Global [GetIt] service locator instance.
/// Access via `sl<MyType>()` throughout the app.
final GetIt sl = GetIt.instance;

/// Initialises the service-locator.
/// Must be called (and awaited) before [runApp] in `main.dart`.
///
/// Registration order:
///   1. External / platform dependencies (Firebase, SharedPreferences, …)
///   2. Core services (Network client, secure storage, …)
///   3. Feature modules — each feature registers its own repos, BLoCs, etc.
Future<void> initDependencies() async {
  // ── 1. External ─────────────────────────────────────────────────────────────
  await _registerExternal();

  // ── 2. Core ─────────────────────────────────────────────────────────────────
  _registerCore();

  // ── 3. Features ─────────────────────────────────────────────────────────────
  // Call each feature-injection module here once implemented.
  authInjection(sl);
  profileInjection(sl);
  appointmentsInjection(sl);
  doctorsInjection(sl);
  hospitalsInjection(sl);
  hospitalsQueueInjection(sl);
  // pharmacyInjection(sl);
  sosInjection(sl);
  // chatInjection(sl);
  // aiSearchInjection(sl);
}

// ── Private helpers ──────────────────────────────────────────────────────────

Future<void> _registerExternal() async {
  // Firebase Auth
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Cloud Firestore
  final firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  sl.registerLazySingleton<FirebaseFirestore>(() => firestore);
  // SharedPreferences — requires async init
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
}

void _registerCore() {
  // Add core-level singletons here (e.g., NetworkClient, SecureStorage).
  // Example:
  //   sl.registerLazySingleton<NetworkClient>(() => NetworkClient(sl()));
}
