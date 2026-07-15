import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/badge_entity.dart';
import '../../repositories/profile_repository.dart';
import '../usecase.dart';

/// Caso de uso: obtener las insignias (gamificación) del usuario (F-05).
class GetBadgesUseCase implements UseCase<List<BadgeEntity>, String> {
  final ProfileRepository repository;
  GetBadgesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BadgeEntity>>> call(String uid) =>
      repository.getBadges(uid);
}
