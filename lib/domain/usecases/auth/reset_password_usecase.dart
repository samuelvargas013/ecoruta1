import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class ResetPasswordUseCase implements UseCase<Unit, String> {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      repository.sendPasswordReset(email);
}
