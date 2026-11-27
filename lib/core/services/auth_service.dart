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
      throw AuthException(_errorCode(e));
    }
  }

  Future<void> createAccountWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_errorCode(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Don't reveal whether an account exists for this email.
      if (e.code == 'user-not-found') return;
      throw AuthException(_errorCode(e));
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

  /// Maps Firebase error codes to app-level codes the UI can translate.
  AuthErrorCode _errorCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'user-disabled':
        return AuthErrorCode.userDisabled;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthErrorCode.wrongCredentials;
      case 'email-already-in-use':
        return AuthErrorCode.emailInUse;
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'network-request-failed':
        return AuthErrorCode.network;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      default:
        return AuthErrorCode.unknown;
    }
  }
}

enum AuthErrorCode {
  invalidEmail,
  userDisabled,
  wrongCredentials,
  emailInUse,
  weakPassword,
  network,
  tooManyRequests,
  unknown,
}

/// Thrown for auth failures; translate [code] in the UI.
class AuthException implements Exception {
  const AuthException(this.code);
  final AuthErrorCode code;

  @override
  String toString() => 'AuthException($code)';
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
