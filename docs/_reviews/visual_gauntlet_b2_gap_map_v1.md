# VISUAL GAUNTLET B2 — GAP MAP v1

Mission: `VISUAL_GAUNTLET_B2_PREMIUM_TABLE_AND_ENVIRONMENT_ART_V1`
Starting live `origin/main`: `c8f15c5e95b2950694b182280eb26216f5ca5a7b`
(contains B1 integrated main `a4f9e8ef`, B1 = `CLOSED_PASS`)
Branch: `feat/visual-gauntlet-b2-premium-table-and-environment-art-v1`
Primary viewport: `402x874`.
Produced BEFORE any production mutation.

## 0. What B1 actually left behind

B1 is spatially correct and is not reopened. The material layer underneath it is
close to unbuilt. Read from live source, not from memory:

| Element | Current implementation | Reading |
| --- | --- | --- |
| Rail | `Container(padding: 10)` + `ShapeDecoration` gradient `railInner -> railMid -> railOuter` | all three tokens are **the same colour** `0xFF14273A`. The rail is a flat 10 px navy band. |
| Rail edge | `BorderSide(innerHairline 0xFF7ADCC8, 1.5)` | a neon cyan outline. This is the single strongest "styled Flutter shape" signal in the scene. |
| Felt | `RadialGradient(feltCenter, feltMid, feltEdge)` + white/navy vertical wash | one soft blob; no directional light, no nap, no rail contact shadow. |
| Material separation | none | nothing distinguishes a matte cloth from a hard rail. |
| Table light | `feltSoftLift` radial at alpha 0.08-0.10 | not directional and does not agree with the environment light pool above it. |
| Room | B1 `Act0SceneEnvironmentPainterV1` | deliberate structural placeholder: wall/floor/horizon/vignette gradients only. |
| Horizon | `horizon = 0.17` | numerically present, visually invisible. |
| Far-player plane | head-peek only | B1 recorded this as the vertical trade B2 owns. |
| Hero foreground | `0xFF060C16` flat mass + rim | correct geometry, no material. |

Token guardrail worth naming: `Act0ShellTokensV1` states cyan is *"a focus/coach
accent, not a general surface fill."* A permanent cyan table outline already sits
against that rule and competes with the cyan used for selectable seats. Replacing
it with material bevel is both the premium move and the token-correct one.

## 1. Benchmark principles extracted (PokerSkill)

Structure and physics only. No art, palette, character, branding or layout copied.

1. The rail is a **volume**, not a stroke: a lit crown, a shadowed outer wall,
   and an inner bevel turning down into the cloth.
2. The rail **casts a shadow onto the felt**. This is what proves it is raised.
3. Felt is **matte and absorbs light**; the rail is **semi-gloss and returns a
   specular**. That contrast is what reads as "materials".
4. One key light above and slightly in front of the table governs every
   highlight in the scene; nothing glows on its own.
5. Felt luminance **falls off with distance** — the far end is darker.
6. The room has layered depth, not one gradient.
7. Far players are readable against the room because the room is darker than
   they are, not because they are outlined.

## 2. Gap map — required classification

| # | Item | Class | Finding |
| --- | --- | --- | --- |
| 1 | Table silhouette | `B2` | app-rounded corners plus a neon outline; reads as a widget, not a table. Refine contour and kill the outline. |
| 2 | Felt | `B2` | single radial blob; no directional key, no distance falloff, no nap, no contact shadow. |
| 3 | Rail | `B2` | **largest material gap.** Flat 10 px band, three identical tokens, zero volume. |
| 4 | Material response | `B2` | no matte/gloss distinction anywhere in the scene. |
| 5 | Table lighting | `B2` | non-directional; disagrees with the environment pool. |
| 6 | Room / environment | `B2` | B1 structural placeholder by design; B2 replaces it. |
| 7 | Atmosphere | `B2` | haze applies to player volumes only, not scene-wide. |
| 8 | Horizon / floor | `B2` | present in code, invisible in render. |
| 9 | Far-player visibility | `B2` | head-peek only; B2 owns the bounded vertical trade. |
| 10 | Hero framing | `B2` | geometry correct from B1; material and light missing. |
| 11 | Vertical allocation | `B2` | table takes 484 of 874 px; far plane starved. |
| 12 | Background depth | `B2` | one gradient, no layering. |
| 13 | Premium perception | `B2` | the composite of 1-12. Currently "clean UI", not "premium object in a room". |

### Explicitly NOT B2

| Gap | Class |
| --- | --- |
| Faces, clothing, poses, the character family | `DEFERRED B3` |
| Stacks/bets/position plates bound to `plateAnchor` / `betAnchor` | `DEFERRED B4` |
| Attention-aware rendering, selective focus, depth of field | `DEFERRED B5` |
| Chip flight, seat reveal, camera moves, any motion program | `DEFERRED B6` |
| Final benchmark parity and cohesion polish | `DEFERRED B7` |

## 3. Largest class-level B2 gap

**The table has no material.** The rail is the specific offender: a flat band
with a neon edge cannot read as a physical object no matter how good the room
behind it becomes. Room work done first would sit behind a widget.

Iteration order therefore follows the admission's default plan:

1. **Iteration 1** — table physicality: rail volume, felt material, one
   directional key light, contact shadow, silhouette/edge refinement.
2. **Iteration 2** — premium room, shared lighting, and the bounded vertical
   trade that buys far-player visibility.
3. **Iteration 3** — only if one large B2 class survives.

## 4. Material / lighting architecture chosen

New production module `lib/ui_v2/act0_shell/act0_scene_material_v1.dart`:

- `Act0SceneLightV1` — ONE key light (screen position, intensity, warmth). Every
  highlight in the scene derives from it, so nothing glows per-widget.
- `Act0SceneTableMaterialPainterV1` — rail as a volume: shadowed outer wall, lit
  crown with a directional specular, inner bevel picking up felt bounce, and the
  rail's cast shadow on the cloth.
- `Act0SceneFeltMaterialPainterV1` — matte cloth: key pool, distance falloff
  toward the far rail, directional sheen, edge absorption.
- `Act0SceneRoomPainterV1` (iteration 2) — layered premium room replacing the B1
  structural placeholder.

B1 geometry is imported, not replaced: `Act0SceneTableShapeV1`,
`Act0ScenePerspectiveV1`, `act0SceneSeatSlotsV1` and every anchor stay as-is.

Rail material stays navy (Deep Ocean identity) with a cool specular, reading as
polished leather rather than borrowed reference wood. Gold is not used — it
remains reserved for mastery and reward.

Geometry-risk decision: the rail band keeps its existing `padding: 10`. All new
volume is painted, not laid out, so seat anchors and table allocation stay
byte-identical and B1's contract audit continues to hold.

## 5. Protected foundation for this mission

Unchanged: `environment -> farPlayer -> table -> nearPlayer -> overlay`; seat
slots and identities; `characterAnchor`, `plateAnchor`, `betAnchor`,
`cardAnchor`; hero zone; the B1 perspective model; Wave A learning hierarchy,
answer truth, evaluation, feedback, causal clue, repair/recheck, continuation,
telemetry, routes, accessibility, safe-area and responsive profiles.

`HUMAN_PROOF = FALSE`
