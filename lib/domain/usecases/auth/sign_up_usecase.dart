import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return repository.signUpWithEmail(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class SignUpParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, password, role];
}
