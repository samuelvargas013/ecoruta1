import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/usecase.dart';
import '../../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC de autenticación (F-01): el "cerebro" del inicio de sesión.
///
/// Funcionamiento del patrón BLoC:
///   1. La pantalla dispara un EVENTO (ej. "el usuario pulsó Iniciar Sesión").
///   2. El BLoC ejecuta el caso de uso correspondiente.
///   3. El BLoC emite un nuevo ESTADO (cargando, autenticado, error...).
///   4. La pantalla se redibuja automáticamente según ese estado.
///
/// Además, escucha el stream de sesión de Firebase: si la sesión cambia
/// (login, logout, expiración), toda la app se entera al instante.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final GoogleSignInUseCase googleSignIn;
  final SignOutUseCase signOut;
  final ResetPasswordUseCase resetPassword;

  late final StreamSubscription<UserEntity?> _authSub;

  AuthBloc({
    required this.authRepository,
    required this.signIn,
    required this.signUp,
    required this.googleSignIn,
    required this.signOut,
    required this.resetPassword,
  }) : super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleSignInRequested>(_onGoogle);
    on<AuthPasswordResetRequested>(_onReset);
    on<AuthSignOutRequested>(_onSignOut);

    // Suscripción permanente: cualquier cambio de sesión en Firebase
    // se convierte en un evento AuthUserChanged.
    _authSub = authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: event.user,
        isSubmitting: false,
        clearMessages: true,
      ));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    final result = await signIn(
        SignInParams(email: event.email, password: event.password));
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(isSubmitting: false)),
    );
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    final result = await signUp(SignUpParams(
      name: event.name,
      email: event.email,
      password: event.password,
      role: event.role,
    ));
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(isSubmitting: false)),
    );
  }

  Future<void> _onGoogle(
      AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    final result = await googleSignIn(const NoParams());
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(isSubmitting: false)),
    );
  }

  Future<void> _onReset(
      AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    final result = await resetPassword(event.email);
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(
          isSubmitting: false,
          infoMessage: 'Te enviamos un correo para recuperar tu contraseña.')),
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await signOut(const NoParams());
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
