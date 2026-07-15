part of 'auth_bloc.dart';

/// Estados posibles de la sesión:
/// - unknown: aún verificando (se muestra un spinner al abrir la app)
/// - authenticated: hay usuario -> se muestra la app (HomeShell)
/// - unauthenticated: sin sesión -> se muestra el login
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado inmutable de autenticación. copyWith crea una copia modificada
/// en lugar de mutar el estado (requisito del patrón BLoC).
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
