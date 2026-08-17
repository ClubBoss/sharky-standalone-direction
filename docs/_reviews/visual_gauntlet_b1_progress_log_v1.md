# Visual Gauntlet B1 — progress / continuity log v1

Continuity artifact. Written so this mission survives a session or usage-limit
interruption. Not production behavior.

## Fixed facts

| Field | Value |
| --- | --- |
| Mission | `VISUAL_GAUNTLET_B1_SPATIAL_CHARACTER_READY_FOUNDATION_V1` |
| Starting live `origin/main` | `da22a09b25ea36d5e2becfc5d2384b448840d265` |
| Branch | `feat/visual-gauntlet-b1-spatial-character-ready-foundation-v1` |
| Primary viewport | `402x874` portrait |
| Gap map | `docs/_reviews/visual_gauntlet_b1_gap_map_v1.md` |
| Evidence root (uncommitted) | `output/visual_gauntlet_b1/` |
| Capture harness | `test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart` |
| `HUMAN_PROOF` | `FALSE` |

## Capture command

```
flutter test test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart \
  --dart-define=ACTION_EVIDENCE_DEVICE=iphone17_class \
  --dart-define=ACTION_EVIDENCE_OUTPUT=output/visual_gauntlet_b1/<label>
```

Devices: `iphone17_class` (402x874), `compact` (375x812), `tall_phone`
(390x844), `large_phone` (430x932). Text scale via
`ACTION_EVIDENCE_TEXT_SCALE`.

## Architecture decision

Single scene-space owner: `lib/ui_v2/act0_shell/act0_scene_depth_v1.dart`.
One projection (`Act0ScenePerspectiveV1`) consumed by every scene element, so
no widget invents its own fake depth. Wiring confined to the canonical learning
scene seam `act0_integrated_scene_perspective_table` in
`act0_lesson_runner_shell_v1.dart`.

## Checkpoint ledger

### CP0 — gap map + architecture setup

- Status: **done**
- Baseline captured at 402x874 and reproduced exactly against the owner-supplied
  Wave A pack.
- Measured: table 290x483 at x 55.9, 112 px dead flank, far and near seat layout
  volumes both 72x64, hero a 73x42 badge, taper ratio 0.82.
- Largest B1 gap identified: **no scene depth model**.
- Changed files: docs only.

### CP1 — iteration 1: depth architecture + environment plane

- Status: **done**
- Goal: establish `environment / farPlayer / table / nearPlayer / overlay`
  planes and a real perspective; stop the table floating in empty UI space.
- Added `lib/ui_v2/act0_shell/act0_scene_depth_v1.dart` as the single scene-space
  owner. Deleted the local `_IntegratedPerspectiveTableShapeV2` and
  `_integratedPerspectivePointV2`; every consumer now reads the canonical
  projection.
- Silhouette taper 0.82 -> 0.68. Plate depth range now derived from
  `plateScaleAt`, deliberately narrow to protect small-text accessibility.
- Environment plane (wall, horizon bloom, floor falloff, overhead light pool,
  vignette) plus a grounding contact shadow, reaching past the table into the
  112 px flanks Wave A left flat.
- Regression caught and fixed in-loop: the first environment build painted over
  the Wave A teaching line. Growth re-anchored to `Alignment(0, -0.9)` so the
  room only continues downward behind the action dock.
- Validated: all five canonical states re-captured; learning hierarchy intact.
- Evidence: `output/visual_gauntlet_b1/iter1_402x874/`

### CP2 — iteration 2: character volumes + hero ownership

- Status: **done**
- Goal: character-ready player volumes occluded by the rail; hero owns the
  near/foreground plane instead of a badge.
- `Act0SceneVolumeLayerV1` mounted on the `farPlayer` plane, between the
  environment and the table, so the rail cuts across the volumes.
- Asymmetric outward push: horizontal fills the flanks and crops near seats at
  the screen edge; vertical stays small because the teaching layer sits
  directly above the far rail.
- Volume depth range widened to 0.74..1.42 — the range plates cannot take
  without hurting small-text legibility.
- `Act0SceneHeroPlanePainterV1`: hero foreground pool plus near-rail rim,
  clipped to the table silhouette.
- Regression caught and fixed in-loop: the Wave A drop shadow
  (`0xD8000000`, blur 48) became a black moat cutting the players off from the
  table. Reduced to a contact shadow (`0x66000000`, blur 26); the environment
  plane now does the lifting.
- Validated: all five canonical states re-captured; focused tests match the
  authority baseline exactly.
- Evidence: `output/visual_gauntlet_b1/iter2_402x874/`

### Pre-existing test failures inherited from main

`test/ui_v2/task_table_presentation_semantics_v1_test.dart` fails `+5 -3` on the
authority baseline `da22a09b` and `+5 -3` on this branch, with identical test
names:

- `large-text Action theory keeps its fixed continuation control reachable ...`
- `Day 2 repair keeps the table locked above a content-sized active panel`
- `one hand keeps table geometry through decision and feedback`

Not caused by B1 and not repaired here — unrelated debt is explicit non-scope.

### CP3 — iteration 3: symmetric occlusion

- Status: **done**
- Two class-level gaps survived iteration 2: the far seat's volume was fully
  hidden behind the table, and the hero was still the detached `You BTN` badge
  the admission names in §8.3.
- `Act0SceneHeroForegroundV1`: the learner's own volume, seen from behind,
  drawn AFTER the table so it cuts across the near rail. Far players are
  occluded BY the table; the hero occludes it. That symmetry is what seats the
  learner rather than perching them above a diagram.
- Far seat given a fixed larger vertical push so its head clears the far rail,
  bounded by the teaching layer directly above it.
- Bug caught and fixed in-loop: hero resolution used `table.heroSeatId`, which
  is optional and usually null. Neither hero element rendered at all until it
  was changed to the seat's own `isHero` flag, matching seat placement.
- Verified at zoom that the far volume clears the teaching text in the
  tightest state (table-object task).
- Evidence: `output/visual_gauntlet_b1/iter3_402x874/`

### CP4 — final evidence + draft PR

- Status: **pending**

## Next remaining class-level gap

None at B1 scope. All five depth planes are established, populated and
occluding each other correctly. Residual gaps are material and art, which
belong to B2-B7 — see the final report.
