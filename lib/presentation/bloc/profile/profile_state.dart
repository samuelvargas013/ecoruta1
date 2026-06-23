part of 'profile_bloc.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final List<BadgeEntity> badges;

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.user,
    this.badges = const [],
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    List<BadgeEntity>? badges,
  }) =>
      ProfileState(
        status: status ?? this.status,
        user: user ?? this.user,
        badges: badges ?? this.badges,
      );

  @override
  List<Object?> get props => [status, user, badges];
}
