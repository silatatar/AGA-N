# Phase 34 — Supabase auth and cloud sync

Without both public build values the runtime status is
`SUPABASE_UNCONFIGURED`. Never embed a service-role key, database password, or
OAuth client secret in Flutter.

Apply `supabase/migrations/202608210001_phase34_learner_cloud_state.sql`, enable
email authentication, configure allowed redirect URLs, then run:

```text
flutter run --dart-define=SUPABASE_URL=https://PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=PUBLIC_KEY
```

`SUPABASE_ANON_KEY` is accepted for older projects. Deterministic development
auth is explicit: `--dart-define=AGAIN_USE_DEVELOPMENT_BACKEND=true`.

The UI sees repositories only. `SupabaseRuntime` owns the single SDK client.
The auth adapter maps verification and safe failures. The cloud adapter trusts
only the current session UID. Progress and canonical personalization share an
owner-scoped row but remain separate JSON documents. RLS blocks cross-account
access. Live integration remains unverified until real public project values
and the migration are available.
