import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

/// Caso de uso: iniciar sesión con Google (F-01).
///
/// Un "caso de uso" representa UNA acción concreta que el usuario puede
/// realizar en la app. La pantalla no habla directamente con Firebase:
/// llama a este caso de uso, y este delega en el repositorio.
class GoogleSignInUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  GoogleSignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      repository.signInWithGoogle();
}
