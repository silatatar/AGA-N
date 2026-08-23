# Phase 36 — Production truth and release-readiness audit

Date: 2026-08-22. Baseline: 286/286 tests passing before fixes.

## Findings

| Area | Findings | Fixed now | Deferred |
|---|---:|---:|---:|
| Production truth | 4 | 2 | 2 |
| Security/secrets | 1 | 1 | 0 |
| Data loss/isolation | 3 | 2 | 1 |
| Progression | 0 | 0 | 0 |
| Voice | 0 | 0 | 1 verification |
| AI | 0 | 0 | 1 configuration |
| Assets | 0 | 0 | 1 visual QA |
| Release configuration | 2 | 0 | 2 |

## Concrete fixes

- Legacy `developmentAuthenticated` and `productionAuthenticated` strings can
  no longer restore an authenticated production session. A restored account is
  verified only when persisted `emailVerified` is explicitly `true`.
- Corrupt canonical progression and learner-personalization payloads are copied
  verbatim to dedicated recovery keys before legacy recovery writes occur.
- Unused `dio` was removed from production dependencies.
- No client-side service-role key, model-provider key, database password,
  bearer token, signing secret, or private client secret was found.

## Truthful intentional states

- Story Square explicitly labels all community activity as fictional demo data.
- Future chapters, placement test, photo upload, voice and pronunciation are
  visibly marked unavailable/coming soon and do not award progress.
- `SUPABASE_UNCONFIGURED` and `AI_UNCONFIGURED` fail closed. Scripted Hüma is
  semantically local and remote AI remains behind Phase 28.1.
- Exactly 12 playable stories and two disabled future Deniz chapters remain
  covered by catalog/manifest tests. The temporary atlas filename is an art
  replacement seam, not baked-in interactive UI.

## Deferred release blockers

1. Local progression and canonical personalization are still stored under
   installation-wide keys. Before multi-account production sync is enabled,
   Phase 28.1/account lifecycle integration must switch repositories through
   `DataOwner.storageKey` and prove logout/login isolation and guest adoption.
   Cloud UID/RLS isolation is already enforced, but it does not namespace the
   current local repositories.
2. Android release currently uses debug signing. Real release signing requires
   externally supplied keystore credentials and must not be invented.
3. Physical-device voice verification, Supabase/provider deployment, and final
   runtime visual/composite QA remain external or intentionally deferred.

## Route inventory and Phase 28.1 checklist

- Public: splash, Hüma arrival, learner/profile/onboarding, account decision,
  login/register/reset.
- Verification-only: email verification.
- Guest/local learning: home, map, world/story, vocabulary, tasks, Hüma,
  profile and Atlas after onboarding.
- Internal design-system preview is not a public path but should be removed or
  compile-time gated before store release.

Phase 28.1 must install `RouteAccessPolicy.redirect` as a reactive GoRouter
guard, refresh on auth/startup changes, protect direct deep links, preserve
guest local learning, isolate owner-scoped repositories during account changes,
and test sign-out, verification, guest upgrade and back-button behavior.

## Final runtime checklist

- Home and onboarding/profile at compact phone and desktop sizes.
- Map at 390×844, 412×915 and 1366×768; all three world details.
- One representative story per world and Hava Durumu mobile crop.
- Hüma text mode plus microphone available/unavailable states.
- Auth and sync in configured and unconfigured states.
