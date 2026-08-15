/**
 * Seeds official California mutual support groups.
 * Admin SDK bypasses client rules so copy can be refreshed later.
 */
import {CallableRequest} from "firebase-functions/v2/https";
import {getFirestore} from "firebase-admin/firestore";
import {initializeApp, getApps} from "firebase-admin/app";

if (getApps().length === 0) {
  initializeApp();
}

interface StarterGroup {
  id: string;
  title: string;
  description: string;
  category: string;
  region: string;
  languages: string[];
}

const STARTER_GROUPS: StarterGroup[] = [
  {
    id: "ca-new-parents",
    title: "New immigrant parents",
    description:
      "Share tips about schools, childcare, and raising kids in a new country. Meet other parents who understand the same questions.",
    category: "parents",
    region: "California",
    languages: ["en", "es"],
  },
  {
    id: "ca-job-seekers",
    title: "Job seekers",
    description:
      "Help each other with resumes, interviews, and finding a first job in the US. Celebrate small wins and share leads.",
    category: "jobs",
    region: "California",
    languages: ["en", "es"],
  },
  {
    id: "ca-language-learners",
    title: "Language learners",
    description:
      "Practice English, swap useful phrases, and find conversation partners. All levels are welcome.",
    category: "language",
    region: "California",
    languages: ["en", "es"],
  },
  {
    id: "ca-professional-network",
    title: "Professional networking",
    description:
      "Connect with others rebuilding a career. Share events, introductions, credential questions, and advice.",
    category: "networking",
    region: "California",
    languages: ["en"],
  },
  {
    id: "ca-cultural-community",
    title: "Cultural community",
    description:
      "Celebrate your culture, find local events, and make friends who understand the journey of starting over.",
    category: "culture",
    region: "California",
    languages: ["en", "es"],
  },
  {
    id: "ca-housing-circle",
    title: "Housing circle",
    description:
      "Ask questions about renting, roommates, and avoiding housing scams. Support each other through the search.",
    category: "housing",
    region: "California",
    languages: ["en", "es"],
  },
];

export const seedSupportGroupsCallableOptions = {
  enforceAppCheck: false,
};

export async function handleSeedSupportGroups(
  request: CallableRequest,
  requireAuth: (req: CallableRequest) => string,
): Promise<Record<string, unknown>> {
  requireAuth(request);
  const db = getFirestore();
  const batch = db.batch();
  let written = 0;

  for (const group of STARTER_GROUPS) {
    const ref = db.collection("groups").doc(group.id);
    batch.set(
      ref,
      {
        title: group.title,
        description: group.description,
        category: group.category,
        region: group.region,
        languages: group.languages,
        updatedAt: new Date().toISOString(),
      },
      {merge: true},
    );
    written += 1;
  }

  await batch.commit();
  return {ok: true, written};
}
