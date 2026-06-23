import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/badge_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/profile/get_badges_usecase.dart';
import '../../../domain/usecases/profile/watch_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC del perfil y gamificación (F-05).
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final WatchProfileUseCase watchProfile;
  final GetBadgesUseCase getBadges;

  StreamSubscription? _sub;

  ProfileBloc({required this.watchProfile, required this.getBadges})
      : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<_ProfileUpdated>(_onUpdated);
  }

  Future<void> _onStarted(
      ProfileStarted event, Emitter<ProfileState> emit) async {
    final badgesResult = await getBadges(event.uid);
    final badges = badgesResult.getOrElse(() => const []);

    _sub?.cancel();
    _sub = watchProfile(event.uid).listen(
      (user) => add(_ProfileUpdated(user, badges)),
    );
  }

  void _onUpdated(_ProfileUpdated event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      status: ProfileStatus.loaded,
      user: event.user,
      badges: event.badges,
    ));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
