---
status: "undeclared"
status_source: "absent"
generated_by: "docs_frontmatter_v1"
---

# Table identity policy Wave B — learner labels

## Terminal verdict

Green. Wave B consumes the already-transported typed policy in the learner-seat primary-label formatter only. It does not change marker behavior, geometry, task state, or routes.

## Source owners changed

- `act0RuntimeLocalizedSeatPrimaryLabelV1` is the pure, localization-aware label formatter.
- `_SeatNodeV1` supplies its transported `identityPolicy` to that formatter.
- No separate accessibility string is derived from this label; existing semantic table summaries remain untouched.

## Formatter and final matrix

| Policy | learner primary label |
| --- | --- |
| `currentProduction` | exact legacy `BTN Hero` |
| `learnerOnly` | `You` |
| `learnerPosition` | `You · BTN` (or canonical seat position) |
| `learnerPositionAndDealerOrder` | `You · BTN` |
| missing canonical position | `You` |

The position is read only from `Act0SeatStateV1.seatLabel`; no copy, focus label, route, world, or widget state is inspected. Typed modes do not emit `Hero`.

## Legacy, accessibility, and dealer marker

The default policy remains `currentProduction`, retaining the exact legacy formatter branch. The dealer-marker resolver and every dealer-disc path are unchanged; dealer-order presently changes the label only, as required for Wave B. Accessibility has no shared learner-label source, so no accessibility copy changed.

## Geometry equivalence

The implementation alters only the `Text` value at the existing primary-label call site. Production-scene captures keep identical public table bounds across all policy cases and are deterministic. No table, seat-slot, hero-card, board, pot, W9 anchor, or lower-panel allocation code changed.

## Tests and evidence

- `flutter test test/ui_v2/table_identity_policy_wave_b_labels_v1_test.dart test/ui_v2/table_identity_semantic_metadata_seam_v1_test.dart test/guards/w7_w12_table_context_readiness_audit_contract_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart`
- deterministic capture harness: `flutter test tmp/wave_b_labels_capture_test.dart`
- `flutter analyze lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart test/ui_v2/table_identity_policy_wave_b_labels_v1_test.dart`
- local-only evidence: `output/evidence/table_identity_policy_phase_a_v1/wave_b_labels/` (captures, contact sheet, label inventory, geometry report)

The W7–W12 table-context guard, feedback-clue rhythm suite, and canonical repair/recheck coverage suite passed. The W9 visual capture is retained with the label evidence; W9 route context is protected by the active-route guard.

## Admission and repository status

Wave C is admitted for the separately scoped dealer-disc policy consumer. The corrected-T1 production pilot was not begun. This Wave B commit is local only and is not pushed; evidence remains untracked.
