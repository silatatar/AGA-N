# Phase 42 — Research Sources

Access date: 2026-08-25

## Scope and evidence rule

This review uses official product publications and the Council of Europe as primary evidence. Product descriptions are facts only when the cited source says so. Design choices for AGAIN are explicitly labelled as recommendations. No competitor prompt, artwork, path layout, or brand element may be copied.

No official source reviewed publishes a universal fixed Duolingo item count per lesson. Claims such as “Duolingo always uses X questions” are therefore unsupported. AGAIN's proposed 10–14 scored items is an internal, testable design recommendation, not a competitor fact.

## Evidence matrix

| Source | Publisher / date | Supported finding | AGAIN implication | Limitation |
|---|---|---|---|---|
| [Duolingo 101: How to learn a language on Duolingo](https://blog.duolingo.com/duolingo-101-how-to-learn-a-language-on-duolingo/) | Duolingo | Courses mix reading, listening, speaking, and writing and progress from supported recognition toward harder use. | Sessions should mix receptive and productive work and increase retrieval demand. | Marketing/product explanation; it does not publish a fixed item count. |
| [The Duolingo Method](https://blog.duolingo.com/duolingo-teaching-method/) | Duolingo, 2022 | Content is communicative, scaffolded, personalized, and balanced between familiar and challenging material. | Every exercise should point to a communicative objective and a deliberate difficulty step. | Describes principles, not a transferable curriculum or exact algorithm. |
| [How Duolingo's learning path works](https://blog.duolingo.com/new-duolingo-home-screen-design/) | Duolingo, 2022 | New content, Stories, personalized practice, and unit review are placed in one ordered path. | AGAIN can sequence teach, practice, story, review, and checkpoint nodes in one world-specific path. | The visual path and branded mechanics are proprietary and must not be copied. |
| [What is spaced repetition?](https://blog.duolingo.com/spaced-repetition-for-learning/) | Duolingo, 2023 | Mistakes return at lesson end; personalized practice selects prior words/grammar using time and accuracy. | Same-session delayed retry and later due review should be separate from immediate correction. | No complete public scheduling algorithm is provided. |
| [The right level of difficulty](https://blog.duolingo.com/right-level-of-difficulty/) | Duolingo, 2023 | Personalized practice targets weak words and grammar; difficulty differs by learner. | Serve from a larger validated pool and select review targets from actual attempts. | Personalization implementation is not public and cannot justify fabricated precision. |
| [Human expertise and AI in teaching](https://blog.duolingo.com/how-duolingo-experts-work-with-ai/) | Duolingo, 2022 | Experts define curriculum/objectives and raw content; exercise variants target particular language features; human-written comprehension questions align with objectives. | Objective, accepted variants, distractor rationale, and human QA must precede scaled generation. | Examples belong to Duolingo and must not be reused. |
| [One Babbel lesson](https://www.babbel.com/en/magazine/speaking-a-new-language-with-one-babbel-lesson) | Babbel, 2019 | A described lesson lasts about 15 minutes, cycles content, ends in contextual use, and feeds a spaced Review Manager. | Keep sessions bounded, contextual, and connected to later review. | A first-person product article, not an independent efficacy trial or universal duration. |
| [Microlearning](https://www.babbel.com/en/magazine/microlearning) | Babbel, 2016 | Babbel describes interactive, narrowly focused, bite-sized lessons of roughly 10–15 minutes. | AGAIN's shorter 4–7 minute session should cover one narrow objective, not a whole topic. | Competitor timing is context, not an AGAIN requirement. |
| [What is Busuu?](https://help.busuu.com/hc/en-us/articles/15936615354641-What-is-Busuu) | Busuu Support, updated product page | Busuu describes 3–5 minute focused lessons, CEFR alignment, four skills, checkpoints, and expert-created content. | A 4–7 minute AGAIN session is plausible if it is focused and measurable. | Product description; exact item counts and mastery thresholds are not disclosed. |
| [Busuu methodology](https://www.busuu.com/en/it-works/busuu-methodology) | Busuu | Controlled work includes gap fill, multiple choice, dictation, and sentence ordering; free practice includes writing; vocabulary and grammar appear in dialogue context. | AGAIN needs controlled recognition/recall plus contextual production, not story taps alone. | Community correction cannot be assumed safe or available in AGAIN. |
| [Memrise memory and spaced repetition](https://www.memrise.com/blog/memory-tricks-to-get-conversational-in-a-language-in-7-days) | Memrise, 2022 | New/difficult items recur more often; successful items receive longer intervals; listening and speaking practice are included. | Review intervals should react deterministically to success/error and keep capability truth. | Promotional article; numerical learning claims are not used as curriculum evidence. |
| [CEFR Companion Volume and language versions](https://www.coe.int/en/web/common-european-framework-reference-languages/cefr-companion-volume-and-its-language-versions) | Council of Europe, 2020 | CEFR frames communication through reception, production, interaction, and mediation and uses observable can-do descriptors. | Each chapter needs an observable communicative can-do and evidence across relevant modes. | CEFR does not prescribe an app UI, item count, reward system, or spaced-review algorithm. |
| [CEFR descriptors](https://www.coe.int/en/web/common-european-framework-reference-languages/cefr-descriptors) | Council of Europe | Descriptor scales support curriculum alignment and observable performance at Pre-A1/A1 and beyond. | Objectives and assessments should be bounded by what a learner can demonstrably do. | Descriptors require contextual curriculum interpretation; labels alone do not validate content. |

## Findings versus recommendations

### Officially supported patterns

- Effective product structures use short, focused learning with explicit communicative targets.
- Exercise families span recognition, listening, controlled recall, production, and contextual use.
- Difficulty and review respond to learner performance.
- Error correction and later retrieval are distinct learning moments.
- CEFR alignment is about observable language activity, not attaching an `A1` label to a story.

### AGAIN recommendations derived from the evidence

- Serve 10–14 scored items in a 4–7 minute micro-session.
- Maintain a validated pool of 24–36 unique candidates per objective/session template so selection can vary without near-duplicate inflation.
- Limit a session to 4–6 new lexical targets or one narrow grammar/function target.
- Require notice → recognition → controlled recall → contextual production → delayed retrieval.
- Keep speaking optional until the real device/capability path is available; silent completion must remain honest.

These are implementation hypotheses. The first-encounter pilot must measure completion time, error rate, abandonment, accessibility, and evidence coverage before world-wide rollout.
