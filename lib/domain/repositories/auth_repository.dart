import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/firestore_paths.dart';
import '../entities/user_entity.dart';

/// Contrato de autenticación (F-01). La capa de datos lo implementa.
abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, Unit>> sendPasswordReset(String email);

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, UserEntity>> getCurrentUser();
}
