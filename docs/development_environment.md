# AGAIN development environment notes

These are local toolchain limitations observed during Phase 27B. They are not
known application compilation failures.

## Chrome and Flutter web

- `flutter devices` exposed only the Windows desktop target in the current
  Codex environment; Chrome was not available as a Flutter device.
- `flutter run -d web-server` exited inside Flutter tooling with
  `Null check operator used on a null value` before serving the application.
- Recheck with `flutter doctor -v` and `flutter devices` on a normal local
  Flutter installation. If Chrome is listed, run `flutter run -d chrome`.
- Do not report web runtime as verified until the application is actually
  opened and inspected at the supported responsive sizes.

## Windows desktop

- Windows plugin builds require symbolic-link support.
- Enable Windows Developer Mode in **Settings → Privacy & security → For
  developers**, then restart the terminal/Codex application.
- Run `flutter doctor -v`, followed by `flutter run -d windows`.
- If Flutter needs missing cached Windows artifacts, network access to the
  official Flutter artifact host is also required.

## OneDrive workspace latency

- The workspace is inside OneDrive. During Phase 27B, file and process startup
  occasionally stalled long enough to exceed the execution timeout.
- Validation was therefore repeated from a local verification copy after
  synchronising the current `lib`, `test`, `assets`, and `pubspec.yaml` files.
- The verified result was `flutter analyze` with zero issues and 130 passing
  tests.
- Before large automated edits, create a Git checkpoint. Avoid interrupting a
  file write while OneDrive is synchronising.

## Current truthful capability boundary

- Authentication, community activity, AI conversation, voice recording, cloud
  sync, payments, and premium access are not production services yet.
- Development repositories and fictional community examples must remain
  clearly identified and must not be presented as real users or live services.
- Prepared-choice practice must not increase `speakingMinutes`; only a future
  verified voice activity may record speaking time.
