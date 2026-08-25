# Phase 42 — Current Learning Content Audit

Audit date: 2026-08-25

Source checkpoint: `3573d07d382ebaabf377a8b9b518db093c24d89a`

## Executive finding

AGAIN currently has a functioning story/progression prototype, not a professionally complete lesson system. Twelve playable story definitions contain 71 story nodes, but node count is not learning-item count. Under the Phase 42 evidence definition, there are **0 scored language-evidence items**: choices do not record correctness/mastery, writing checks only minimum length, speaking/listening do not gate or grade learning, and no attempt/retry/mastery contract exists.

## Counting method

- A **story node** is a narrative graph node.
- An **interactive node** is a choice, writing, speaking, or node carrying a listening activity ID.
- A **scored evidence item** must have a target, accepted answer/variants, an evaluable result, and an attempt that can contribute evidence to mastery.
- Categories below are primary classifications; secondary issues such as insufficient validation can overlap.
- Runtime locked/current state is learner-specific. Static totals distinguish playable versus future; fresh default state is reported separately.

## Exact inventory

| Metric | Count |
|---|---:|
| Worlds | 3 |
| Chapter rows | 14 |
| Playable chapter/story pairs | 12 |
| Future chapters | 2 |
| StoryDefinition | 12 |
| StoryNode | 71 |
| Choice nodes | 13 |
| Writing nodes | 5 |
| Speaking nodes | 1 |
| Nodes with `listeningActivityId` | 2 |
| Scored language-evidence items | 0 |
| Playable chapters below 10–14 scored-item contract | 12 / 12 |
| Playable chapters without canonical can-do objective ID | 12 / 12 |
| All chapter rows without canonical can-do contract | 14 / 14 |
| Playable chapters without attempt/retry/mastery flow | 12 / 12 |
| Broken/dead runtime routes found | 0 |

Fresh default `AgainProgress` has `first-encounter` current/available and the other 11 playable chapters locked; the two non-playable Deniz chapters are `comingSoon`. Lock state changes through canonical progression and is not hard-coded into this audit table.

## Story depth by chapter

| World | Story / chapter | Nodes (N/D/C/W/S/X) | Listening IDs | Declared duration / vocabulary | Current scored evidence |
|---|---|---:|---:|---:|---:|
| Yaşam Vadisi | `first-encounter` | 1/4/1/0/0/1 = 7 | 1 | 3 min / 5 | 0 |
| Yaşam Vadisi | `ben-kimim` | 0/3/1/1/0/1 = 6 | 0 | 7 / 6 | 0 |
| Yaşam Vadisi | `gunluk-hayat` | 1/2/1/0/0/1 = 5 | 0 | 8 / 7 | 0 |
| Yaşam Vadisi | `sevdigim-seyler` | 0/4/1/0/0/1 = 6 | 0 | 8 / 7 | 0 |
| Yaşam Vadisi | `kucuk-bir-gun` | 0/3/2/1/0/1 = 7 | 0 | 10 / 5 | 0 |
| Sessiz Orman | `ormana-giris` | 1/2/1/0/0/1 = 5 | 0 | 8 / 8 | 0 |
| Sessiz Orman | `kaybolan-yol` | 0/3/1/0/0/1 = 5 | 0 | 9 / 8 | 0 |
| Sessiz Orman | `gece-sesleri` | 1/2/1/1/0/1 = 6 | 0 | 9 / 7 | 0 |
| Deniz Krallığı | `duygular` | 0/4/1/0/0/1 = 6 | 0 | 7 / 6 | 0 |
| Deniz Krallığı | `weather-storm` / `hava-durumu` | 0/3/1/1/1/1 = 7 | 1 | 15 / 6 | 0 |
| Deniz Krallığı | `ulasim-araclari` | 0/3/1/0/0/1 = 5 | 0 | 9 / 8 | 0 |
| Deniz Krallığı | `yolculuk-hazirligi` | 0/3/1/1/0/1 = 6 | 0 | 10 / 8 | 0 |

Legend: narration/dialogue/choice/writing/speaking/completion.

## Interactive prompt classification

The 13 choice prompts have these primary roles:

| Primary classification | Count | Examples |
|---|---:|---|
| Scored language evidence | 0 | None records an assessed result. |
| Scaffold/comprehension only | 2 | Weather clue → umbrella; routine sequence → breakfast. |
| Narrative branch | 2 | Greeting reply; left/right forest path. |
| Preference/personalization | 6 | Likes, activity, morning/preference, feeling, transport. |
| Visual/sensory trivia | 1 | `ormana-giris/notice-choice`: river/path visible in scene/context. |
| Ambiguous/multiple-valid answer | 2 | `gece-sesleri/sound-choice`; `yolculuk-hazirligi/packing-choice`. |

