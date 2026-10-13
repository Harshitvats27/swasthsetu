import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swasthsetu/core/errors/failures.dart';
import 'package:swasthsetu/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:swasthsetu/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';
import 'package:swasthsetu/features/auth/data/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final firebaseUser = await _remote.signInWithGoogle();

      final exists = await _remote.userExists(uid: firebaseUser.uid);

      if (exists) {
        await _remote.updateLastLogin(uid: firebaseUser.uid);
        final user = await _remote.getUser(uid: firebaseUser.uid);
        await _local.saveSession(uid: firebaseUser.uid);
        return Right(user);
      } else {
        // New user — create minimal Firestore document
        final newUser = UserModel(
          uid: firebaseUser.uid,
          phone: firebaseUser.phoneNumber ?? firebaseUser.email ?? '', // Using email as fallback for Google
          isProfileComplete: false,
        );
        final created = await _remote.createUser(user: newUser);
        await _local.saveSession(uid: firebaseUser.uid);
        return Right(created);
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(
        message: _friendlyAuthError(e.code),
        code: e.code,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> userExists({required String uid}) async {
    try {
      return Right(await _remote.userExists(uid: uid));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> createUser({required UserModel user}) async {
    try {
      return Right(await _remote.createUser(user: user));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUser({required String uid}) async {
    try {
      return Right(await _remote.getUser(uid: uid));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastLogin({required String uid}) async {
    try {
      await _remote.updateLastLogin(uid: uid);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    try {
      return Right(await _local.isBiometricAvailable());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    try {
      return Right(await _local.authenticateWithBiometric());
    } catch (e) {
      return Left(AuthFailure(message: 'Biometric authentication failed'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSession({required String uid}) async {
    try {
      await _local.saveSession(uid: uid);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getSession() async {
    try {
      return Right(await _local.getSession());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _local.clearSession();
      await _remote.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  String _friendlyAuthError(String code) => switch (code) {
        'invalid-phone-number' => 'The phone number entered is not valid.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'invalid-verification-code' => 'Incorrect OTP. Please check and retry.',
        'session-expired' => 'OTP has expired. Please request a new one.',
        'quota-exceeded' => 'SMS quota exceeded. Please try again later.',
        'network-request-failed' => 'No internet connection. Check your network.',
        'user-disabled' => 'This account has been disabled.',
        _ => 'Authentication failed. Please try again.',
      };
}
