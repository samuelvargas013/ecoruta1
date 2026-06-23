import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../bloc/auth/auth_bloc.dart';
import '../widgets/primary_button.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context
          .read<AuthBloc>()
          .add(AuthSignInRequested(_email.text.trim(), _password.text));
    }
  }

  void _resetPassword() {
    if (Validators.email(_email.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Escribe tu correo para recuperar la contraseña.')));
      return;
    }
    context.read<AuthBloc>().add(AuthPasswordResetRequested(_email.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage ||
              p.infoMessage != c.infoMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error));
            } else if (state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.infoMessage!),
                  backgroundColor: AppColors.primary));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  const Icon(Icons.eco, size: 64, color: AppColors.primary),
                  const SizedBox(height: 8),
                  const Text(AppStrings.appName,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark)),
                  const Text(AppStrings.appTagline,
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textHint)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(AppStrings.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => PrimaryButton(
                      label: AppStrings.login,
                      loading: state.isSubmitting,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('o continúa con',
                          style: TextStyle(color: AppColors.textHint)),
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(AuthGoogleSignInRequested()),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text(AppStrings.continueWithGoogle),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.noAccount,
                          style: TextStyle(color: AppColors.textHint)),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        ),
                        child: const Text(AppStrings.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
