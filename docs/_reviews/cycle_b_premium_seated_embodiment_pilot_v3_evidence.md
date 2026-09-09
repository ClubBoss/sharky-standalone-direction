# Cycle B — Premium Seated Embodiment Pilot v3 — Evidence Pack

Status: `PASS` — was `BLOCKED_ON_PRODUCTION_IMAGE_ASSET` until the owner supplied the asset; see the "RESUMED" section at the end.
Freshness: 2026-09-10
Worktree: `/private/tmp/sharky-cycleB-seated-embodiment-v3`
Branch: `mission/cycle-b-seated-embodiment-pilot-v3`
Starting main: `cc91e0421393aa94a29ab88fa2f75776dd17af8f` (origin/main, PR #211 merged)

Evidence classes: OBSERVED = executed/inspected. DERIVED = deterministic from OBSERVED. INFERRED = reasoned, unverified.

---

## B0 — Live truth (OBSERVED)

- `git fetch origin` → `origin/main = cc91e0421393aa94a29ab88fa2f75776dd17af8f`. Has **not** advanced past the SHA named in the prompt. Local checkout `/Users/elmarsalimzade/Sharky_1.0` was on `2766d94f` (behind) with unrelated uncommitted WIP; **not touched**. Isolated worktree created off `cc91e042`.
- Authority read: `AGENTS.md`, `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`, `docs/reference/visual_benchmarks/PRE_P02_CHARACTER_AND_SHARKY_ASSET_PRODUCTION_SPEC_v1.md`.
  - `CURRENT_STAGE = PRE_P02_NORTH_STAR_CONVERGENCE`; `ACTIVE_FAMILY = PRE_P02_VISUAL_ART_COMPLETION_GAUNTLET_V1`; `INITIAL_FOCUS = LEARNING_SCENE_CHARACTER_AND_COACH_VISUAL_COMPLETION`.
  - `CAMERA_RETUNE_AGAIN = NO`; `PR203_CANONICAL_TABLE_GEOMETRY = FROZEN`; `PR205_COMMITMENT_OWNERSHIP = FROZEN`.
  - **No authority contradiction with this mission.** Mission scope (one opponent, no camera/table change) is inside the active family.
- PR #211 far-seat isolation **is present in main** (OBSERVED): `git show 9647c1db` — `lib/ui_v2/act0_shell/act0_scene_depth_v1.dart` carries the split push branch `depth <= 0.24 ? 0.11 : depth <= 0.34 ? 0.082 : 0.052 + 0.030*depth` at lines 437–441.

## B2 — Character pipeline audit (OBSERVED)

- **The transparent-PNG character-asset architecture is NOT in main.** `Act0SceneCharacterAssetPainterV1`, `Act0SceneCharacterAssetStoreV1`, `Act0SceneCharacterAssetV1`, `act0SceneAuthoredOpponentSeatIdV1` — **zero occurrences** in `lib/` or `test/` at `cc91e042`. `git log --all` for `act0_scene_character_asset*` → empty (never committed on any branch). `assets/act0_characters/` does not exist; not in `pubspec.yaml`.
- Current opponent rendering = `_Act0ScenePlayerFigurePainterV1` in `lib/ui_v2/act0_shell/act0_scene_player_v1.dart` — **100% procedural** `Canvas` drawing (paths / circles / gradients). No `Image`, no `drawImageRect`, no `BoxFit`.
- Wiring: `Act0LessonRunnerShellV1` → `buildPhysicalTableV1(cameraStageSize: stageRect.size)` → Stack `[room, grounding, Act0ScenePlayerLayerV1, scene(table), Act0ScenePlayerHeroV1]`. **The table paints AFTER the player layer**, so each opponent figure is visible only where its box extends beyond the tapered table silhouette (deliberate — `act0_scene_depth_v1.dart:694`).
- Consequence for integration: a real asset needs (a) an image painter (`drawImageRect` whole-src→whole-dst, no BoxFit — matches the PR #210 spec's stated non-negotiable), (b) a seat→asset resolver, (c) an async decode/precache guard, (d) `pubspec.yaml` asset registration. **None exists in main.** Per mission IMAGE-GENERATION BOUNDARY, this scaffold must NOT be landed without the real art.

## B1 — Real runtime geometry (OBSERVED via Flutter widget test)

Harness: `test/ui_v2/cycle_b_seated_embodiment_geometry_probe_v1_test.dart` (added, read-only; no product code changed). Same host as `act0_b7_canonical_scene_geometry_invariant_v1_test.dart`: `Act0ShellPreviewScreenV1` debug-harness `directState / runnerDrill`, `world_1 / fold_check_call_raise / actions_check_drill`. `flutter test` PASS on all 3 viewports. Raw JSON: `output/cycle_b/geometry_probe_raw.txt`.

Fixture renders 5 opponent figures (`utg, bb, hj, sb, co`) + hero. **Every figure box has aspect w/h = 0.8909** (`= 0.245 / 0.275`, `Act0SceneSeatSlotV1.volumeSize`) — viewport-invariant.

### Per-seat destination rect (screen logical px)

| seat | depth | tier | 375×812 (W×H) | 402×874 (W×H) | 430×932 (W×H) | on-screen? | rail/table occlusion |
|---|---|---|---|---|---|---|---|
| **utg** (far-centre) | 0.082 | far | 74.3×83.4 @ (143,130) | **79.6×89.4 @ (153,140)** | 85.2×95.6 @ (164,149) | fully | far rail cuts bottom **~36%**; **top ~64% (57 px @402) = clean head+shoulders relief above the rail** |
| bb (upper-left flank) | 0.332 | far | 83.1×93.3 @ (19,253) | 89.1×100.0 @ (20,273) | 95.3×107.0 @ (21,291) | fully | **0% vertical relief**; box sits inside the table's vertical span; visible only as a **16–18 px lateral sliver** left of the table |
| hj (upper-right flank) | 0.332 | far | 83.1×93.3 @ (258,251) | 89.1×100.0 @ (277,271) | 95.3×107.0 @ (296,288) | fully | 0% vertical relief; **~0.5 px** band right of the table — effectively fully occluded; box right edge overhangs the silhouette by ~1 px |
| sb (lower-left flank) | 0.678 | mid | 95.3×107.0 @ (−16,416) | 102.2×114.7 @ (−18,448) | 109.3×122.7 @ (−19,477) | **left edge off-screen** (−16 to −19) | 0% vertical relief; ~34–39 px band left of table, of which the leftmost is off-screen; overlaps felt/pot/board zone |
| co (lower-right flank) | 0.678 | mid | 95.3×107.0 @ (279,417) | 102.2×114.7 @ (299,450) | 109.3×122.7 @ (320,479) | right edge at/again screen edge (co.R = 428.96 vs 430) | 0% vertical relief; ~33–38 px band right of table; overlaps felt/pot/board zone |

Named anchors @402 (OBSERVED): coach-surface bottom `y=114`; scene-window `y 114–725`; felt `y 206.65–623.65`, `x 46.55–355.45`; table silhouette bbox `y 196.65–633.65`, `x 36.55–365.45`; board card-0 `y 403–446`; pot `y 452–473.3`; hero card-0 `y 531.8–583.2`.

### Mirror check (DERIVED)
Left and right flanks are **not true mirrors**: `plateAnchor.dx` bb `0.1942` vs hj `0.7621` (offsets from centre 0.306 vs 0.262); `characterAnchor.dx` bb `0.0853` vs hj `0.8660`. bb/hj `top` differ by ~2 px. Right-flank art cannot be a horizontal flip of left-flank art without a retargeted crop.

### Pilot-seat selection — `utg` (far-centre) (DERIVED)
- **Only seat with a coherent unoccluded region:** 64% vertical relief above the far rail → a clean head + shoulders + upper-chest read (57 px tall @402, 74–85 px wide across viewports); the remaining ~36% is cut by the far rail = the correct "seated behind the table" cue.
- All four flank seats resolve to **16–39 px lateral slivers** (hj ≈ fully occluded; sb clipped off-screen). A flank pilot would test art against a marginal/degenerate envelope → INCONCLUSIVE-prone.
- utg is the exact seat PR #211 retuned "for premium character embodiment" (`depth ≤ 0.24 → pushY 0.11`). Piloting it validates/falsifies that just-merged change.
- No collision with coach surface (25.6 px clearance above @402), board, pot, hero cards, commitments, or Coach Surface. No lateral clip.
- Facing: `facing = ((0.5 − 0.4811) × 2.4).clamp(±1) = +0.045` → **near-frontal**, a whisper of turn toward frame-centre.
- De-risk logic: a PASS on the cleanest envelope proves the direction; a FAIL on the best-case seat is decisive against it. The flank seats' thin-sliver visibility is a **separate DERIVED finding** (they may not warrant full premium renders, or need their own FAIL_SPATIAL_GEOMETRY evaluation).

## B3 — Production asset contract for the `utg` pilot

Rendering constraint (from PR #210 spec + OBSERVED painter): the asset painter must draw whole-source → whole-destination with **no `BoxFit`**. **Author the source at exactly aspect `0.8909 : 1` (w : h)** or it stretches.

| field | value | class |
|---|---|---|
| target seat | `utg` — far-centre opponent, `Key('act0_scene_player_figure_utg')` | OBSERVED |
| destination rect (canonical 402×874) | 79.65 × 89.40 logical px, top-left (153.41, 139.63) | OBSERVED |
| on-device pixel scale | 74.3–85.2 px wide (375→430 dp viewports); ×DPR on real devices (≈ 223–256 px @3×) | DERIVED |
| **source aspect (hard)** | **0.8909 : 1 (w : h)** — invariant | DERIVED |
| recommended source canvas | **1250 × 1403 px** (0.8909), transparent, PNG-32 straight alpha, sRGB | INFERRED |
| visible envelope inside the box | head fully inside **top 42%**; shoulders/upper-chest through the **top ~64%**; **bottom ~36% is permanently occluded by the far rail** — let the torso/garment run off the bottom edge with no hard cut-off line | DERIVED |
| pose | **seated, near-frontal (3/4 barely)**, facing the camera/hero; head slightly toward frame centre; shoulders square-ish with a small inward roll; visible from crown to ~mid-chest, forearms optional and low | DERIVED from `facing ≈ +0.045` |
| chair | not required to be visible (occluded); implied by posture only | INFERRED |
| hands | keep out of frame or at the very bottom edge only (bottom 36% is behind the rail anyway); **must not** reach up into the head/shoulder band | DERIVED |
| lighting | single overhead lamp, **horizontally centred, slightly toward viewer** — `Act0SceneLightV1.origin = Alignment(0, −0.58)`. Top key, symmetric; cool specular `#BBD6EE` rim on the crown/shoulder tops; green felt bounce `#2F6D5C` low on the underside. **NOT** an upper-left key (corrects the PR #210 prompt). | OBSERVED |
| value / palette | deep-ocean dark; nothing brighter than mid-felt; graded toward room tone `#1B3350` / `#0A1725`; face may be the lightest area but still sub-felt; garment darker/lower-chroma than skin; ambient `#25405C` | OBSERVED tokens |
| depth grade baked in | depth 0.082 → `hazeAt = 0.505`; runtime also lerps ~31% toward `#1B3350` and drops opacity. Author the asset **already low-contrast and cool** so it does not need to survive further haze as a high-detail image. | DERIVED |
| forbidden | background elements, vignette baked into alpha, white matte/halo, drop-shadow plate, text, logos, real-brand signifiers, readable UI, generative edge/anatomy artifacts at 80 px, frontal passport/bust crop, floating-head composition | mission contract |
| repo path | `assets/act0_characters/opponent_far_centre_in_hand.png` | INFERRED |
| pubspec | add `- assets/act0_characters/` under `flutter: assets:` | INFERRED |

### Exact generation prompt (utg pilot)

```
Stylized premium 2.5D character illustration for a mobile poker-coaching app,
transparent background. Subject: one adult poker opponent SEATED at a card
table, seen from directly across the table — near-frontal, head and shoulders
turned a few degrees toward frame centre, NOT a passport/bust crop. Visible
from the crown of the head down to roughly mid-chest; the lower torso and any
forearms run off the bottom edge of the frame (they will sit behind a table
rail). Believable seated posture and shoulder mass — this must read as a person
sitting down, not a floating head.

Simplified confident shape language; facial features as clean soft planes, not
fine photoreal detail — final on-screen size is ~80 px wide on a phone, so
silhouette and value read matter far more than detail. Bold simple hair
silhouette, clear shoulder line, visible neck and collar. Casual muted-neutral
clothing, soft fabric shading, no logos, no readable text, no real-world brands.

Lighting: a single overhead lamp, centred and slightly toward the viewer —
symmetric soft top key, cool pale-blue rim (#BBD6EE) along the top of the head
and shoulders, faint green bounce (#2F6D5C) on the underside. Overall value
graded dark: deep navy blue-black room tone (#0A1725 to #1B3350); nothing on
the figure brighter than a mid-tone green table felt; face may be the lightest
area but still darker than felt; clothing darker and lower-chroma than skin.
Painterly but clean, warm/cool contrast, no harsh outlines.

Full straight alpha around the figure. No background, no vignette in the alpha
edge, no drop shadow, no ground plane, no white halo. Portrait canvas
1250 x 1403 px, subject centred horizontally, head inside the top 42% of the
canvas, generous empty margin at the bottom.
```

## Validation (OBSERVED)

- `dart format` — `test/ui_v2/cycle_b_seated_embodiment_geometry_probe_v1_test.dart`: formatted, clean.
- `flutter analyze test/ui_v2/cycle_b_seated_embodiment_geometry_probe_v1_test.dart` — **No issues found**.
- `flutter test test/ui_v2/cycle_b_seated_embodiment_geometry_probe_v1_test.dart` — **+3 PASS** (all viewports), JSON dumped.
- No product code changed → geometry invariant `act0_b7_canonical_scene_geometry_invariant_v1_test.dart` not re-run (would be unaffected; only a new read-only test added).

## Verdict

`BLOCKED_ON_PRODUCTION_IMAGE_ASSET` — this environment (Claude Code / Sonnet) has **no production-capable image-generation path**; the required asset is a premium reference-conditioned 2.5D character render. Same constraint recorded by commit `8ea8705b` (PR #210). B0–B3 are complete with OBSERVED/DERIVED evidence; the mission question is not answerable without the real asset.

`BOUNDED_CAMERA_FALSIFICATION = NOT_EVALUATED` — no camera change was attempted or is recommended from this mission. Note (INFERRED, not a recommendation): the flank/near seats resolving to 16–39 px slivers is a geometry property; if a future wave wants five *individually legible* premium opponents it may need to evaluate that envelope, but the far-centre pilot does not require it.

---

# RESUMED — production asset supplied (2026-09-10)

Owner supplied `opponent_far_centre_in_hand.png` (1184×1328, RGBA, real straight
alpha — corners α0; aspect w/h 0.8916 vs contract 0.8909, a 0.08% delta = sub-
pixel at 80 px, no re-authoring needed). Verdict revised from
`BLOCKED_ON_PRODUCTION_IMAGE_ASSET` to the runtime result below.

## Integration (OBSERVED — files changed)

- `assets/act0_characters/opponent_far_centre_in_hand.png` — the supplied asset.
- `pubspec.yaml` — `+ - assets/act0_characters/` under `flutter: assets:`.
- `lib/ui_v2/act0_shell/act0_scene_player_v1.dart`:
  - `Act0ScenePilotCharacterAssetV1` — asset path + `isFarCentrePilotSeat(slot)`
    selector (geometry-based: `far` detail tier ∧ `|plateAnchor.dx − 0.5| < 0.15`
    ∧ not hero — routes correctly regardless of seat-id labelling).
  - `_Act0ScenePilotFigureV1` (stateful) — decodes the asset once, paints
    `_Act0ScenePilotFigurePainterV1`, falls back to the existing procedural
    painter until decode completes (no blank frame).
  - `_Act0ScenePilotFigurePainterV1` — `drawImageRect` whole-src → whole-dst (no
    `BoxFit`), then a `srcATop` room-tone (`#1B3350`) haze tint at `haze*0.62`
    (matches the procedural `_recede`), + folded recession. `Act0ScenePlayerFigureV1.build`
    routes the pilot seat here; **every other seat is byte-identical**.
- No change to camera, table geometry, seat anchors, projection, commitments,
  Coach Surface, CTA shelf, copy, poker state or telemetry.

## Runtime evidence (OBSERVED — real Flutter frames)

`test/ui_v2/cycle_b_seated_embodiment_pilot_capture_v1_test.dart` — same
canonical host, golden PNGs under `test/ui_v2/goldens/cycle_b/`, **+3 PASS**.
Asset decode is awaited via `precacheImage` before capture (the first,
un-awaited pass captured the one-frame procedural fallback at 375 — a
capture-tool timing artifact, corrected, not an art result).

| viewport | pilot rect (L,T,W,H) — pre vs post integration | states captured |
|---|---|---|
| 375×812  | (143.10, 129.55, 74.30, 83.40) — **identical** | decide / correct / wrong / repair |
| 402×874  | (153.41, 139.63, 79.65, 89.40) — **identical** | decide / correct / wrong / repair |
| 430×932  | (164.09, 148.75, 85.20, 95.63) — **identical** | decide / correct / wrong / repair |

Geometry drift pre→post integration and across all four learning states: **0.0 px**.

Visual read (OBSERVED from the goldens, 4× crops in `output/cycle_b/crops/`):
- Reads immediately as a man **seated across the table**: head, hair, face,
  neck, open collar, shoulders, upper chest; the far rail cleanly crosses the
  lower chest → correct "behind the table" occlusion. Torso mass present — not
  a floating head / bust.
- Forearms (present in the source) land in the rail-occluded bottom 36% → **no
  felt intrusion**.
- No collision with coach surface (25 px gap @402, and the repair-state coach
  card clears the head), board, pot, hero cards, seat plates, commitments.
- Does **not** overpower the information hierarchy — board cards, pot, focus
  reticle and Sharky's coach card stay dominant; the opponent recedes.
- Decisive **class-level lift** vs the 4 procedural blob figures visible in the
  same frame.
- Weaknesses (art-polish backlog, non-blocking): at 375 px the face is legible
  but low-contrast; the asset's baked cool rim is slightly hot at 4× zoom
  (subtle at 1×). Neither warrants a correction pass — the direction is proven.

## Validation (OBSERVED)

- `dart format` — clean (3 files).
- `flutter analyze` (changed lib + both test files) — No issues found.
- `flutter test test/ui_v2/cycle_b_seated_embodiment_pilot_capture_v1_test.dart` — +3 PASS.
- `flutter test test/ui_v2/act0_b7_canonical_scene_geometry_invariant_v1_test.dart` — **+11 PASS** (incl. `far seat anchor` = `act0_scene_player_figure_utg` does not move; felt/silhouette unchanged).
- `flutter test test/ui_v2/runner/` — **+213 PASS**.
- scene semantic-motion / attention-phase / world1 compositor / seat-scene-contract / geometry probe — +16 PASS.

## VERDICT (revised)

`PASS`

CAUSAL_REASON: the supplied reference-conditioned 2.5D render drops into the
far-centre seat's exact reserved volume, rides the frozen PR203/PR211
camera + rail occlusion with zero geometry change, and reads as a credible
premium seated opponent across all three canonical viewports and all four
learning states — a material class-level lift over the procedural ceiling. All
15 acceptance points are met (point 7, face-readable-at-375, is a threshold
pass with a noted asset-polish backlog). The correction budget was not used.

`BOUNDED_CAMERA_FALSIFICATION = NOT_JUSTIFIED` — no spatial-geometry failure was
observed for the far-centre seat. (Separate DERIVED note, not a recommendation:
the four flank seats resolve to 16–39 px slivers behind the table; if a future
wave wants all five opponents individually legible it should evaluate that
envelope, but the pilot proves the direction and does not require it.)
