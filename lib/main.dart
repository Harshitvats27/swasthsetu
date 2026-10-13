import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/core.dart';
import 'firebase_options.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';
import 'package:swasthsetu/core/utils/seeder.dart';
import 'package:swasthsetu/features/sos/bloc/sos_bloc.dart';

/// BLoC observer for logging state transitions during development.
class _AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // ignore: avoid_print
    debugPrint('[BLoC] ${bloc.runtimeType}: $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    debugPrint('[BLoC ERROR] ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


// ── Dependency Injection ──────────────────────────────────────────────────
  await initDependencies();

  // Run seeding in background without blocking runApp
  Seeder.seedDatabase().then((_) => debugPrint('Database seeded!'));

  // ── BLoC observer ────────────────────────────────────────────────────────
  Bloc.observer = _AppBlocObserver();

  runApp(const SwasthSetuApp());
}

/// Root application widget.
class SwasthSetuApp extends StatelessWidget {
  const SwasthSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const CheckSessionEvent()),
        ),
        BlocProvider<SosBloc>(
          create: (_) => sl<SosBloc>()..add(StartSosListening()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            appRouter.go(AppRoutes.login);
          }
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          // go_router
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
