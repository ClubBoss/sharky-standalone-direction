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

### CP1/CP2 — salience model, feedback + repair/recheck restoration
- Status: **done**
- `act0_scene_salience_v1.dart`: one phase resolved from deterministic Wave A
  state, turned into bounded recession for the room plane, the player plane and
  B4's clue anchor.
- **Mechanism corrected mid-iteration.** The first build used a colour matrix
  alone (desaturate + darken) and measured a mean pixel delta of `2.5/255` at
  the strongest phase — this scene is already dark and nearly neutral, so
  darkening it has no headroom. Opacity attenuation is the lever that works on
  a dark scene. No blur adopted.
- Recession applies **per plane, never per seat**, so eligible answers stay
  fair by construction.
- Cards, board, pot, bets, plates, hero cards, teaching copy and the action
  dock are never attenuated.
- B4's always-on clue bracket now belongs to the phases talking about it.

### CP3 — final validation, evidence, draft PR
- Status: **done**
- `dart format` clean, `flutter analyze lib` clean,
  `tools/release_gate_world1.sh` PASS, focused `+15 -3` (inherited since B1).
- Responsive: compact 375x812, large 430x932, 1.4x text.
- Matched B4-vs-B5 evidence for 6 states + contact sheet + provenance.

### CP4 — phase-resolution completion (blocker admitted and resolved)
- Status: **done**
- Canonical owner found: `Act0ActionSequenceStageV1` via
  `_advanceActionSequenceReviewV1`. Exposed as one view-only field,
  `learningLoopStage`. No parallel state machine, no progression change.
- Canonical walking acceptance test passes: wrong feedback -> repair ->
  recheck, orchestration through renderer.
- Clue gold px: decision 169, wrong feedback 297, repair 422, recheck 186.
- Repair clue emphasis restored from the 0.34 compromise to 0.85.

### Superseded limitation (kept for provenance)
Separating `repair` from `recheck` in the captured surfaces proved unreliable
inside the window: `targeted_recheck` does not expose a receipt line that
distinguishes it from the repair attempt. Rather than ship a bracket that might
persist as a standing pointer during recognition, the clue emphasis is quiet
for **every** phase where an answer is still open — decision, repair and
recheck alike — and asserts only in correct/wrong feedback. Repair
reacquisition rides on the quieted field instead of on a stronger marker.
This is the safe side of the §8.5 answer-leak risk, not the ideal one.

## Next remaining class-level gap

Salience model delivered. The honest remainder is phase resolution fidelity for
`recheck`, recorded above.
