import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swasthsetu/features/auth/bloc/auth_bloc.dart';
import 'package:swasthsetu/features/auth/data/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:swasthsetu/features/auth/data/models/user_model.dart';
import 'package:swasthsetu/core/errors/failures.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    return const Right(UserModel(uid: 'fake', phone: '123', isProfileComplete: true));
  }

  @override
  Future<Either<Failure, String?>> getSession() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> userExists({required String uid}) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> isBiometricAvailable() async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometric() async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, void>> updateLastLogin({required String uid}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserModel>> createUser({required UserModel user}) async {
    return Right(user);
  }

  @override
  Future<Either<Failure, UserModel>> getUser({required String uid}) async {
    return const Right(UserModel(uid: 'fake', phone: '123', isProfileComplete: true));
  }

  @override
  Future<Either<Failure, void>> saveSession({required String uid}) async {
    return const Right(null);
  }
}

void main() {
  group('AuthBloc', () {
    late AuthBloc bloc;
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
      bloc = AuthBloc(repository: repository);
    });
    
    tearDown(() => bloc.close());

    // ── Initial state ─────────────────────────────────────────────────────────
    test('emits AuthInitial as the initial state', () {
      expect(bloc.state, isA<AuthInitial>());
    });

    // ── State equality ────────────────────────────────────────────────────────
    test('AuthInitial instances are equal', () {
      expect(const AuthInitial(), const AuthInitial());
    });

    test('AuthLoading instances are equal', () {
      expect(const AuthLoading(), const AuthLoading());
    });

    test('AuthError carries the message in props', () {
      const e = AuthError(message: 'invalid-cred');
      expect(e.props, contains('invalid-cred'));
    });

    test('two AuthErrors with different messages are not equal', () {
      const a = AuthError(message: 'error-a');
      const b = AuthError(message: 'error-b');
      expect(a, isNot(equals(b)));
    });

    test('AuthAuthenticated carries userId', () {
      const s = AuthAuthenticated(userId: 'uid-42', isProfileComplete: true);
      expect(s.props, contains('uid-42'));
    });
  });
}
