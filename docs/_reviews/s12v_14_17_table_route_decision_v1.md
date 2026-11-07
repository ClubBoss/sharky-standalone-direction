---
status: "DOCS-ONLY decision + technical contract package for S12.V-14..17. Not an S12.V PASS, not a visual wave admission, not Human admission. Owner decides."
status_source: "manual"
baseline: "f99da096dcfd"
generated_by: "claude_s12v_table_decision_20261019"
---

# S12.V-14..17 — Physical Five-Opponent Table: Route Decision + Technical Contract

Base `main` `f99da096dcfda7d001c24003c052b1f3f314362a`. Authority: Master Plan §10A (S12.V),
`docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`, Issue #287, `AGENTS.md`.
No production Flutter, asset, grading/XP/telemetry, PR #224 or PR #290 file is touched by this package.

**Terminal verdict: `TABLE_ROUTE_DECISION_READY_FOR_OWNER`**
**Preferred route: `T2 SCENE RESTRUCTURE`, executed as a gated spike (Stage A) before the full wave.**
This package prepares S12.V-14..17; it does **not** close them and does **not** record `S12.V_PASS`.

## 0. Evidence basis and its limits (read first)

| Item | Truth |
| --- | --- |
| Photographed evidence | Native iOS-simulator captures, iPhone 16e, compact 375x667, candidate `6610103fcd30` — Actions run `38332096846`, artifact `native-audit-shard-compact-normal-6610103f…` (not expired when read). Rows used: `showdown.compact.normal`, `vrt02_incorrect.compact.normal`. Classification in manifest: `NATIVE_PRODUCTION_RENDERER_INJECTED_STATE`. |
| Not available to me | Standard-size shard viewed; natural first-use journey; any capture of `f99da09`. Compact-only, injected-state, older-SHA. Therefore the *visible-symptom* statements below are `PHOTOGRAPHED_ON_6610103`, and the owner's `HOLD_VISUAL_TRUST` is consistent with them but not re-proven on `f99da09`. |
| Is `6610103` evidence still valid for the scene? | `git diff 6610103fcd30..f99da09 -- lib/ui_v2/act0_shell/act0_scene_*.dart act0_learning_scene_v3.dart assets/act0_characters assets/act0_render_class assets/act0_room pubspec.yaml` is **empty**. `act0_lesson_runner_shell_v1.dart` did change (+205/-143), so the *runner-owned* parts (seat slot tables, layer order) must be re-confirmed by Stage A capture on `f99da09`. |
| Source-proven (not photographed) | Asset measurements and source facts in §1–2 were measured directly from the repo files at `f99da09`. |
| Old output | `output/device_audit/**` (git-ignored, 2026-10-12) shows a different, pre-hybrid renderer; **not** used. V4 concept renders are not used as production evidence. |

## 1. Established cause of the P1 (source-proven, with photographic symptom)

The P1 is **not a camera/perspective-tuning problem**. It is a **three-owners-of-one-space problem plus missing physical source art**.

1. **Space has three independent geometry owners that never meet in one coordinate frame.**
   - (a) Baked plate `hybrid_scene_shell_v4.png` (941x1672): room + a very long narrow stadium table. Verified by viewing: **no chairs, no seats, no sitters**; table seen end-on as a runway.
   - (b) Procedural camera/perspective: `Act0SceneCameraV1` (far rail 0.270, projected height 0.470 → near rail 0.740, outer width 0.810, horizon 0.25) + `Act0ScenePerspectiveV1` (far/near width 0.60/0.99, depthEase 1.55). The plate is *scaled to match only the two rail heights* (`Act0SceneHybridShellFootprintV1`: heightFactor 0.7118115942, topFraction 0.0758695652). Horizontal rail curvature of the baked art is **not** modelled by the procedural projection.
   - (c) Seat slots: flat Wave-A tables (`_seatSlotsForVariant`, compact ring x 0.08/0.47/0.86, y 0.06–0.86) → perspective project → `characterAnchor = projected + outward*(pushX 0.104+0.072·depth, pushY 0.11/0.082/0.052+0.03·depth)` in `act0SceneSeatSlotsV1`. The "outward push" is a heuristic, not a measurement of where a body meets the baked rail.
