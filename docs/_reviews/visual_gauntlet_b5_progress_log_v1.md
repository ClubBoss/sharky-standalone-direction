# Visual Gauntlet B5 — progress / continuity ledger v1

| Field | Value |
| --- | --- |
| Mission | `VISUAL_GAUNTLET_B5_ATTENTION_AWARE_RENDERING_V1` |
| Starting live `origin/main` | `2766d94fec110a5f21e776ba830917c81bc0042a` |
| Branch | `feat/visual-gauntlet-b5-attention-aware-rendering-v1` |
| Primary viewport | `402x874` |
| Gap map | `docs/_reviews/visual_gauntlet_b5_gap_map_v1.md` |
| Evidence root (uncommitted) | `output/visual_gauntlet_b5/` |
| B4 baseline captures | `output/visual_gauntlet_b5/baseline_b4_402x874/` |
| `HUMAN_PROOF` | `FALSE` |

## Checkpoint ledger

### CP0 — gap map + setup
- Status: **done**
- Largest B5 gap: **the scene does not know what the learner is doing.**
  Decision, wrong feedback, repair and recheck render at identical salience.
- Noted artefact: B4's clue bracket is always-on, so it carries no state
  information and persists into recheck.
- Changed files: docs only.

### CP1 — iteration 1: decision + feedback salience model
- Status: **pending**

### CP2 — iteration 2: repair + recheck + scene restoration
- Status: **pending**

### CP3 — final validation, evidence, draft PR
- Status: **pending**

## Next remaining class-level gap

`SCENE_HAS_NO_SALIENCE_MODEL` — owned by iteration 1.
