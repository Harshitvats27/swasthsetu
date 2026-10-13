import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';
import 'package:swasthsetu/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:swasthsetu/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swasthsetu/features/auth/data/repositories/auth_repository.dart';
import 'package:swasthsetu/features/auth/data/repositories/auth_repository_impl.dart';

/// Registers all auth-feature dependencies into [sl].
///
/// Registration order:
///   1. Platform / external (LocalAuthentication, FlutterSecureStorage)
///   2. Data sources
///   3. Repository
///   4. BLoC (factory — new instance per widget subtree)
void authInjection(GetIt sl) {
  // ── 1. Platform ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: const AndroidOptions(),
    ),
  );

  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // ── 2. Data sources ────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      secureStorage: sl(),
      prefs: sl(),
      localAuth: sl(),
    ),
  );

  // ── 3. Repository ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  // ── 4. BLoC ────────────────────────────────────────────────────────────────
  // Factory so each BlocProvider gets a fresh instance.
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(repository: sl()),
  );
}
