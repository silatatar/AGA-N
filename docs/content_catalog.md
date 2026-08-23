# AGAIN Content Catalog

## Phase 31 baseline

Phase 31 uses the existing data-driven `StoryDefinition` player. Ordinary new
stories must be supplied as content definitions and must not require a custom
Flutter screen.

Stable identifiers that must remain compatible with saved progress:

- World: `yasam-vadisi`
- World: `sessiz-orman`
- World: `deniz-kralligi`
- Story/chapter: `first-encounter`
- Story: `weather-storm`
- Chapter: `hava-durumu`

## Current playable catalog

| World | Chapter | Story | Story ID | CEFR | Vocabulary | Grammar focus | Branching | Writing | Listening-ready | Speaking-ready | Minutes | Status |
|---|---|---|---|---|---:|---|---|---|---|---|---:|---|
| Yaşam Vadisi | İlk Karşılaşma | İlk Karşılaşma | `first-encounter` | A1 | 5 | Hello / Hi; My name is; I am | Yes | No | Yes | Yes | 3 | Playable, stable ID preserved |
| Yaşam Vadisi | Ben Kimim? | Ben Kimim? | `ben-kimim` | A1 | 6 | I am; I like; I don't like | Yes | Yes | Yes | Yes | 7 | Playable |
| Yaşam Vadisi | Günlük Hayat | Günlük Hayat | `gunluk-hayat` | A1 | 7 | Simple Present with I | Yes | No | Yes | No | 8 | Playable |
| Yaşam Vadisi | Sevdiğim Şeyler | Sevdiğim Şeyler | `sevdigim-seyler` | A1+ | 7 | Do you like?; Yes/No | Yes | No | Yes | No | 8 | Playable |
| Yaşam Vadisi | Küçük Bir Gün | Küçük Bir Gün | `kucuk-bir-gun` | A1+ | 5 | A1 structure reinforcement | Yes | Yes | Yes | No | 10 | Playable |
| Sessiz Orman | Ormana Giriş | Ormana Giriş | `ormana-giris` | A1 | 8 | There is / are; I can see | Yes | No | Yes | Yes | 8 | Playable |
| Sessiz Orman | Kaybolan Yol | Kaybolan Yol | `kaybolan-yol` | A1+ | 8 | Directions and prepositions | Yes | No | Yes | Yes | 9 | Playable |
| Sessiz Orman | Gece Sesleri | Gece Sesleri | `gece-sesleri` | A1+ | 7 | I can hear / see | Yes | Yes | Yes | Yes | 9 | Playable |
| Deniz Krallığı | Duygular | Duygular | `duygular` | A1 | 6 | I am + feeling | Yes | No | Yes | Yes | 7 | Playable |
| Deniz Krallığı | Hava Durumu | Fırtına Öncesi | `weather-storm` | A1 | 6 | It is + weather; present continuous | Yes | Yes | Yes | Yes | 15 | Playable, stable ID preserved |
| Deniz Krallığı | Ulaşım Araçları | Ulaşım Araçları | `ulasim-araclari` | A1+ | 8 | go by; We can take | Yes | No | Yes | Yes | 9 | Playable |
| Deniz Krallığı | Yolculuk Hazırlığı | Yolculuk Hazırlığı | `yolculuk-hazirligi` | A1+ | 8 | I need; I have | Yes | Yes | Yes | Yes | 10 | Playable |

## Catalog API

`StoryCatalog` provides lightweight queries by story ID, world, chapter, CEFR,
learner type and interest tag. `StoryCatalog` contains definitions only; it does
not eagerly build story-player widgets.

`validateStoryCatalog` validates catalog-level identity, world references,
learner eligibility, learning metadata and every story's existing structural
validation. It is intended to fail content tests during development rather than
surface malformed content to learners at runtime.

## Audit findings

- Only two generic stories existed at the start of Phase 31.
- World and chapter progress requirements are still maintained manually outside
  the story catalog. Moving those requirements to catalog-derived data is a
  later Phase 31 slice and must preserve Phase 18 behavior.
- Several pre-existing Turkish strings are stored as mojibake. They require a
  scoped UTF-8 repair with regression coverage; this foundation slice does not
  perform an unrelated bulk rewrite.
- The existing `first-encounter` and `weather-storm` IDs are preserved.
- Phase 28.1/router and Phase 30 voice implementation are untouched.

## Planned initial pack

- Yaşam Vadisi: 5 playable stories, A1.
- Sessiz Orman: at least 3 playable stories, A1 to A1+.
- Deniz Krallığı: at least 4 playable stories, A1 to early A2, preserving
  `weather-storm` and `hava-durumu`.

Each new story must include explicit learning goals, CEFR, grammar targets,
skill focus, learner eligibility, deterministic rewards, approximately 5–10
target words or phrases, and meaningful branching where pedagogically useful.
