/**
 * Grants the Firebase Auth `admin` custom claim to bootstrap admins.
 *
 * Firestore rules also allow the bootstrap email directly, so approvals work
 * even before this function is deployed. The claim is what other admin-only
 * rules (`request.auth.token.admin == true`) already expect.
 */
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {getAuth} from "firebase-admin/auth";
import {initializeApp, getApps} from "firebase-admin/app";

if (getApps().length === 0) {
  initializeApp();
}

const BOOTSTRAP_ADMIN_EMAILS = new Set(["y@yunhanluo.com"]);

export const ensureAdminClaimCallableOptions = {
  enforceAppCheck: false,
};

export async function handleEnsureAdminClaim(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  const uid = requireAuth(request);
  const email = `${request.auth?.token?.email ?? ""}`.trim().toLowerCase();
  const alreadyClaim = request.auth?.token?.admin === true;
  const isBootstrap = BOOTSTRAP_ADMIN_EMAILS.has(email);

  if (!isBootstrap && !alreadyClaim) {
    throw new HttpsError("permission-denied", "Not an admin.");
  }

  const auth = getAuth();
  const user = await auth.getUser(uid);
  if (user.customClaims?.admin === true) {
    return {ok: true, admin: true, already: true};
  }

  await auth.setCustomUserClaims(uid, {
    ...(user.customClaims ?? {}),
    admin: true,
  });
  return {ok: true, admin: true};
}
