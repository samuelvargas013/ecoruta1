import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Stream<UserEntity?> watchProfile(String uid) => remote.watchProfile(uid);

  @override
  Future<Either<Failure, List<BadgeEntity>>> getBadges(String uid) async {
    try {
      final badges = await remote.getBadges(uid);
      return Right(badges);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
