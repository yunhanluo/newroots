import 'package:flutter/material.dart';

/// Sign-in / sign-up entry point (Firebase Auth: email + phone).
/// PLACEHOLDER: UI not yet implemented.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco_outlined, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('NewRoots', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('From arrival to belonging.', style: theme.textTheme.bodyLarge),
              const Spacer(),
              // TODO: language picker, email/phone sign-in, social auth.
              FilledButton(
                onPressed: () {}, // TODO: wire AuthService.signInWithPhone
                child: const Text('Continue with phone'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {}, // TODO: wire AuthService.signInWithEmail
                child: const Text('Continue with email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
