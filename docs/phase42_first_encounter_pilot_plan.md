# Phase 42 — First Encounter Pilot Plan

Status: implementation-free plan

Future pilot: Yaşam Vadisi / `first-encounter`

## Goal

Transform the current seven-node introduction into one measurable Pre-A1/A1 micro-session while preserving its cinematic valley arrival, Hüma, first seed, stable story/chapter IDs, and `AgainProgress` reward boundary.

Proposed can-do:

> Can greet someone and introduce oneself using a name in a short first meeting.

This can-do must receive a stable objective ID during the future implementation design. The pilot must not treat choosing a friendly story reply as mastery.

## Target bounds

- Functions: greeting; saying one's name; recognizing/answering a simple name question.
- New lexical/formulaic targets: maximum 4–6, proposed semantic set around `hello/hi`, `my name is…`, `what is your name?`, and `nice to meet you`.
- Grammar/function: fixed first-person introduction frame; no broad present-tense lesson.
- CEFR: Pre-A1 entry with A1 communicative application.
- Speaking: optional practice only. Text/reading/writing path must complete honestly without microphone.

Final vocabulary and wording require human content review; this plan does not supply a production question bank.

## Served session proposal

Target: 12 scored items (allowed range 10–14) plus 3–4 short non-scored narrative/scaffold beats.

| Phase | Scored items | Purpose |
|---|---:|---|
| Arrival + Hüma setup | 0 | Establish scene and can-do; concise Turkish support. |
| Notice/meaning | 2 | Recognize greeting/name function in short context. |
| Controlled recognition | 2 | Meaning-in-context and dialogue response. |
| Controlled recall | 3 | Ordering, cloze, and limited listen/choose when audio truthful. |
| Contextual application | 3 | Dialogue response and short typed introduction; optional speaking variant. |
| Delayed retrieval/check | 2 | New context and different family; include a prior-error target when needed. |
| Completion | 0 | Persist completion once, show first seed, continue to map. |

No more than two consecutive items use the same family. The current narrative greeting branch may remain for agency, but is excluded from the 12 scored items.

## Candidate pool proposal

Create and human-review 28–32 unique candidates for this objective, then serve 10–14 according to target coverage and attempt history. Proposed pool distribution:

- 5–6 meaning/context candidates
- 4–5 dialogue-response candidates
- 4–5 sentence-order/cloze candidates
- 3–4 listening candidates with text-family alternatives
- 3–4 controlled translation/form candidates
- 3–4 short typed-production rubrics/contexts
- 3–4 delayed retrieval variants

Near-identical text with reordered choices is one candidate family, not additional depth.

## Exercise and evidence distribution

- Reception: greeting/name meaning in text; listening only after real playback.
- Controlled recall: reconstruct or complete the introduction frame.
- Interaction: choose an unambiguously appropriate reply in a specified context.
- Production: type a bounded self-introduction; accepted patterns/normalization explicit.
- Optional speech: repeat or roleplay after explicit permission/capability; absence cannot block completion.
- Delayed retrieval: use another character/context after intervening items.

Each scored candidate must carry objective ID, target feature, family, accepted variants, evidence rationale, CEFR, feedback, retry, and accessibility behavior.

## Hüma and narrative beats

Hüma may:

1. Welcome the learner and name the goal.
2. Demonstrate a greeting in context.
3. Bridge from recognition to first reply.
4. Explain one concise contrast after an error.
5. Celebrate completion after canonical persistence.

Hüma may not mark correctness, fabricate listening/speaking success, or award the seed/XP. Narrative choice outcomes must remain separate from scored attempts.

## Error, retry, and review

- First error: calm result plus one meaning/form explanation.
- Continue with at least two intervening scored items.
- Retry the target in a different valid family near session end.
- Correct immediate retry permits session recovery but does not create mastery.
- Schedule first future review for the next learning day after successful delayed retrieval; shorten after lapse.
- Resume retains served IDs, attempts, and pending retry without duplicate reward.

## Integration boundaries

- Preserve stable route `/story/first-encounter` and existing world/chapter/story identity unless a separately reviewed migration is required.
- Curriculum/exercise engine emits typed evidence and completion eligibility.
- `AgainProgress` alone applies completion, XP, seed, unlocks, and idempotency.
- Existing owner isolation stores attempts/review state under Guest/User namespaces.
- Existing vocabulary garden remains canonical for saved-word review; integrate, do not duplicate.
- Voice/audio services remain capability-truthful and optional.

## Future validator and test gates

### Content/static gates

- Objective and all item IDs unique.
- At least 24 valid unique candidates; target range 28–32.
- Served session always 10–14 scored items with full target/evidence coverage.
- Every assessed feature introduced first.
- Accepted variants and distractor rationales reviewed.
- No anti-trivia or near-duplicate inflation.
- Silent path reaches completion without claiming listening/speaking.

### Logic tests

- Correct, incorrect, partial, unsupported attempts.
- Hint escalation and delayed retry.
- Immediate retry does not master.
- Resume preserves session and pending retry.
- Completion/reward occurs once; replay gives no duplicate XP/seed.
- Guest/User A/User B evidence isolation.
- Locked/future/product gates unchanged.

### Widget/runtime QA

- 360×800, 390×844, 412×915, and wide layout.
- Galaxy A35 portrait: keyboard, scroll, system insets, back/resume, cold launch.
- Audio unavailable, permission required, denial, and real available states.
- Reduced motion and small jump/fade only after persisted completion.
- No overflow, dead control, blank screen, route loop, or privacy-sensitive logging.

## Pilot acceptance metrics

- 10–14 scored items are actually served and distinguishable from narrative taps.
- Median completion fits the 4–7 minute hypothesis; outliers and accessibility paths reported.
- Every target has notice, recognition, recall, application, and delayed retrieval evidence.
- Ambiguous-item review rate is zero before release.
- No false audio/speaking success.
- No duplicate reward/progression event.
- Human Turkish/English copy review complete.
- User approves the feel and learning quality before any second chapter rollout.

No efficacy threshold should be claimed from one internal pilot. Metrics validate usability/content behavior and inform iteration.

## Rollout and rollback

1. Implement behind a local content-version boundary, not a new progression authority.
2. Preserve the prior story definition until migration/replay compatibility is proven.
3. Release only to the representative pilot route/state.
4. If completion, resume, scoring, or reward invariants fail, disable the pilot content version and return to the prior playable story without deleting learner data.
5. After user/content QA approval, plan one next chapter; do not bulk-roll out all worlds.

## Decisions still required before implementation

1. Confirm final can-do wording and exact 4–6 target expressions.
2. Choose whether the default served count is 12 or adapts within 10–14 from the first release.
3. Approve accepted Turkish support level and typed-answer normalization rules.
4. Approve which listening items have real audio at pilot launch.
5. Confirm the first-seed narrative/reward remains at this session's completion.
6. Decide whether legacy first-encounter completion users replay the pilot as optional review or are migrated without replay.
7. Approve the visual path/jump concept separately after a wireframe; no competitor visual copying.

Pilot implementation, content generation, schema/controller work, and path UI are **not authorized** in Phase 42.
