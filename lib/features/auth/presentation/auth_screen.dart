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
  final _passwordFocus = FocusNode();
  bool _loading = false;
  String? _error;
  String? _notice;

  bool get _canSubmit =>
      !_loading &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  void _onFieldChanged(String _) => setState(() {});

  @override
  void dispose() {
    _passwordFocus.dispose();
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
      _notice = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
      // On success, the router redirect sends the user home automatically.
    } on AuthException catch (e) {
      if (mounted) {
        setState(
          () =>
              _error = localizedAuthError(AppLocalizations.of(context), e.code),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final sentTo = await showDialog<String>(
      context: context,
      builder: (_) =>
          _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (sentTo == null || !mounted) return;
    setState(() {
      _error = null;
      _notice = AppLocalizations.of(context).authResetSent(sentTo);
    });
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
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _emailController,
                              label: l10n.authEmail,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.username,
                              ],
                              onChanged: _onFieldChanged,
                              onSubmitted: (_) => _passwordFocus.requestFocus(),
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: l10n.authPassword,
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onChanged: _onFieldChanged,
                              onSubmitted: (_) {
                                if (_canSubmit) _logIn();
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _loading ? null : _forgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: kBrandGreen,
                          ),
                          child: Text(l10n.authForgotPassword),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        AuthMessageBanner(message: _error!),
                      ],
                      if (_notice != null) ...[
                        const SizedBox(height: 8),
                        AuthMessageBanner(message: _notice!, isError: false),
                      ],
                      const SizedBox(height: 16),
                      AuthPrimaryButton(
                        label: l10n.actionLogIn,
                        loading: _loading,
                        onPressed: _canSubmit ? _logIn : null,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
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

/// Asks for an email and sends a Firebase password-reset link.
/// Pops with the email address on success.
class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l10n.authEmailRequired);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) Navigator.of(context).pop(email);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = localizedAuthError(l10n, e.code));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Text(l10n.authResetTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.authResetBody,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: l10n.authEmail,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => _sending ? null : _send(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              AuthMessageBanner(message: _error!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: kBrandGreen),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          style: FilledButton.styleFrom(backgroundColor: kBrandGreen),
          child: _sending
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.authResetSend),
        ),
      ],
    );
  }
}
