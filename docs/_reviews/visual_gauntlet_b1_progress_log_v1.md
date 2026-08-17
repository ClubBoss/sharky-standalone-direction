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

- Status: **pending**
- Goal: character-ready player volumes occluded by the rail; hero owns the
  near/foreground plane instead of a badge.

### CP3 — iteration 3 (conditional)

- Status: **pending**
- Goal: only if a class-level B1 gap survives iteration 2.

### CP4 — final evidence + draft PR

- Status: **pending**

## Next remaining class-level gap

`NO_PLAYER_VOLUMES_AND_NO_HERO_OWNERSHIP` — owned by iteration 2.
Iteration 1 alone still reads as "same table, better background", which the
admission explicitly calls INSUFFICIENT.
