# Phase 32 Visual Manifest

Updated: 2026-08-19

This is the canonical ownership and QA record for the Phase 32 world and story artwork. It replaces slice-by-slice assumptions; earlier audit documents remain historical evidence only.

## Status and invariants

- Playable catalog: 12 stories — Yaşam Vadisi 5, Sessiz Orman 3, Deniz Krallığı 4.
- Deniz future catalog: `seyahat-plani` and `deniz-canlilari` remain non-playable, `comingSoon`, art-free entries.
- All playable covers are owned by `StoryDefinition.coverVisual`.
- All playable scenes are owned by `StoryScene.visual`.
- World artwork paths are owned by `WorldVisualProfiles` and `WorldMapAssets`.
- No presentation file contains a direct story/world artwork literal or a story/world-ID visual switch.
- All interaction, labels, locks, progress and rewards remain Flutter UI/state.
- Accepted art is classified `FINAL_CANDIDATE_PENDING_RUNTIME_QA`, not final production art.
- Phase 28.1/router and learning/progression semantics are outside this manifest and were not changed by Slice 10.

## Canonical 12-story inventory

All rows have valid cover and scene metadata, a non-empty Turkish accessibility description, valid alignment/overlay ranges, and resolvable files.

| World | Stable story ID | Display title | Cover (dimensions; bytes) | Scene asset(s) (dimensions; bytes; node reuse) | Class |
|---|---|---|---|---|---|
| Yaşam | `first-encounter` | Yaşam Vadisi — İlk Karşılaşma | `ilk_karsilasma/cover_v1.webp` (1024×1536; 279,960) | `scene_arrival_v1.webp` (1024×1536; 236,310; 1 node), `scene_meeting_v1.webp` (1024×1536; 353,630; 6 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Yaşam | `ben-kimim` | Ben Kimim? | `ben_kimim/cover_v1.webp` (1024×1536; 304,896) | `scene_01_v1.webp` (1024×1536; 290,484; 6 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Yaşam | `gunluk-hayat` | Günlük Hayat | `gunluk_hayat/cover_v1.webp` (1024×1536; 343,072) | `scene_01_v1.webp` (1024×1536; 308,950; 5 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Yaşam | `sevdigim-seyler` | Sevdiğim Şeyler | `sevdigim_seyler/cover_v1.webp` (1024×1536; 344,208) | `scene_01_v1.webp` (1024×1536; 346,448; 6 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Yaşam | `kucuk-bir-gun` | Küçük Bir Gün | `kucuk_bir_gun/cover_v1.webp` (1024×1536; 331,556) | `scene_morning_v1.webp` (1024×1536; 303,178; 5 nodes), `scene_finale_v1.webp` (1024×1536; 239,028; 2 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Orman | `ormana-giris` | Ormana Giriş | `ormana_giris/cover_v1.webp` (1024×1536; 244,030) | `scene_01_v1.webp` (1024×1536; 205,132; 5 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Orman | `kaybolan-yol` | Kaybolan Yol | `kaybolan_yol/cover_v1.webp` (1024×1536; 253,276) | `scene_01_v1.webp` (1024×1536; 224,434; 5 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Orman | `gece-sesleri` | Gece Sesleri | `gece_sesleri/cover_v1.webp` (1024×1536; 260,938) | `scene_01_v1.webp` (1024×1536; 194,526; 6 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Deniz | `duygular` | Duygular | `duygular/cover_v1.webp` (1024×1536; 253,854) | `scene_01_v1.webp` (1024×1536; 223,916; 6 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Deniz | `weather-storm` | Hava Durumu / Fırtına Öncesi | `hava_durumu/cover_v1.webp` (1024×1536; 264,574) | preserved `scene_01.webp` (1672×941; 175,246; 7 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Deniz | `ulasim-araclari` | Ulaşım Araçları | `ulasim_araclari/cover_v1.webp` (1024×1536; 355,140) | `scene_01_v1.webp` (1024×1536; 287,392; 5 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |
| Deniz | `yolculuk-hazirligi` | Yolculuk Hazırlığı | `yolculuk_hazirligi/cover_v1.webp` (1024×1536; 331,422) | `scene_01_v1.webp` (1024×1536; 236,166; 6 nodes) | FINAL_CANDIDATE_PENDING_RUNTIME_QA |

Story paths above are relative to `assets/images/stories/<world>/`. Scene reuse is intentional when the narrative location is unchanged; cover art is not used as a scene when a dedicated scene exists.

## World and character ownership

| Asset | Dimensions | Bytes | Classification | Runtime responsibility |
|---|---:|---:|---|---|
| `assets/images/huma.png` | 1024×1536 | 892,610 | REAL | Canonical Hüma character asset |
| `worlds/yasam_vadisi/environment_v1.webp` | 1024×1536 | 351,682 | FINAL_CANDIDATE_PENDING_RUNTIME_QA | Map Yaşam plate and Yaşam detail hero |
| `worlds/sessiz_orman/environment_v1.webp` | 1024×1536 | 267,770 | FINAL_CANDIDATE_PENDING_RUNTIME_QA | Map Orman plate and Orman detail hero |
| `worlds/deniz_kralligi/environment_v1.webp` | 1024×1536 | 212,108 | FINAL_CANDIDATE_PENDING_RUNTIME_QA | Map Deniz plate |
| `worlds/deniz_kralligi/hero_background.webp` | 1536×1024 | 149,944 | FINAL_CANDIDATE_PENDING_RUNTIME_QA | Deniz detail hero |
| `worlds/shared/world_map_atlas_placeholder.webp` | 1024×1536 | 302,944 | PLACEHOLDER + PARTIALLY_REQUIRED + LEGACY_CANDIDATE | Map continuity, transitions, uncovered silhouette and future-world depth |

The atlas must not be deleted or retired before runtime composite QA proves its remaining responsibilities are covered.

## Payload and duplicate audit

| Bucket | Files | Bytes | MiB |
|---|---:|---:|---:|
| Story covers | 12 | 3,566,926 | 3.40 |
| Story scenes | 14 | 3,624,840 | 3.46 |
| All story art | 26 | 7,191,766 | 6.86 |
| Unique world WebPs | 5 | 1,284,448 | 1.23 |
| Total unique Phase 32 WebPs | 31 | 8,476,214 | 8.08 |
| Map runtime stack (atlas + three environment plates) | 4 | 1,134,504 | 1.08 |
| World-detail source set (two reused environments + Deniz hero) | 3 | 769,396 | 0.73 |
| Hüma, reported separately | 1 | 892,610 | 0.85 |
| Atlas, included in world/map totals | 1 | 302,944 | 0.29 |

The world-detail value overlaps the unique world total because Yaşam and Orman reuse their map environment files. SHA256 audit found zero exact duplicates. Runtime/data reference audit found zero orphan assets and zero missing files. Pubspec has no duplicate declaration that resolves to the same story asset. No generated PNG is present under `assets/images/stories` or `assets/images/worlds`; `huma.png` is intentional and REAL.

### Largest ten WebPs

1. `deniz_kralligi/ulasim_araclari/cover_v1.webp` — 355,140 B
2. `yasam_vadisi/ilk_karsilasma/scene_meeting_v1.webp` — 353,630 B
3. `worlds/yasam_vadisi/environment_v1.webp` — 351,682 B
4. `yasam_vadisi/sevdigim_seyler/scene_01_v1.webp` — 346,448 B
5. `yasam_vadisi/sevdigim_seyler/cover_v1.webp` — 344,208 B
6. `yasam_vadisi/gunluk_hayat/cover_v1.webp` — 343,072 B
7. `yasam_vadisi/kucuk_bir_gun/cover_v1.webp` — 331,556 B
8. `deniz_kralligi/yolculuk_hazirligi/cover_v1.webp` — 331,422 B
9. `yasam_vadisi/gunluk_hayat/scene_01_v1.webp` — 308,950 B
10. `yasam_vadisi/ben_kimim/cover_v1.webp` — 304,896 B

No file is an obvious compression outlier; no recompression is justified solely by these sizes.

## Decode, preload and fallback audit

- Story scenes use `cacheWidth: 1024`, appropriate for a full-width high-DPR scene without decoding beyond source width.
- Map atlas/environment plates use `cacheWidth: 1024`, appropriate for full-width layered artwork.
- World-detail heroes use 1280–1440 decode widths; reasonable for their wide/desktop role and not changed without runtime memory evidence.
- Both compact 44×44 chapter cover presentations use `cacheWidth: 160`, which covers roughly 3× device pixel ratio without decoding the 1024px source.
- Cover thumbnails are excluded from semantics because the containing chapter control already announces title and state. Story scenes use the metadata accessibility description through one explicit `Semantics(image: true)` node.
- No `precacheImage`, global story-art warmup, or startup traversal of image files exists. Artwork is decoded when its map/detail/story widget is reached.
- Missing covers fall back to a chapter number. Missing/unreadable story scenes fall back to the branded gradient and unsupported-image icon. A future chapter without art remains valid and disabled.
- Image loading and fallback paths do not call progression/reward code; an artwork error cannot award XP or fake completion.

## Static visual consistency audit

- Yaşam: warm emerald/gold, welcoming growth and village/valley compositions.
- Sessiz Orman: moonlit teal/cyan, mist, ancient paths and calm discovery without horror.
- Deniz: royal/navy blue, aqua light, submerged architecture and travel/preparation compositions.
- All images use a coherent premium painterly fantasy treatment; the three worlds remain distinguishable.
- No inspected asset contains baked UI, title, readable signage, progress, lock, Hüma substitute, human/NPC portrait, watermark or fake interactive marker.
- Reuse is deliberate, not byte duplication. No concrete defect currently justifies regeneration.
- Runtime-only risk: the preserved Hava Durumu scene is landscape (1672×941), so its mobile `BoxFit.cover` crop must be checked. Other remaining risks are crop, brightness and overlay contrast on real device/browser frames.

## Canonical runtime composite QA checklist

Tooling/runtime verification remains `RUNTIME_COMPOSITE_QA_REQUIRED`.

### Map — 390×844, 412×915, 1366×768

- Three-world transition continuity and any hard mask/seam.
- Atlas visibility and whether it still fills real gaps.
- Node label/state readability and hit areas.
- Hüma overlap/clash, darkness and future-world silhouette.

### World details — Yaşam, Orman, Deniz

- Hero crop and contrast.
- Metadata-driven 44×44 cover thumbnail crop.
- Chapter title/status readability and scrolling.
- Deniz future entries remain visibly disabled.

### Representative stories — one per world

- Cover crop from the corresponding world detail.
- Scene crop, overlay contrast and Flutter text readability.
- Choice/writing panel readability on small mobile and wide desktop.
- Specifically inspect the landscape Hava Durumu harbour scene on mobile.

The full Flutter suite completed at 265/265 after the obsolete visual-less fallback fixture was replaced by a valid test-only visual-less story. Do not call artwork production-final until the runtime checklist completes.
