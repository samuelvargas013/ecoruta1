import '../../entities/user_entity.dart';
import '../../repositories/profile_repository.dart';

class WatchProfileUseCase {
  final ProfileRepository repository;
  WatchProfileUseCase(this.repository);

  Stream<UserEntity?> call(String uid) => repository.watchProfile(uid);
}
