import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/admin_config.dart';
import 'auth_service.dart';

/// Syncs the Firebase Auth `admin` custom claim for bootstrap admins.
class AdminService {
  AdminService(this._auth, this._functions);

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  Future<bool> hasAdminClaim() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult();
    return token.claims?['admin'] == true;
  }

  /// Sets `admin: true` on the Auth user when the signed-in email is a
  /// bootstrap admin. No-ops if the claim is already present or the function
  /// has not been deployed yet (rules still honor the bootstrap email).
  Future<void> syncAdminClaim() async {
    final user = _auth.currentUser;
    if (user == null || !isBootstrapAdmin(user.email)) return;
    if (await hasAdminClaim()) return;
    try {
      await _functions.httpsCallable('ensureAdminClaim').call();
      await user.getIdToken(true);
    } catch (_) {
      // Claim sync is best-effort. Bootstrap email still passes isAdmin()
      // in Firestore rules.
    }
  }
}

final adminServiceProvider = Provider<AdminService>(
  (ref) => AdminService(
    FirebaseAuth.instance,
    FirebaseFunctions.instanceFor(region: 'us-west1'),
  ),
);

/// True when the signed-in user is a bootstrap admin or has the `admin` claim.
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  final claim = ref.watch(adminClaimProvider).value ?? false;
  return isBootstrapAdmin(user?.email) || claim;
});

final adminClaimProvider = StreamProvider<bool>((ref) {
  return FirebaseAuth.instance.idTokenChanges().asyncMap((user) async {
    if (user == null) return false;
    if (isBootstrapAdmin(user.email)) return true;
    final token = await user.getIdTokenResult();
    return token.claims?['admin'] == true;
  });
});

/// Runs once per sign-in to persist the admin claim for bootstrap accounts.
final adminSyncProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || !isBootstrapAdmin(user.email)) return;
  await ref.read(adminServiceProvider).syncAdminClaim();
});
