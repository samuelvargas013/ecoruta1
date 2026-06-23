import 'package:dartz/dartz.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Stream<UserEntity?> get authStateChanges =>
      remote.firebaseAuthState.asyncMap((fbUser) async {
        if (fbUser == null) return null;
        try {
          return await remote.getCurrentUser();
        } catch (_) {
          return null;
        }
      });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remote.signInWithEmail(email, password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = await remote.signUpWithEmail(name, email, password, role);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await remote.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordReset(String email) async {
    try {
      await remote.sendPasswordReset(email);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remote.signOut();
      return const Right(unit);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remote.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