2. **The cast has no physical contact surface.** Five single-pose half-body cutouts (`opponent_{utg,bb,hj,sb,co}_engaged.png`, 1184x1328). Measured alpha: bounding box touches the canvas edge on **bottom (all 5)**, **right (BB, SB)**, **left (CO)**; i.e. bodies are cropped by the *image rectangle*, not by a rail. Nothing in the layer stack covers that crop: characters are painted *over* the baked plate (`Positioned.fromRect(stage)` over `Act0SceneHybridShellPlaneV1`), so there is no rail-front occluder. Folded reuses the Engaged image + tint (`Act0SceneCharacterAssetRegistryV1.pathFor`); no Empty art exists (no chair to show).
3. **Art identity is bound to a screen-slot classifier, not to the seat.** `Act0SceneCharacterIdentityResolverV1` resolves art by (x, depth); filenames say `bb/hj/sb/co` but mean "left-upper/right-upper/left-lower/right-lower".
4. **Information layer is positioned against procedural anchors** (`cardAnchor = projected − 0.055·outward`, `betAnchor = projected − 0.115·outward`) while the bodies are placed by a different push on the same projected point, so cards/labels land on faces and shoulders by construction.

Photographed symptoms on `6610103` compact (all consistent with 1–4):
- Rectangular matte/box edges on BB (right edge ≈ x210/924 at y≈870–960), SB (right edge ≈ x213, bottom ≈ y1505), CO (left edge): the image-rectangle crop is visible.
- Flank sitters stand on carpet **outside** the baked rail with no chair; no rail-to-torso contact; perspective scale jump UTG ≪ SB/CO.
- Showdown: CO's second hole card (J) is covered by CO's face; SB cards overlap SB's head; SB label truncated to "all blind" behind the figure; Hero hole cards straddle near rail / "You BTN" plate / dock edge.
- Repair state: a second thin procedural rail outline floats off the baked felt edge (double table silhouette); UTG reads as a translucent ghost.
- Hero hands sit under/behind the translucent action dock edge.

Causation statement: `PHOTOGRAPHED_SYMPTOM = confirmed (compact, 6610103)`; `SOURCE_CAUSE = items 1–4 above, source/asset-measured at f99da09`. Item (b)'s double-outline is photographed, its exact procedural paint site is **not** pinned (see §4 unknowns).

## 2. Prior-failure map (what must not be repeated)

| History | Lesson applied |
| --- | --- |
| W3 camera-only retune failed | T1/T2 below do **not** retune camera/perspective; the plate footprint is frozen and becomes the single reference frame. `TABLE_GEOMETRY_INVARIANT_V1` (0.0 px delta) is kept as a regression. |
| Empty/Folded/Engaged + mask/layer history | State is a **layer-visibility contract in one frame**, not new full-scene renders per state (§3). |
| V4 concept renders / PR #224 | #224 (open, 17 files) adds per-seat `*_SEAT_ACTIVE_V4R1` cutouts (e.g. SB 167x324) + `registration_v4r1.json` in 941x1672 **plate pixel coordinates**. Viewed SB: still a cutout, flush to canvas edge, **no chair/rail contact** — it is the same asset class. Its useful idea is the registration-in-plate-pixels mechanism; its art does not solve contact. Not admitted, not merged. |

## 3. Route comparison

| | T0 KEEP | T1 TARGETED REPAIR | T2 SCENE RESTRUCTURE (rec.) | T3 PHYSICAL PRESENTATION REPLACEMENT |
| --- | --- | --- | --- | --- |
| Feasibility | Rejected: defects in §1 are in current native evidence and source-proven | High. No new art: rail-front occluder cropped from the existing plate (plate footprint is deterministic), edge feather/crop-aware fit, card/label offset, remove double outline | Medium-high. One shared 941x1672 frame; needs new art (chairs, re-seated sitters, rail-front) | Medium-low; abandons table/camera/plate; largest scope |
| Expected visual benefit | none | Medium: removes box edges and some occlusion; **cannot create chairs, seated posture or rail contact** (no source for them) → still reads as floating cutouts | High: chair + body + rail contact are authored once in the same frame; Empty/Engaged/Folded become visibility states | Highest ceiling, unproven |
| Required source assets | none | none beyond existing PNGs | **Missing today:** empty-chair plate variant of the 941x1672 shell; 5 sitters authored *with chair/rail geometry in the same frame*; a rail-front layer (can be derived from the plate); a seat-anchor table in plate pixels | New table, camera, cast, seat system |
| Registration risk | Low | Medium (occluder must align to baked rail ellipse) | Lowest *if* all layers share one canvas and one footprint (the mechanism the current hybrid shell already proves) | High |
| Flutter integration | none | ~200–400 LOC in `act0_scene_*` | Reuses `Act0SceneSinglePlateImageStoreV1`, `Act0SceneHybridShellFootprintV1`, decode-once/missing-is-supported rollback; replaces push heuristic with measured anchors | Rewrites scene, geometry tests |
| Verification cost | Low | Low-medium | Medium (Standard+Compact native + geometry/semantic tests) | High |
| Repeat-of-old-failure probability | n/a | **High** (it is another patch on patch: masks/occluders on a cutout class that previously failed) | Low-medium; main risk is art quality, which is why Stage A exists | Medium |

