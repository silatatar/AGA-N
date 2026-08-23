# Phase 35 — Hüma remote AI backend

Classification without deployed Supabase and provider secrets: `AI_UNCONFIGURED`.

## Data boundaries

- Client data: bounded user message, recent turns, goals, target vocabulary,
  story context, level, locale, request/session/turn IDs.
- Server processing: authenticated UID verification, authoritative safety and
  level policy, prompt assembly, rate/cost bounds, idempotency and schema checks.
- Provider processing: only the bounded payload and server policy needed for the
  current response. Provider credentials and raw failures never reach Flutter.

The function does not intentionally persist indefinite conversation history or
raw prompts. Logs contain coarse request/session identifiers and failure type,
not message text, tokens, keys, or the system policy. Remote AI remains disabled
for guests and while the Phase 28.1 release gate is open. Local scripted Hüma
remains independent. AI responses have no authority over XP, unlocks, speaking
minutes, badges, or other progression state.
