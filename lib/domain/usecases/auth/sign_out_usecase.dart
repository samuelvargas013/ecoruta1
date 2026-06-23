import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignOutUseCase implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => repository.signOut();
}
