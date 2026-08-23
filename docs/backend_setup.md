# AGAIN backend decision and setup

## Decision

Supabase is the preferred production provider for Phase 28. AGAIN's learning
state is structured and user-owned, which maps well to Postgres tables with Row
Level Security. Supabase Auth covers email/password and future social identity,
while Edge Functions provide a future server-only boundary for Hüma AI, payment
webhooks, and moderation. The app remains provider-agnostic through repository
interfaces.

Firebase remains a strong alternative where built-in Firestore offline caching,
FCM, App Check, analytics, and Flutter-native operations are the priority.
AGAIN already owns its offline-first local state and needs deterministic,
domain-aware conflict rules rather than generic last-write-wins, so Postgres/RLS
is the better initial fit. A custom backend would add unnecessary operational
cost at this stage.

Official references:

- https://supabase.com/docs/reference/dart/installing
- https://supabase.com/docs/guides/functions
- https://firebase.google.com/docs/firestore/manage-data/enable-offline
- https://firebase.google.com/docs/auth/flutter/start

## Current status

No Supabase project URL or publishable key is present. The production SDK is
therefore not installed and the app must not claim authentication or cloud sync
is live. `UnconfiguredCloudProgressRepository` preserves this truthful boundary.

## Required production setup

1. Create separate Supabase projects for staging and production.
2. Configure Auth email/password; add Google and Apple only after their platform
   credentials and redirect URLs are ready.
3. Create versioned profile/progress/vocabulary tables with `user_id` ownership.
4. Enable RLS on every user table before client access; policies must require
   `auth.uid() = user_id`.
5. Store URL and publishable key in runtime environment configuration. Never
   commit service-role or secret keys to the Flutter application.
6. Keep service-role keys and future AI/payment secrets inside Edge Function
   environment secrets only.
7. Generate and test database migrations in staging before production.

## Environment policy

`BackendConfig` explicitly distinguishes development, staging, and production.
Release mode alone never selects production. Missing production configuration
must fail closed to local-only behavior, never a fabricated successful sync.
