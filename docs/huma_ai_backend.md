# Hüma AI backend foundation

Phase 29 preserves the Phase 24 deterministic guidance and scripted conversation. Three modes are explicit: `productGuidance`, `localScripted`, and `remoteAi`. The application must never label a scripted response as remote AI.

## Production boundary

`Flutter → authenticated AGAIN backend → safety/context assembly → AI provider → structured validation → Flutter`

Flutter sends typed learning context only. It never sends an arbitrary system prompt or provider secret. The backend verifies identity, derives the trusted owner, selects the learner safety policy, enforces payload/rate/cost limits, assembles versioned Hüma instructions, invokes a provider with bounded timeout/retry, validates output, and returns a typed response.

Supabase RLS protects database rows. It does not by itself authorize or protect an Edge Function or external model call; the backend boundary must verify the session separately.

## Context and retention

Requests contain the current message, learner type/level, scenario, action, bounded recent turns, bounded relevant vocabulary, and optional current story context. Passwords, auth secrets, payment data, unrelated profile metadata, lifetime conversation history, and microphone recordings are excluded. Phase 29 conversation memory is session-scoped and bounded. Optional long-term AI memory remains future, inspectable, deletable, retention-limited, and consent-aware.

## Safety and truthfulness

Child, teen, and adult safety profiles are typed. Keyword checks can only be one layer; production also requires authenticated policy selection, input checks, provider safeguards, structured schema validation, and output safety validation. Invalid, unsafe, malformed, timed-out, or unavailable responses use a safe local fallback and never expose raw provider output.

AI output cannot award XP, increase speaking minutes for text, unlock content, set premium access, or choose rewards. Trusted AGAIN business logic owns those decisions.

## Versions, limits, and secrets

`HumaPolicyConfig` versions personality and safety policy and bounds message size, recent turns, target vocabulary, and output size. Production adds per-user/device minute and daily limits, idempotent request/session/turn IDs, bounded retries, and provider-independent usage/cost metadata. Provider keys exist only in server environment secrets—never Flutter, assets, SharedPreferences, public tables, or client logs.

Without a configured backend, `UnconfiguredHumaAiBackend` reports `providerUnavailable`; the UI continues with Phase 24 local scripted practice. Production AI release remains blocked until Phase 28.1 reactive router/session integration is closed.

## Edge Function endpoint contract

The future endpoint is a narrow authenticated operation such as `POST /huma/chat`, not a generic prompt proxy. The client sends `HumaAiRequest`; it cannot provide a system prompt, provider secret, trusted authorization user ID, or arbitrary model parameters. The Edge Function derives identity from the verified session, checks learner ownership, applies rate limits, assembles versioned policy and personality context, invokes the selected provider, validates `HumaAiResponse`, performs output safety checks, and returns only the validated structure.

Request and response propagation includes `policyVersion`, `promptVersion`, and `responseSchemaVersion`. A schema mismatch becomes a typed safe fallback; raw provider output never reaches presentation. Supabase RLS protects database rows, while Edge Function authorization independently protects the AI operation and verifies trusted identity.

`HumaRemoteAiReadiness` is the canonical capability gate. It combines real `BackendConfig`, endpoint availability, Phase 28.1 completion, safety validation readiness, rate-limit readiness, and operational state. Remote UI is available only for `available`; local scripted practice remains independent in every state. Telemetry contains coarse typed events and never raw messages, secrets, auth tokens, or full prompts.
