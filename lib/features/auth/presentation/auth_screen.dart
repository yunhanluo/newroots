import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/language_menu_button.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/auth_widgets.dart';

/// Log-in screen (email/password). Minimalist green & white UI.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(
        () => _error = AppLocalizations.of(context).authEmailPasswordRequired,
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
      // On success, the router redirect sends the user home automatically.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(Routes.landing);
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const LanguageMenuButton(),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 56, 28, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(subtitle: l10n.authWelcomeBack),
                      const SizedBox(height: 36),
                      AuthTextField(
                        controller: _emailController,
                        label: l10n.authEmail,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: l10n.authPassword,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _logIn(),
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
                        label: l10n.actionLogIn,
                        loading: _loading,
                        onPressed: _logIn,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.authNoAccount,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => context.goNamed(Routes.signup),
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandGreen,
                            ),
                            child: Text(l10n.actionSignUp),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => context.pushNamed(Routes.privacy),
                        style: TextButton.styleFrom(
                          foregroundColor: kBrandGreen,
                        ),
                        child: Text(l10n.authPrivacyPolicy),
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
