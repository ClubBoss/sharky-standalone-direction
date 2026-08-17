# Visual Gauntlet B3 — progress / continuity ledger v1

| Field | Value |
| --- | --- |
| Mission | `VISUAL_GAUNTLET_B3_PLAYER_EMBODIMENT_V1` |
| Starting live `origin/main` | `13f33b0c97d95ea72872bcdb8bf509078dac96cb` |
| B2 integrated main | `dcb8baa39e46b3a69734e1f030af918cd5b1790c` (`CLOSED_PASS`) |
| Branch | `feat/visual-gauntlet-b3-player-embodiment-v1` |
| Primary viewport | `402x874` |
| Gap map | `docs/_reviews/visual_gauntlet_b3_gap_map_v1.md` |
| Evidence root (uncommitted) | `output/visual_gauntlet_b3/` |
| B2 baseline captures | `output/visual_gauntlet_b3/baseline_b2_402x874/` |
| Capture harness | `test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart` |
| `HUMAN_PROOF` | `FALSE` |

## Capture command

```
flutter test test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart \
  --dart-define=ACTION_EVIDENCE_DEVICE=iphone17_class \
  --dart-define=ACTION_EVIDENCE_OUTPUT=output/visual_gauntlet_b3/<label>
```

## Approach

Procedural original vector silhouettes in
`lib/ui_v2/act0_shell/act0_scene_player_v1.dart`. No raster assets, no new
dependencies, no faces. Silhouette > body language > depth > lighting >
differentiation. B1 geometry and B2 material imported, never replaced.

## Checkpoint ledger

### CP0 — gap map + setup
- Status: **done**
- Largest B3 gap: **nothing reads as a person**; family language, seat
  ownership, state posture and differentiation are all downstream of it.
- Changed files: docs only.

### CP1 — iteration 1: player family + depth
- Status: **done**
- Added `lib/ui_v2/act0_shell/act0_scene_player_v1.dart`: four archetypes,
  deterministic seat->archetype hash, posture enum, figure painter, and
  `Act0ScenePlayerLayerV1` replacing B1's `Act0SceneVolumeLayerV1`.
- **Three rejections of my own output, in loop:**
  1. First build kept a rounded-rect chair wider than the player; it became the
     dominant shape and the figure read as furniture. Chair removed entirely.
  2. Two symmetric arms made the figure read frontally and the outer arm swept
     *away* from the table. Replaced with a single near arm reaching toward the
     pot, into the rail cut.
  3. Figure value sat at ~`0x1A2C46` against a `0x244B6E` lit wall — barely a
     value step, so no silhouette read at all. Pushed to near-black at far, with
     the key-light rim carrying the form.
- `characterAnchor` push tightened (`pushX 0.135->0.104`, `pushY` similarly) —
  there was a visible gap between figure and rail, which breaks the "seated at
  it" read. `plateAnchor` / `betAnchor` / `cardAnchor` untouched.
- No faces drawn: at 60-110 px a face is noise. Identity is silhouette + posture.
- Evidence: `output/visual_gauntlet_b3/iter1_402x874/`

### CP2 — iteration 2: hero + state integration
- Status: **pending**

### CP3 — final validation, evidence, draft PR
- Status: **pending**

## Next remaining class-level gap

`HERO_NOT_YET_EMBODIED` — owned by iteration 2. Opponents are now people; the
learner is still B1's rim-lit mass with no arms and no relationship to the hero
cards.
