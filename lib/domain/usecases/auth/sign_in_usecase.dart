import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Caso de uso: iniciar sesión con correo y contraseña (F-01).
/// Devuelve el usuario autenticado o un Failure con el motivo del error.
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signInWithEmail(
        email: params.email, password: params.password);
  }
}

/// Datos que necesita el inicio de sesión: correo y contraseña.
class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
