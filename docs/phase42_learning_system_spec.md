# Phase 42 — Learning System Specification

Status: proposal only; no implementation authorization

Curriculum range: Pre-A1 → A1

## 1. Separation of canonical truths

The future system must keep these concerns independent:

1. **Curriculum truth**: objective, target language, accepted evidence, CEFR scope, prerequisites.
2. **Exercise truth**: prompt family, variants, scoring, feedback, accessibility fallback.
3. **Knowledge truth**: attempts, due review, strengthening/mastery/lapse evidence, owner scope.
4. **Narrative truth**: scene, character, story branch, Hüma narration.
5. **Progression truth**: `AgainProgress` remains the sole authority for unlocks, completion rewards, XP, and world/chapter state.
6. **Presentation truth**: cards, path nodes, animation, audio controls, and labels reflect the above; they do not invent it.

Story completion or XP is not proof of language mastery. Hüma, AI, content definitions, and animations may never award XP/unlocks directly.

## 2. Canonical learning objective contract

Every playable chapter must conceptually declare:

| Field | Requirement |
|---|---|
| `objectiveId` | Stable, unique, version-aware identity. |
| `cefrLevel` | Pre-A1 or A1 for the first curriculum slice. |
| `canDo` | One observable real-life ability, e.g. introduce oneself with a greeting and name. |
| `languageFunction` | One narrow function/grammar focus. |
| `lexicalTargets` | Bounded set; normally 4–6 new items per micro-session. |
| `receptionOutcome` | What meaning the learner can understand. |
| `productionOutcome` | What the learner can produce in writing or optional speech. |
| `interactionOutcome` | What appropriate response the learner can select/create when relevant. |
| `mediationOutcome` | Optional simple reformulation/meaning transfer when age/level appropriate. |
| `prerequisites` | Prior objective IDs, not XP guesses. |
| `masteryEvidence` | Required contexts, exercise families, delay, and success conditions. |
| `reviewPolicy` | Due-selection and lapse behavior. |

An `A1` label or broad topic such as “weather” is not a can-do objective. Objectives must be concrete, bounded, and assessable.

## 3. Micro-session contract

### Served session

- Target: **10–14 scored items**, approximately **4–7 minutes**.
- Non-scored narrative/scaffold screens: normally 2–4, excluded from scored count.
- New material: maximum 4–6 lexical items **or** one narrow grammar/function objective.
- No more than two consecutive scored items from the same exercise family.
- Final 2–3 scored items must require retrieval/application rather than immediate recognition.
- Completion threshold proposal: at least 80% first-attempt/accepted performance overall **and** required target coverage. This is a pilot hypothesis, not final mastery science.
- A learner may complete after targeted delayed retry, but immediate correction alone cannot mark a target mastered.

### Required sequence for each new target

1. Notice/meaning scaffold (may be non-scored).
2. Recognition in target-language context.
3. Controlled recall.
4. Contextual application or short production.
5. Delayed retrieval in a different exercise family.

Rewording the same prompt or shuffling identical options is not a distinct encounter.

### Candidate pool

Recommendation: **24–36 validated unique scored candidates** for a session template/objective, from which 10–14 are served. The pool should contain at least three meaningful encounters per target and multiple families/contexts. This range supports variation, error-targeted replacement, and review without inflating the pool with near-duplicates. It is an AGAIN design hypothesis to validate in the pilot, not a competitor fact.

### Resume and early exit

- Persist current session/objective, served candidate IDs, attempt order, and pending delayed retries in the owner namespace.
- Resume must reconstruct the same session safely; it must not regenerate answers or duplicate rewards.
- Early exit awards no false completion/mastery. Valid completed attempts remain evidence.
- If content version changes incompatibly, terminate safely with an explicit restart explanation rather than interpreting stale answers.

## 4. Exercise family matrix

