# AGAIN — Project Handoff and Recovery Guide

Last updated: 2026-08-23 (Europe/Istanbul)

This file is the canonical handoff for a new Codex/ChatGPT conversation or a new development machine. Read it together with the phase reports under `docs/` before changing production code.

## Product identity

AGAIN is a premium, story-led English-learning application. Its visual language is mature fantasy: deep midnight navy, turquoise magical light, restrained gold ornament, emerald growth states, purple for advanced or mysterious areas, and readable glass panels.

Hüma is the living guide character. The canonical Hüma image is `assets/images/huma.png`; do not replace it with generic bird, owl, penguin, or demo artwork. The visible product name is always **AGAIN**. The local folder name may retain `AGAİN YENİDEN`; renaming it is not required and can affect tooling.

## Repository and recovery

- Intended GitHub repository: `https://github.com/silatatar/AGA-N`
- Local branch at Phase 40 preparation: `master`
- Pre-checkpoint base HEAD: `28a0dc57441f01e989aae47b7bb0e8119adbb032`
- Older compressed backup filename: `AGAIN_20260822_201543.tar.gz` (stored outside the repository)
- Backup SHA-256: `D88E1E1425AD165FCFD374DF808F1DD87A92575E6EC73B8E7FB82A984DAAEEDE`

The Git repository is the primary recovery mechanism after Phase 40. Never commit `.env` files, credentials, provider/API keys, service-role secrets, signing files, keystores, tokens, browser profiles, user data, `build/`, `.dart_tool/`, logs, SDK caches, or dated binary backups.

## Technology

- Flutter / Dart, multi-platform
- Material 3 light and dark themes
- Riverpod-style provider/controller state architecture
- GoRouter with a central typed access policy
- Local repositories for offline/demo behavior
- Supabase-ready auth/sync/function architecture, fail-closed when unconfigured
- Hüma AI backend interface with deterministic/local behavior and secure backend boundary
- Voice pipeline architecture with honest permission and availability states

Primary commands on this Windows machine:

```powershell
flutter pub get
dart format --set-exit-if-changed .
dart analyze lib test
flutter test --no-pub
```

The workspace path contains Turkish uppercase `İ`; some Flutter/Dart tooling versions can behave differently with Unicode paths. Do not rename or copy the project during a release audit without an explicit plan and a verified backup.

## Implemented product surfaces

The project contains reusable/adaptive implementations for:

- Design system, responsive shell, themes, localization foundations and branded errors
- Native/Flutter splash, Hüma arrival, learner type, name/avatar and personalized onboarding
- Account decision, login/register/reset/verification visual states
- Guided first story and data-driven interactive story player
- Layered fantasy world map and world detail/chapter selection
- Three current worlds: Yaşam Vadisi, Sessiz Orman and Deniz Krallığı
- Personalized home dashboard and daily progression
- Kelime Bahçesi vocabulary saving/review loop
- Hüma conversation prototype and safe Hüma backend boundary
- Safe Hikâye Meydanı prototype
- Profile, collections, progress and Atlas
- Owner-scoped local persistence and session transition isolation
- Auth/cloud/sync foundations and Supabase schema/function assets
- Voice capability, orchestration and privacy foundations

Do not create parallel versions of these screens or replace the architecture with isolated prototypes.

## Content and art structure

Production UI remains Flutter widgets; background art must not contain baked-in buttons, text, labels, progress badges, fake Hüma, or fake interactive objects.

Important assets:

- `assets/images/huma.png` — canonical Hüma
- `assets/images/worlds/shared/world_map_atlas_placeholder.webp` — temporary shared map continuity artwork
- `assets/images/worlds/<world>/environment_v1.webp` — world environment plates
- `assets/images/stories/<world>/<story>/` — story cover and scene WebP files

The complete asset status, dimensions, usage and placeholder classification is documented in `docs/phase32_visual_manifest.md`. The content registry is described in `docs/content_catalog.md`.

## Router and access invariants

The production GoRouter is connected to one central `RouteAccessPolicy` through a typed access snapshot and a controlled reactive refresh bridge. The policy is the single access decision authority.

Critical invariants:

- `UNRESOLVED` / `LOADING` is not the same as signed out.
- A requested protected destination is preserved safely across loading and onboarding completion.
- Guest learners retain access to local Home, World Map, playable stories, Vocabulary, Profile, Atlas and local Hüma.
- Product locks (locked worlds and future content) are not auth redirects.
- Invalid dynamic IDs and unknown routes use branded NotFound behavior.
- Identical state updates must not cause redirect churn or loops.
- Logout and Guest→UserA→Guest→UserB transitions must not leak owner data.

Phase 28.1 has an 11/11 real-GoRouter harness covering the required state-only resume and access cases.

## Ownership and persistence invariants

Every locally persisted learner dataset is scoped to a typed owner. Guest, User A and User B data must remain isolated. Never weaken owner isolation to fix a widget test or routing failure; fix the shared test harness or common root cause.

The JavaScript-safe guest owner identifier fix is important:

```dart
Random.secure().nextInt(4294967296)
```

Do not change it back to `nextInt(1 << 32)`: JavaScript 32-bit shift semantics turn that expression into zero and cause a runtime `RangeError`.

See `docs/phase37_local_data_ownership.md` and `docs/data_privacy_model.md`.

## Backend, AI and voice truth states

- Without Supabase credentials, the product must remain `SUPABASE_UNCONFIGURED` and fail closed.
- Without AI backend credentials, the product must remain `AI_UNCONFIGURED` and must not pretend the deterministic local conversation is production AI.
- Provider keys and service-role credentials must exist only in a secure backend environment, never in Flutter assets or source.
- Microphone and voice controls must reflect actual platform permission/capability states; no fake availability or success claims.
- Real authentication, cloud success, physical microphone validation, signing, store setup and deployment are still external release conditions.

Setup and architecture references:

- `docs/backend_setup.md`
- `docs/phase34_supabase_setup.md`
- `docs/phase35_huma_ai_backend.md`
- `docs/huma_ai_backend.md`
- `docs/voice_architecture.md`

## Verification history

Accepted Phase 38 baseline:

- Dart analyzer: 0 issues
- Focused Phase 37 ownership tests: 9/9 PASS
- Full Flutter test suite: 307/307 PASS

Phase 39 classification: `RUNTIME_QA_ENVIRONMENT_BLOCKED`.

This does **not** mean application compilation failed. Edge reached the current build main entrypoint and debug service, but an independent inspectable Flutter surface did not mount. The one allowed web-server attempt did not produce a service within the five-minute time box. Therefore the live viewport/deep-link matrix was correctly left BLOCKED/NOT RUN instead of being reported as PASS.

See:

- `docs/phase36_release_readiness_audit.md`
- `docs/phase38_runtime_qa.md`
- `docs/phase39_live_runtime_verification.md`

## Current release limitations

Before claiming a production release, obtain one stable inspectable runtime target and complete the live viewport/deep-link matrix, including 390x844, 412x915 and 1366x768; startup/onboarding/session transitions; three worlds and representative stories; vocabulary/profile/Atlas/Hüma/auth; product locks; invalid/unknown routes; overflow, crop, back navigation, loop/churn and console privacy checks.

External requirements remain: real credentials/configuration, physical voice verification, native signing, store metadata and deployment. Do not solve those by embedding secrets or claiming mock behavior is live.

## Safe continuation rules

1. Read this file and the latest phase reports first.
2. Preserve the existing dirty/user work unless a verified checkpoint includes it.
3. Diagnose common root causes; do not patch many screens individually.
4. Do not weaken router, owner isolation, privacy, product locks or fail-closed truth states to make tests pass.
5. Do not regenerate final-candidate art unless it is missing/corrupt or the task explicitly requests replacement.
6. Do not delete, reset, clean, rewrite history, force-push, install/upgrade SDKs, or change credentials without explicit user approval.
7. If source changes, run format, analyzer, targeted regression tests and the complete Flutter suite.
8. Report environment/tooling failures separately from application-source failures.
9. Commit small verified milestones and push them to the recovery repository after user approval.

## Recommended next action after recovery

Verify that the Phase 40 checkpoint hash exists locally and on GitHub, run `git status`, read the latest `docs/phase*.md`, and continue only from the advisor-approved next objective. Do not restart the product from Phase 1 or rebuild already completed features.