**Decision: T2, gated.** T1 is rejected as the *primary* route because its ceiling is below the owner's stated bar (physical seating/contact) and it extends the patch-on-patch pattern the Master Plan forbids; but T1's rail-front occluder is *reused inside T2* (derived from the plate, so no extra art). T3 is **not justified now**; it is the defined fallback if Stage A fails its gate (§6).

Owner-visible cost range (estimate, not measured): Stage A art ≈ 1 chair-plate + 1 sitter + rail-front; full T2 ≈ chair-plate + 5 sitters (Engaged only; Folded = recession treatment already in `Act0SceneCharacterPainterV1`) + anchors file. Hours are owner/art-pipeline dependent and **not invented here**.

## 4. Technical map of current sources, layers, coordinates, owners

| Concern | Owner today (file) | Frame |
| --- | --- | --- |
| Room + table plate | `assets/act0_render_class/hybrid_scene_shell_v4.png` (941x1672), painted by `Act0SceneHybridShellPainterV1` in `act0_scene_hybrid_shell_v1.dart` over `Act0SceneRoomPlaneV1`(room_plate_v1.png 1254x1254) | footprint: heightFactor 0.7118115942, topFraction 0.0758695652 of scene box, width from aspect, clipped |
| Camera / stage rect | `Act0SceneCameraV1.canonical` (`act0_scene_depth_v1.dart`) | far rail 0.270, near rail 0.740, outerW 0.810, horizon offset 0.020 |
| Seat ring (base slots) | `_seatSlotsForVariant` (`act0_lesson_runner_shell_v1.dart` ≈L12490) compact ring + standard ring | table-normalized 0..1 |
| Seat slots/anchors | `act0SceneSeatSlotsV1` (`act0_scene_depth_v1.dart` L396): plate/character/bet/card anchors | scene-normalized, perspective-projected |
| Character art + identity | `act0_scene_character_asset_v1.dart` (+ resolver by x/depth); art fit only UTG scale 1.12 offset (0,-0.20) | seat envelope |
| Character paint + haze/fold | `Act0SceneCharacterPainterV1` | envelope rect |
| Hero POV | `hero_pov_foreground_v3.png` 2048x682 via `Act0ScenePlayerHeroV1` (width 0.86, height 0.25, dy 0.46) | bottom-aligned fraction |
| Procedural material suppression | runner listens to `shellStore.readyNotifier` (≈L11774, 11805, 12051, 12086) | — |
| Commitments | `act0SceneCommitmentAnchorsV1` (bet anchors per seat) | — |
| Game truth | `Act0SeatBetStateV1`, `world1_canonical_table_seat_state_v1.dart`, seat IDs from `table.seats` | **must not change** |

Unknowns the executor must pin **before** editing (cheap, source/capture reads; I did not invent them): (U1) exact z-order of characters vs cards/labels/chips inside `buildPhysicalTableV1`; (U2) the paint site of the second procedural rail outline seen in repair state; (U3) the standard-size slot ring effective values; (U4) whether post-`6610103` runner-shell changes altered layer order.

## 5. Contract of the future scene (S12.V-15, -16)

**5.1 One frame.** All physical art layers are authored on the existing 941x1672 plate canvas and drawn with the **existing** `Act0SceneHybridShellFootprintV1` (no camera/perspective retune; `TABLE_GEOMETRY_INVARIANT_V1` stays green). No layer is positioned by `characterAnchor` push heuristics.

