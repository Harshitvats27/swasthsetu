part of 'auth_bloc.dart';

// ────────────────────────────────────────────────────────────────────────────
// Events
// ────────────────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Checks the local session on app start.
/// • If a UID is stored → emits [SessionRestored] (biometric prompt follows).
/// • If nothing stored → emits [AuthUnauthenticated].
class CheckSessionEvent extends AuthEvent {
  const CheckSessionEvent();
}

/// Signs in the user using Google Sign-In.
class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

/// Runs the biometric prompt.
/// Emits [AuthAuthenticated] on success or [AuthError] on failure.
class BiometricCheckEvent extends AuthEvent {
  const BiometricCheckEvent({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// User opts in to (or out of) biometric unlock for future sessions.
class SetBiometricPreferenceEvent extends AuthEvent {
  const SetBiometricPreferenceEvent({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Clears the session and signs out.
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