Secondary validation findings:

- All 13 choice nodes advance regardless of correctness; only three options carry `isPreferred`, and that flag is not an assessment record.
- All 5 writing nodes accept any trimmed string meeting a minimum character count.
- The one speaking node and two listening IDs do not create canonical graded language evidence.
- Immediate explanatory branch feedback exists in places, but there is no delayed retry or future review based on the attempt.

## P0/P1 prompt issues

No P0 crash, impossible completion, or dead route was found. The following P1 issues require rewrite principles, not patching individual labels:

| File | Story / node | Current prompt summary | Problem | Required rewrite principle |
|---|---|---|---|---|
| `story_repository.dart` | `first-encounter/reply-choice` | Reply with full introduction or “Hi” | Both are valid narrative replies; no objective/accepted evidence. | Preserve branch as narrative, then assess greeting/introduction through separate recall and contextual production items. |
| `story_repository.dart` | `weather-storm/weather-question` | Umbrella versus sunglasses after rain clues | Intended comprehension is plausible, but controller does not score or retry it. | Bind to a weather can-do, record result, explain contrast, and retry later in a different form. |
| `yasam_vadisi_content.dart` | `ben-kimim/like-choice` | Music versus animals | Preference, not correctness. | Keep as personalization; never count it toward mastery. Add separate `I like…` form/meaning evidence. |
| `yasam_vadisi_content.dart` | `gunluk-hayat/routine-choice` | Breakfast versus come home | One intended sequence, but no assessment state and only one encounter. | Use scaffold, ordering, cloze, and delayed contextual recall. |
| `yasam_vadisi_content.dart` | `sevdigim-seyler/activity-choice` | Music/game/garden | All options valid preferences. | Keep branch outside score and assess preference language separately. |
| `yasam_vadisi_content.dart` | `kucuk-bir-gun/morning-choice` and `preference-choice` | Morning action and yes/no preference | Both branches are communicatively valid; no mastery evidence. | Treat as interaction; add objective-linked retrieval before completion. |
| `sessiz_orman_content.dart` | `ormana-giris/notice-choice` | What do you notice: river/path | Answer can be obtained from visible scene; both are plausible. | Visual may scaffold vocabulary only; mastery must require language processing in a new context. |
| `sessiz_orman_content.dart` | `kaybolan-yol/trail-choice` | Go left/right | No linguistic evidence determines a correct path. | Keep as narrative agency; assess directions/prepositions through separate evidence. |
| `sessiz_orman_content.dart` | `gece-sesleri/sound-choice` | Hear owl/river without actual listening evidence | Multiple valid answers and no audio-backed target. | Provide truthful audio or reading-context evidence; silent fallback must assess another skill, not claim listening. |
| `deniz_kralligi_content.dart` | `duygular/feeling-choice` | Choose a feeling sentence | Preference/self-report; all valid. | Keep emotional choice unscored and assess `I am + adjective` separately. |
| `deniz_kralligi_content.dart` | `ulasim-araclari/transport-choice` | Boat versus train | Both valid travel choices. | Keep as branch; assess transport phrase meaning/order in separate items. |
| `deniz_kralligi_content.dart` | `yolculuk-hazirligi/packing-choice` | Coat versus map for rainy trip | Both can be needed; intended preference is ambiguous. | Define a precise language objective and unambiguous evidence, or retain only as narrative. |

## Deniz metadata truth audit

Four playable Deniz chapter rows have metadata divergence. There are **9 direct UI-versus-story field mismatches**, plus capability-evidence gaps:

| Chapter | UI metadata | Story metadata | Actual node evidence | Result |
|---|---|---|---|---|
| Duygular | 12 min, 14 vocab, listening, speaking | 7, 6, listening, no speaking | no listening ID, no speaking | False duration/vocab/speaking and unsupported listening claim. |
| Hava Durumu | 15, 18, listening, speaking | 15, 6, listening, speaking | 1 listening, 1 speaking | Vocabulary mismatch; capability exists but is not scored mastery. |
| Ulaşım Araçları | 14, 16, listening, no speaking | 9, 8, listening, no speaking | no listening ID | Duration/vocab mismatch and unsupported listening claim. |
| Yolculuk Hazırlığı | 18, 20, listening, speaking | 10, 8, listening, no speaking | no listening ID, no speaking | False duration/vocab/speaking and unsupported listening claim. |

Metadata must be derived from canonical curriculum/content truth in a later implementation; Phase 42 does not modify it.

## Route and progression audit

