import '../../entities/user_entity.dart';
import '../../repositories/profile_repository.dart';

/// Caso de uso: observar el perfil del usuario en tiempo real (F-05).
/// Devuelve un Stream: cada vez que cambian los puntos o kg reciclados
/// en Firestore, la pantalla de perfil se actualiza sola.
class WatchProfileUseCase {
  final ProfileRepository repository;
  WatchProfileUseCase(this.repository);

  Stream<UserEntity?> call(String uid) => repository.watchProfile(uid);
}
