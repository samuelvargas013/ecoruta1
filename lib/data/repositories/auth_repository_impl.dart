import 'package:dartz/dartz.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementa el contrato AuthRepository del dominio.
///
/// Su trabajo principal: llamar al datasource y TRADUCIR errores.
/// Las excepciones técnicas (AuthException) se convierten en Failures,
/// de modo que la UI nunca ve errores crudos de Firebase, solo
/// resultados Either: Left(Failure) = falló, Right(dato) = funcionó.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  /// Stream que indica si hay sesión activa. Cuando Firebase notifica un
  /// usuario, se carga su perfil completo desde Firestore.
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