**5.2 Layer stack, bottom → top (single paint pipeline, one owner each):**
1. `L0 room+table+chairs plate` (empty chairs baked into the plate; occupied-seat chair is covered by the sitter layer or identical) — art.
2. `L1 sitter[seat]` — one full-canvas (or tight-bbox + plate-pixel registration) alpha layer per seat, **bottom edge ends inside the rail-front zone, never at the image edge**; visible only when seat state = Engaged/Folded.
3. `L2 rail-front occluder` — nearest rail lip + table side as one alpha layer so sitters visibly sit *behind/at* the rail (contact).
4. `L3 Hero POV foreground` (existing asset; re-fit only if Stage A shows overlap).
5. `L4 semantic layer` (Flutter, unchanged semantics): seat plates/labels, hole cards, bet chips, pot, dealer button, board, position badges.
6. `L5 HUD/teaching/dock` (unchanged ownership).

**5.3 Seat states (visibility contract, no per-state scene renders):**
- Empty: L1 hidden; chair visible from L0; plate/label per existing semantics.
- Engaged: L1 full.
- Folded: L1 with existing recession treatment (`haze`/0.72 opacity/tint — reuse `Act0SceneCharacterPainterV1`); cards hidden per existing source semantics. **No new Folded art.**

**5.4 Ownership.** Seat identity = `seatId` from source seat state; the (x, depth) classifier is replaced by an explicit `seatSlot → art` map keyed by screen slot (left-lower, left-upper, far, right-upper, right-lower) in the anchors file — art naming must say *slot*, not poker position. Card/pot/chip/label anchors come **only** from the measured anchors file (plate pixels), expressed per seat: `facePad`, `cardPad`, `labelPad`, `betPad`, plus keep-out rects for each sitter's head/face region. Pot/board remain on the felt centre, never inside a keep-out.

**5.5 Geometry deliverable (S12.V-16)** — the anchors file `assets/act0_render_class/scene_anchors_v1.json` (to be created by executor in plate pixels, values **measured from the final art, not guessed**): per seat {rail contact point, head keep-out rect, card rect, label rect, bet rect}; Hero {hole-card rect, plate rect, dealer button rect, hand keep-out}; board/pot rects; for Standard and Compact separately (compact table region + dock reservation). Minimum clearances to be asserted, not guessed here: label never occludes a face keep-out; card never overlaps face keep-out; ≥ one tap-target (44 pt) around any tappable seat target (existing source tap targets retained).

**5.6 Preserved (frozen):** seat IDs, action tokens, `world1_canonical_*` seat/marker contracts, grading, XP, telemetry keys, Coach silence in assessment, `TABLE_GEOMETRY_INVARIANT_V1` values (outerW 0.810, far/near rail 0.270/0.740, perspective 0.60/0.99, depthEase 1.55), Modern Table untouched.

## 6. Work order for ONE future executor (S12.V-15/16 build, only after owner admission)

**Admission text for owner:** "Admit one bounded pre-Human Table Scene wave T2, Stage A then Stage B, budget and rollback below."

**Allowed files/assets (exhaustive):**
- New: `assets/act0_render_class/scene_layers_v1/**` (chair plate, sitter layers, rail-front), `assets/act0_render_class/scene_anchors_v1.json`, one new `lib/ui_v2/act0_shell/act0_scene_layers_v1.dart`, its tests under `test/ui_v2/`, `pubspec.yaml` asset entries.
- Modify (minimal): `act0_scene_character_asset_v1.dart`, `act0_scene_hybrid_shell_v1.dart`, `act0_scene_depth_v1.dart` (anchor source only), and the table-stage call sites in `act0_lesson_runner_shell_v1.dart` (layer insertion + removal of the second procedural rail outline and of push-anchor use).
- Forbidden: camera/perspective constants, grading/XP/telemetry/routes, copy, Modern Table, PR #224/#290 files, generated output committed.

**Stage A (spike, one seat + frame; stop/go gate).** Produce chair plate, the SB sitter (hardest contact: nearest, left-lower), rail-front; integrate behind a flag; capture native Standard + Compact `showdown` and `repair` states on the exact new HEAD. **GO only if** (i) no rectangular crop edge visible; (ii) sitter reads as seated at the rail with chair; (iii) SB cards/label clear the face keep-out; (iv) registration error of rail-front vs plate ≤ 1 source pixel in a diff overlay; (v) `TABLE_GEOMETRY_INVARIANT_V1` and seat-semantics tests green. **NO-GO** → stop, record `T2_STAGE_A_FAIL`, return to owner for T3 decision. No further polish.

