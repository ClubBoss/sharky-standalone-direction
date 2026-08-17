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

- Status: **pending**

### CP2 — iteration 2: room + light + vertical composition

- Status: **pending**

### CP3 — iteration 3 (conditional)

- Status: **pending**

### CP4 — full validation, evidence, draft PR

- Status: **pending**

## Next remaining class-level gap

`TABLE_HAS_NO_MATERIAL` — owned by iteration 1.
