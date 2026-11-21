import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_text_field.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) =>
          _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );

    if (email != null && mounted) {
      context.read<AuthBloc>().add(AuthPasswordResetRequested(email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              (current.errorMessage != null &&
                  previous.errorMessage != current.errorMessage) ||
              (current.infoMessage != null &&
                  previous.infoMessage != current.infoMessage),
          listener: (context, state) {
            // Only react if this screen is the one on top
            if (ModalRoute.of(context)?.isCurrent != true) return;

            final message = state.errorMessage ?? state.infoMessage!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to continue shopping',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: AuthValidators.required,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.isSubmitting != current.isSubmitting,
                      builder: (context, state) {
                        return SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.isSubmitting ? null : _submit,
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text('Create one'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final _controller = TextEditingController(text: widget.initialEmail);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your account email and we\'ll send you a link '
              'to set a new password.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (_) => _send(),
              decoration: const InputDecoration(labelText: 'Email'),
              validator: AuthValidators.email,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _send, child: const Text('Send link')),
      ],
    );
  }
}
