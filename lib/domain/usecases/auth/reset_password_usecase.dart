import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Caso de uso: enviar correo de recuperación de contraseña (F-01).
/// Recibe el email del usuario y pide al repositorio que envíe el enlace.
class ResetPasswordUseCase implements UseCase<Unit, String> {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      repository.sendPasswordReset(email);
}