- Home/path → world → chapter → story → completion routes exist for all 12 playable story definitions.
- Unknown story IDs now produce branded NotFound; future Deniz chapters remain non-playable `comingSoon`.
- Catalog validation tests cover all 12 definitions and progression completion chains; dead/broken route count is 0.
- `AgainProgress` is authoritative for unlock/reward state and must remain so.
- Legacy graph concern: `first-encounter` unlocks both `ben-kimim` and Deniz/`duygular`; `kucuk-bir-gun` unlocks Sessiz Orman; `gece-sesleri` unlocks Deniz again. This is not corrupt, but it weakens a clear world sequence and needs an explicit future product decision.

## Final chapter decision table

| World | Chapter | Runtime/static state | Route | Content depth | Scored evidence | Metadata truth | CEFR objective | Severity | Decision |
|---|---|---|---|---|---:|---|---|---|---|
| Yaşam | first-encounter | playable; fresh current | works | 7 story nodes, shallow lesson | 0 | mostly local story truth | no canonical can-do | P1/P2 | REWRITE |
| Yaşam | ben-kimim | playable; initially locked | works | branch + weak writing | 0 | story-derived | no canonical can-do | P1/P2 | EXPAND |
| Yaşam | gunluk-hayat | playable; initially locked | works | one sequence scaffold | 0 | story-derived | no canonical can-do | P1/P2 | EXPAND |
| Yaşam | sevdigim-seyler | playable; initially locked | works | preference branch only | 0 | story-derived | no canonical can-do | P1/P2 | EXPAND |
| Yaşam | kucuk-bir-gun | playable; initially locked | works | two branches + weak writing | 0 | story-derived | no canonical can-do | P1/P2 | EXPAND |
| Sessiz | ormana-giris | playable; initially locked | works | visual trivia branch | 0 | story-derived | no canonical can-do | P1/P2 | REWRITE |
| Sessiz | kaybolan-yol | playable; initially locked | works | narrative direction branch | 0 | story-derived | no canonical can-do | P1/P2 | REWRITE |
| Sessiz | gece-sesleri | playable; initially locked | works | sensory prompt without audio | 0 | false listening implication | no canonical can-do | P1/P2 | REWRITE |
| Deniz | duygular | playable; initially locked | works | preference branch | 0 | false/mismatched | no canonical can-do | P1/P2 | REWRITE |
| Deniz | hava-durumu | playable; initially locked | works | most varied current prototype | 0 | vocab mismatch | no canonical can-do | P1/P2 | EXPAND |
| Deniz | ulasim-araclari | playable; initially locked | works | narrative transport branch | 0 | false/mismatched | no canonical can-do | P1/P2 | EXPAND |
| Deniz | yolculuk-hazirligi | playable; initially locked | works | ambiguous branch + weak writing | 0 | false/mismatched | no canonical can-do | P1/P2 | REWRITE |
| Deniz | seyahat-plani | comingSoon | product gate works | none | 0 | future declaration | none | P3 | FUTURE |
| Deniz | deniz-canlilari | comingSoon | product gate works | none | 0 | future declaration | none | P3 | FUTURE |

Decision totals: **KEEP 0, EXPAND 6, REWRITE 6, DISABLE 0, FUTURE 2**.

## Severity metrics

Counts below are impacted chapter rows; severities overlap by design.

| World | P0 | P1 | P2 | P3 |
|---|---:|---:|---:|---:|
| Yaşam Vadisi | 0 | 5 | 5 | 5 |
| Sessiz Orman | 0 | 3 | 3 | 3 |
| Deniz Krallığı | 0 | 4 | 4 | 6 |
| Total | 0 | 12 | 12 | 14 |

- P1: every playable chapter lacks sufficient assessing content/objective; Deniz also has four metadata-truth rows.
- P2: every playable chapter lacks balanced skills, delayed review, robust feedback, and adaptation evidence.
- P3: every chapter row needs an explicit original path-node presentation; two are future-only.

## Required explicit answers

1. Are all current chapters professionally lesson-complete? **NO**.
2. Does node count equal learning-item count? **NO**.
3. Do current choices prove mastery? **NO**.
4. Is current writing validation sufficient? **NO**.
5. Are visual-trivia items allowed as mastery evidence? **NO**.
6. Is there a canonical CEFR objective per chapter today? **NO**.
7. Is there sufficient variety/repetition today? **NO**.
8. Are declared metadata and actual content aligned? **NO**.
9. Can speaking block silent/device-limited learners in the proposed spec? **NO**.
10. Will `AgainProgress` remain authoritative? **YES**.
11. Is pilot implementation authorized? **NO**.
