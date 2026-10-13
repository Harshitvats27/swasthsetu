import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swasthsetu/features/auth/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Manages the authentication lifecycle for SwasthSetu.
///
/// Flow:
///   App open → [CheckSessionEvent]
///     ↳ session found → [SessionRestored] → [BiometricCheckEvent]
///         ↳ success   → [AuthAuthenticated]
///     ↳ no session   → [AuthUnauthenticated] → login screen
///
///   Login screen → [SendOtpEvent] → [OtpSent]
///   OTP screen   → [VerifyOtpEvent]
///     ↳ existing user → [AuthAuthenticated]
///     ↳ new user      → [NewUserRegistered]
///
///   Post first-login → check biometric → [BiometricAvailable] → opt-in
///
///   Any screen → [LogoutEvent] → [AuthUnauthenticated]
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repo = repository,
        super(const AuthInitial()) {
    on<CheckSessionEvent>(_onCheckSession);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<BiometricCheckEvent>(_onBiometricCheck);
    on<SetBiometricPreferenceEvent>(_onSetBiometricPreference);
    on<LogoutEvent>(_onLogout);
  }

  final AuthRepository _repo;

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onCheckSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final sessionResult = await _repo.getSession();
    await sessionResult.fold(
      (failure) async => emit(const AuthUnauthenticated()),
      (uid) async {
        if (uid == null || uid.isEmpty) {
          emit(const AuthUnauthenticated());
        } else {
          final userResult = await _repo.getUser(uid: uid);
          userResult.fold(
            (failure) => emit(const AuthUnauthenticated()),
            (user) {
              if (!user.isProfileComplete) {
                emit(NewUserRegistered(userId: user.uid, phone: user.phone));
              } else {
                emit(AuthAuthenticated(userId: user.uid, isProfileComplete: user.isProfileComplete));
              }
            },
          );
        }
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repo.signInWithGoogle();

    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        if (!user.isProfileComplete) {
          // Brand-new user — go to profile creation
          emit(NewUserRegistered(userId: user.uid, phone: user.phone));
        } else {
          // Existing user — go straight to home
          emit(AuthAuthenticated(
            userId: user.uid,
            isProfileComplete: user.isProfileComplete,
          ));
        }
      },
    );
  }

  Future<void> _onBiometricCheck(
    BiometricCheckEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repo.authenticateWithBiometric();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (authenticated) {
        if (authenticated) {
          // Restore the user from Firestore
          _repo.getUser(uid: event.uid).then((userResult) {
            userResult.fold(
              (failure) => emit(AuthError(message: failure.message)),
              (user) => emit(AuthAuthenticated(
                userId: user.uid,
                isProfileComplete: user.isProfileComplete,
              )),
            );
          });
        } else {
          // User cancelled biometric — fall back to OTP login
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSetBiometricPreference(
    SetBiometricPreferenceEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Preference is stored in SharedPreferences via the local datasource.
    // The BLoC doesn't emit a new state here — the calling page handles the UI.
    // (This is an intentional fire-and-forget preference save.)
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.logout();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
