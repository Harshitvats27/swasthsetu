import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/router/app_routes.dart';

// ── Auth pages ──────────────────────────────────────────────────────────────
import 'package:swasthsetu/features/auth/presentation/pages/splash_page.dart';
import 'package:swasthsetu/features/auth/presentation/pages/login_page.dart';
// Removed otp_page.dart

// ── Shell / Home ────────────────────────────────────────────────────────────
import 'package:swasthsetu/core/router/shell_scaffold.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/core/di/injection_container.dart';
import 'package:swasthsetu/features/profile/bloc/profile_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_bloc.dart';
import 'package:swasthsetu/features/doctors/bloc/doctor_event.dart';
import 'package:swasthsetu/features/appointments/bloc/appointments_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swasthsetu/features/appointments/data/models/appointment_model.dart';
import 'package:swasthsetu/features/hospitals_queue/bloc/hospitals_queue_bloc.dart';

// ── Feature pages ───────────────────────────────────────────────────────────
import 'package:swasthsetu/features/profile/presentation/pages/profile_page.dart';
import 'package:swasthsetu/features/profile/presentation/pages/patient_details_page.dart';
import 'package:swasthsetu/features/home/presentation/pages/home_page.dart';
import 'package:swasthsetu/features/appointments/presentation/pages/appointments_page.dart';
import 'package:swasthsetu/features/doctors/presentation/pages/doctors_page.dart';
import 'package:swasthsetu/features/hospitals/presentation/pages/hospitals_page.dart';
import 'package:swasthsetu/features/hospitals/presentation/pages/hospital_detail_page.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_bloc.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_event.dart';
import 'package:swasthsetu/features/hospitals/bloc/hospital_state.dart';
import 'package:swasthsetu/features/hospitals/data/models/hospital_model.dart';
import 'package:swasthsetu/features/hospitals_queue/presentation/pages/hospitals_queue_page.dart';
import 'package:swasthsetu/features/pharmacy/presentation/pages/pharmacy_page.dart';
import 'package:swasthsetu/features/sos/presentation/pages/sos_page.dart';
import 'package:swasthsetu/features/chat/presentation/pages/chat_page.dart';
import 'package:swasthsetu/features/ai_search/presentation/pages/ai_search_page.dart';

/// The top-level [GoRouter] for SwasthSetu.
///
/// Structure:
///   /                     → SplashPage (initial)
///   /login                → LoginPage  (phone entry)
///   /otp                  → OtpPage    (OTP verify)
///   /pin                  → PinPage    (4-digit PIN / biometric)
///   /shell                → ShellScaffold (persistent bottom nav)
///     /home               → HomePage
///     /profile            → ProfilePage
///     /appointments       → AppointmentsPage
///     /doctors            → DoctorsPage
///     /hospitals-queue    → HospitalsQueuePage
///     /pharmacy           → PharmacyPage
///     /sos                → SosPage
///     /chat               → ChatPage
///     /ai-search          → AiSearchPage
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // ── Auth flow ────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.patientDetails,
      name: 'patientDetails',
      builder: (context, state) => BlocProvider<ProfileBloc>(
        create: (_) => sl<ProfileBloc>(),
        child: const PatientDetailsPage(),
      ),
    ),

    // ── Shell (bottom nav) ────────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>(
            create: (_) => sl<ProfileBloc>()..add(LoadProfileEvent(uid: sl<FirebaseAuth>().currentUser?.uid ?? '')),
          ),
          BlocProvider<AppointmentsBloc>(
            create: (_) => sl<AppointmentsBloc>(),
          ),
          BlocProvider<HospitalBloc>(
            create: (_) => sl<HospitalBloc>()..add(LoadHospitalsEvent()),
          ),
        ],
        child: ShellScaffold(child: child),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => BlocProvider<DoctorBloc>(
            create: (_) => sl<DoctorBloc>()..add(LoadDoctorsEvent()),
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.appointments,
          name: 'appointments',
          builder: (context, state) => const AppointmentsPage(),
        ),
        GoRoute(
          path: AppRoutes.doctors,
          name: 'doctors',
          builder: (context, state) => BlocProvider<DoctorBloc>(
            create: (_) => sl<DoctorBloc>(),
            child: const DoctorsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.hospitals,
          name: 'hospitals',
          builder: (context, state) => const HospitalsPage(),
        ),
        GoRoute(
          path: AppRoutes.hospitalDetail,
          name: 'hospitalDetail',
          builder: (context, state) {
            final hospitalId = state.pathParameters['id'];
            
            // Try to find the hospital from the bloc state
            final hospitalBlocState = context.read<HospitalBloc>().state;
            HospitalModel? hospital;
            if (hospitalBlocState is HospitalLoaded) {
              try {
                hospital = hospitalBlocState.hospitals.firstWhere((h) => h.id == hospitalId);
              } catch (_) {
                hospital = null;
              }
            }
            // Fallback to extra if still passed for some reason, though we shouldn't pass it anymore
            hospital ??= state.extra as HospitalModel?;
            
            if (hospital == null) {
              return const Scaffold(body: Center(child: Text('Hospital not found')));
            }

            return BlocProvider<DoctorBloc>(
              create: (_) => sl<DoctorBloc>(),
              child: HospitalDetailPage(hospital: hospital),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.hospitalsQueue,
          name: 'hospitalsQueue',
          builder: (context, state) {
            // Find appointment either from extra or fallback
            AppointmentModel? appt = state.extra as AppointmentModel?;
            
            return BlocProvider<HospitalsQueueBloc>(
              create: (_) => sl<HospitalsQueueBloc>(),
              child: HospitalsQueuePage(appointment: appt),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.pharmacy,
          name: 'pharmacy',
          builder: (context, state) => const PharmacyPage(),
        ),
        GoRoute(
          path: AppRoutes.sos,
          name: 'sos',
          builder: (context, state) => const SosPage(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          builder: (context, state) => const ChatPage(),
        ),
        GoRoute(
          path: AppRoutes.aiSearch,
          name: 'aiSearch',
          builder: (context, state) => const AiSearchPage(),
        ),
      ],
    ),
  ],

  // ── Error page ──────────────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);

