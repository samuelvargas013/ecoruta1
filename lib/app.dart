import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth/google_sign_in_usecase.dart';
import 'domain/usecases/auth/reset_password_usecase.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/pages/home_shell.dart';
import 'presentation/pages/login_page.dart';

class EcoRutaApp extends StatelessWidget {
  const EcoRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        authRepository: sl<AuthRepository>(),
        signIn: sl<SignInUseCase>(),
        signUp: sl<SignUpUseCase>(),
        googleSignIn: sl<GoogleSignInUseCase>(),
        signOut: sl<SignOutUseCase>(),
        resetPassword: sl<ResetPasswordUseCase>(),
      ),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Decide qué pantalla mostrar según el estado de autenticación.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return HomeShell(user: state.user!);
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
