part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  final String uid;
  const ProfileStarted(this.uid);
  @override
  List<Object?> get props => [uid];
}

class _ProfileUpdated extends ProfileEvent {
  final UserEntity? user;
  final List<BadgeEntity> badges;
  const _ProfileUpdated(this.user, this.badges);
  @override
  List<Object?> get props => [user, badges];
}
