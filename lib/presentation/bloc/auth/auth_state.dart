part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : errorMessage,
      infoMessage: clearMessages ? null : infoMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, user, isSubmitting, errorMessage, infoMessage];
}
