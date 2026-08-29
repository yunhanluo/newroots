/**
 * Permanently deletes admin-hidden posts after the appeal window, unless an
 * appeal is still waiting for a moderator.
 */
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {initializeApp, getApps} from "firebase-admin/app";
import type {ScheduledEvent} from "firebase-functions/v2/scheduler";

if (getApps().length === 0) {
  initializeApp();
}

export const purgeRemovedGroupPostsOptions = {
  region: "us-west1" as const,
  schedule: "every 1 hours",
  timeZone: "America/Los_Angeles",
  timeoutSeconds: 120,
  memory: "256MiB" as const,
};

function noticeId(groupId: string, postId: string): string {
  return `${groupId}_${postId}`;
}

function imagePathsFromData(data: Record<string, unknown>): string[] {
  const paths: string[] = [];
  const raw = data.imagePaths;
  if (Array.isArray(raw)) {
    for (const item of raw) {
      const path = `${item}`.trim();
      if (path) paths.push(path);
    }
  }
  if (paths.length === 0) {
    const legacy = `${data.imagePath ?? ""}`.trim();
    if (legacy) paths.push(legacy);
  }
  return paths.slice(0, 6);
}

function assertGroupImagePath(groupId: string, path: string): string | null {
  const clean = path.trim().replace(/^\/+/, "");
  const prefix = `group-posts/${groupId}/`;
  if (!clean.startsWith(prefix) || clean.includes("..")) return null;
  return clean;
}

async function deleteGroupImages(groupId: string, paths: string[]): Promise<void> {
  if (paths.length === 0) return;
  const bucket = getStorage().bucket();
  for (const raw of paths) {
    const path = assertGroupImagePath(groupId, raw);
    if (!path) continue;
    try {
      await bucket.file(path).delete({ignoreNotFound: true});
    } catch (error) {
      console.warn("Could not delete purged group image", path, error);
    }
  }
}

export async function handlePurgeRemovedGroupPosts(
  _event: ScheduledEvent,
): Promise<void> {
  const db = getFirestore();
  const snap = await db
      .collectionGroup("posts")
      .where("removed", "==", true)
      .where("purgeAt", "<=", Timestamp.now())
      .get();

  for (const doc of snap.docs) {
    const data = doc.data() as Record<string, unknown>;
    if (`${data.appealStatus ?? ""}` === "pending") continue;
    const groupId = doc.ref.parent.parent?.id;
    if (!groupId) continue;
    const authorUid = `${data.authorUid ?? ""}`.trim();
    const imagePaths = imagePathsFromData(data);

    const replies = await doc.ref.collection("replies").get();
    const batch = db.batch();
    for (const reply of replies.docs) {
      batch.delete(reply.ref);
    }
    batch.delete(doc.ref);
    await batch.commit();
    await deleteGroupImages(groupId, imagePaths);

    if (!authorUid) continue;
    try {
      await db
          .collection("users")
          .doc(authorUid)
          .collection("postDeletionNotices")
          .doc(noticeId(groupId, doc.id))
          .update({
            appealStatus: "expired",
            seen: false,
            decidedAt: Timestamp.now(),
          });
    } catch (error) {
      console.warn("Could not mark deletion notice expired", groupId, doc.id, error);
    }
  }
}
