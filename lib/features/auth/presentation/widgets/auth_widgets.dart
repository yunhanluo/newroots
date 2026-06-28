import 'package:flutter/material.dart';

/// Brand green used across the auth screens.
const Color kBrandGreen = Color(0xFF1B6B5A);

/// Logo + title header shown at the top of the auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: const BoxDecoration(
            color: kBrandGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.eco_outlined, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
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
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
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
                tooltip: _obscured ? 'Show password' : 'Hide password',
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
