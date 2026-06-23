import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/utils/validators.dart';
import '../bloc/auth/auth_bloc.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.vecino;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthSignUpRequested(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            role: _role,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.register)),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  validator: (v) => Validators.notEmpty(v, 'El nombre'),
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),
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
                  obscureText: true,
                  validator: Validators.password,
                  decoration: const InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Soy:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                        value: UserRole.vecino,
                        label: Text('Vecino'),
                        icon: Icon(Icons.home_outlined)),
                    ButtonSegment(
                        value: UserRole.reciclador,
                        label: Text('Reciclador'),
                        icon: Icon(Icons.recycling)),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                ),
                if (_role == UserRole.reciclador)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Tu cuenta de reciclador deberá ser validada antes de ver el mapa de reportes.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning),
                    ),
                  ),
                const SizedBox(height: 28),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => PrimaryButton(
                    label: 'Crear cuenta',
                    loading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
