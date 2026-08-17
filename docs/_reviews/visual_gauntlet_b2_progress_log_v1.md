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
- Bounded vertical trade applied: `_act0SceneFarPlaneReserveV1 = 30`, taken
  from the table only. Table top +30 and table height -30 in every state; the
  action envelope top is **identical in all 8 states**, so the lower surface,
  CTA and teaching copy keep their full allocation.
- **Two misses caught and fixed in-loop:** (1) the reserve first landed *below*
  the table, because the table is top-aligned in its stage — shrinking alone
  just opened dead space; re-aimed with an explicit top pad. (2) The first room
  was darker than B1 and its vignette crushed the corners the far volumes live
  in, making the far plane less readable, not more; wall/floor tones lifted and
  the vignette pulled back.
- Far-player plane is now readable above the far rail — the gap B1 recorded as
  needing the vertical trade B2 owns.
- Contracts: collision guard clean, zero overflow, tappable `9 -> 9`, runner
  phases identical, all six B1 seat anchors preserved with identical tiers.
- Evidence: `output/visual_gauntlet_b2/iter2_402x874/`

### CP3 — iteration 3 (conditional)

- Status: **pending**

### CP4 — full validation, evidence, draft PR

- Status: **pending**

## Next remaining class-level gap

`LIGHT_NOT_YET_SHARED_WITH_THE_B1_VOLUMES` — candidate for a bounded
iteration 3. The table and room now share one key light, but the player volumes
and hero foreground still carry B1's hardcoded rim, which is exactly the
"widget-specific glow" the B2 acceptance bar calls out.