**Stage B (remaining 4 sitters + anchors for all states).** Same pipeline; no per-seat bespoke code paths.

**DoD:** §7 checks green; owner reviews Standard+Compact native shots; no open P0/P1 in table scope; rollback verified; new exact HEAD/TREE/native binary frozen; S12.V re-evaluation is a *separate* owner step.

**STOP conditions:** Stage A fails; need to change camera/perspective constants; need to edit seat/grading/telemetry semantics; any third geometry owner appears; art needing >1 revision round per seat; native flow not reproducible; scope request touches Home/Review/You (separate lane).

**Missing authoritative input (named, not invented):** layered source files (PSD/EXR) for plate and cast do not exist in the repo (only flattened PNGs); the chair plate and chair-aware sitters must be commissioned/generated by the owner-approved art pipeline. Without them the wave cannot start; T1 is the only no-new-art route and is rejected as primary above.

## 7. Required regressions after the future change (S12.V-17)

Native (iPhone simulator, same pipeline as run `38332096846`; exact new HEAD/TREE/binary recorded):
1. Standard and Compact portrait: `showdown`, `vrt02_incorrect`/repair, `vrt02`, `repair_recheck`, one preflop with blinds posted, one folded-seat state, one empty-seat state.
2. Diff overlay: rail-front registration ≤ 1 source px; no alpha-crop edge at canvas boundary for any sitter.
3. Occlusion audit per seat: label/cards/chips vs head keep-out; hero hole cards vs rail/dock; dealer button visible.
4. Tap targets: seat tap targets ≥ 44 pt and not occluded by L2; action dock clearance preserved.

Source/test (reuse, then add):
5. `act0_b7_canonical_scene_geometry_invariant_v1_test.dart` unchanged and green (0.0 px delta at 375/402/430).
6. `act0_scene_character_asset_v1_test.dart`: replace the (x, depth) resolver tests with slot-map tests; one new asset-missing-is-supported (procedural fallback) test per layer.
7. New: layer z-order test (L0<L1<L2<L3<L4<L5); anchors-file schema + per-seat non-overlap test (label/card vs face keep-out) for Standard and Compact; Empty/Engaged/Folded visibility truth table test for all five slots.
8. Game semantics (source-owned): `act0_s11_mapped_repair_seat_truth_v1_test.dart` and existing seat/commitment/marker contract tests green; assertion that seat ID → rendered slot → semantic anchors is a bijection for hero seat in each of the six positions (rotation).
9. Reduced motion + accessibility labels unchanged (existing guards).
10. Required repo CI for exact PR head; no net-new failures.

## 8. Rollback and stop-polish criterion

- **Rollback:** layers load through the existing decode-once stores; a missing/invalid asset is a supported state falling back to the current plate + procedural path. Ship behind one constant (`useSceneLayersV1`); revert = flip the constant, then delete `scene_layers_v1/` in a follow-up. Pre-change baseline = `f99da09` captures (taken in Stage A step 0).
- **Stop polishing when:** Stage A/B gate items pass for Standard and Compact and the owner sees no P0/P1 in table scope in the new native captures. Further art iteration is **not** justified if a seat needs a second correction round after Stage A, or if remaining defects are cosmetic (skin tone, hair detail, rim light) with no physical-contact, occlusion or ownership defect.
- **Fallback if Stage A fails:** owner chooses between T3 (full physical presentation replacement, new separate admission) and accepting `S12.V_HOLD` as an explicit product decision. No camera-only experiments.

## 9. Open items / honesty notes

- Standard-size and `f99da09`-pinned captures were not available to me; Stage A step 0 must capture them before any edit.
- This package makes no claim on Home/Review/You/Summary surfaces (light Academy vs dark legacy discontinuity noted elsewhere); they are out of this table wave.
- PR #224 is neither used nor assessed beyond the two files I inspected (`registration_v4r1.json`, `SB_SEAT_ACTIVE_V4R1`).
- No hour estimates are given because none are supported by repo evidence.

## 10. Single next action

**Owner: approve or reject the one bounded "T2 Stage A spike" wave (one chair plate + SB sitter + rail-front, Standard+Compact native, go/no-go gate in §6).**
