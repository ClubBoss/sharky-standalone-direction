# Visual Gauntlet B2 — progress / continuity ledger v1

Continuity artifact so this mission survives a usage-limit interruption.

## Fixed facts

| Field | Value |
| --- | --- |
| Mission | `VISUAL_GAUNTLET_B2_PREMIUM_TABLE_AND_ENVIRONMENT_ART_V1` |
| Starting live `origin/main` | `c8f15c5e95b2950694b182280eb26216f5ca5a7b` |
| B1 integrated main | `a4f9e8ef83359bdf04914aa6a5f964267e209a0b` (`CLOSED_PASS`) |
| Branch | `feat/visual-gauntlet-b2-premium-table-and-environment-art-v1` |
| Primary viewport | `402x874` |
| Gap map | `docs/_reviews/visual_gauntlet_b2_gap_map_v1.md` |
| Evidence root (uncommitted) | `output/visual_gauntlet_b2/` |
| B1 baseline captures | `output/visual_gauntlet_b2/baseline_b1_402x874/` |
| Capture harness | `test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart` |
| `HUMAN_PROOF` | `FALSE` |

## Capture command

```
flutter test test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart \
  --dart-define=ACTION_EVIDENCE_DEVICE=iphone17_class \
  --dart-define=ACTION_EVIDENCE_OUTPUT=output/visual_gauntlet_b2/<label>
```

Devices: `iphone17_class` (402x874), `compact` (375x812), `tall_phone`
(390x844), `large_phone` (430x932). Text scale via `ACTION_EVIDENCE_TEXT_SCALE`.

## Architecture / material decision

New module `lib/ui_v2/act0_shell/act0_scene_material_v1.dart` owns material and
light. ONE key light (`Act0SceneLightV1`) governs every highlight. B1 geometry
(`act0_scene_depth_v1.dart`) is imported and not replaced. Rail keeps
`padding: 10` so all new volume is painted rather than laid out, holding seat
anchors and table allocation byte-identical.

## Checkpoint ledger

### CP0 — gap map + setup

- Status: **done**
- B1 baseline captured at 402x874 from the merged canonical scene.
- Largest B2 gap identified: **the table has no material**, rail specifically
  (three identical rail tokens, flat 10 px band, neon cyan outline).
- Changed files: docs only.

### CP1 — iteration 1: table physicality + material system

- Status: **done**
- Added `lib/ui_v2/act0_shell/act0_scene_material_v1.dart`: `Act0SceneLightV1`
  (one key light), `Act0SceneTableMaterialPainterV1` (rail volume),
  `Act0SceneFeltMaterialPainterV1` (matte cloth).
- Rail is now a physical object: shadowed outer wall, lit crown with a
  directional specular, inner bevel picking up felt bounce, silhouette contact
  shadow. The flat single-colour band is gone.
- All three neon cyan outlines removed (rail border, felt border). A real table
  is defined by a dark edge, not a lit one — and this returns cyan to its token
  role as a focus accent instead of a surface fill.
- Felt behaves as cloth: distance falloff toward the far rail, key pool under
  the lamp, nap sheen, rail cast shadow, edge absorption.
- **Regression caught and fixed in-loop:** widening the felt inset to 18 px to
  buy rail volume pushed the blind chip over the first board card's rank,
  destroying learning-relevant information. The rail now gains its volume
  *outward* into the room (`railOverhang = 5`) with the felt inset held at the
  B1 value of 10, so the playing surface geometry is byte-identical.
- Contracts verified: table allocation, action envelope, collision guard,
  tappable objects `9 -> 9`, zero overflow — all identical to the B1 baseline.
- Evidence: `output/visual_gauntlet_b2/iter1_402x874/`

### CP2 — iteration 2: room + light + vertical composition

- Status: **done**
- `Act0SceneRoomPainterV1` replaces B1's structural environment placeholder:
  lit back wall, architectural piers, floor falloff, horizon with atmospheric
  haze, table-lamp spill on the floor, framing vignette — all sharing the same
  `Act0SceneLightV1` as the table.
- Bounded vertical trade applied as a **shift, not a shrink**:
  `_act0SceneFarPlaneReserveV1 = 18`, a paint-only translate that spends the
  dead gap between the near rail and the action dock. Table width and height
  are identical to B1 in every state; only the top moves, by +18.
- **Three misses caught and fixed in-loop:** (1) the reserve first landed
  *below* the table, because the table is top-aligned in its stage — shrinking
  alone just opened dead space. (2) The first room was darker than B1 and its
  vignette crushed the corners the far volumes live in, making the far plane
  less readable, not more; wall/floor tones lifted and the vignette pulled
  back. (3) Taking the reserve out of the table's **height** broke three Wave A
  table-dominance guards in `t5_two_family_runner_closure_v1_test.dart`, which
  leave as little as 7 px of slack — that is the real bound on "bounded". The
  trade was converted to a paint-only shift, restoring full table allocation.
- Far-player plane is now readable above the far rail — the gap B1 recorded as
  needing the vertical trade B2 owns.
- Contracts: collision guard clean, zero overflow, tappable `9 -> 9`, runner
  phases identical, all six B1 seat anchors preserved with identical tiers.
- Evidence: `output/visual_gauntlet_b2/iter2_402x874/`

### CP3 — iteration 3: one key light across the whole scene

- Status: **done**
- Surviving B2 class: the table and room shared a key light, but the B1 player
  volumes and hero foreground still carried hardcoded self-lit rims — exactly
  the "widget-specific glow" the acceptance bar rules out.
- `Act0SceneCharacterVolumeV1`, `Act0SceneVolumeLayerV1` and
  `Act0SceneHeroForegroundV1` now accept rim/body tones, and the runner feeds
  them `Act0SceneLightV1.specular` / `.ambient`. B1 defaults are retained when
  no light is supplied, so the B1 geometry module stays independently valid and
  keeps no import on the B2 material module.
- Geometry untouched: this iteration changes colour inputs only.

### CP4 — full validation, evidence, draft PR

- Status: **done**
- `dart format` clean, `flutter analyze lib` clean,
  `tools/fast_loop_world1_v1.sh` PASS, `tools/release_gate_world1.sh` PASS.
- Focused suites `+15 -3`, identical in count and test name to the B2 starting
  main `c8f15c5e` — verified by checking out that SHA and re-running.
- Responsive: compact 375x812, tall 390x844, large 430x932, 1.4x text.
- Matched B1-vs-B2 evidence for the five canonical states, one contact sheet and
  SHA provenance under `output/visual_gauntlet_b2/evidence/`.
- Reverted an unrelated coach-phrase reformat pulled in by a directory-wide
  `dart format`; unrelated cleanup is explicit non-scope.

## Next remaining class-level gap

None at B2 scope. Remaining richness is asset-and-parity work owned by B7, and
character/HUD/attention/motion work owned by B3-B6.
