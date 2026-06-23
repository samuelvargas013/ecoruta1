import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/badge_entity.dart';

/// Contrato del perfil y gamificación (F-05).
abstract class ProfileRepository {
  Stream<UserEntity?> watchProfile(String uid);
  Future<Either<Failure, List<BadgeEntity>>> getBadges(String uid);
}
