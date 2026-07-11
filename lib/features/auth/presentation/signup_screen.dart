import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import 'widgets/auth_widgets.dart';

/// Create-account screen (email/password). Minimalist green & white UI.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .createAccountWithEmail(email, password);
      if (mounted) context.goNamed(Routes.onboarding);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Faint, green-tinted Statue of Liberty backdrop, full-bleed.
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/liberty.png',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.22),
                ),
                Container(color: kBrandGreen.withOpacity(0.30)),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        subtitle: 'Create your account to get started.',
                      ),
                      const SizedBox(height: 36),
                      AuthTextField(
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmController,
                        label: 'Confirm password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _createAccount(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                      AuthPrimaryButton(
                        label: 'Create account',
                        loading: _loading,
                        onPressed: _createAccount,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => context.goNamed(Routes.auth),
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandGreen,
                            ),
                            child: const Text('Log in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
