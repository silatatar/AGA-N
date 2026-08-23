# Phase 32 Slice 5 — Atlas retirement audit

Decision date: 2026-08-18

## Decision

`world_map_atlas_placeholder.webp` is **PARTIALLY_REQUIRED**.

The three final-candidate environment plates now provide the visual identity of
Yaşam Vadisi, Sessiz Orman and Deniz Krallığı. The atlas no longer needs to be
the dominant artwork, but it still has real responsibilities that cannot be
removed safely before runtime composite QA:

- continuous terrain below the transparent mask edges;
- the narrow Yaşam-to-Orman transition where both plates are fading;
- background depth and a single vertical map silhouette;
- uncovered space around and below the three environment zones;
- the future-world area near normalized `y = .89`;
- a safe fallback if a plate is visually transparent at an aspect-ratio edge.

Removing the atlas now would replace a known 302,944-byte cost with unverified
gaps or new visual code. It remains in composition and remains in assets. It is
also marked a **LEGACY-CANDIDATE** for reconsideration after runtime QA.

## Runtime layer order

Inside the map `RepaintBoundary`, back to front:

1. Shared atlas base (`cacheWidth: 1024`, cover).
2. Yaşam environment: top-aligned, `heightFactor: .34`; fully visible through
   72% of its zone, then fades to transparent.
3. Sessiz Orman environment: centered, `heightFactor: .38`; transparent at
   both edges with a 16% transition on each side.
4. Deniz environment: `Alignment(0, .72)`, `heightFactor: .36`; transparent at
   both edges with 14% transitions, artwork alignment `(-.12, .48)`.
5. Static world ambient glows, depth gradient and edge vignette.
6. Flutter journey/path painter driven by real completed chapters.
7. Flutter world nodes at unchanged normalized coordinates.
8. Flutter future-world locked node.
9. Real Hüma asset and contextual guide message.
10. Lightweight atmospheric painter using the existing shared controller.

The HUD is above the canvas in the page slivers. Flutter navigation is fixed
above the page at the bottom. Artwork never owns interaction or state.

## Transition audit

The static ranges are intentionally overlapping:

- Yaşam: approximately `0.00–0.34` of the canvas.
- Orman: approximately `0.31–0.69`.
- Deniz: approximately `0.55–0.91`.

Yaşam → Orman has a short overlap while both mask edges are changing opacity;
the atlas supplies necessary terrain continuity there. Orman → Deniz has a
larger overlap, but the atlas still prevents a dark or empty hole at the mask
tails. Static source inspection reveals no rectangular boundary because every
internal plate edge is masked. A definitive seam/brightness/crop verdict still
requires the deferred runtime composite screenshots.

No mask, alignment, canvas dimension or node coordinate was changed in this
slice. Without runtime evidence, reducing atlas opacity would be speculative.

## Canonical asset boundaries

All world paths are owned by `WorldVisualProfiles`; the shared atlas path is
owned by `WorldMapAssets.baseAtlas`. World Map, World Detail and Home consume
these canonical values instead of duplicating literals.

## Payload

| Runtime map artwork | Bytes | Classification |
|---|---:|---|
| Shared atlas | 302,944 | PLACEHOLDER / PARTIALLY_REQUIRED / LEGACY-CANDIDATE |
| Yaşam environment | 351,682 | FINAL-CANDIDATE |
| Orman environment | 267,770 | FINAL-CANDIDATE |
| Deniz environment | 212,108 | FINAL-CANDIDATE |
| **Map artwork total** | **1,134,504** | about 1.08 MiB compressed |
| Hüma | 892,610 | REAL CHARACTER ASSET |
| **Map artwork + Hüma** | **2,027,114** | about 1.93 MiB compressed |

Each map raster requests a 1024-pixel decode width and is isolated by
`RepaintBoundary`. Detail screens load only their selected hero asset. No new
animation controller, blur, particle engine or continuous shader was added.

## Remaining QA debt

`RUNTIME_COMPOSITE_QA_REQUIRED` remains open because Flutter 3.44.8 DWDS
crashes before startup and the release build encountered Windows disk-full
errors. When the environment is healthy, capture 390×844, 412×915 and
1366×768 and inspect all three transitions, node readability, Hüma separation,
crop behavior and brightness balance before reconsidering atlas retirement.
