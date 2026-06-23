part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Disparado por el stream de Firebase cuando cambia la sesión.
class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, password, role];
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthSignOutRequested extends AuthEvent {}
