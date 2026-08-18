# Visual Gauntlet B6 — progress / continuity ledger v1

| Field | Value |
| --- | --- |
| Mission | `VISUAL_GAUNTLET_B6_SEMANTIC_MOTION_V1` |
| Starting live `origin/main` | `7c0e39813fd156822b07c5eced69f2a6ce5972a4` |
| Branch | `feat/visual-gauntlet-b6-semantic-motion-v1` |
| Primary viewport | `402x874` |
| Gap map | `docs/_reviews/visual_gauntlet_b6_gap_map_v1.md` |
| Evidence root (uncommitted) | `output/visual_gauntlet_b6/` |
| Capture tool | `tools/act0_b6_semantic_motion_capture_v1.dart` |
| `HUMAN_PROOF` | `FALSE` |

## Checkpoint ledger

### CP0 — gap map + baseline measurement
- Status: **done**
- Largest B6 gap, measured rather than asserted: **the scene knows what state
  it is in and never shows the learner that the state changed.** On the
  canonical route the room plane dropped `0.876 -> 0.5412` opacity between one
  frame and the next, `settle_frames = 0`.
- Decisive architecture measurement: across every learning-loop hop the runner
  `State` **persists** while the scene subtree's elements are **replaced**.
  Implicit animation inside the table is therefore impossible — it would
  remount with no "from" value at exactly the moments B6 exists to smooth.
- Changed files: docs only.

### CP1 — one semantic-motion mechanism
- Status: **done**
- `Act0SceneAttentionValuesV1` detaches B5's three bounded numbers from the
  phase so two states can be interpolated. No second salience model: every
  value still originates in B5's own switch expressions.
- `Act0SceneAttentionMotionV1` carries one in-flight interpolation;
  `Act0SceneRecedeMotionV1` applies it with the subtree passed through
  `AnimatedBuilder`'s `child`, so room, players and hero are never rebuilt per
  frame — the only per-frame work is the `Opacity` + `ColorFilter` already in
  the tree.
- The interpolation is owned by `_Act0LessonRunnerShellV1State`, the one owner
  that survives every hop.
- One mechanism carries all four meanings because B5 already encoded them as
  numbers: field quiets on feedback, clue rises for "here is why" and again for
  repair reacquisition, field restores on recheck.
- **Adopted asymmetry:** the clue releases instantly on entering `recheck` and
  never interpolates out. A fade-out is still a clue animating into a
  recognition attempt, which the acceptance bar names as insufficient. Answer
  fairness beats transition symmetry.

### CP2 — verdict arrival, timing, responsive proof
- Status: **done**
- The canonical route takes the feedback branch that had **no** motion reveal
  (measured: `reveal=false`), so the verdict hard-cut while the scene moved. It
  now reuses the accepted `_ProofMotionRevealV1` rather than inventing motion.
  It starts at `0.92` opacity, so the continue CTA is visible and
  interaction-ready on the first frame; guarded by tapping the CTA
  mid-transition and asserting the phase still advances.
- **Curve retuned from `settle` to `enter`.** Measured, `settle`
  (easeInOutCubic) moved only `4.7%` of the way in its first 64ms, so a
  transition the learner had just caused read as lag before it read as motion.
  `enter` (easeOutCubic) profile: `32ms 17% · 64ms 48% · 128ms 82% · 192ms 96%
  · 256ms 100%`. Both are sanctioned `Act0MotionTokensV1` tokens.
- Compact `375x812`, large `430x932` and `1.4x` text all settle on the
  identical B5 endpoint — recession is a phase property, never a layout one.

### CP3 — motion evidence + validation
- Status: **done** (see `## Measured results` and `## Validation`)

## Measured results

Frames produced per hop at `402x874`, and the reduced-motion counterpart:

| Hop | Animated frames | Room plane path | Reduced motion | Endpoint parity |
| --- | --- | --- | --- | --- |
| `decision -> wrongFeedback` | `18` | `0.876 -> 0.5412` | `1` frame | identical |
| `wrongFeedback -> repair` | `18` | `0.5412 -> 0.6776` | `1` frame | identical |
| `repair -> correctFeedback` | scene static by design (both phases share `0.52` room recession); clue rises `0.85 -> 1.0` | — | identical |
| `correctFeedback -> recheck` | `18` | `0.6776 -> 0.9256`, clue released | `1` frame | identical |

Reduced motion reaches **exactly** the animated endpoints, so no B1-B5 evidence
geometry moved.

## Design decisions worth carrying forward

**Selection commitment resolved by departure, not by a new beat.** Gap item 1
asked for "I committed a choice". The dock is replaced in the same frame as the
tap, so any commitment animation would have to delay feedback — which the motion
authority forbids outright. Instead the frame that discovers the phase change
renders the *outgoing* values, and the scene then visibly departs from them. The
learner sees the world respond to their input, at zero interaction cost. No
selection animation was added.

**No scale adopted.** The B6 packet permits "restrained scale / settle", but
`docs/_reviews/motion_direction_system_v1.md` reserves scale for `milestone`
and `confirmation_proof` only. The stricter in-repo authority wins; the scene
transition uses opacity/luminance interpolation alone.

## Known limitations

1. **`repair -> correctFeedback` produces no scene motion.** B5 assigns both
   phases the same room and player recession (`0.52` / `0.56`), so only the clue
   moves (`0.85 -> 1.0`). This is faithful to B5 rather than a B6 defect —
   changing it would mean editing accepted B5 salience values, which is out of
   scope. Flagged in case Mastermind wants the differentiation opened later.
2. **An unrelated ~1.8s proof animation shares the repair-success beat** (113
   scheduled frames, present identically with reduced motion off *and* on).
   `docs/_reviews/motion_direction_system_v1.md` §6 already flags the `1800ms`
   widgets as over-long and slated for shortening when next touched. B6 did not
   touch them: doing so is polish, not semantic motion, and would widen scope.
3. **Motion evidence is frame-sequence + GIF, not video.** This reuses the
   existing accepted evidence pattern; no video harness was built, per the
   packet's instruction not to build a large new harness to prove motion.
