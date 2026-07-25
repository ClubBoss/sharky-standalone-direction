---
status: "w1_w6_wave2_canonical_assessment_validity_implemented"
status_source: "derived"
baseline: "9a291b11662c"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Wave 2 Canonical Assessment Validity v1

Verdict: `w1_w6_wave2_canonical_assessment_validity_implemented`

Branch: `codex/w1-w6-wave2-canonical-assessment-validity-v1`

Base: `9a291b11662c399d39682cfb1292be437214a242`

## Scope Implemented

Wave 2 implemented the admitted canonical Act0 assessment-validity repairs from
`docs/_reviews/w1_w6_consolidated_repair_admission_program_v1.md`:

- CAP-005 confirmed prompt/hint leakage cleanup in W1, W2, W4, and W5.
- CAP-003 W3 `position_six_seats` six-seat recognition correction.
- CAP-004 W2 strong/borderline bucket differentiation.

No Wave 3 repair mapping, `repairFocus*`, Review/Home CTA, transfer-depth,
W6/W7 content, Modern Table, JSON Session Drill, campaign pack, progression,
persistence, or telemetry contract was modified.

## Leakage Repairs

Primary source:
`lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

The assessed prompt surface was changed so captions/hints no longer disclose
the answer before the learner chooses:

- W1 flush ranking drill no longer states `Flush beats straight` in the hint or
  center label before the answer.
- W2 bucket classification drills no longer pre-label AA/JJ/KQo/J8o as
  premium, strong, medium, or trash in assessed captions/hints.
- W4 value, bluff, and protection/check drills no longer state the purpose or
  free-card answer before the question.
- W5 wet-board texture drill no longer names the wet classification in the hint
  before the learner answers.

Theory/learn tasks still explain concepts explicitly; the cleanup is limited to
assessed canonical runner prompts.

## W3 Six-Seat Repair

Canonical lesson preserved:
`world_3` -> `position_six_seats`

The lesson no longer inherits the W1 position task list. It now uses a bounded
dedicated table-based sequence covering:

- UTG
- HJ
- CO
- BTN
- SB
- BB

The repair includes an HJ-vs-CO contrast where both middle seats are highlighted
and the learner must distinguish nearby positions without solving from button or
blind markers alone.

Existing `position_six_seats` lesson identity and W3 progression position are
preserved. Existing BTN/UTG repair task IDs are retained with the same repair
runner family for compatibility.

## W2 Strong/Borderline Repair

Canonical lesson preserved:
`world_2` -> `hand_discipline_buckets`

The strong task remains the pocket-jacks strong example. The borderline task now
uses a distinct QJs runner:

- strong: JJ, correct bucket `strong`;
- borderline: QJs, correct bucket `medium`, with feedback explaining that it is
  a conditional/borderline hand needing context.

The task IDs `hand_discipline_buckets_strong` and
`hand_discipline_buckets_borderline` are preserved.

## Tests

Added:
`test/ui_v2/act0_wave2_canonical_assessment_validity_v1_test.dart`

The test proves:

- confirmed leakage strings no longer appear in assessed runner captions/hints;
- theory tasks may still explain bucket concepts explicitly;
- W3 `position_six_seats` covers all six positions through table-based correct
  seat options;
- W3 no longer resolves primarily to the old W1 button/UTG/late-position
  runner reuse;
- HJ-vs-CO recognition is independently assessed;
- W2 strong and borderline tasks use distinct runner states and hand examples;
- world, lesson, task, and progression identities relevant to the repair remain
  stable.

## Deferred Scope

Still deferred:

- Wave 3 same-signal repair mapping and `repairFocus*` expansion;
- Review/Home CTA or hierarchy work;
- W4 purpose-to-size transfer;
- W5 texture-to-action transfer;
- W6 checkpoint, range advantage, combo-count, or W7 content work;
- Human QA conclusions;
- final per-world scoring.

## Ledger Impact

The W1-W6 ledger is updated only to record that Wave 2 was implemented pending
canonical-only re-score and fixed-build Human QA.

No final score is assigned here. No world is marked 9/10.

## Integration Status

Integration disposition:
`IMPLEMENTED_PENDING_RE_SCORE_AND_HUMAN_QA`

Minimum next step:
run Wave 3 canonical repair/recheck coverage or a requested canonical-only
re-score gate before claiming W1-W6 closure.
