import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication service backed by Firebase Auth (email/password).
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  AppUser? get currentUser => _mapUser(_auth.currentUser);

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> createAccountWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
    );
  }

  /// Translates Firebase error codes into plain, friendly language.
  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Thrown for auth failures with a user-friendly [message].
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Lightweight user model independent of Firebase types.
class AppUser {
  const AppUser({required this.uid, this.email, this.phoneNumber});

  final String uid;
  final String? email;
  final String? phoneNumber;
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(FirebaseAuth.instance),
);

/// Emits the current auth state for routing/guards.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Per-user Firestore streams must restart on sign-in/out. Yields
/// [whenSignedOut] first so the previous account's data is never shown.
Stream<T> watchForSignedInUser<T>({
  required Ref ref,
  required T whenSignedOut,
  required Stream<T> Function(String uid) watch,
}) async* {
  final uid = ref.watch(authStateProvider).value?.uid;
  yield whenSignedOut;
  if (uid == null) return;
  yield* watch(uid);
}