| Family | Measures | Pre-A1/A1 use | Scoring and distractors | Feedback / fallback | Mastery evidence? |
|---|---|---|---|---|---|
| Meaning in context | Reading reception | Word/phrase meaning in short context | One unambiguous best meaning; distractors same semantic class and previously known | Explain contextual clue; text-only supported | Yes, recognition only |
| Listen and choose | Listening reception | Short word/phrase/dialogue | Real played audio required; phonologically plausible choices | Replay/slow if truthful; transcript fallback becomes reading and cannot count as listening | Yes for listening |
| Listen and order | Listening + form | Reconstruct short heard utterance | Normalized token sequence; bounded accepted variants | Highlight misplaced chunk; no-audio fallback uses another family | Yes |
| Sentence ordering | Syntax/controlled production | Formulaic sentence building | Required tokens plus limited plausible distractors | Show canonical order and function | Yes |
| Contextual cloze | Recall/grammar/lexis | One meaningful blank in a short context | Accepted inflections/variants explicit; no clue that gives answer away | Contrast learner form with target | Yes |
| Dictation | Listening + writing | Very short familiar utterance | Safe normalization for case/punctuation; lexical errors remain meaningful | Replay and token-level contrast; unavailable audio cannot pass | Yes |
| Controlled translation | Meaning/form mapping | Limited short functional phrases | Multiple natural variants accepted; avoid word-for-word traps | Explain function, not only literal equivalence | Yes, sparingly |
| Form transformation | Grammar/function | Change person, polarity, or simple form | Explicit source/target condition; accepted variants bounded | Contrast changed element | Yes |
| Error correction | Form awareness + production | One clear error in known material | Only one intended error unless multiple answers declared | Explain why and provide corrected contrast | Yes |
| Dialogue response | Interaction | Select/type an appropriate turn | Alternatives pragmatically distinct; preference choices unscored | Explain appropriacy and meaning | Yes when unambiguous |
| Short typed production | Writing production | 1 short phrase/sentence | Rubric/accepted structures; unsupported free text marked for review, not auto-wrong | Hint escalation and example after attempt | Yes with validated grading |
| Speaking/repeat/roleplay | Spoken production/interaction | Optional familiar utterance/scenario | Only real recorded/recognized evidence; confidence thresholds transparent | Text alternative preserves completion but not speaking evidence | Yes when capability truthful; never required now |
| Story comprehension/inference | Reading/listening comprehension | Short scene with objective-linked question | Question must require language meaning, not obvious art | Cite clue/contrast without revealing before attempt | Yes |
| Delayed retrieval/review | Retention across time/context | Prior target in new family/context | Select from due evidence, not random XP state | Explain lapse and reschedule | Required for mastery |

No exercise family awards XP or unlocks. It emits a typed attempt result; canonical completion orchestration later requests progression once, idempotently.

## 5. Valid exercise conceptual contract

Every future scored item must declare:

- `itemId`, `contentVersion`, `learningObjectiveId`
- `targetLanguageFeature`, `exerciseFamily`, `cefrLevel`
- prompt/input and accepted answer variants
- normalization rules and grading method
- distractor rationale when applicable
- `evidenceOfLearning`
- introduction/prerequisite relationship
- retry and future-review behavior
- accessibility and capability fallback
- age/context variants that preserve correctness truth

### Anti-trivia rule

Art may establish atmosphere and scaffold meaning. If the answer is directly visible and requires no target-language processing, the item is invalid for mastery/checkpoint evidence. “What is in this picture?” may be used sparingly as an early vocabulary scaffold, never as final proof.

## 6. Attempt, feedback, retry, and mastery

### Attempt record (conceptual)

- owner key, objective/item/content version
- session ID and attempt sequence
- presented family/context and capability mode
- normalized learner response (minimized; privacy rules apply)
- result: `correct`, `incorrect`, `partiallyAccepted`, `unsupported`
- first-attempt flag, hints used, response time bucket
- feedback code, retry source, timestamp
- evidence skill/mode; never raw secret/token/provider payload

### Feedback sequence

1. Acknowledge result calmly.
2. Give one short reason tied to meaning/form.
3. Contrast learner response and target where useful.
4. Offer a bounded hint on later attempt.
5. Re-present after intervening items in another valid form.

### Mastery lifecycle

Map to the existing owner-scoped vocabulary model rather than creating duplicate truth. Conceptual states:

`new → learning → reviewDue → strengthening → mastered → lapsed`

Mastery requires successful retrieval across time, in more than one context and preferably more than one exercise family. Immediate corrected retry restores the current session but does not alone advance to mastered. A later error shortens the interval and may mark a lapse without deleting history.

## 7. Deterministic spaced-review proposal

This is an initial product schedule, not a claim of scientific optimality:

- New target: introduce, then reappear after at least 2 intervening scored items.
- Error: explanatory correction, then delayed retry near session end.
- First successful delayed retrieval: due next learning day.
- Consecutive successful reviews: proposed intervals 1, 3, 7, 14, 30 days.
- Error/lapse: return to 1 day (or later same session when appropriate), preserving history.
- Selection ranks overdue/weak objectives, but review occupies no more than about 40% of an ordinary new-content session unless the learner explicitly chooses Review.
- Per-objective and per-vocabulary due evidence must coexist without duplicating XP/progress.
- Scheduling remains deterministic, local/offline-first, and owner-scoped. Guest/User A/User B isolation from Phase 37 is mandatory.

Pilot data may adjust intervals and review cap. The UI must never call the schedule “scientifically optimal.”

## 8. Child, teen, and adult adaptation

One canonical objective, target, accepted answers, and mastery rule serves all learner types.

| Dimension | Child | Teen | Adult |
|---|---|---|---|
| Context | Safe, concrete, imaginative | School, identity, discovery, travel | Travel, work, relationships, culture |
| Instruction | Short, one action | Concise and modern without forced slang | Compact, information-efficient |
| Hints | Earlier/more visual scaffolding | Optional contextual hint | Optional concise rule/contrast |
| Reading load | Lower; larger touch targets | Moderate | Denser when appropriate |
| Feedback | Warm, direct, never babyish | Encouraging, autonomous | Respectful, practical |
| Safety | No unrestricted public communication; minimal personal data | Guarded social scenarios | Mature scenarios within privacy rules |

Hüma introduces goals, bridges narrative and practice, explains one useful contrast, and encourages recovery. Hüma is not correct-answer, mastery, reward, or progression authority.

## 9. Gamified world path specification

### Original AGAIN node model

- **Micro-session node**: focused teach/practice unit.
- **Story node**: applies learned material in the world's narrative.
- **Review node**: appears when canonical knowledge state is due.
- **Checkpoint node**: samples varied evidence for chapter can-do.
- **Chapter gate**: reflects `AgainProgress` unlock/completion only.

Node states: `locked`, `available`, `current`, `completed`, `reviewDue`.

Suggested chapter rhythm: 2–4 micro-sessions → story application → review/checkpoint. Exact count depends on objective breadth; chapters may not be declared playable without adequate pool/evidence.

### “Jump” behavior

- After canonical completion is persisted, a small learner/Hüma marker moves to the next available node along an AGAIN-original fantasy path.
- Animation is presentation-only and cannot mutate progress or award rewards.
- Reduced motion replaces movement with a short cross-fade/state highlight.
- Off-screen animation pauses; resume reads canonical state.
- Locked/future nodes remain visibly distinct and never redirect to auth.

Current world art direction, environmental identity, normalized positioning, and layered Flutter interaction remain the visual foundation. No competitor path geometry, iconography, or motion is copied.

## 10. Future content validation plan

| Validation | Severity |
|---|---|
| Unique stable world/chapter/story/objective/item IDs | ERROR |
| Every referenced target exists and route/catalog agree | ERROR |
| Playable chapter has minimum validated scored pool | ERROR |
| Locked/future chapter cannot launch | ERROR |
| Assessed target was introduced/scaffolded first | ERROR |
| Accepted answers normalize safely; no empty/duplicate variants | ERROR |
| Distractors plausible, distinct, and unambiguous | ERROR |
| No near-duplicate pool inflation | WARNING (ERROR at threshold breach) |
| Vocab/duration/listening/speaking metadata matches actual content | ERROR |
| CEFR target within objective bounds | ERROR |
| Audio/capability truth and honest silent fallback | ERROR |
| Silent fallback never counts listening/speaking | ERROR |
| No dead-end nodes; every playable path completes | ERROR |
| Completion/reward idempotent; no reward authority in content/AI/Hüma | ERROR |
| Owner isolation boundary preserved | ERROR |
| Child safety/privacy rules satisfied | ERROR |
| Turkish/English copy, punctuation, encoding, accessibility labels | WARNING; ERROR when meaning/safety changes |
| Optional delight/art metadata present | INFO |

Future validators should report file, stable ID, objective, rule, severity, and remediation principle. Phase 42 creates no validator code.

## 11. Rollout sequence

1. Implement one `first-encounter` pilot only after separate user authorization.
2. Run content validation, unit/controller/widget tests, Android runtime QA, and learner review.
3. Measure time, completion, first-attempt accuracy, retry load, accessibility, and prompt ambiguity.
4. Adjust contract deliberately and version it.
5. Roll out chapter-by-chapter, then world-by-world; never bulk-generate an unreviewed question bank.

Pilot implementation is **not authorized** by this document.
