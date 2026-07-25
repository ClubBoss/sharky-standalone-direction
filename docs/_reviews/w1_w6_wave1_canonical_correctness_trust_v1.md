---
status: "w1_w6_wave1_canonical_correctness_trust_implemented"
status_source: "derived"
baseline: "d0a3a3eabfde"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Wave 1 Canonical Correctness and Trust v1

Verdict: `w1_w6_wave1_canonical_correctness_trust_implemented`

Branch: `codex/w1-w6-wave1-canonical-correctness-trust-v1`

Base: `d0a3a3eabfde8dd91549931d8b9f48d80055bbea`

## Scope Implemented

Wave 1 implemented the admitted canonical Act0 correctness/trust repairs from
`docs/_reviews/w1_w6_consolidated_repair_admission_program_v1.md`:

- CAP-001 feedback-title trust fixes for the verified incongruent correct
  options in W1, W4, and W5.
- CAP-002 W2 `apply_hj_decision` binding fix.
- Same-source CAP-008 W4/W5/W6 stale adjacent subtitle correction.

No session-drill JSON, campaign pack, route, progression, telemetry, repair
mapping, Modern Table, W7-owned content, or noncanonical owner was modified.

## Source Changes

Primary source:
`lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

The following correct-option feedback titles were replaced with semantic
titles that match the actual proof:

- `_buttonSeatRunner`: `BTN seat found.`
- `_utgSeatRunner`: `UTG seat found.`
- `_latePositionRunner`: `Late seat found.`
- `_handRankingsRunner`: `Pair found.`
- `_world4CheckpointRunner`: `Purpose and price connected.`
- `_world5GapBoardRunner`: `Gap board identified.`

The W2 `hand_discipline_apply` task `apply_hj_decision` now binds to
`_w1DisciplineApplyHjMediumRunner`, a dedicated HJ unopened-pot KQo runner.
The task id remains `apply_hj_decision`; the runner no longer launches the old
UTG `8s 4d` trash-fold scenario.

The adjacent stale subtitle copy was corrected in the same source owner:

- W4 purpose/price source runners no longer display `Board Awareness`.
- W5 board-awareness source runner no longer displays `Range Thinking`.
- W6 range-thinking source/repair runners no longer display
  `Visible Cards Change Ranges`.

## Tests Added

Added:
`test/ui_v2/act0_wave1_canonical_correctness_trust_v1_test.dart`

The focused guard verifies:

- repaired correct options use the expected semantic feedback titles;
- the known recycled strings no longer appear on the affected correct options;
- W2 `apply_hj_decision` uses the HJ medium-hand runner;
- W2 `apply_hj_decision` no longer launches the UTG `8s 4d` runner;
- W4/W5/W6 canonical runners do not carry the adjacent stale subtitle values;
- task IDs and canonical lesson/world lookup paths remain stable.

## Non-Goals Preserved

This wave did not address:

- prompt leakage cleanup;
- W3 six-seat expansion;
- W2 strong/borderline differentiation;
- same-signal repair mapping or `repairFocus` expansion;
- W4 sizing/transfer depth;
- W5 action transfer;
- W6 scope/payoff expansion;
- Human QA conclusions;
- any optional/session-drill closure evidence.

## Ledger Impact

The W1-W6 ledger is updated only to record that Wave 1 was implemented pending
canonical-only re-score and fixed-build Human QA.

No new W1-W6 numerical score is assigned here. No final 9/10 closure is claimed
from Wave 1 alone.

## Integration Status

Integration disposition:
`IMPLEMENTED_PENDING_RE_SCORE_AND_HUMAN_QA`

Minimum next step:
run the remaining Wave 2 canonical assessment-validity work before per-world
re-score, unless a narrower validation gate is requested first.
