import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_languages.dart';
import '../../../core/l10n/app_locale.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../welcome/presentation/welcome_screen.dart';
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
      setState(() => _error = AppLocalizations.of(context).authFillAllFields);
      return;
    }
    if (password.length < 6) {
      setState(
        () => _error = AppLocalizations.of(context).authPasswordTooShort,
      );
      return;
    }
    if (password != confirm) {
      setState(
        () => _error = AppLocalizations.of(context).authPasswordsDoNotMatch,
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final languageCode = ref.read(appLocaleProvider).languageCode;
      ref.read(localeOverrideProvider.notifier).setCode(languageCode);
      ref.read(justSignedUpProvider.notifier).mark();
      await ref
          .read(authServiceProvider)
          .createAccountWithEmail(email, password);
      try {
        await ref
            .read(userProfileServiceProvider)
            .updateField('languageCode', languageCode);
      } catch (_) {
        // Account exists; onboarding still has the session language.
      }
      if (mounted) context.goNamed(Routes.welcome);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = ref.watch(appLocaleProvider).languageCode;
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
                Container(color: kBrandGreen.withValues(alpha: 0.30)),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(Routes.landing);
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      AuthHeader(subtitle: l10n.authCreateAccountSubtitle),
                      const SizedBox(height: 36),
                      Text(
                        l10n.preferredLanguage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: languageCode,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.language,
                            color: Colors.black54,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFD9E2DE),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: kBrandGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          for (final language in kAppLanguages)
                            DropdownMenuItem(
                              value: language.code,
                              child: Text(language.nativeName),
                            ),
                        ],
                        onChanged: _loading
                            ? null
                            : (code) {
                                if (code == null) return;
                                ref
                                    .read(localeOverrideProvider.notifier)
                                    .setCode(code);
                              },
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        label: l10n.authEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        label: l10n.authPassword,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmController,
                        label: l10n.authConfirmPassword,
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
                        label: l10n.actionCreateAccount,
                        loading: _loading,
                        onPressed: _createAccount,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.authHaveAccount,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => context.goNamed(Routes.auth),
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandGreen,
                            ),
                            child: Text(l10n.actionLogIn),
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
