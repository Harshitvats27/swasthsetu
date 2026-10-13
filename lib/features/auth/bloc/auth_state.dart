part of 'auth_bloc.dart';

// ────────────────────────────────────────────────────────────────────────────
// States
// ────────────────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no auth decision yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Any async operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// A valid session UID was found locally; biometric prompt should fire.
class SessionRestored extends AuthState {
  const SessionRestored({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// OTP was sent successfully; UI should show OTP entry screen.
class OtpSent extends AuthState {
  const OtpSent({required this.verificationId, required this.phone});
  final String verificationId;
  final String phone;

  @override
  List<Object?> get props => [verificationId, phone];
}

/// OTP was resent; same verificationId but timer reset.
class OtpResent extends AuthState {
  const OtpResent({required this.verificationId, required this.phone});
  final String verificationId;
  final String phone;

  @override
  List<Object?> get props => [verificationId, phone];
}

/// OTP verified → existing user → navigate to Home.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.isProfileComplete,
  });
  final String userId;
  final bool isProfileComplete;

  @override
  List<Object?> get props => [userId, isProfileComplete];
}

/// OTP verified → brand new user → navigate to profile creation.
class NewUserRegistered extends AuthState {
  const NewUserRegistered({required this.userId, required this.phone});
  final String userId;
  final String phone;

  @override
  List<Object?> get props => [userId, phone];
}

/// Device supports biometrics; offer the biometric opt-in dialog.
class BiometricAvailable extends AuthState {
  const BiometricAvailable({required this.userId});
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Signed out — navigate to login.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Something went wrong.
class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
