import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';

/// Contrato base de un caso de uso que devuelve Either<Failure, Type>.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Para casos de uso sin parámetros.
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
