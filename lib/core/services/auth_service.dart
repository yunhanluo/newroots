import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication service (Firebase Auth).
///
/// PLACEHOLDER: methods are stubbed. Wire to `firebase_auth` once Firebase
/// projects are configured (see DEPLOY_PLAN.md §3).
class AuthService {
  // TODO: inject FirebaseAuth.instance.

  Stream<AppUser?> authStateChanges() {
    // TODO: map FirebaseAuth.instance.authStateChanges() -> AppUser.
    return const Stream<AppUser?>.empty();
  }

  AppUser? get currentUser => null; // TODO

  Future<void> signInWithEmail(String email, String password) async {
    // TODO: FirebaseAuth.instance.signInWithEmailAndPassword(...)
    throw UnimplementedError();
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    // TODO: phone auth flow (friendly for newcomers).
    throw UnimplementedError();
  }

  Future<void> signOut() async {
    // TODO: FirebaseAuth.instance.signOut()
  }
}

/// Lightweight user model independent of Firebase types.
class AppUser {
  const AppUser({required this.uid, this.email, this.phoneNumber});

  final String uid;
  final String? email;
  final String? phoneNumber;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Emits the current auth state for routing/guards.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});
