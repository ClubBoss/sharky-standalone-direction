# Visual Gauntlet B4 — progress / continuity ledger v1

| Field | Value |
| --- | --- |
| Mission | `VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1` |
| Starting live `origin/main` | `da5115b3779a46eaa55275768ed9f16f1b1d782d` |
| B3 integrated main | `19f97534aae83ef508193b50408dbfa9a0707bf5` (`CLOSED_PASS`) |
| Branch | `feat/visual-gauntlet-b4-object-attached-hud-v1` |
| Primary viewport | `402x874` |
| Gap map | `docs/_reviews/visual_gauntlet_b4_gap_map_v1.md` |
| Evidence root (uncommitted) | `output/visual_gauntlet_b4/` |
| B3 baseline captures | `output/visual_gauntlet_b4/baseline_b3_402x874/` |
| Draft PR | `#192` |
| PR head | `f91120b3b70f3ab9849c079445800d448c80184f` |
| `HUMAN_PROOF` | `FALSE` |

## Checkpoint ledger

### CP0 — gap map + setup
- Status: **done**
- Largest B4 gap: **information does not belong to its owner** — a generic
  avatar glyph sits beside a real B3 player, and B1's `betAnchor` is consumed
  by nothing while commitments float mid-cloth.
- Changed files: docs only.

### CP1 — iteration 1: player-local identity / stack / position / dealer
- Status: **done**
- `act0_scene_hud_v1.dart` adds the B4 seam: `Act0SceneNameplateV1`, an
  engraved plate set into the surface — recessed fill the cloth reads through,
  dark top edge, lit lower lip on the same lamp as the rail crown.
- Generic `person_rounded` glyph dropped for occupied seats: B3 already draws
  the person, so it was a duplicate and the most app-like mark on the cloth.
  The selectable touch glyph and empty-seat mark stay — interaction truth.
- Reclaimed width returned as padding so the plate stays plate-shaped.

### CP2 — iteration 2: bet / state / hero / clue attachment
- Status: **done (scope corrected mid-iteration)**
- **Gap-map claim corrected by measurement.** I recorded that bets "float
  mid-felt" and that wiring B1's unused `betAnchor` would attach them. Both
  halves were wrong:
  1. The repository's own informative-object guard rejected the move — there is
     no offset from `betAnchor` that clears both the seat's card+plate column
     and the board panel. I tried two variants; the guard caught both.
  2. Measured baseline bounds show the legacy ring already seats each chip
     immediately beside its owner (bb seat x82-150, bb chip x122-166).
  Chip placement was reverted to exactly what Wave A validated, and the B1
  `betAnchor` definition was restored untouched.
- The real bet gap was **treatment, not position**: commitments rendered as
  frosted-glass app pills with a backdrop blur. They now use the same engraved
  carrier as the nameplate, so identity and commitment read as one attached
  family. Every bet-kind colour semantic is unchanged.

### CP3 — final validation, evidence, draft PR
- Status: **done**
- `dart format` clean, `flutter analyze lib` clean,
  `tools/release_gate_world1.sh` PASS.
- Focused `+15 -3` — the three inherited
  `task_table_presentation_semantics_v1_test.dart` names carried since B1.
- Responsive: compact 375x812, large 430x932, 1.4x text.
- Matched B3-vs-B4 evidence + contact sheet + provenance under
  `output/visual_gauntlet_b4/evidence/`.

### CP4 — Mastermind completion pass (dealer + clue)
- Status: **done**
- `Act0SceneDealerPuckV1` replaces the flat white `D` capsule with a pressed
  disc resting on the cloth. Dealer semantics untouched.
- Clue brackets clamped to `_CenterSignalAnchorV1` — the object whose own
  tooltip is "Table clue". First attempt bracketed cards and rendered nothing:
  `highlightedCardIds` is empty in these states, so the causal object is the
  centre cue chip, not a card.
- Validation: `flutter analyze lib` clean, `release_gate_world1.sh` PASS,
  focused `+15 -3` (inherited), responsive at compact / large / 1.4x.
- Evidence refreshed for 7 states including repair and recheck.

## Next remaining class-level gap

None at B4 scope. All six admitted ownership areas now have an object-attached
treatment.
