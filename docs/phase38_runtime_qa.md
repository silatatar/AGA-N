# Phase 38 — Final Integrated Runtime QA

## Classification

`RELEASE_RUNTIME_PARTIALLY_VERIFIED`

Static, widget and router evidence is green. A real web startup was observed,
and one repeatable application blocker was fixed. The corrected candidate
could not complete the full live viewport/deep-link matrix because available
web runtime targets exceeded the time box without an application stack trace.

## Environment

- Windows 11 Home Single Language 23H2
- Flutter stable 3.44.8 (`058e0af2c2`)
- Dart 3.12.2
- Chrome 151.0.7922.140
- Edge 151.0.4129.93
- Workspace path contains Turkish Unicode: `AGAİN YENİDEN`
- Windows desktop is unavailable because Visual Studio is not installed.
- Android SDK exists, but some Android licences are not accepted.
- Supabase credentials: unconfigured
- Production Hüma AI provider: unconfigured

## Runtime commands

1. `flutter doctor -v` — completed.
2. `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357 -v`
   — served after 148.7 seconds.
3. In-app browser at 390×844 — Flutter started and exposed a repeatable
   application exception during guest-owner creation.
4. Corrected build at web-server port 7358 — compilation completed in 145.2
   seconds; browser DDC loading/control did not reach a stable inspectable
   current-build surface inside the browser-control time box.
5. `flutter run -d chrome --web-port 7360` — no application stack trace, but
   debug-service connection did not complete within the time box.
6. `flutter build web --release --no-pub` — remained in compilation for five
   minutes without success or failure output and was stopped accurately as a
   tooling/environment timeout.

## Proven application blocker and minimal fix

The browser console reported:

`RangeError: max must be in range 0 < max ≤ 2^32, was 0`

The source was `Random.secure().nextInt(1 << 32)` in guest installation-ID
generation. JavaScript bitwise shifts use 32-bit operands, so `1 << 32`
became zero. It was replaced with the web-safe integer literal `4294967296`.
No ownership semantics changed.

A focused regression assertion now ensures the supported upper bound remains
usable. Phase 37 tests pass 9/9.

## QA matrix

| Surface | Result | Evidence |
| --- | --- | --- |
| Flutter web-server startup/tool stack | PASS | Served in 148.7s; initial short-run crash was not reproduced with verbose evidence. |
| Real Flutter main entrypoint | PASS | Browser log reached `Starting application from main method`. |
| Guest owner bootstrap | PASS after fix | Root cause fixed; targeted tests 9/9; corrected live re-inspection tooling-blocked. |
| Loading/session/onboarding/owner transitions | PASS | Real-GoRouter harness 11/11; no second manual navigation. |
| Guest product-route access and auth guards | PASS | Router harness and full widget suite. |
| Unknown/invalid branded NotFound | PASS | Router harness and widget suite. |
| Locked world/future Deniz behaviour | PASS | Router harness and widget suite; no auth redirect. |
| Home responsive matrix | PASS | Widget runtime at 320, 360, 390, 412, 600, 1024 and 1366 widths. |
| World map responsive matrix | PASS | Widget runtime at 320, 360, 390, 412, 600, 1024 and 1366 widths. |
| Three world details and representative stories | PASS | Catalog/story-entry/widget runtime tests. |
| Vocabulary, Profile, Atlas, local Hüma | PASS | Widget and feature tests. |
| Full current-build browser viewport/deep-link walkthrough | BLOCKED | Chrome/debug and browser-control connection timeouts, no app stack trace. |
| Real Supabase auth/cloud sync | NOT RUN | `SUPABASE_UNCONFIGURED`; fail-closed truth retained. |
| Production AI | NOT RUN | `AI_UNCONFIGURED`; local deterministic Hüma remains truthful. |
| Physical microphone/voice | NOT RUN | Requires physical-device permission and provider verification. |
| Windows desktop runtime | BLOCKED | Visual Studio desktop toolchain missing. |
| Android runtime | BLOCKED | No connected Android device and licences incomplete. |

## Quality gates after the fix

- `dart format --set-exit-if-changed .`: 157 files, 0 changed
- `dart analyze lib test`: no issues
- Targeted Phase 37 ownership tests: 9/9 pass
- Full `flutter test --no-pub`: 307/307 pass

## Remaining external release conditions

- Supply and validate Supabase public configuration and production project.
- Configure and validate the production Hüma AI backend/provider.
- Complete native signing/store setup.
- Complete physical-device microphone/voice verification.
- Run the full live responsive/deep-link matrix on a stable browser or device
  runtime when the local Flutter debug/build connection is available.

No deployment, dependency/SDK upgrade, signing, cache repair, credential setup,
or unrelated feature/design change was performed.
