import 'package:flutter/material.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../l10n/app_localizations.dart';

export '../../../../core/theme/brand_colors.dart';

/// Logo + title header shown at the top of the auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

/// Minimal rounded text field used by the auth forms.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.focusNode,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      autocorrect:
          !widget.obscureText &&
          widget.keyboardType != TextInputType.emailAddress,
      enableSuggestions: !widget.obscureText,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Colors.black54)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.black54,
                ),
                tooltip: _obscured
                    ? l10n.authShowPassword
                    : l10n.authHidePassword,
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E2DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBrandGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
      ),
    );
  }
}

/// Full-width green primary button with a loading state.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: kBrandGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// Translates an [AuthErrorCode] into the current app language.
String localizedAuthError(AppLocalizations l10n, AuthErrorCode code) {
  switch (code) {
    case AuthErrorCode.invalidEmail:
      return l10n.authErrorInvalidEmail;
    case AuthErrorCode.userDisabled:
      return l10n.authErrorUserDisabled;
    case AuthErrorCode.wrongCredentials:
      return l10n.authErrorWrongCredentials;
    case AuthErrorCode.emailInUse:
      return l10n.authErrorEmailInUse;
    case AuthErrorCode.weakPassword:
      return l10n.authErrorWeakPassword;
    case AuthErrorCode.network:
      return l10n.authErrorNetwork;
    case AuthErrorCode.tooManyRequests:
      return l10n.authErrorTooManyRequests;
    case AuthErrorCode.unknown:
      return l10n.authErrorGeneric;
  }
}

/// Tinted message box for form errors (or successes) on the auth screens.
class AuthMessageBanner extends StatelessWidget {
  const AuthMessageBanner({
    super.key,
    required this.message,
    this.isError = true,
  });

  final String message;
  final bool isError;

  static const _errorColor = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    final color = isError ? _errorColor : kBrandGreen;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontSize: 14, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
