import 'package:dartz/dartz.dart';
import 'package:swasthsetu/core/errors/failures.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';

/// Contract for all authentication operations.
/// Implemented by [AuthRepositoryImpl].
abstract interface class AuthRepository {
  /// Signs in using Google.
  /// Returns the authenticated [UserModel] on success.
  Future<Either<Failure, UserModel>> signInWithGoogle();

  /// Checks whether a user document exists in Firestore for [uid].
  Future<Either<Failure, bool>> userExists({required String uid});

  /// Creates a minimal user document in Firestore for a new user.
  Future<Either<Failure, UserModel>> createUser({required UserModel user});

  /// Fetches the user document from Firestore.
  Future<Either<Failure, UserModel>> getUser({required String uid});

  /// Updates the [lastLoginAt] timestamp.
  Future<Either<Failure, void>> updateLastLogin({required String uid});

  /// Returns true if biometric (fingerprint / face) is available on device.
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Triggers the biometric authentication prompt.
  /// Returns true if authenticated successfully.
  Future<Either<Failure, bool>> authenticateWithBiometric();

  /// Saves the [uid] of the logged-in user to secure local storage.
  Future<Either<Failure, void>> saveSession({required String uid});

  /// Reads the saved session uid. Returns null if no session exists.
  Future<Either<Failure, String?>> getSession();

  /// Clears the local session and signs out of Firebase.
  Future<Either<Failure, void>> logout();
}
